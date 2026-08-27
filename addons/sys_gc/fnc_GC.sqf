//#define DEBUG_MODE_FULL
#include "\x\alive\addons\sys_GC\script_component.hpp"
SCRIPT(GC);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_GC
Description:
Garbage collector module. Acts as a driver: every request arrives as an
operation on the module logic, and long running work is broken into small
operations ("tick", "processDeletionQueue", "beginCandidateScan",
"scanCandidates") that the
per-frame handler registered by "start" can execute in short slices in the
unscheduled environment. Each slice is a normal operation call so the script
profiler attributes cost per concern.

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Attributes:
Boolean - debug - Debug enable, disable or refresh
init
start
tick

Examples:
(begin example)
// start the garbage collector
[_logic, "start"] call ALIVE_fnc_GC;
(end)

See Also:

Author:
BIS
Highhead

Peer reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClassHash
#define MAINCLASS ALIVE_fnc_GC

#define MTEMPLATE "ALiVE_GC_%1"

// items inspected or deleted per tick
#define GC_BUDGET_PER_FRAME 2

TRACE_1("GC - input",_this);

private "_result";

params [
    ["_logic", objNull, [objNull,[]]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,grpNull,[],"",0,true,false]]
];

PROFILE_SCOPE(OPERATION, _operation)

