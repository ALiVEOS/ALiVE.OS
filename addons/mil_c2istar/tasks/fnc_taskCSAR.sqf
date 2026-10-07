#include "\x\alive\addons\mil_c2istar\script_component.hpp"
SCRIPT(taskCSAR);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskCSAR

Description:
Combat Search and Rescue Task.

The task is only ever offered for a real pilot: an AI crewman who ejects from a
plane and lands alive while his side has players taking tasks. It is raised at
the spot he landed on, he is held there, and if nobody reaches him in time the
task, the pilot and his strobe are all cleared away. A pool pick or a tablet
request carries no pilot, so "init" returns [] for it and the task handler picks
another type.

Besides the task stages ("init", "Parent", "Rescue", "Return") this file holds
the operations that drive the task, because it is the only file the task has:

    "watchTick"    - the ejection watcher, run on the server every 2 s by the
                     per-frame handler in XEH_postInit.sqf
    "findRestSpot" - [position, ignoreObject] -> nearest safe spot (ATL) or []
    "pilotHold"    - [unit] keep a landed pilot crouched in place; runs where
                     the pilot is local
    "pilotRelease" - [unit] give a pilot his AI back; runs on the rescuing
                     player
    "retirePilots" - [units, "delete" | "retire"] clear the pilots of a task

Parameters:
String - task stage or operation
String - task ID
Array - the task, or the operation's arguments
Array - task params hash
Bool - debug

Returns:
Array - stage result, rest spot, or nothing

Test hook:
ALiVE_c2istar_csarTestSides - an array of side texts, e.g. ["WEST"]. A side
listed here counts as having players at the side gate, so a test rig with
nobody connected can still raise the task. Nil, and so off, by default.
Nothing in ALiVE sets it.

Examples:
(begin example)
private _spot = ["findRestSpot", "", [getPosATL _pilot, _pilot], [], false] call ALIVE_fnc_taskCSAR;
(end)

See Also:

Author:
Tupolov
Jman
---------------------------------------------------------------------------- */

// A crew-seat sighting stays good for this long. The pilot rides the ejection
// seat for up to ~9.6 s before the canopy opens, so 10 s missed most of them.
#define CSAR_SEAT_WINDOW 20
// Seconds a pilot may hang under a canopy before he is given up on.
#define CSAR_TRACK_LIMIT 300
// Crew of one aircraft landing this close together, this soon after each
// other, share one task.
#define CSAR_CREW_WINDOW 60
#define CSAR_CREW_RADIUS 300
#define CSAR_DEFAULT_TIMEOUT 1800
#define CSAR_MIN_TIMEOUT 300
// How far a landed pilot may be moved off bad ground, on land and from water.
#define CSAR_LAND_CAP 150
#define CSAR_WATER_CAP 400
// An offer is an event; the task appears a moment later. This long without it
// means it was never going to.
#define CSAR_OFFER_GRACE 30
#define CSAR_RETIRE_DELAY 60

private ["_taskState","_taskID","_task","_params","_debug","_result"];

_taskState = _this select 0;
_taskID = _this select 1;
_task = _this select 2;
_params = _this select 3;
_debug = _this select 4;
_result = [];

// Pilots by netId, each one only if he still carries this task's id. NetIds are
// reissued per session, so a stale id could point at somebody else entirely.
private _fnc_resolvePilots = {
    params ["_netIDs", "_rootID"];

    _netIDs apply {
        private _unit = if (_x isEqualType "") then {_x call BIS_fnc_objectFromNetId} else {objNull};
        if (isNull _unit || {(_unit getVariable ["ALIVE_csarTaskID", ""]) != _rootID}) then {objNull} else {_unit};
    };
};

private _fnc_sideText = {
    params ["_side"];
    [[_side] call ALIVE_fnc_sideObjectToNumber] call ALIVE_fnc_sideNumberToText
};

// Every terminal stage comes through here: strobes off, then the pilots.
private _fnc_cleanupTask = {
    params ["_taskParams", "_mode"];

    {
        if !(isNull _x) then {
            detach _x;
            deleteVehicle _x;
        };
    } forEach ([_taskParams, "strobes", []] call ALIVE_fnc_hashGet);

    [_taskParams, "strobes", []] call ALIVE_fnc_hashSet;

    private _rootID = ([_taskParams, "taskIDs", [""]] call ALIVE_fnc_hashGet) select 0;
    private _pilots = [[_taskParams, "pilotNetIDs", []] call ALIVE_fnc_hashGet, _rootID] call _fnc_resolvePilots;

    ["retirePilots", "", [_pilots select {!isNull _x && {alive _x}}, _mode], [], false] call ALIVE_fnc_taskCSAR;
};

// A chat line that may be missing from an older Tasks.hpp falls back to another.
private _fnc_chat = {
    params ["_code", "_fallback", "_dialog", "_side", "_players"];

    if !(_code in (_dialog select 1)) then {_code = _fallback};
    if !(_code in (_dialog select 1)) exitWith {};
    [_code, _dialog, _side, _players] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
};

