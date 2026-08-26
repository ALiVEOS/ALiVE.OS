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

switch(_operation) do {

    case "create": {
        PROFILE_SCOPE(GCCREATE, "ALiVE GC: create")

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

        PROFILE_SCOPE_END(GCCREATE)
    };

    case "init": {
        PROFILE_SCOPE(GCINIT, "ALiVE GC: init")

        if (isServer) then {
            _logic setVariable ["super", SUPERCLASS];
            _logic setVariable ["class", MAINCLASS];

            _logic setVariable ["moduleType", "ALIVE_GC"];
            _logic setVariable ["startupComplete", false];
            TRACE_1("After module init",_logic);

            [_logic,"start"] call MAINCLASS;

        };
        _logic setVariable ["bis_fnc_initModules_activate",true];

        PROFILE_SCOPE_END(GCINIT)
    };

    case "start": {
        PROFILE_SCOPE(GCSTAR, "ALiVE GC: start")

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

        PROFILE_SCOPE_END(GCSTAR)
    };

    case "destroy": {
        PROFILE_SCOPE(GCDESTROY, "ALiVE GC: destroy")

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

        PROFILE_SCOPE_END(GCDESTROY)
    };

    /*
    DRIVER - invoked by the per-frame handler registered in "start". Slices
    the collector's work onto the caller; each slice is delegated to a normal
    operation so the profiler sees one named zone per concern.
    */
    case "tick": {
        PROFILE_SCOPE(GCTICK, "ALiVE GC: tick")

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

        PROFILE_SCOPE_END(GCTICK)
    };

    /*
    Drain a fixed number of queued entries: expired objects near no player,
    empty groups, and stale references are removed; everything else stays
    queued and is revisited when the cursor wraps.
    */
    case "processDeletionQueue": {
        PROFILE_SCOPE(GCPROCESSDELETIONQUEUE, "ALiVE GC: processDeletionQueue")

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

            // Instant mode is evaluated per tick rather than once per cycle: the moment allDead
            // crosses the threshold the queue drains instantly regardless of expiry
            // and player proximity, which is exactly when the server most needs the
            // corpses gone. Same behaviour as the FSM passing _instant = true to
            // process, just more responsive to load spikes.
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

        PROFILE_SCOPE_END(GCPROCESSDELETIONQUEUE)
    };

    /*
    Begin a collection sweep: capture the synchronised-object exclusion list
    and reset the stage walk. Sources themselves are snapshotted lazily by
    scanCandidates as it enters each stage.
    */
    case "beginCandidateScan": {
        PROFILE_SCOPE(GCBEGINCANDIDATESCAN, "ALiVE GC: beginCandidateScan")

        _logic setVariable ["gcPhase", "scanning"];
        _logic setVariable ["gcSweepStage", 0];
        _logic setVariable ["gcSweepIndex", 0];
        _logic setVariable ["gcSweepSync", synchronizedObjects _logic];
        _logic setVariable ["gcDeletedCount", 0];
        _logic setVariable ["gcSweepStartTime", diag_tickTime];

        PROFILE_SCOPE_END(GCBEGINCANDIDATESCAN)
    };

    /*
    Inspect a fixed number of candidates from the current sweep stage,
    enqueueing qualifying ones through "trashIt".

    Sources are snapshotted once when the walk enters a stage rather than
    being fetched every tick: allMissionObjects in particular builds a fresh
    array of everything on the map, and re-fetching it across a walk lasting
    thousands of ticks would cost more than the inspection budget it feeds.
    A snapshot per stage costs one array copy per stage per sweep. The
    staleness this introduces matches what the FSM did - it also snapshotted
    its candidate lists once per collect - so anything that dies mid-sweep
    waits for the next sweep, exactly as it always has. Entries that other
    systems delete out from under the sweep resolve to null and are skipped.
    */
    case "scanCandidates": {
        PROFILE_SCOPE(GCSCANCANDIDATES, "ALiVE GC: scanCandidates")

        private _stage = _logic getVariable ["gcSweepStage", 0];
        private _idx = _logic getVariable ["gcSweepIndex", 0];
        private _sync = _logic getVariable ["gcSweepSync", []];
        private _individual = _logic getVariable ["ALiVE_GC_INDIVIDUALTYPES", []];
        private _source = _logic getVariable ["gcSweepSource", []];
        private _sourceStage = _logic getVariable ["gcSweepSourceStage", -1];

        private _inspected = 0;

        while { true } do {

            if (_stage > 2) exitWith {
                _logic setVariable ["gcPhase", "idle"];
                _logic setVariable ["nextCollectTime", time + (_logic getVariable ["gcInterval", 300])];

            };

            if (_sourceStage != _stage) then {
                _source = switch (_stage) do {
                    case 0: { allDead };
                    case 1: { allGroups };
                    case 2: { if ((count _individual) > 0) then { allMissionObjects "" } else { [] } };
                    default { [] };
                };
                _sourceStage = _stage;
                _logic setVariable ["gcSweepSource", _source];
                _logic setVariable ["gcSweepSourceStage", _stage];

                if (_logic getVariable ["debug", false]) then {
                    private _sourceName = ["allDead", "allGroups", "allMissionObjects"] select _stage;
                    ["GC scanCandidates %1 stage starting with %2 items", _sourceName, count _source] call ALiVE_fnc_dump;
                };
            };

            if (_idx >= (count _source)) then {
                _stage = _stage + 1;
                _idx = 0;
            } else {
                if (_inspected >= GC_BUDGET_PER_FRAME) exitWith {};

                private _candidate = _source select _idx;
                _idx = _idx + 1;
                _inspected = _inspected + 1;

                switch (_stage) do {
                    case 0: {
                        // Bodies can be deleted by other systems between the
                        // snapshot and this inspection; a stale reference is
                        // simply skipped.
                        if (!(isNull _candidate)
                            && { !(_candidate in _sync) }
                            && { !(_candidate getVariable [QGVAR(IGNORE), false]) }
                            && { !(_candidate in (_logic getVariable ["queue", []])) }) then {
                            [_logic,"trashIt", _candidate] call MAINCLASS;
                        };
                    };

                    case 1: {
                        if (((count units _candidate) == 0)
                            && { !(_candidate in (_logic getVariable ["queue", []])) }) then {
                            [_logic,"trashIt", _candidate] call MAINCLASS;
                        };
                    };

                    case 2: {
                        if (((typeOf _candidate) in _individual)
                            && { !(_candidate in (_logic getVariable ["queue", []])) }) then {
                            [_logic,"trashIt", _candidate] call MAINCLASS;
                        };
                    };
                };
            };
        };

        _logic setVariable ["gcSweepStage", _stage];
        _logic setVariable ["gcSweepIndex", _idx];

        if ((_stage > 2) && { _logic getVariable ["debug", false] }) then {
            private _startTime = _logic getVariable ["gcSweepStartTime", diag_tickTime];
            ["GC scanCandidates finished in %1 seconds", diag_tickTime - _startTime] call ALiVE_fnc_dump;
        };

        PROFILE_SCOPE_END(GCSCANCANDIDATES)
    };

    /*
    Enqueue an object or group for deletion once its expiry has passed.
    Called externally by other systems (the profile simulator virtualising
    entities) as well as by scanCandidates.
    */
    case "trashIt": {
        PROFILE_SCOPE(GCTRASHIT, "ALiVE GC: trashIt")

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

        PROFILE_SCOPE_END(GCTRASHIT)
    };

    case "debug": {
        PROFILE_SCOPE(GCDEBUG, "ALiVE GC: debug")

        if (_args isequaltype true) then {
            _result = _logic getvariable "debug";
        } else {
            _logic setvariable ["debug", _args];
            _result = _args;
        };

        PROFILE_SCOPE_END(GCDEBUG)
    };

    default {
        PROFILE_SCOPE(GCSUPER, "ALiVE GC: superclass")

        _result = [_logic, _operation, _args] call SUPERCLASS;

        PROFILE_SCOPE_END(GCSUPER)
    };
};

TRACE_1("GC - output",_result);

if (!isnil "_result") then {_result} else {nil}
