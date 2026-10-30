#include "\x\alive\addons\mil_c2istar\script_component.hpp"
SCRIPT(taskReconObjective);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskReconObjective

Description:
Reconnaissance task (Javen on Discord, 22 Oct; made a real recon at Ando's asking the same day): players move to a
final rendezvous point (FRV) short of an objective, then man two observation posts (OPs) on different sides of it, a
minute at each. Only enemy the players' side actually spots while someone is at an OP counts: each such unit's group is
reported to the side (ALiVE_reconReports), which an AI Commander with Tasks Only Against Known Enemy counts as seen, so
its next preparation tasks go after them. Watching longer, from either OP, spots more.

Stages: Parent, Travel (reach the FRV), Observe1 (a minute at OP 1), Observe (a minute at OP 2, then report).
The OPs can be manned in either order: OP 2 done first is ticked off at once and OP 1 then closes the task.
With the C2ISTAR module's Recon Task OPs at 4 (Ando on Discord, 30 Oct) there are four OPs all round the objective,
stages Observe1 to Observe4, manned in any order; the last one done closes the task.

Parameters:
The usual task parameters (see ALIVE_fnc_taskWiretap).

Returns:
The task set on init, the task on a stage change

Author:
Jman
---------------------------------------------------------------------------- */

#define RECON_FRV_RANGES [800, 1000, 1200]
#define RECON_OP_RANGES [300, 450, 600]
#define RECON_OP_RANGES_TOWN [450, 600, 750]
#define RECON_AT_FRV 150
#define RECON_AT_OP 100
#define RECON_WATCH_SECONDS 60
#define RECON_REPORT_RADIUS 500
#define RECON_KNOW 1.5
#define RECON_SIGHT 600

private ["_taskState","_taskID","_task","_params","_debug","_result"];

_taskState = _this select 0;
_taskID = _this select 1;
_task = _this select 2;
_params = _this select 3;
_debug = _this select 4;
_result = [];

// the objective's centre, a little above the ground, as an eye would see it
private _fnc_eye = { private _p = AGLToASL [_this select 0, _this select 1, 0]; _p set [2, (_p select 2) + 2]; _p };

switch (_taskState) do {
    case "init": {
        private _taskData = _task;
        _taskID = _taskData select 0;
        private _requestPlayerID = _taskData select 1;
        private _taskSide = _taskData select 2;
        private _taskFaction = _taskData select 3;
        private _taskLocationType = _taskData select 5;
        private _taskLocation = _taskData select 6;
        private _taskPlayers = _taskData select 7;
        private _taskEnemyFaction = _taskData select 8;
        private _taskCurrent = _taskData select 9;
        private _taskApplyType = _taskData select 10;

        if (_taskID == "") exitWith {["C2ISTAR - Task ReconObjective - Wrong input for _taskID!"] call ALiVE_fnc_Dump};
        if (_taskFaction == "") exitWith {["C2ISTAR - Task ReconObjective - Wrong input for _taskFaction!"] call ALiVE_fnc_Dump};
        if (count _taskLocation < 2) exitWith {["C2ISTAR - Task ReconObjective - Wrong input for _taskLocation!"] call ALiVE_fnc_Dump};
        if (count _taskPlayers == 0) exitWith {["C2ISTAR - Task ReconObjective - Wrong input for _taskPlayers!"] call ALiVE_fnc_Dump};
        if (_taskApplyType == "") exitWith {["C2ISTAR - Task ReconObjective - Wrong input for _taskApplyType!"] call ALiVE_fnc_Dump};

        private _targetPosition = +_taskLocation;
        _targetPosition set [2, 0];
        private _playerPos = _taskLocation;
        if (count _taskPlayers > 0 && {count (_taskPlayers select 0) > 0}) then {
            private _uid = (_taskPlayers select 0) select 0;
            if (_uid isEqualType "" && {_uid != ""}) then {
                private _p = [_uid] call ALIVE_fnc_getPlayerByUID;
                if (!isNull _p) then { _playerPos = getPos _p };
            };
        };
        // the side the players come from; somewhere at random when they're on top of it
        private _bearing = if ((_playerPos distance2D _targetPosition) > 100) then { _targetPosition getDir _playerPos } else { random 360 };
        private _targetEye = _targetPosition call _fnc_eye;
        private _cover = { count (nearestTerrainObjects [_this, ["TREE", "SMALL TREE", "BUSH", "FOREST", "ROCK", "ROCKS"], 25, false, true]) min 10 };
        private _inTown = count (nearestTerrainObjects [_targetPosition, ["HOUSE", "BUILDING"], 75, false, true]) > 3;
        // inside the map with a margin: near a coast or the map edge a point can otherwise land off the terrain
        private _onMap = { (_this select 0) > 50 && {(_this select 1) > 50} && {(_this select 0) < worldSize - 50} && {(_this select 1) < worldSize - 50} };
        private _enemySides = ["EAST", "WEST", "GUER"] select { (([_taskSide] call ALIVE_fnc_sideTextToObject) getFriend ([_x] call ALIVE_fnc_sideTextToObject)) < 0.6 };

        // FRV: on the players' side, 800 to 1200 m out, on land, out of town and away from the enemy, in cover and out
        // of sight of the objective where it can be. Each rule is dropped in turn if nothing passes
        // when the players' side is all sea (a small island, or players coming in from the water), all round instead,
        // rather than falling back to a point on the objective itself
        private _frvCandidates = [];
        {
            private _arc = _x;
            if (_frvCandidates isEqualTo []) then {
                {
                    private _r = _x;
                    for "_a" from -_arc to _arc step 15 do {
                        private _p = _targetPosition getPos [_r, _bearing + _a];
                        _p set [2, 0];
                        if (!(surfaceIsWater _p) && {_p call _onMap}) then { _frvCandidates pushBack _p };
                    };
                } forEach RECON_FRV_RANGES;
            };
        } forEach [45, 180];
        private _frvScore = {
            private _hidden = terrainIntersectASL [_targetEye, _this call _fnc_eye];
            (_this call _cover) + ([0, 10] select _hidden)
        };
        private _frvTiers = [
            { count (nearestTerrainObjects [_this, ["HOUSE", "BUILDING"], 30, false, true]) <= 3
                && {(_enemySides findIf { ([_this, 400, [_x, "entity"]] call ALIVE_fnc_getNearProfiles) isNotEqualTo [] }) < 0} },
            { true }
        ];
        private _frv = [];
        {
            private _rule = _x;
            if (_frv isEqualTo []) then {
                private _ok = _frvCandidates select { _x call _rule };
                if (_ok isNotEqualTo []) then {
                    private _scored = _ok apply { [_x call _frvScore, _x] };
                    _scored sort false;
                    _frv = (_scored select 0) select 1;
                    if (_forEachIndex > 0) then { ["C2ISTAR - Task ReconObjective %1: FRV picked without the town and enemy rules", _taskID] call ALiVE_fnc_Dump };
                };
            };
        } forEach _frvTiers;
        if (_frv isEqualTo []) then {
            _frv = [_targetPosition, "overwatch", _playerPos] call ALIVE_fnc_taskGetSectorPosition;
            if (isNil "_frv" || {!(_frv isEqualType [])} || {count _frv < 2}) then { _frv = _targetPosition getPos [1000, _bearing] };
            ["C2ISTAR - Task ReconObjective %1: no land for an FRV on the players' side; using %2", _taskID, mapGridPosition _frv] call ALiVE_fnc_Dump;
        };

        // OPs: 24 bearings at three ranges round the objective, on land, clear of buildings. Higher ground, a line of
        // sight to the objective and cover score; OP 2 must be at least 90 degrees round from OP 1
        private _opCandidates = [];
        {
            private _r = _x;
            for "_a" from 0 to 345 step 15 do {
                private _p = _targetPosition getPos [_r, _a];
                _p set [2, 0];
                if (!(surfaceIsWater _p) && {_p call _onMap}) then {
                    private _eye = AGLToASL [_p select 0, _p select 1, 1.8];
                    private _h = (((_eye select 2) - (_targetEye select 2)) max -20) min 60;
                    private _los = !(terrainIntersectASL [_eye, _targetEye]);
                    private _clear = count (nearestTerrainObjects [_p, ["HOUSE", "BUILDING"], 15, false, true]) == 0;
                    _opCandidates pushBack [_h + ([0, 10] select _los) + (_p call _cover) - 0.01 * _r, _p, _a, _los, _clear];
                };
            };
        } forEach ([RECON_OP_RANGES, RECON_OP_RANGES_TOWN] select _inTown);
        private _angle = { private _d = abs ((_this select 0) - (_this select 1)) % 360; _d min (360 - _d) };
        // the players' side of the objective: the first rules keep both OPs within 100 degrees of the FRV's bearing, so
        // the team doesn't have to cross or go round the objective to reach them
        private _frvBrg = if ((_frv distance2D _targetPosition) > 100) then { _targetPosition getDir _frv } else { _bearing };
        // the C2ISTAR module's Recon Task OPs (Ando on Discord, 30 Oct): 2, both on the players' side, or 4 all round
        // the objective, so the team works its way round it as a close target recce would
        private _opCount = [2, 4] select ((missionNamespace getVariable ["ALiVE_c2istar_reconOPs", 2]) == 4);
        // the best-scoring candidate first, then each next one at least _sep degrees round from every OP already taken
        private _fnc_pickOps = {
            params ["_pool", "_sep", "_n"];
            private _taken = [];
            {
                private _c = _x;
                if (count _taken < _n && {(_taken findIf { ([_x select 2, _c select 2] call _angle) < _sep }) < 0}) then { _taken pushBack _c };
            } forEach _pool;
            _taken
        };
        private _ops = [];
        {
            _x params ["_needLos", "_needClear", "_sep", ["_nearSide", false]];
            if (count _ops < _opCount) then {
                private _pool = _opCandidates select { (!_needLos || {_x select 3}) && {!_needClear || {_x select 4}} && {!_nearSide || {([_x select 2, _frvBrg] call _angle) <= 100}} };
                _pool sort false;
                private _taken = [_pool, _sep, _opCount] call _fnc_pickOps;
                if (count _taken == _opCount) then {
                    // in order round the objective, starting on the players' side, so the team walks one way round
                    if (_opCount > 2) then {
                        private _keyed = _taken apply { [((_x select 2) - (_frvBrg - 60) + 720) % 360, _x] };
                        _keyed sort true;
                        _taken = _keyed apply { _x select 1 };
                    };
                    _ops = _taken apply { _x select 1 };
                    if (_forEachIndex > 0) then { ["C2ISTAR - Task ReconObjective %1: OPs picked with looser rules (%2)", _taskID, _x] call ALiVE_fnc_Dump };
                };
            };
        } forEach ([
            [[true, true, 90, true], [false, true, 90, true], [false, false, 60, true], [true, true, 90], [false, true, 90], [false, false, 90], [false, false, 60]],
            [[true, true, 70], [false, true, 70], [false, false, 60], [false, false, 45]]
        ] select (_opCount > 2));
        if (count _ops < _opCount) then {
            private _brgs = [[_frvBrg + 60, _frvBrg - 60], [_frvBrg - 45, _frvBrg + 45, _frvBrg + 135, _frvBrg + 225]] select (_opCount > 2);
            _ops = _brgs apply { private _p = _targetPosition getPos [450, _x]; _p set [2, 0]; _p };
            ["C2ISTAR - Task ReconObjective %1: no land for %2 OPs; using points 450 m out", _taskID, _opCount] call ALiVE_fnc_Dump;
        };

        private _dialogOption = +(selectRandom (([ALIVE_generatedTasks, "ReconObjective"] call ALIVE_fnc_hashGet) select 1));
        private _nearestTown = [_targetPosition] call ALIVE_fnc_taskGetNearestLocationName;
        if (isNil "_nearestTown" || {!(_nearestTown isEqualType "")} || {_nearestTown == ""}) then { _nearestTown = "grid " + mapGridPosition _targetPosition };

        // the place name into each stage's text and its opening radio call
        {
            private _d = [_dialogOption, _x] call ALIVE_fnc_hashGet;
            if (!isNil "_d") then {
                [_d, "title", format [[_d, "title", ""] call ALIVE_fnc_hashGet, _nearestTown]] call ALIVE_fnc_hashSet;
                [_d, "description", format [[_d, "description", ""] call ALIVE_fnc_hashGet, _nearestTown]] call ALIVE_fnc_hashSet;
                private _chat = [_d, "chat_start", []] call ALIVE_fnc_hashGet;
                if (_chat isNotEqualTo []) then {
                    private _m = _chat select 0;
                    _m set [1, format [_m select 1, _nearestTown]];
                    [_d, "chat_start", _chat] call ALIVE_fnc_hashSet;
                };
            };
        } forEach ["Parent", "Travel", "Observe1", "Observe", "Observe2", "Observe3", "Observe4"];

        private _state = ["Created", "Assigned"] select (_taskCurrent == "Y");
        private _tasks = [];
        private _taskIDs = [];

        private _d = [_dialogOption, "Parent"] call ALIVE_fnc_hashGet;
        _tasks pushBack [_taskID, _requestPlayerID, _taskSide, _targetPosition, _taskFaction, [_d, "title"] call ALIVE_fnc_hashGet, [_d, "description"] call ALIVE_fnc_hashGet,
            _taskPlayers, _state, _taskApplyType, "N", "None", format ["%1-ReconObjective-Parent", _taskID], false];
        _taskIDs pushBack _taskID;

        _d = [_dialogOption, "Travel"] call ALIVE_fnc_hashGet;
        _tasks pushBack [format ["%1_c1", _taskID], _requestPlayerID, _taskSide, _frv, _taskFaction, [_d, "title"] call ALIVE_fnc_hashGet, [_d, "description"] call ALIVE_fnc_hashGet,
            _taskPlayers, _state, _taskApplyType, _taskCurrent, _taskID, format ["%1-ReconObjective-Travel", _taskID], false];
        _taskIDs pushBack format ["%1_c1", _taskID];

        // one stage per OP: with 2, Observe1 and Observe as before; with 4, Observe1 to Observe4
        private _stages = [["Observe1", "Observe"], ["Observe1", "Observe2", "Observe3", "Observe4"]] select (_opCount > 2);
        {
            private _last = _forEachIndex == (count _ops - 1);
            // custom task text without the 4-OP stages borrows OP 1's
            _d = [_dialogOption, _stages select _forEachIndex, [_dialogOption, "Observe1"] call ALIVE_fnc_hashGet] call ALIVE_fnc_hashGet;
            _tasks pushBack [format ["%1_c%2", _taskID, _forEachIndex + 2], _requestPlayerID, _taskSide, _x, _taskFaction, [_d, "title"] call ALIVE_fnc_hashGet, [_d, "description"] call ALIVE_fnc_hashGet,
                _taskPlayers, "Created", _taskApplyType, "N", _taskID, format ["%1-ReconObjective-%2", _taskID, _stages select _forEachIndex], _last];
            _taskIDs pushBack format ["%1_c%2", _taskID, _forEachIndex + 2];
        } forEach _ops;

        private _taskParams = [] call ALIVE_fnc_hashCreate;
        [_taskParams, "nextTask", _taskIDs select 1] call ALIVE_fnc_hashSet;
        [_taskParams, "taskIDs", _taskIDs] call ALIVE_fnc_hashSet;
        [_taskParams, "dialog", _dialogOption] call ALIVE_fnc_hashSet;
        [_taskParams, "enemyFaction", _taskEnemyFaction] call ALIVE_fnc_hashSet;
        [_taskParams, "target", _targetPosition] call ALIVE_fnc_hashSet;
        [_taskParams, "frv", _frv] call ALIVE_fnc_hashSet;
        [_taskParams, "ops", _ops] call ALIVE_fnc_hashSet;
        [_taskParams, "opDwell", _ops apply { 0 }] call ALIVE_fnc_hashSet;
        // each OP watched from for its full minute and ticked off, in any order
        [_taskParams, "opDone", _ops apply { false }] call ALIVE_fnc_hashSet;
        // what the players have spotted: unit -> [its group's profile id, position, class, how well]
        [_taskParams, "seen", createHashMap] call ALIVE_fnc_hashSet;
        [_taskParams, "lastState", ""] call ALIVE_fnc_hashSet;
        ["C2ISTAR - Task ReconObjective %1: FRV %2, %3 OPs %4 round %5", _taskID, mapGridPosition _frv, count _ops, _ops apply { mapGridPosition _x }, mapGridPosition _targetPosition] call ALiVE_fnc_Dump;

        _result = [_tasks, _taskParams];
    };

    case "Parent": {};

    // to the FRV
    case "Travel": {
        private _taskSide = _task select 2;
        private _taskPosition = _task select 3;
        private _taskPlayers = _task select 7 select 0;
        private _currentTaskDialog = [[_params, "dialog"] call ALIVE_fnc_hashGet, _taskState] call ALIVE_fnc_hashGet;
        // the opening call once (a shared lastState can't gate two stages, #931)
        if !([_params, "chatStartDone_Travel", false] call ALIVE_fnc_hashGet) then {
            ["chat_start", _currentTaskDialog, _taskSide, _taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
            [_params, "chatStartDone_Travel", true] call ALIVE_fnc_hashSet;
        };
        if ([_taskPosition, _taskPlayers, RECON_AT_FRV] call ALIVE_fnc_taskHavePlayersReachedDestination) then {
            [_params, "nextTask", ([_params, "taskIDs"] call ALIVE_fnc_hashGet) select 2] call ALIVE_fnc_hashSet;
            _task set [8, "Succeeded"];
            _task set [10, "N"];
            _result = _task;
        };
    };

    // a minute at each OP, in either order, then the report. Both OPs count whichever stage is open, and every tick
    // with someone at an OP adds what they can see. OP 2 manned first is ticked off straight away (A. Ares on Discord,
    // 23 Oct: it sat by the FRV and waited for OP 1); OP 1 then closes the task with the report
    // with Recon Task OPs at 4 the stages are Observe1 to Observe4, and any OP can be manned first: each one watched from
    // for its minute is ticked off, and the task moves on to the next OP not yet done
    case "Observe1";
    case "Observe2";
    case "Observe3";
    case "Observe4";
    case "Observe": {
        private _taskSide = _task select 2;
        private _taskFaction = _task select 4;
        private _taskPlayers = _task select 7 select 0;
        private _taskIDs = [_params, "taskIDs"] call ALIVE_fnc_hashGet;
        private _opsNow = [_params, "ops"] call ALIVE_fnc_hashGet;
        // the OP this stage is on: its place in the task's list of ids, after the parent and the FRV
        private _k = (_taskIDs find (_task select 0)) - 2;
        if (_k < 0 || {_k >= count _opsNow}) then { _k = [count _opsNow - 1, 0] select (_taskState == "Observe1") };
        // a task saved before the 4-OP change has op2Done rather than opDone
        private _done = [_params, "opDone"] call ALIVE_fnc_hashGet;
        if (isNil "_done") then {
            _done = _opsNow apply { false };
            if ([_params, "op2Done", false] call ALIVE_fnc_hashGet) then { _done set [1, true] };
            [_params, "opDone", _done] call ALIVE_fnc_hashSet;
        };
        private _currentTaskDialog = [[_params, "dialog"] call ALIVE_fnc_hashGet, _taskState] call ALIVE_fnc_hashGet;
        if !([_params, "chatStartDone_" + _taskState, false] call ALIVE_fnc_hashGet) then {
            ["chat_start", _currentTaskDialog, _taskSide, _taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
            [_params, "chatStartDone_" + _taskState, true] call ALIVE_fnc_hashSet;
            if (isNil {[_params, "lastTick"] call ALIVE_fnc_hashGet}) then { [_params, "lastTick", time] call ALIVE_fnc_hashSet };
        };
        private _now = time;
        private _dt = (_now - ([_params, "lastTick", _now] call ALIVE_fnc_hashGet)) min 30;
        [_params, "lastTick", _now] call ALIVE_fnc_hashSet;

        private _target = [_params, "target"] call ALIVE_fnc_hashGet;
        private _ops = [_params, "ops"] call ALIVE_fnc_hashGet;
        private _dwell = [_params, "opDwell", _ops apply { 0 }] call ALIVE_fnc_hashGet;
        private _seen = [_params, "seen", createHashMap] call ALIVE_fnc_hashGet;
        private _players = (_taskPlayers apply { [_x] call ALIVE_fnc_getPlayerByUID }) select { !isNull _x && {alive _x} };
        private _watchers = [];
        {
            private _op = _x;
            private _at = _players select { (_x distance2D _op) <= RECON_AT_OP };
            if (_at isNotEqualTo []) then { _dwell set [_forEachIndex, (_dwell select _forEachIndex) + _dt]; _watchers append _at };
        } forEach _ops;
        [_params, "opDwell", _dwell] call ALIVE_fnc_hashSet;

        // another OP done while this one is still the open stage: tick it off now and say so
        {
            if (_forEachIndex != _k && {_x >= RECON_WATCH_SECONDS} && {!(_done select _forEachIndex)}) then {
                private _row = [ALiVE_TaskHandler, "getTask", _taskIDs select (2 + _forEachIndex)] call ALiVE_fnc_TaskHandler;
                if (!isNil "_row") then {
                    _row set [8, "Succeeded"];
                    _row set [10, "N"];
                    [ALiVE_TaskHandler, "TASK_UPDATE", _row] call ALiVE_fnc_TaskHandler;
                };
                _done set [_forEachIndex, true];
                // said only while this OP still needs time: a team split over the OPs closing together just gets the report
                if ((_dwell select _k) < RECON_WATCH_SECONDS) then {
                    private _line = ["chat_early", "chat_early_any"] select (count _ops > 2);
                    [_line, [[_params, "dialog"] call ALIVE_fnc_hashGet, "Observe"] call ALIVE_fnc_hashGet, _taskSide, _taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
                };
                ["C2ISTAR - Task ReconObjective %1: OP %2 manned before OP %3", _taskID, _forEachIndex + 1, _k + 1] call ALiVE_fnc_Dump;
            };
        } forEach _dwell;
        [_params, "opDone", _done] call ALIVE_fnc_hashSet;

        // what is spotted from the OPs: an enemy unit round the objective that the side knows about, or that a player
        // at an OP has a clear line of sight to within 600 m (a remote player's own knowledge isn't held on the server)
        if (_watchers isNotEqualTo []) then {
            private _sideObj = [_taskSide] call ALIVE_fnc_sideTextToObject;
            {
                private _u = _x;
                if (alive _u && {(_sideObj getFriend side group _u) < 0.6} && {!(_u getVariable ["profileID", ""] isEqualTo "")}) then {
                    private _know = _sideObj knowsAbout _u;
                    private _spotted = _know >= RECON_KNOW || {
                        (_watchers findIf {
                            (_x distance _u) <= RECON_SIGHT
                            && {!terrainIntersectASL [eyePos _x, aimPos _u]}
                            && {(lineIntersectsSurfaces [eyePos _x, aimPos _u, _x, vehicle _u, true, 1, "VIEW", "FIRE"]) isEqualTo []}
                        }) >= 0
                    };
                    if (_spotted) then { _seen set [_u call BIS_fnc_netId, [_u getVariable ["profileID", ""], getPosATL _u, typeOf _u, _know max RECON_KNOW]] };
                };
            } forEach (_target nearEntities [["CAManBase"], RECON_REPORT_RADIUS]);
            // vehicles: one in view is reported by its own profile, crewed or parked empty (the commander's preparation
            // tasks go after vehicles, and count one as known when a report puts something within 100 m of it); its
            // crew are reported too, by their group's profile
            private _enemySides = ["EAST", "WEST", "GUER"] select { (_sideObj getFriend ([_x] call ALIVE_fnc_sideTextToObject)) < 0.6 };
            {
                private _v = _x;
                private _vid = _v getVariable ["profileID", ""];
                private _vprof = if (_vid == "") then { nil } else { [ALIVE_profileHandler, "getProfile", _vid] call ALIVE_fnc_profileHandler };
                private _vside = if (isNil "_vprof") then { "" } else { [_vprof, "side", ""] call ALIVE_fnc_hashGet };
                if (alive _v && {_vside in _enemySides}
                    && {(_sideObj knowsAbout _v) >= RECON_KNOW || {(_watchers findIf { (_x distance _v) <= RECON_SIGHT && {!terrainIntersectASL [eyePos _x, aimPos _v]} }) >= 0}}) then {
                    _seen set [_v call BIS_fnc_netId, [_vid, getPosATL _v, typeOf _v, (_sideObj knowsAbout _v) max RECON_KNOW]];
                    {
                        if (alive _x && {!((_x getVariable ["profileID", ""]) isEqualTo "")}) then {
                            _seen set [_x call BIS_fnc_netId, [_x getVariable ["profileID", ""], getPosATL _v, typeOf _x, (_sideObj knowsAbout _x) max RECON_KNOW]];
                        };
                    } forEach crew _v;
                };
            } forEach (_target nearEntities [["LandVehicle", "StaticWeapon", "Ship"], RECON_REPORT_RADIUS]);
        };

        if ((_dwell select _k) >= RECON_WATCH_SECONDS) then {
            _done set [_k, true];
            [_params, "opDone", _done] call ALIVE_fnc_hashSet;
            // the next OP not yet done, going on round from this one
            private _n = count _done;
            private _next = -1;
            for "_j" from 1 to (_n - 1) do { if (_next < 0 && {!(_done select ((_k + _j) % _n))}) then { _next = (_k + _j) % _n } };
            if (_next >= 0) exitWith {
                [_params, "nextTask", _taskIDs select (2 + _next)] call ALIVE_fnc_hashSet;
                _task set [8, "Succeeded"];
                _task set [10, "N"];
                _result = _task;
            };
            // the groups the spotted units belong to, reported to the side: [side, position, time, group profile ids,
            // group positions, this task's id, units spotted, the OPs]. The id is how a commander that asked for the
            // recon knows it has reported: the task's own rows are deleted the moment it finishes
            private _ids = [];
            private _pos = [];
            private _units = [];
            {
                _y params ["_pid", "_upos", "_class", "_know"];
                _units pushBack [_pid, _upos, _class, _know];
                if !(_pid in _ids) then {
                    _ids pushBack _pid;
                    private _prof = [ALIVE_profileHandler, "getProfile", _pid] call ALIVE_fnc_profileHandler;
                    _pos pushBack (if (isNil "_prof") then { _upos } else { [_prof, "position", _upos] call ALIVE_fnc_hashGet });
                };
            } forEach _seen;
            private _reports = missionNamespace getVariable ["ALiVE_reconReports", []];
            _reports pushBack [_taskSide, +_target, time, _ids, _pos, _task select 11, _units, +_ops];
            ALiVE_reconReports = _reports select { time - (_x select 2) < 3600 };
            ["C2ISTAR - Task ReconObjective %1: %2 enemy spotted in %3 groups round %4", _taskID, count _units, count _ids, mapGridPosition _target] call ALiVE_fnc_Dump;

            [_params, "nextTask", ""] call ALIVE_fnc_hashSet;
            _task set [8, "Succeeded"];
            _task set [10, "N"];
            _result = _task;
            // the closing exchange and the reward sit on the OP 2 stage, whichever OP closed the task
            private _endDialog = [[_params, "dialog"] call ALIVE_fnc_hashGet, "Observe"] call ALIVE_fnc_hashGet;
            ["chat_success", _endDialog, _taskSide, _taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
            [_endDialog, _taskSide, _taskFaction] call ALIVE_fnc_taskCreateReward;
        };
    };
};

_result