switch (_taskState) do {

    // ---- the ejection watcher --------------------------------------------------
    case "watchTick": {
        if (!isServer || {isNil "ALIVE_taskHandler"}) exitWith {};

        if (isNil "ALiVE_c2istar_csarTracked") then {
            // under a canopy: [unit, seenAt, hullKey, class, groundTicks, sideText]
            ALiVE_c2istar_csarTracked = [];
            // landed and held, waiting for an offer: [unit, landedAt, hullKey, class, sideText]
            ALiVE_c2istar_csarLanded = [];
            // offered: [unit, rootTaskID, offeredAt]
            ALiVE_c2istar_csarOffered = [];
            // side text -> [rootTaskID, offeredAt], one open rescue per side
            ALiVE_c2istar_csarOpen = createHashMap;
            ALiVE_c2istar_csarCount = 0;
        };

        private _now = time;
        private _timeout = missionNamespace getVariable ["ALIVE_taskCsarTimeout", CSAR_DEFAULT_TIMEOUT];
        if !(_timeout isEqualType 0) then {_timeout = CSAR_DEFAULT_TIMEOUT};
        _timeout = _timeout max CSAR_MIN_TIMEOUT;
        private _autoOff = !isNil "ALiVE_c2istar_autoPlayerTasks" && {!ALiVE_c2istar_autoPlayerTasks};

        private _taskKeys = ([ALIVE_taskHandler, "tasks", ["", [], [], nil]] call ALIVE_fnc_hashGet) select 1;

        // [ok, players, enemyFaction] for a side text. The side must have
        // somebody taking tasks and must not be set to generate none.
        private _fnc_sideGate = {
            params ["_sideText"];

            private _autoSides = [ALIVE_taskHandler, "autoGenerateSides", ["", [], [], ""]] call ALIVE_fnc_hashGet;
            private _mode = [_autoSides, _sideText, ["None", ""]] call ALIVE_fnc_hashGet;
            if ((_mode select 0) == "None") exitWith {[false, [[], []], ""]};

            private _players = ["getAutoOrderSidePlayers", [_sideText]] call ALiVE_fnc_playerOrders;
            if (isNil "_players" || {!(_players isEqualType [])} || {count _players < 2}) then {_players = [[], []]};

            private _testSides = missionNamespace getVariable ["ALiVE_c2istar_csarTestSides", []];
            private _testSide = _testSides isEqualType [] && {_sideText in _testSides};

            if (((_players select 0) isEqualTo []) && {!_testSide}) exitWith {[false, _players, ""]};

            [true, _players, _mode param [1, ""]]
        };

        // [allowed, chance] for an air commander's aircraft: its own task switch
        // and its chance of rescue, read off the module flying that faction.
        private _fnc_atoTerms = {
            params ["_faction", "_sideText"];

            // A module flying this faction first, else one on this side, else
            // the module's own default of always offering.
            private _byFaction = [];
            private _bySide = [];
            {
                private _kernel = _x getVariable ["ALiVE_mil_ato_kernel", []];
                if ([_kernel] call ALIVE_fnc_isHash) then {
                    private _atoTask = [_kernel, "task", []] call ALIVE_fnc_hashGet;
                    if ([_atoTask] call ALIVE_fnc_isHash) then {
                        private _chance = [_atoTask, "chanceOfRescue", 1] call ALIVE_fnc_hashGet;
                        if !(_chance isEqualType 0) then {_chance = 1};
                        private _terms = [([_atoTask, "generateTasks", false] call ALIVE_fnc_hashGet) isEqualTo true, _chance];

                        if (_byFaction isEqualTo [] && {([_atoTask, "faction", ""] call ALIVE_fnc_hashGet) == _faction}) then {_byFaction = _terms};
                        if (_bySide isEqualTo [] && {([_atoTask, "side", ""] call ALIVE_fnc_hashGet) == _sideText}) then {_bySide = _terms};
                    };
                };
            } forEach (entities "ALiVE_mil_ATO");

            switch (true) do {
                case (!(_byFaction isEqualTo [])): {_byFaction};
                case (!(_bySide isEqualTo [])): {_bySide};
                default {[true, 1]};
            }
        };

        // Out of the profile system and into a group of his own, in this order:
        // a pilot left in his aircraft's group runs off once he lands (330-410 m
        // in two minutes), in an empty group he stays where he is.
        private _fnc_releasePilot = {
            params ["_unit"];

            private _grp = createGroup [side group _unit, true];
            if (isNull _grp) exitWith {grpNull};

            [_unit] joinSilent _grp;
            _grp setVariable ["ALIVE_profileIgnore", true, true];

            private _profileID = _unit getVariable ["profileID", ""];
            if (_profileID isEqualType "" && {_profileID != ""} && {!isNil "ALIVE_profileHandler"}) then {
                private _profile = [ALIVE_profileHandler, "getProfile", _profileID] call ALIVE_fnc_profileHandler;
                if (!isNil "_profile") then {
                    // false means the profile is now empty
                    private _hasUnits = [_profile, "handleDeath", _unit] call ALiVE_fnc_profileEntity;
                    if (!isNil "_hasUnits" && {_hasUnits isEqualTo false}) then {
                        [ALIVE_profileHandler, "unregisterProfile", _profile] call ALIVE_fnc_profileHandler;
                    };
                };
            };

            _unit setVariable ["profileID", nil, true];
            _unit setVariable ["profileIndex", nil, true];
            // Kept on the server: the AI distributor hands any server group
            // without this flag to a headless client, mid hold.
            _unit setVariable ["ALiVE_ignore_HC", true, true];

            _grp
        };

        private _fnc_untrack = {
            params ["_unit", "_why"];

            if !(isNull _unit) then {
                _unit setVariable ["ALIVE_csarTracked", nil, true];
                _unit setVariable ["ALIVE_csarHeld", nil, true];
                _unit setVariable ["ALIVE_csarTaskID", nil, true];
            };
            ["C2ISTAR - Task CSAR - %1 no longer followed: %2", _unit, _why] call ALiVE_fnc_dump;
        };

        // A pilot already out of the profile system who will get no task: the
        // profile system will never clear him, so he is held and removed a
        // minute later, the same way a finished task's pilots are.
        private _fnc_dropPilot = {
            params ["_unit", "_why"];

            [_unit, _why] call _fnc_untrack;
            if (!isNull _unit && {alive _unit}) then {
                ["retirePilots", "", [[_unit], "retire"], [], false] call ALIVE_fnc_taskCSAR;
            };
        };

        // A man under a canopy or in an ejection seat. Only somebody seen in a
        // plane's crew seat a moment ago is a pilot; paratroopers never are.
        private _fnc_considerPilot = {
            params ["_unit"];

            private _seat = _unit getVariable ["ALIVE_csarSeat", []];
            if (_seat isEqualTo [] || {(_now - (_seat select 0)) > CSAR_SEAT_WINDOW}) exitWith {};
            if (((units group _unit) findIf {isPlayer _x}) > -1) exitWith {};

            _unit setVariable ["ALIVE_csarSeen", true];
            // No task can be offered, so he is left in his profile.
            if (_autoOff) exitWith {};
            _seat params ["", "_hullKey", "_class", "_tail"];

            private _sideText = [side group _unit] call _fnc_sideText;
            if !(([_sideText] call _fnc_sideGate) select 0) exitWith {};

            // The air commander's own aircraft keep its chance of rescue.
            private _isATO = (_tail isEqualType "" && {_tail != ""}) || {_unit getVariable ["ALiVE_mil_ato_crew", false]};
            if (_isATO) then {
                private _terms = [faction _unit, _sideText] call _fnc_atoTerms;
                if (!(_terms select 0) || {(random 1) >= (_terms select 1)}) then {_isATO = "refused"};
            };
            if (_isATO isEqualTo "refused") exitWith {
                ["C2ISTAR - Task CSAR - %1 ejected from %2, air commander rolled no rescue", _unit, _class] call ALiVE_fnc_dump;
            };

            private _grp = [_unit] call _fnc_releasePilot;
            if (isNull _grp) exitWith {};

            _unit setVariable ["ALIVE_csarTracked", true, true];
            _unit setVariable ["ALIVE_csarAircraft", _class, true];

            ALiVE_c2istar_csarTracked pushBack [_unit, _now, _hullKey, _class, 0, _sideText];

            ["C2ISTAR - Task CSAR - %1 (%2) ejected from %3, following him down", _unit, _sideText, _class] call ALiVE_fnc_dump;
        };

        // On the ground: move him off bad ground if he must, hold him, queue him.
        private _fnc_onLanded = {
            params ["_entry"];
            _entry params ["_unit", "", "_hullKey", "_class", "", "_sideText"];

            if !(([_sideText] call _fnc_sideGate) select 0) exitWith {
                [_unit, "nobody on his side to rescue him"] call _fnc_dropPilot;
            };

            // Down still strapped in his seat or chute: out of it first.
            if !(isNull objectParent _unit) then {
                if (local _unit) then {moveOut _unit} else {[_unit] remoteExecCall ["moveOut", _unit]};
            };

            private _spot = ["findRestSpot", "", [getPosATL _unit, _unit], [], false] call ALIVE_fnc_taskCSAR;
            if (_spot isEqualTo []) exitWith {
                [_unit, "no safe ground within reach"] call _fnc_dropPilot;
            };

            if ((_spot distance2D _unit) > 0.5) then {
                _unit setPosATL _spot;
            };

            _unit setVariable ["ALIVE_csarHeld", true, true];
            ["pilotHold", "", [_unit], [], false] remoteExec ["ALIVE_fnc_taskCSAR", _unit];

            ALiVE_c2istar_csarLanded pushBack [_unit, _now, _hullKey, _class, _sideText];

            ["C2ISTAR - Task CSAR - %1 landed alive at %2", _unit, _spot] call ALiVE_fnc_dump;
        };

        // ---- 1. crew seats of every live plane
        {
            private _veh = _x;
            if (alive _veh && {_veh isKindOf "Plane"} && {!unitIsUAV _veh}) then {
                private _hullKey = _veh call BIS_fnc_netId;
                private _class = typeOf _veh;
                private _tail = _veh getVariable ["ALiVE_mil_ato_tail", ""];
                {
                    _x params ["_unit", "_role", "", "", ["_personTurret", false]];
                    // Person turrets are FFV seats; profile passengers sit in them.
                    if (alive _unit && {!isPlayer _unit} && {!_personTurret} && {(toLower _role) in ["driver", "gunner", "commander", "turret"]}) then {
                        _unit setVariable ["ALIVE_csarSeat", [_now, _hullKey, _class, _tail]];
                    };
                } forEach (fullCrew _veh);
            };
        } forEach vehicles;

        // ---- 2. men in an ejection seat or under a canopy
        {
            private _carrier = _x;
            if (_carrier isKindOf "ParachuteBase" || {_carrier isKindOf "Ejection_Seat_Base_F"}) then {
                {
                    if (alive _x && {!isPlayer _x} && {!(_x getVariable ["ALIVE_csarSeen", false])}) then {
                        [_x] call _fnc_considerPilot;
                    };
                } forEach (crew _carrier);
            };
        } forEach vehicles;

        // ---- 3. follow them down
        private _airborne = [];
        {
            private _entry = _x;
            _entry params ["_unit", "_seenAt", "", "", "_groundTicks"];

            if (isNull _unit || {!alive _unit}) then {
                [_unit, "died before landing"] call _fnc_untrack;
            } else {
                private _pos = getPosATL _unit;
                private _carrier = objectParent _unit;
                // Two ticks in a row, because there is a moment between the seat
                // and the canopy when he is in nothing at all. A seat or chute
                // that reaches the ground with him still in it counts too.
                private _onGround = if (isNull _carrier) then {
                    isTouchingGround _unit
                    || {(_pos select 2) < 2}
                    || {surfaceIsWater _pos && {((getPosASLW _unit) select 2) < 2}}
                } else {
                    (_carrier isKindOf "ParachuteBase" || {_carrier isKindOf "Ejection_Seat_Base_F"})
                    && {isTouchingGround _carrier || {((getPosATL _carrier) select 2) < 1}}
                };

                if (_onGround) then {
                    _entry set [4, _groundTicks + 1];
                    if ((_groundTicks + 1) >= 2) then {
                        [_entry] call _fnc_onLanded;
                    } else {
                        _airborne pushBack _entry;
                    };
                } else {
                    _entry set [4, 0];
                    if ((_now - _seenAt) > CSAR_TRACK_LIMIT) then {
                        [_unit, "never reached the ground"] call _fnc_dropPilot;
                    } else {
                        _airborne pushBack _entry;
                    };
                };
            };
        } forEach ALiVE_c2istar_csarTracked;
        ALiVE_c2istar_csarTracked = _airborne;

        // ---- 4. offer the landed, one rescue per side at a time
        private _waiting = [];
        private _handled = [];

        {
            _x params ["_leader", "_landedAt", "_hullKey", "_class", "_sideText"];

            if (_leader in _handled) then {continue};

            if (isNull _leader || {!alive _leader}) then {
                _handled pushBack _leader;
                [_leader, "died before a rescue was offered"] call _fnc_untrack;
                continue
            };

            // his crewmates who came down close by
            private _crew = ALiVE_c2istar_csarLanded select {
                (_x select 2) == _hullKey
                && {!((_x select 0) in _handled)}
                && {alive (_x select 0)}
                && {((_x select 0) distance2D _leader) <= CSAR_CREW_RADIUS}
                && {((_x select 1) - _landedAt) <= CSAR_CREW_WINDOW}
            };
            private _group = _crew apply {_x select 0};
            if !(_leader in _group) then {_group = [_leader] + _group};
            _handled append _group;

            private _crewAirborne = (ALiVE_c2istar_csarTracked findIf {(_x select 2) == _hullKey}) > -1;
            private _open = ALiVE_c2istar_csarOpen getOrDefault [_sideText, ["", -1e9]];
            private _busy = ((_open select 0) in _taskKeys) || {(_now - (_open select 1)) < CSAR_OFFER_GRACE};
            private _gate = [_sideText] call _fnc_sideGate;

            private _giveUp = _autoOff || {(_now - _landedAt) > _timeout};
            private _wait = (_crewAirborne && {(_now - _landedAt) < CSAR_CREW_WINDOW}) || {_busy} || {!(_gate select 0)};

            if (_giveUp) then {
                {
                    [_x, "no rescue was offered in time"] call _fnc_dropPilot;
                } forEach _group;
            } else {
                if (_wait) then {
                    _waiting append (ALiVE_c2istar_csarLanded select {(_x select 0) in _group});
                } else {
                    ALiVE_c2istar_csarCount = ALiVE_c2istar_csarCount + 1;
                    private _rootID = format ["CSAR_%1_%2_%3", _sideText, floor _now, ALiVE_c2istar_csarCount];
                    private _netIDs = _group apply {_x call BIS_fnc_netId};

                    { _x setVariable ["ALIVE_csarTaskID", _rootID, true]; } forEach _group;

                    private _taskData = [
                        _rootID, "C2ISTAR", _sideText, faction _leader, "CSAR", "NULL",
                        getPosATL _leader, _gate select 1, _gate select 2, "Y", "Side",
                        [_netIDs, _hullKey]
                    ];

                    private _event = ["TASK_GENERATE", _taskData, "C2ISTAR"] call ALIVE_fnc_event;
                    [ALIVE_eventLog, "addEvent", _event] call ALIVE_fnc_eventLog;

                    ALiVE_c2istar_csarOpen set [_sideText, [_rootID, _now]];
                    { ALiVE_c2istar_csarOffered pushBack [_x, _rootID, _now]; } forEach _group;

                    ["C2ISTAR - Task CSAR - rescue %1 offered to %2 for %3 (%4)", _rootID, _sideText, _group, _class] call ALiVE_fnc_dump;
                };
            };
        } forEach ALiVE_c2istar_csarLanded;
        ALiVE_c2istar_csarLanded = _waiting;

        // ---- 5. pilots whose task has gone
        private _offered = [];
        {
            _x params ["_unit", "_rootID", "_offeredAt"];

            if (isNull _unit) then {continue};

            if (_rootID in _taskKeys) then {
                _offered pushBack _x;
                continue
            };

            if (_unit getVariable ["ALIVE_csarLive", false]) then {
                // The task existed and is now gone, cancelled or deleted by some
                // other route than its own stages: a pilot still held goes too.
                if (alive _unit && {_unit getVariable ["ALIVE_csarHeld", false]} && {!(_unit getVariable ["ALIVE_csarRetiring", false])}) then {
                    ["retirePilots", "", [[_unit], "delete"], [], false] call ALIVE_fnc_taskCSAR;
                    ["C2ISTAR - Task CSAR - %1 removed, rescue %2 no longer exists", _unit, _rootID] call ALiVE_fnc_dump;
                };
                continue
            };

            if ((_now - _offeredAt) < CSAR_OFFER_GRACE) then {
                _offered pushBack _x;
                continue
            };

            // The offer never became a task.
            [_unit, format ["rescue %1 was never created", _rootID]] call _fnc_dropPilot;
        } forEach ALiVE_c2istar_csarOffered;
        ALiVE_c2istar_csarOffered = _offered;
    };

    // ---- the nearest place a pilot can sit -------------------------------------
    // Where he landed if that will do; otherwise the smallest move: rings out to
    // 60 m, then a wider search to 150 m. From water, rings out to 400 m.
    case "findRestSpot": {
        private _pos = _task param [0, []];
        private _ignore = _task param [1, objNull];

        if !(_pos isEqualType [] && {count _pos >= 2}) exitWith {};
        _pos = [_pos select 0, _pos select 1, 0];

        private _fnc_spotOK = {
            params ["_spot", "_ignore"];

            if (surfaceIsWater _spot) exitWith {false};
            if (((surfaceNormal _spot) select 2) < 0.93) exitWith {false};
            if !((nearestObjects [_spot, ["House", "Building", "Wall"], 2]) isEqualTo []) exitWith {false};
            // a wreck or a vehicle, but not his own canopy or seat lying beside him
            private _vehicles = (nearestObjects [_spot, ["LandVehicle", "Air", "Ship"], 4]) select {
                _x != _ignore && {!(_x isKindOf "ParachuteBase")} && {!(_x isKindOf "Ejection_Seat_Base_F")}
            };
            if !(_vehicles isEqualTo []) exitWith {false};

            // anything solid from head height down into the ground; the terrain
            // itself comes back with no object and does not count
            private _hits = lineIntersectsSurfaces [
                AGLToASL (_spot vectorAdd [0, 0, 3]),
                AGLToASL (_spot vectorAdd [0, 0, -0.5]),
                _ignore, objNull, true, 3, "GEOM", "NONE"
            ];
            (_hits findIf {!isNull (_x select 2)}) == -1
        };

        private _fnc_ring = {
            params ["_centre", "_radius", "_count"];

            private _found = [];
            private _start = random 360;
            for "_i" from 0 to (_count - 1) do {
                private _spot = _centre getPos [_radius, _start + (_i * 360 / _count)];
                _spot = [_spot select 0, _spot select 1, 0];
                if ([_spot, _ignore] call _fnc_spotOK) exitWith {_found = _spot};
            };
            _found
        };

        private _spot = [];

        if !(surfaceIsWater _pos) then {
            if ([_pos, _ignore] call _fnc_spotOK) then {
                _spot = _pos;
            } else {
                private _radius = 5;
                while {_spot isEqualTo [] && {_radius <= 60}} do {
                    _spot = [_pos, _radius, 12] call _fnc_ring;
                    _radius = _radius + 5;
                };

                if (_spot isEqualTo []) then {
                    private _safe = [_pos, 0, CSAR_LAND_CAP, 2, 0, 0.25, 0, [], [[0, 0], [0, 0]]] call BIS_fnc_findSafePos;
                    if (_safe isEqualType [] && {count _safe >= 2}) then {
                        _safe = [_safe select 0, _safe select 1, 0];
                        if ((_safe distance2D _pos) <= CSAR_LAND_CAP && {[_safe, _ignore] call _fnc_spotOK}) then {
                            _spot = _safe;
                        };
                    };
                };
            };
        } else {
            private _radius = 20;
            while {_spot isEqualTo [] && {_radius <= CSAR_WATER_CAP}} do {
                _spot = [_pos, _radius, ((ceil (_radius * 2 * pi / 20)) max 12) min 72] call _fnc_ring;
                _radius = _radius + 20;
            };
        };

        _result = _spot;
    };

    // ---- where the pilot is local: stay put --------------------------------------
    case "pilotHold": {
        private _unit = _task param [0, objNull];
        private _hops = _task param [1, 0];

        if (isNull _unit || {!alive _unit}) exitWith {};

        // Ownership can move while the message travels; follow it a few times.
        if !(local _unit) exitWith {
            if (_hops < 3) then {
                ["pilotHold", "", [_unit, _hops + 1], [], false] remoteExec ["ALIVE_fnc_taskCSAR", _unit];
            };
        };

        { _unit disableAI _x; } forEach ["AUTOTARGET", "TARGET", "FSM", "MOVE", "PATH", "AUTOCOMBAT"];
        _unit allowFleeing 0;
        doStop _unit;
        _unit setUnitPos "MIDDLE";
        _unit setCaptive true;
        removeHeadgear _unit;
    };

    // ---- give the pilot his AI back ----------------------------------------------
    // After joinSilent the pilot only becomes local to his new leader a moment
    // later, so this waits for that before touching him.
    case "pilotRelease": {
        private _unit = _task param [0, objNull];
        private _hops = _task param [1, 0];

        if (isNull _unit) exitWith {};

        [_unit, _hops] spawn {
            params ["_unit", "_hops"];

            private _start = diag_tickTime;
            waitUntil {sleep 0.25; isNull _unit || {local _unit} || {(diag_tickTime - _start) > 10}};

            if (isNull _unit || {!alive _unit}) exitWith {};
            if !(local _unit) exitWith {
                if (_hops < 3) then {
                    ["pilotRelease", "", [_unit, _hops + 1], [], false] remoteExec ["ALIVE_fnc_taskCSAR", _unit];
                };
            };

            { _unit enableAI _x; } forEach ["AUTOTARGET", "TARGET", "FSM", "MOVE", "PATH", "AUTOCOMBAT"];
            _unit setCaptive false;
            _unit setUnitPos "AUTO";
            // He still has the behaviour his aircraft's group flew with, which is CARELESS for
            // Combat Support CAS and the air commander's quiet aircraft, and a CARELESS man
            // ignores the enemy. He takes his new group's.
            _unit setCombatBehaviour (combatBehaviour (group _unit));
            if (leader group _unit != _unit) then {
                _unit doFollow (leader group _unit);
            };
        };
    };

    // ---- clear the pilots of a finished task -------------------------------------
    // "delete": gone now, with his group. "retire": out of the player's group,
    // held where he stands, gone a minute later.
    case "retirePilots": {
        private _pilots = _task param [0, []];
        private _mode = _task param [1, "delete"];

        {
            private _unit = _x;

            private _strobe = _unit getVariable ["ALIVE_csarStrobe", objNull];
            if !(isNull _strobe) then {
                detach _strobe;
                deleteVehicle _strobe;
            };

            private _withPlayers = ((units group _unit) findIf {isPlayer _x}) > -1;

            if (_mode == "delete" && {!_withPlayers}) then {
                // the unit first: deleteGroup does nothing to a group with men in it
                private _grp = group _unit;
                deleteVehicle _unit;
                _grp call ALiVE_fnc_DeleteGroupRemote;
            } else {
                _unit setVariable ["ALIVE_csarRetiring", true];
                private _grp = createGroup [side group _unit, true];
                [_unit] joinSilent _grp;
                _grp setVariable ["ALIVE_profileIgnore", true, true];
                _unit setVariable ["ALIVE_csarHeld", true, true];
                _unit setVariable ["ALiVE_ignore_HC", true, true];

                // Out of a player's group he only becomes the server's a moment
                // later, and a hold applied on the old owner is lost in the move.
                [{
                    params ["_unit"];
                    isNull _unit || {local _unit}
                }, {
                    params ["_unit"];
                    ["pilotHold", "", [_unit], [], false] call ALIVE_fnc_taskCSAR;
                }, [_unit], 10, {
                    params ["_unit"];
                    ["pilotHold", "", [_unit], [], false] remoteExec ["ALIVE_fnc_taskCSAR", _unit];
                }] call CBA_fnc_waitUntilAndExecute;

                [{
                    params ["_unit", "_grp"];
                    if !(isNull _unit) then {deleteVehicle _unit};
                    _grp call ALiVE_fnc_DeleteGroupRemote;
                }, [_unit, _grp], CSAR_RETIRE_DELAY] call CBA_fnc_waitAndExecute;
            };
        } forEach (_pilots select {!isNull _x});
    };

    // ---- the task ------------------------------------------------------------------
    case "init": {
        _task params [
            ["_taskID", ""],
            ["_requestPlayerID", ""],
            ["_taskSide", ""],
            ["_taskFaction", ""],
            ["_taskType", ""],
            ["_taskLocationType", ""],
            ["_taskLocation", []],
            ["_taskPlayers", []],
            ["_taskEnemyFaction", ""],
            ["_taskCurrent", "Y"],
            ["_taskApplyType", "Side"]
        ];

        // Index 11 is [[pilot netIds], hull netId], put there by the watcher.
        // Anything else (a pool pick, a tablet request) has no pilot to rescue.
        private _targets = _task param [11, []];

        if (_taskID == "") exitwith {["C2ISTAR - Task CSAR - Wrong input for _taskID!"] call ALiVE_fnc_Dump};
        if (_taskFaction == "") exitwith {["C2ISTAR - Task CSAR - Wrong input for _taskFaction!"] call ALiVE_fnc_Dump};
        if !(_taskLocation isEqualType [] && {count _taskLocation >= 2}) exitwith {["C2ISTAR - Task CSAR - Wrong input for _taskLocation!"] call ALiVE_fnc_Dump};

        if !(_targets isEqualType [] && {count _targets > 0} && {(_targets select 0) isEqualType []} && {count (_targets select 0) > 0}) exitWith {
            ["C2ISTAR - Task CSAR - %1 has no pilot; this task is only raised when a pilot ejects and lands", _taskID] call ALiVE_fnc_Dump;
        };

        private _netIDs = _targets select 0;
        private _wreckNetID = _targets param [1, ""];

        private _pilots = [];
        private _bad = false;
        {
            private _unit = if (_x isEqualType "") then {_x call BIS_fnc_objectFromNetId} else {objNull};
            if (isNull _unit
                || {!alive _unit}
                || {!(_unit getVariable ["ALIVE_csarTracked", false])}
                || {!((_unit getVariable ["ALIVE_csarTaskID", ""]) in ["", _taskID])}
            ) then {
                _bad = true;
            } else {
                _pilots pushBack _unit;
            };
        } forEach _netIDs;

        if (_bad) exitWith {
            ["C2ISTAR - Task CSAR - %1: a pilot in %2 is gone or not this task's", _taskID, _netIDs] call ALiVE_fnc_Dump;
        };

        private _dialogOptions = [ALIVE_generatedTasks, "CSAR", ["", []]] call ALIVE_fnc_hashGet;
        _dialogOptions = _dialogOptions param [1, []];
        if (_dialogOptions isEqualTo []) exitWith {
            ["C2ISTAR - Task CSAR - %1: no CSAR dialog in the task data", _taskID] call ALiVE_fnc_Dump;
        };
        private _dialogOption = +(_dialogOptions select 0);

        private _leader = _pilots select 0;
        private _targetPosition = getPosATL _leader;

        // Return location: first try the friendly side's OPCOM main HQ
        // (the OPCOM module's Eden placement position). When no friendly
        // OPCOM is placed, fall back to the legacy friendly-cluster ->
        // random-safe-pos -> spawn-camp chain.
        if (_taskLocationType == "NULL") then {_taskLocationType = "MEDIUM";};
        private _returnPosition = [_taskSide] call ALIVE_fnc_taskGetReturnPosition;

        if (count _returnPosition == 0) then {
            // legacy fallback - friendly cluster
            _returnPosition = [_taskLocation,_taskLocationType,_taskSide] call ALIVE_fnc_taskGetSideCluster;

            if (count _returnPosition == 0) then {
                // no friendly cluster found
                // try to get a position containing friendlies
                _returnPosition = [_taskLocation,_taskLocationType,_taskSide] call ALIVE_fnc_taskGetSideSectorCompositionPosition;

                if (count _returnPosition == 0) then {
                    _returnPosition = [
                        _taskLocation,
                        50,
                        500,
                        1,
                        0,
                        0.25,
                        0,
                        [],
                        [_taskLocation]
                    ] call BIS_fnc_findSafePos;
                };

                _returnPosition = [_returnPosition, 250] call ALIVE_fnc_findFlatArea;

                // spawn a populated composition
                private _compType = "Military";
                private _category = [];
                If (_taskFaction call ALiVE_fnc_factionSide == RESISTANCE) then {
                    _compType = "Guerrilla";
                    _category = ["HQ", "Outposts", "FieldHQ", "Camps","Supports","Comms"];
                } else {
                    _category = ["Outposts", "FieldHQ", "Camps","Supports","Heliports","Comms"];
                };
                [_returnPosition, _compType, _category, _taskFaction, ["Medium","Small"], 2] call ALIVE_fnc_spawnRandomPopulatedComposition;
            };
        };

        if (isNil "_returnPosition" || {!(_returnPosition isEqualType [])} || {count _returnPosition < 2}) exitWith {
            ["C2ISTAR - Task CSAR - %1: no return position for %2", _taskID, _taskSide] call ALiVE_fnc_Dump;
        };

        private _aircraft = _leader getVariable ["ALIVE_csarAircraft", ""];
        private _aircraftName = if (_aircraft != "") then {getText (configFile >> "CfgVehicles" >> _aircraft >> "displayName")} else {""};
        if (_aircraftName == "") then {_aircraftName = "An aircraft"};

        // The marker sits 200-400 m from the pilot, so players have to search.
        private _newTaskPosition = _targetPosition getPos [200 + (random 200), random 360];

        // Rescue
        private _nearestTown = [_newTaskPosition] call ALIVE_fnc_taskGetNearestLocationName;
        private _dialog = [_dialogOption,"Rescue"] call ALIVE_fnc_hashGet;

        private _formatDescription = [_dialog,"description"] call ALIVE_fnc_hashGet;
        _formatDescription = format[_formatDescription,_aircraftName,_nearestTown];
        [_dialog,"description",_formatDescription] call ALIVE_fnc_hashSet;

        private _formatChat = [_dialog,"chat_start"] call ALIVE_fnc_hashGet;
        private _formatMessage = _formatChat select 0;
        private _formatMessageText = _formatMessage select 1;
        _formatMessageText = format[_formatMessageText,_aircraftName,_nearestTown];
        _formatMessage set [1,_formatMessageText];
        _formatChat set [0,_formatMessage];
        [_dialog,"chat_start",_formatChat] call ALIVE_fnc_hashSet;

        // Return
        _nearestTown = [_returnPosition] call ALIVE_fnc_taskGetNearestLocationName;
        _dialog = [_dialogOption,"Return"] call ALIVE_fnc_hashGet;

        _formatDescription = [_dialog,"description"] call ALIVE_fnc_hashGet;
        _formatDescription = format[_formatDescription,_nearestTown];
        [_dialog,"description",_formatDescription] call ALIVE_fnc_hashSet;

        _formatChat = [_dialog,"chat_start"] call ALIVE_fnc_hashGet;
        _formatMessage = _formatChat select 0;
        _formatMessageText = _formatMessage select 1;
        _formatMessageText = format[_formatMessageText,_nearestTown];
        _formatMessage set [1,_formatMessageText];
        _formatChat set [0,_formatMessage];
        [_dialog,"chat_start",_formatChat] call ALIVE_fnc_hashSet;

        // create the tasks
        private _state = if (_taskCurrent == "Y") then {"Assigned"} else {"Created"};
        private _tasks = [];
        private _taskIDs = [];

        // parent
        _dialog = [_dialogOption,"Parent"] call ALIVE_fnc_hashGet;
        private _taskTitle = [_dialog,"title"] call ALIVE_fnc_hashGet;
        private _taskDescription = [_dialog,"description"] call ALIVE_fnc_hashGet;
        private _taskSource = format["%1-CSAR-Parent",_taskID];
        _tasks pushback [_taskID,_requestPlayerID,_taskSide,_newTaskPosition,_taskFaction,_taskTitle,_taskDescription,_taskPlayers,_state,_taskApplyType,"N","None",_taskSource,false];
        _taskIDs pushback _taskID;

        // rescue
        _dialog = [_dialogOption,"Rescue"] call ALIVE_fnc_hashGet;
        _taskTitle = [_dialog,"title"] call ALIVE_fnc_hashGet;
        _taskDescription = [_dialog,"description"] call ALIVE_fnc_hashGet;
        private _newTaskID = format["%1_c1",_taskID];
        _taskSource = format["%1-CSAR-Rescue",_taskID];
        _tasks pushback [_newTaskID,_requestPlayerID,_taskSide,_newTaskPosition,_taskFaction,_taskTitle,_taskDescription,_taskPlayers,_state,_taskApplyType,_taskCurrent,_taskID,_taskSource,true];
        _taskIDs pushback _newTaskID;

        // return
        _dialog = [_dialogOption,"Return"] call ALIVE_fnc_hashGet;
        _taskTitle = [_dialog,"title"] call ALIVE_fnc_hashGet;
        _taskDescription = [_dialog,"description"] call ALIVE_fnc_hashGet;
        _newTaskID = format["%1_c2",_taskID];
        _taskSource = format["%1-CSAR-Return",_taskID];
        _tasks pushback [_newTaskID,_requestPlayerID,_taskSide,_returnPosition,_taskFaction,_taskTitle,_taskDescription,_taskPlayers,"Created",_taskApplyType,"N",_taskID,_taskSource,true];
        _taskIDs pushback _newTaskID;

        private _timeout = missionNamespace getVariable ["ALIVE_taskCsarTimeout", CSAR_DEFAULT_TIMEOUT];
        if !(_timeout isEqualType 0) then {_timeout = CSAR_DEFAULT_TIMEOUT};
        _timeout = _timeout max CSAR_MIN_TIMEOUT;

        private _taskParams = [] call ALIVE_fnc_hashCreate;
        [_taskParams,"nextTask",_taskIDs select 1] call ALIVE_fnc_hashSet;
        [_taskParams,"taskIDs",_taskIDs] call ALIVE_fnc_hashSet;
        [_taskParams,"dialog",_dialogOption] call ALIVE_fnc_hashSet;
        [_taskParams,"pilotNetIDs",_netIDs] call ALIVE_fnc_hashSet;
        [_taskParams,"wreckNetID",_wreckNetID] call ALIVE_fnc_hashSet;
        [_taskParams,"expiresAt",time + _timeout] call ALIVE_fnc_hashSet;
        [_taskParams,"strobes",[]] call ALIVE_fnc_hashSet;
        [_taskParams,"pilotFound",false] call ALIVE_fnc_hashSet;
        [_taskParams,"lastState",""] call ALIVE_fnc_hashSet;
        [_taskParams,"aircraft",_aircraft] call ALIVE_fnc_hashSet;
        [_taskParams,"actualPosition",_targetPosition] call ALIVE_fnc_hashSet;
        [_taskParams,"enemyFaction",_taskEnemyFaction] call ALIVE_fnc_hashSet;

        // The pilots belong to this task now, and carry the hold action that
        // hands them to whoever reaches them. Keyed to the pilot, so it goes
        // when he does.
        {
            _x setVariable ["ALIVE_csarTaskID", _taskID, true];
            _x setVariable ["ALIVE_csarLive", true];

            [
                _x,
                format ["Rescue %1", name _x],
                "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unbind_ca.paa",
                "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unbind_ca.paa",
                "_this distance _target < 3 && {alive _target} && {!(_target getVariable ['ALIVE_csarRescued', false])} && {((side group _this) getFriend (side group _target)) >= 0.6}",
                "_caller distance _target < 3",
                {},
                {},
                {
                    params ["_target", "_caller"];

                    if (_target getVariable ["ALIVE_csarRescued", false]) exitWith {};

                    _target setVariable ["ALIVE_csarRescued", true, true];
                    _target setVariable ["ALIVE_csarHeld", false, true];
                    // A pilot often outranks the players; keep their leader.
                    private _prevLeader = leader group _caller;
                    [_target] joinSilent (group _caller);
                    [group _caller, _prevLeader] remoteExecCall ["selectLeader", _prevLeader];
                    ["pilotRelease", "", [_target], [], false] call ALIVE_fnc_taskCSAR;

                    ["Rescue", format ["You have rescued %1!", name _target]] call BIS_fnc_showSubtitle;
                },
                {},
                [],
                6
            ] remoteExec ["BIS_fnc_holdActionAdd", [0, -2] select isDedicated, _x];
        } forEach _pilots;

        ["C2ISTAR - Task CSAR - %1 created for %2 at %3, expires in %4 s", _taskID, _pilots, _targetPosition, _timeout] call ALiVE_fnc_Dump;

        _result = [_tasks,_taskParams];
    };

    case "Parent":{
    };

    case "Rescue":{
        _task params ["_taskID", "_requestPlayerID", "_taskSide", "_taskPosition", "_taskFaction", "_taskTitle", "_taskDescription", "_taskPlayers"];
        _taskPlayers = _taskPlayers select 0;

        private _taskIDs = [_params, "taskIDs", [""]] call ALIVE_fnc_hashGet;
        private _rootID = _taskIDs select 0;
        private _taskDialog = [_params, "dialog"] call ALIVE_fnc_hashGet;
        private _currentTaskDialog = [_taskDialog, _taskState] call ALIVE_fnc_hashGet;
        private _pilots = [[_params, "pilotNetIDs", []] call ALIVE_fnc_hashGet, _rootID] call _fnc_resolvePilots;
        private _expiresAt = [_params, "expiresAt", 0] call ALIVE_fnc_hashGet;

        if !([_params, "chatStartDone_Rescue", false] call ALIVE_fnc_hashGet) then {
            ["chat_start",_currentTaskDialog,_taskSide,_taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
            [_params, "chatStartDone_Rescue", true] call ALIVE_fnc_hashSet;
        };

        switch (true) do {
            // a pilot killed, or gone some other way
            case (_pilots isEqualTo [] || {(_pilots findIf {isNull _x || {!alive _x}}) > -1}): {
                [_params,"nextTask",""] call ALIVE_fnc_hashSet;

                _task set [8,"Failed"];
                _task set [10,"N"];
                _result = _task;

                [_taskPlayers,_taskID] call ALIVE_fnc_taskDeleteMarkersForPlayers;
                ["chat_failed",_currentTaskDialog,_taskSide,_taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
                [_params, "delete"] call _fnc_cleanupTask;
            };

            // nobody came in time
            case (time > _expiresAt): {
                [_params,"nextTask",""] call ALIVE_fnc_hashSet;

                _task set [8,"Canceled"];
                _task set [10,"N"];
                _result = _task;

                [_taskPlayers,_taskID] call ALIVE_fnc_taskDeleteMarkersForPlayers;
                ["chat_expired", "chat_cancelled", _currentTaskDialog, _taskSide, _taskPlayers] call _fnc_chat;
                [_params, "delete"] call _fnc_cleanupTask;

                ["C2ISTAR - Task CSAR - %1 expired, pilots %2 cleared", _rootID, _pilots] call ALiVE_fnc_Dump;
            };

            default {
                private _leader = _pilots select 0;
                private _position = getPosATL _leader;

                if (!([_params, "pilotFound", false] call ALIVE_fnc_hashGet) && {[_position,_taskPlayers,500] call ALIVE_fnc_taskHavePlayersReachedDestination}) then {
                    private _chat = +([_currentTaskDialog,"chat_update"] call ALIVE_fnc_hashGet);
                    private _message = _chat select 0;
                    _message set [1, format [_message select 1, mapGridPosition _position]];
                    _chat set [0, _message];
                    private _updateDialog = +_currentTaskDialog;
                    [_updateDialog, "chat_update", _chat] call ALIVE_fnc_hashSet;
                    ["chat_update",_updateDialog,_taskSide,_taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;

                    [_position,_taskSide,_taskPlayers,_taskID,"csar","",_taskTitle] call ALIVE_fnc_taskCreateMarkersForPlayers;

                    private _strobes = [];
                    {
                        private _strobe = "NVG_TargetW" createVehicle (getPos _x);
                        _strobe attachTo [_x, [0, 0, 0.2], "neck"];
                        _x setVariable ["ALIVE_csarStrobe", _strobe];
                        _strobes pushBack _strobe;
                    } forEach _pilots;

                    [_params, "strobes", _strobes] call ALIVE_fnc_hashSet;
                    [_params, "pilotFound", true] call ALIVE_fnc_hashSet;
                };

                // every pilot taken by the hold action
                if ((_pilots findIf {!(_x getVariable ["ALIVE_csarRescued", false])}) == -1) then {
                    {
                        if !(isNull _x) then {
                            detach _x;
                            deleteVehicle _x;
                        };
                    } forEach ([_params, "strobes", []] call ALIVE_fnc_hashGet);
                    [_params, "strobes", []] call ALIVE_fnc_hashSet;

                    _task set [8,"Succeeded"];
                    _task set [10, "N"];
                    _task set [3, _position];
                    _result = _task;

                    [_taskPlayers,_taskID] call ALIVE_fnc_taskDeleteMarkersForPlayers;

                    ["chat_success",_currentTaskDialog,_taskSide,_taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;

                    [_currentTaskDialog,_taskSide,_taskFaction] call ALIVE_fnc_taskCreateReward;

                    [_params,"nextTask",_taskIDs select 2] call ALIVE_fnc_hashSet;

                    // the trip home gets a window of its own
                    private _timeout = missionNamespace getVariable ["ALIVE_taskCsarTimeout", CSAR_DEFAULT_TIMEOUT];
                    if !(_timeout isEqualType 0) then {_timeout = CSAR_DEFAULT_TIMEOUT};
                    [_params, "expiresAt", time + (_timeout max CSAR_MIN_TIMEOUT)] call ALIVE_fnc_hashSet;
                };
            };
        };
    };

    case "Return":{
        _task params ["_taskID", "_requestPlayerID", "_taskSide", "_taskPosition", "_taskFaction", "_taskTitle", "_taskDescription", "_taskPlayers"];
        _taskPlayers = _taskPlayers select 0;

        private _taskIDs = [_params, "taskIDs", [""]] call ALIVE_fnc_hashGet;
        private _rootID = _taskIDs select 0;
        private _taskDialog = [_params, "dialog"] call ALIVE_fnc_hashGet;
        private _currentTaskDialog = [_taskDialog, _taskState] call ALIVE_fnc_hashGet;
        private _pilots = [[_params, "pilotNetIDs", []] call ALIVE_fnc_hashGet, _rootID] call _fnc_resolvePilots;
        private _expiresAt = [_params, "expiresAt", 0] call ALIVE_fnc_hashGet;

        if !([_params, "chatStartDone_Return", false] call ALIVE_fnc_hashGet) then {
            ["chat_start",_currentTaskDialog,_taskSide,_taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
            [_params, "chatStartDone_Return", true] call ALIVE_fnc_hashSet;
        };

        if (_pilots isEqualTo [] || {(_pilots findIf {isNull _x || {!alive _x}}) > -1}) then {
            [_params,"nextTask",""] call ALIVE_fnc_hashSet;

            _task set [8,"Failed"];
            _task set [10, "N"];
            _result = _task;

            [_taskPlayers,_taskID] call ALIVE_fnc_taskDeleteMarkersForPlayers;
            ["chat_failed",_currentTaskDialog,_taskSide,_taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
            [_params, "retire"] call _fnc_cleanupTask;
        } else {
            // never brought home in time
            if (time > _expiresAt) exitWith {
                [_params,"nextTask",""] call ALIVE_fnc_hashSet;

                _task set [8,"Canceled"];
                _task set [10, "N"];
                _result = _task;

                [_taskPlayers,_taskID] call ALIVE_fnc_taskDeleteMarkersForPlayers;
                ["chat_expired", "chat_cancelled", _currentTaskDialog, _taskSide, _taskPlayers] call _fnc_chat;
                [_params, "retire"] call _fnc_cleanupTask;

                ["C2ISTAR - Task CSAR - %1 expired on the way home, pilots %2 retired", _rootID, _pilots] call ALiVE_fnc_Dump;
            };

            if ([_taskPosition, _taskPlayers, 10] call ALIVE_fnc_taskHavePlayersReachedDestination
                && {(_pilots findIf {(_x distance2D _taskPosition) > 30}) == -1}
            ) then {
                [_params,"nextTask",""] call ALIVE_fnc_hashSet;

                _task set [8,"Succeeded"];
                _task set [10, "N"];
                _result = _task;

                [_taskPlayers,_taskID] call ALIVE_fnc_taskDeleteMarkersForPlayers;
                ["chat_success",_currentTaskDialog,_taskSide,_taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
                [_currentTaskDialog,_taskSide,_taskFaction] call ALIVE_fnc_taskCreateReward;

                // handed over: out of the player's group, gone in a minute
                [_params, "retire"] call _fnc_cleanupTask;
            };
        };
    };
};

_result
