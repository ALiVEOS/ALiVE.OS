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
        private _enemySides = ["EAST", "WEST", "GUER"] select { (([_taskSide] call ALIVE_fnc_sideTextToObject) getFriend ([_x] call ALIVE_fnc_sideTextToObject)) < 0.6 };

        // FRV: on the players' side, 800 to 1200 m out, on land, out of town and away from the enemy, in cover and out
        // of sight of the objective where it can be. Each rule is dropped in turn if nothing passes
        private _frvCandidates = [];
        {
            private _r = _x;
            for "_a" from -45 to 45 step 15 do {
                private _p = _targetPosition getPos [_r, _bearing + _a];
                _p set [2, 0];
                if !(surfaceIsWater _p) then { _frvCandidates pushBack _p };
            };
        } forEach RECON_FRV_RANGES;
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
                if !(surfaceIsWater _p) then {
                    private _eye = AGLToASL [_p select 0, _p select 1, 1.8];
                    private _h = (((_eye select 2) - (_targetEye select 2)) max -20) min 60;
                    private _los = !(terrainIntersectASL [_eye, _targetEye]);
                    private _clear = count (nearestTerrainObjects [_p, ["HOUSE", "BUILDING"], 15, false, true]) == 0;
                    _opCandidates pushBack [_h + ([0, 10] select _los) + (_p call _cover) - 0.01 * _r, _p, _a, _los, _clear];
                };
            };
        } forEach ([RECON_OP_RANGES, RECON_OP_RANGES_TOWN] select _inTown);
        private _angle = { private _d = abs ((_this select 0) - (_this select 1)) % 360; _d min (360 - _d) };
        private _ops = [];
        {
            _x params ["_needLos", "_needClear", "_sep"];
            if (count _ops < 2) then {
                private _pool = _opCandidates select { (!_needLos || {_x select 3}) && {!_needClear || {_x select 4}} };
                _pool sort false;
                if (_pool isNotEqualTo []) then {
                    private _op1 = _pool select 0;
                    private _i = _pool findIf { ([_x select 2, _op1 select 2] call _angle) >= _sep };
                    if (_i >= 0) then {
                        _ops = [_op1 select 1, (_pool select _i) select 1];
                        if (_forEachIndex > 0) then { ["C2ISTAR - Task ReconObjective %1: OPs picked with looser rules (%2)", _taskID, _x] call ALiVE_fnc_Dump };
                    };
                };
            };
        } forEach [[true, true, 90], [false, true, 90], [false, false, 90], [false, false, 60]];
        if (count _ops < 2) then {
            _ops = [_targetPosition getPos [450, _bearing + 60], _targetPosition getPos [450, _bearing - 60]];
            { _x set [2, 0] } forEach _ops;
            ["C2ISTAR - Task ReconObjective %1: no land for two OPs; using two points 450 m out", _taskID] call ALiVE_fnc_Dump;
        };

        private _dialogOption = +(selectRandom (([ALIVE_generatedTasks, "ReconObjective"] call ALIVE_fnc_hashGet) select 1));
        private _nearestTown = [_targetPosition] call ALIVE_fnc_taskGetNearestLocationName;
        if (isNil "_nearestTown" || {!(_nearestTown isEqualType "")} || {_nearestTown == ""}) then { _nearestTown = "grid " + mapGridPosition _targetPosition };

        // the place name into each stage's text and its opening radio call
        {
            private _d = [_dialogOption, _x] call ALIVE_fnc_hashGet;
            [_d, "title", format [[_d, "title", ""] call ALIVE_fnc_hashGet, _nearestTown]] call ALIVE_fnc_hashSet;
            [_d, "description", format [[_d, "description", ""] call ALIVE_fnc_hashGet, _nearestTown]] call ALIVE_fnc_hashSet;
            private _chat = [_d, "chat_start", []] call ALIVE_fnc_hashGet;
            if (_chat isNotEqualTo []) then {
                private _m = _chat select 0;
                _m set [1, format [_m select 1, _nearestTown]];
                [_d, "chat_start", _chat] call ALIVE_fnc_hashSet;
            };
        } forEach ["Parent", "Travel", "Observe1", "Observe"];

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

        _d = [_dialogOption, "Observe1"] call ALIVE_fnc_hashGet;
        _tasks pushBack [format ["%1_c2", _taskID], _requestPlayerID, _taskSide, _ops select 0, _taskFaction, [_d, "title"] call ALIVE_fnc_hashGet, [_d, "description"] call ALIVE_fnc_hashGet,
            _taskPlayers, "Created", _taskApplyType, "N", _taskID, format ["%1-ReconObjective-Observe1", _taskID], false];
        _taskIDs pushBack format ["%1_c2", _taskID];

        _d = [_dialogOption, "Observe"] call ALIVE_fnc_hashGet;
        _tasks pushBack [format ["%1_c3", _taskID], _requestPlayerID, _taskSide, _ops select 1, _taskFaction, [_d, "title"] call ALIVE_fnc_hashGet, [_d, "description"] call ALIVE_fnc_hashGet,
            _taskPlayers, "Created", _taskApplyType, "N", _taskID, format ["%1-ReconObjective-Observe", _taskID], true];
        _taskIDs pushBack format ["%1_c3", _taskID];

        private _taskParams = [] call ALIVE_fnc_hashCreate;
        [_taskParams, "nextTask", _taskIDs select 1] call ALIVE_fnc_hashSet;
        [_taskParams, "taskIDs", _taskIDs] call ALIVE_fnc_hashSet;
        [_taskParams, "dialog", _dialogOption] call ALIVE_fnc_hashSet;
        [_taskParams, "enemyFaction", _taskEnemyFaction] call ALIVE_fnc_hashSet;
        [_taskParams, "target", _targetPosition] call ALIVE_fnc_hashSet;
        [_taskParams, "frv", _frv] call ALIVE_fnc_hashSet;
        [_taskParams, "ops", _ops] call ALIVE_fnc_hashSet;
        [_taskParams, "opDwell", [0, 0]] call ALIVE_fnc_hashSet;
        // what the players have spotted: unit -> [its group's profile id, position, class, how well]
        [_taskParams, "seen", createHashMap] call ALIVE_fnc_hashSet;
        [_taskParams, "lastState", ""] call ALIVE_fnc_hashSet;
        ["C2ISTAR - Task ReconObjective %1: FRV %2, OP 1 %3, OP 2 %4 round %5", _taskID, mapGridPosition _frv, mapGridPosition (_ops select 0), mapGridPosition (_ops select 1), mapGridPosition _targetPosition] call ALiVE_fnc_Dump;

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

    // a minute at OP 1, then a minute at OP 2 and the report. Both OPs count whichever stage is open, so players who
    // reach OP 2 first don't waste the time, and every tick with someone at an OP adds what they can see
    case "Observe1";
    case "Observe": {
        private _taskSide = _task select 2;
        private _taskFaction = _task select 4;
        private _taskPlayers = _task select 7 select 0;
        private _final = _taskState == "Observe";
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
        private _dwell = [_params, "opDwell", [0, 0]] call ALIVE_fnc_hashGet;
        private _seen = [_params, "seen", createHashMap] call ALIVE_fnc_hashGet;
        private _players = (_taskPlayers apply { [_x] call ALIVE_fnc_getPlayerByUID }) select { !isNull _x && {alive _x} };
        private _watchers = [];
        {
            private _op = _x;
            private _at = _players select { (_x distance2D _op) <= RECON_AT_OP };
            if (_at isNotEqualTo []) then { _dwell set [_forEachIndex, (_dwell select _forEachIndex) + _dt]; _watchers append _at };
        } forEach _ops;
        [_params, "opDwell", _dwell] call ALIVE_fnc_hashSet;

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

        private _index = [0, 1] select _final;
        if ((_dwell select _index) >= RECON_WATCH_SECONDS) then {
            if (!_final) exitWith {
                [_params, "nextTask", ([_params, "taskIDs"] call ALIVE_fnc_hashGet) select 3] call ALIVE_fnc_hashSet;
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
            ["chat_success", _currentTaskDialog, _taskSide, _taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
            [_currentTaskDialog, _taskSide, _taskFaction] call ALIVE_fnc_taskCreateReward;
        };
    };
};

_result