switch(_operation) do {

    case "create": {
        if (isServer) then {
            // Ensure only one module is used
            if !(isNil QMOD(SYS_GC)) then {
                _logic = MOD(SYS_GC);
                ERROR_WITH_TITLE(str _logic, localize "STR_ALIVE_GC_ERROR1");
            } else {
                _logic = (createGroup sideLogic) createUnit [QMOD(SYS_GC), [0,0], [], 0, "NONE"];
                MOD(SYS_GC) = _logic;
            };

            //Push to clients
            PublicVariable QMOD(SYS_GC);
        };

        TRACE_1("Waiting for object to be ready",true);

        waituntil {!isnil QMOD(SYS_GC)};

        TRACE_1("Creating class on all localities",true);

        // initialise module game logic on all localities
        MOD(SYS_GC) setVariable ["super", QUOTE(SUPERCLASS)];
        MOD(SYS_GC) setVariable ["class", QUOTE(MAINCLASS)];

        _result = MOD(SYS_GC);
    };

    case "init": {
        if (isServer) then {
            _logic setVariable ["super", SUPERCLASS];
            _logic setVariable ["class", MAINCLASS];

            _logic setVariable ["moduleType", "ALIVE_GC"];
            _logic setVariable ["startupComplete", false];
            TRACE_1("After module init",_logic);

            [_logic,"start"] call MAINCLASS;

        };
        _logic setVariable ["bis_fnc_initModules_activate",true];
    };

    case "start": {
        if (!isServer) exitwith { PROFILE_SCOPE_END(GCSTAR) };

        ALiVE_GC = _logic;
        Publicvariable "ALiVE_GC";

        private _individualTypes = [_logic getvariable ["ALiVE_GC_INDIVIDUALTYPES", []]] call ALiVE_fnc_parseArrayFromString;
        private _debug = _logic getvariable ["debug","false"];
        private _interval = _logic getvariable ["ALiVE_GC_INTERVAL","300"];
        private _threshold = parseNumber (_logic getvariable ["ALiVE_GC_THRESHHOLD","50"]);

        if (_debug isEqualType "") then {
            _debug = (tolower _debug == "true");
        };

        if (_interval isEqualType "") then {
            _interval = parseNumber _interval;
        };

        _logic setvariable ["ALiVE_GC_INDIVIDUALTYPES", _individualTypes, true];
        _logic setvariable ["debug", _debug, true];
        _logic setVariable ["auto", true];
        _logic setVariable ["gcEnabled", _interval >= 1];
        _logic setVariable ["gcInterval", _interval];
        _logic setVariable ["gcThreshold", _threshold];
        _logic setVariable ["nextCollectTime", time + _interval];
        _logic setVariable ["ALiVE_GC_PFH", -1];

        if (_interval < 1) exitwith {
            ["Garbage Collector turned off..."] call ALiVE_fnc_dump;
            _logic setVariable ["startupComplete", true];
        };

        ["Garbage Collector starting..."] call ALiVE_fnc_dump;

        _logic setVariable ["ALiVE_GC_PFH",
            [{
                params ["_logic","_handle"];

                [_logic, "tick"] call MAINCLASS;
            }, 0.1, _logic] call CBA_fnc_addPerFrameHandler
        ];

        _logic setVariable ["startupComplete", true];
    };

    case "destroy": {
        MOD(SYS_GC) = _logic;

        //Delete class
        if (isServer) then {

            _logic setVariable ["super", nil];
            _logic setVariable ["class", nil];
            _logic setVariable ["init", nil];

            _pfh = _logic getVariable ["ALiVE_GC_PFH", -1];
            if (_pfh > -1) then {
                [_pfh] call CBA_fnc_removePerFrameHandler;
            };
            _logic setVariable ["ALiVE_GC_PFH", nil];

            ALiVE_SYS_GC = nil;
            ALiVE_GC = nil;

            publicVariable "ALiVE_SYS_GC";
            publicVariable "ALiVE_GC";

            deleteVehicle _logic;
            deleteGroup (group _logic);
        };
    };

    case "tick": {
        [_logic,"processDeletionQueue"] call MAINCLASS;

        private _phase = _logic getVariable ["gcPhase", "idle"];

        if (_phase != "scanning") then {
            private _nextCollectTime = _logic getVariable ["nextCollectTime", 0];
            if ((_logic getVariable ["auto", false]) && { time >= _nextCollectTime }) then {
                [_logic,"beginCandidateScan"] call MAINCLASS;
            };
        };

        // beginCandidateScan flips the phase, so a due scan begins walking on the
        // same tick that started it.
        if ((_logic getVariable ["gcPhase", "idle"]) == "scanning") then {
            [_logic,"scanCandidates"] call MAINCLASS;
        };
    };

    /*
        Drain a fixed number of queued entries: expired objects near no player,
        empty groups, and stale references are removed; everything else stays
        queued and is revisited when the cursor wraps.
    */
    case "processDeletionQueue": {
        private _queue = _logic getVariable ["queue", []];
        private _queueCountBefore = count _queue;
        private _handled = 0;

        if ((_logic getVariable ["debug", false]) && { _queueCountBefore > 0 }) then {
            if (isNil { _logic getVariable "gcQueueProcessStartTime" }) then {
                _logic setVariable ["gcQueueProcessStartTime", diag_tickTime];
                ["GC processDeletionQueue starting with %1 items", _queueCountBefore] call ALiVE_fnc_dump;
            };
        } else {
            if !(_logic getVariable ["debug", false]) then {
                _logic setVariable ["gcQueueProcessStartTime", nil];
            };
        };

        if (!(_queue isEqualTo [])) then {

            // the moment allDead crosses the threshold the queue drains
            // instantly regardless of expiry and player proximity
            private _instant = (count allDead) >= (_logic getVariable ["gcThreshold", 50]);

            // Player list cached once per tick; only fetched when it will be used,
            // since instant mode never consults it.
            private _players = if (_instant) then { [] } else { allplayers };

            private _cursor = _logic getVariable ["gcQueueCursor", 0];
            private _deletedCount = _logic getVariable ["gcDeletedCount", 0];

            while { (_handled < GC_BUDGET_PER_FRAME) && { _cursor < (count _queue) } } do {
                _handled = _handled + 1;
                private _object = _queue select _cursor;

                if (isNil "_object" || { isNull _object }) then {
                    _queue deleteAt _cursor;
                } else {
                    private _timeToDie = _object getVariable ["timeToDie", 0];

                    if ((_timeToDie <= time) || { _instant }) then {
                        switch (typeName _object) do {

                            case (typeName objNull): {
                                if (_instant || { ({ (_x distance _object) <= 1700 } count _players) == 0 }) then {
                                    deleteVehicle _object;
                                    _queue deleteAt _cursor;
                                    _deletedCount = _deletedCount + 1;
                                } else {
                                    _cursor = _cursor + 1;
                                };
                            };

                            case (typeName grpNull): {
                                if (({ alive _x } count (units _object)) == 0) then {
                                    _object call ALiVE_fnc_DeleteGroupRemote;
                                    _queue deleteAt _cursor;
                                    _deletedCount = _deletedCount + 1;
                                } else {
                                    _cursor = _cursor + 1;
                                };
                            };

                            default {
                                _cursor = _cursor + 1;
                            };
                        };
                    } else {
                        _cursor = _cursor + 1;
                    };
                };
            };

            if (_cursor >= (count _queue)) then { _cursor = 0; };
            _logic setVariable ["gcQueueCursor", _cursor];
            _logic setVariable ["queue", _queue];
            _logic setVariable ["gcDeletedCount", _deletedCount];
        };

        if ((_logic getVariable ["debug", false])
            && { _queueCountBefore > 0 }
            && { _queue isEqualTo [] }) then {
            private _startTime = _logic getVariable ["gcQueueProcessStartTime", diag_tickTime];
            ["GC processDeletionQueue finished in %1 seconds", diag_tickTime - _startTime] call ALiVE_fnc_dump;
            _logic setVariable ["gcQueueProcessStartTime", nil];
        };
    };

    /*
        Begin a collection sweep: capture every tagged candidate source once and
        capture the synchronised-object exclusion list.
    */
    case "beginCandidateScan": {
        private _individual = _logic getVariable ["ALiVE_GC_INDIVIDUALTYPES", []];
        private _work = [
            ["allDead", allDead],
            ["allGroups", allGroups],
            ["entities", if (_individual isEqualTo []) then { [] } else { entities [_individual, [], true, false] }]
        ];

        _logic setVariable ["gcPhase", "scanning"];
        _logic setVariable ["gcSweepWork", _work];
        _logic setVariable ["gcSweepSync", synchronizedObjects _logic];
        _logic setVariable ["gcDeletedCount", 0];
        _logic setVariable ["gcSweepStartTime", diag_tickTime];

        if (_logic getVariable ["debug", false]) then {
            {
                _x params ["_kind", "_candidates"];
                ["GC scanCandidates %1 stage starting with %2 items", _kind, count _candidates] call ALiVE_fnc_dump;
            } forEach _work;
        };
    };

    /*
        Inspect a fixed number of candidates from the tagged work buckets,
        enqueueing qualifying ones through "trashIt". Each loop iteration either
        removes an empty bucket or consumes one candidate, guaranteeing progress.

        Candidate sources are snapshotted by beginCandidateScan. This operation
        only advances through those existing arrays, inspecting at most the frame
        budget on each call. The staleness matches what the FSM did - it also
        snapshotted its candidate lists once per collect - so anything that dies
        mid-sweep waits for the next sweep. Entries deleted by other systems while
        the sweep is active resolve to null and are skipped.
    */
    case "scanCandidates": {
        private _sync = _logic getVariable ["gcSweepSync", []];
        private _individual = _logic getVariable ["ALiVE_GC_INDIVIDUALTYPES", []];
        private _work = _logic getVariable ["gcSweepWork", []];
        private _queue = _logic getVariable ["queue", []];

        private _inspected = 0;

        while { (_inspected < GC_BUDGET_PER_FRAME) && { !(_work isEqualTo []) } } do {
            (_work select 0) params ["_kind", "_candidates"];

            if (_candidates isEqualTo []) then {
                _work deleteAt 0;
            } else {
                private _candidate = _candidates deleteAt ((count _candidates) - 1);
                _inspected = _inspected + 1;

                switch (_kind) do {
                    case "allDead": {
                        // Bodies can be deleted by other systems between the
                        // snapshot and this inspection; a stale reference is
                        // simply skipped.
                        if (
                            !(isNull _candidate) &&
                            { !(_candidate in _sync) } &&
                            { !(_candidate getVariable [QGVAR(IGNORE), false]) } &&
                            { _queue isEqualTo [] || { !(_candidate in _queue) } }
                        ) then {
                            [_logic,"trashIt", _candidate] call MAINCLASS;
                        };
                    };

                    case "allGroups": {
                        if (((units _candidate) isequalto []) && { _queue isEqualTo [] || { !(_candidate in _queue) } }) then {
                            [_logic,"trashIt", _candidate] call MAINCLASS;
                        };
                    };

                    case "entities": {
                        if (((typeOf _candidate) in _individual)
                            && { _queue isEqualTo [] || { !(_candidate in _queue) } }) then {
                            [_logic,"trashIt", _candidate] call MAINCLASS;
                        };
                    };
                };
            };
        };

        _logic setVariable ["gcSweepWork", _work];

        if (_work isEqualTo []) then {
            _logic setVariable ["gcPhase", "idle"];
            _logic setVariable ["nextCollectTime", time + (_logic getVariable ["gcInterval", 300])];
            _logic setVariable ["gcSweepWork", nil];

            if (_logic getVariable ["debug", false]) then {
                private _startTime = _logic getVariable ["gcSweepStartTime", diag_tickTime];
                ["GC scanCandidates finished in %1 seconds", diag_tickTime - _startTime] call ALiVE_fnc_dump;
            };
        };
    };

    /*
        Enqueue an object or group for deletion once its expiry has passed.
        Called externally by other systems (the profile simulator virtualising
        entities) as well as by scanCandidates.
    */
    case "trashIt": {
        if (isNil "_args") exitWith {debugLog "Log: [trashIt] There should be 1 mandatory parameter!"; false};

        private ["_object", "_queue", "_timeToDie"];
        _object = _args;
        _queue = _logic getVariable ["queue",[]];

        if (isnil "_object") exitwith {};

        // Nothing drains the queue when the collector is turned off
        // (interval < 1), so enqueuing would only grow an array nobody reads.
        if !(_logic getVariable ["gcEnabled", true]) exitwith {
            if (isNil {_logic getVariable "gcDisabledNotice"}) then {
                _logic setVariable ["gcDisabledNotice", true];
                ["Garbage Collector is disabled - ignoring trash request for %1", _object] call ALiVE_fnc_dump;
            };
            false;
        };

        switch (typeName _object) do {
            case (typeName objNull): {
                if (alive _object) then {
                    _timeToDie = time + 30;
                } else {
                    _timeToDie = time + 60;
                };
            };

            case (typeName grpNull): {
                _timeToDie = time + 60;
            };

            default {
                _timeToDie = time;
            };
        };

        _object setvariable ["timeToDie", _timeToDie];
        _queue pushback _object;

        _logic setVariable ["queue", _queue];
    };

    case "debug": {
        if (_args isequaltype true) then {
            _result = _logic getvariable "debug";
        } else {
            _logic setvariable ["debug", _args];
            _result = _args;
        };
    };

    default {
        _result = [_logic, _operation, _args] call SUPERCLASS;
    };
};

PROFILE_SCOPE_END(OPERATION)

TRACE_1("GC - output",_result);

if (!isnil "_result") then {_result} else {nil}
