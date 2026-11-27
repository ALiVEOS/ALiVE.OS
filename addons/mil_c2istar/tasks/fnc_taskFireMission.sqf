#include "\x\alive\addons\mil_c2istar\script_component.hpp"
SCRIPT(taskFireMission);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskFireMission

Description:
Fire Mission for a player-crewed gun (Fitz on Discord, 9 Nov). A player group crewing an artillery piece or a
mortar that asks the AI Commander for orders (or picks Fire Mission on the tablet) gets an enemy group the side
knows of, within the gun's range, as a target: its grid, what it is and how many rounds to fire. Then it moves
the gun at least 300 m before the enemy can fire back (shoot and scoot).

Stages:
    Fire     - succeeds when no enemy is left within 250 m of the target or the target group is gone;
               fails after 20 minutes, when the target is reported to have moved on
    Relocate - succeeds when the gun is 300 m or more from where it fired; fails after 10 minutes, or when the
               gun is destroyed

Parameters:
    0 - STRING task state ("init", "Parent", "Fire", "Relocate")
    1 - STRING task ID
    2 - ARRAY task
    3 - HASH task params
    4 - BOOL debug

Returns:
    "init": [tasks, params]; a stage: the changed task, or []

Author:
Jman
---------------------------------------------------------------------------- */

params ["_taskState", "_taskID", "_task", "_params", "_debug"];
private _result = [];

// the gun one of the task's players is crewing: an artillery piece or a mortar
private _fnc_gun = {
    params ["_playerIDs"];
    private _gun = objNull;
    {
        private _p = [_x] call ALIVE_fnc_getPlayerByUID;
        if (!isNull _p && {alive _p} && {vehicle _p != _p} && {[vehicle _p] call ALIVE_fnc_isArtillery}) exitWith { _gun = vehicle _p };
    } forEach _playerIDs;
    _gun
};

switch (_taskState) do {
    case "init": {
        private _taskData = _task;
        _taskData params ["_taskID", "_requestPlayerID", "_taskSide", "_taskFaction", "", "_taskLocationType", "_taskLocation", "_taskPlayers", "_taskEnemyFaction", ["_taskCurrent", "N"], ["_taskApplyType", ""]];

        if (_taskID == "") exitWith { ["C2ISTAR - Task FireMission - Wrong input for _taskID!"] call ALiVE_fnc_Dump };
        if (_taskFaction == "") exitWith { ["C2ISTAR - Task FireMission - Wrong input for _taskFaction!"] call ALiVE_fnc_Dump };
        if (count _taskPlayers == 0) exitWith { ["C2ISTAR - Task FireMission - Wrong input for _taskPlayers!"] call ALiVE_fnc_Dump };
        if (_taskEnemyFaction == "") exitWith { ["C2ISTAR - Task FireMission - Wrong input for _taskEnemyFaction!"] call ALiVE_fnc_Dump };
        if (isNil "ALiVE_profileHandler") exitWith { ["C2ISTAR - Task FireMission - no profiles, no targets"] call ALiVE_fnc_Dump };

        private _gun = [_taskPlayers select 0] call _fnc_gun;
        if (isNull _gun) exitWith { ["C2ISTAR - Task FireMission - none of %1 is crewing an artillery piece or a mortar", _taskPlayers select 1] call ALiVE_fnc_Dump };

        private _taskEnemySide = [[_taskEnemyFaction call ALiVE_fnc_factionSide] call ALIVE_fnc_sideObjectToNumber] call ALIVE_fnc_sideNumberToText;
        private _gunPos = getPosATL _gun;
        private _mag = currentMagazine _gun;
        // in range of the gun with what it has loaded; with nothing loaded, between 200 m and 10 km
        private _inRange = {
            params ["_pos"];
            if (_mag != "") then { _pos inRangeOfArtillery [[_gun], _mag] } else { (_pos distance2D _gunPos) > 200 && {(_pos distance2D _gunPos) < 10000} }
        };

        // enemy groups, nearest the gun first, that the side knows of and are in range
        private _targets = [ALiVE_profileHandler, "getProfilesByType", "entity"] call ALIVE_fnc_profileHandler;
        _targets = _targets select {
            private _pr = [ALiVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
            !isNil "_pr" && {([_pr, "side", ""] call ALiVE_fnc_HashGet) == _taskEnemySide}
        };
        _targets = [_targets, [_gunPos], {
            private _pr = [ALiVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
            ([_pr, "position", [0,0,0]] call ALiVE_fnc_HashGet) distance2D _Input0
        }, "ASCEND"] call ALiVE_fnc_SortBy;
        if (_taskLocationType != "Map") then { _targets = ["groups", _taskSide, _targets] call ALIVE_fnc_taskKnownEnemy };
        _targets = (_targets select [0, 40]) select {
            private _pr = [ALiVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
            [[_pr, "position", [0,0,0]] call ALiVE_fnc_HashGet] call _inRange
        };
        if (_targets isEqualTo []) exitWith { ["C2ISTAR - Task FireMission - no enemy group known to %1 in range of the %2 at %3", _taskSide, typeOf _gun, mapGridPosition _gun] call ALiVE_fnc_Dump };
        private _free = ["free", _targets] call ALIVE_fnc_taskTargetClaim;
        if (_free isNotEqualTo []) then { _targets = _free };
        private _targetID = _targets select 0;
        ["claim", _targetID] call ALIVE_fnc_taskTargetClaim;

        private _target = [ALiVE_profileHandler, "getProfile", _targetID] call ALIVE_fnc_profileHandler;
        private _targetPos = +([_target, "position", []] call ALiVE_fnc_HashGet);
        if (count _targetPos < 2) exitWith { ["C2ISTAR - Task FireMission - the target has no position"] call ALiVE_fnc_Dump };
        if (count _targetPos < 3) then { _targetPos pushBack 0 };

        // what it is: the vehicles it has, else infantry; more rounds for armour and vehicles
        private _vehicles = [_target, "vehicleAssignments", [[], []]] call ALiVE_fnc_HashGet;
        private _hasVehicles = (_vehicles param [1, []]) isNotEqualTo [];
        private _what = if (_hasVehicles) then { "vehicles" } else { "infantry" };
        private _rounds = [6, 8] select _hasVehicles;
        private _dist = round ((_gunPos distance2D _targetPos) / 100) / 10;
        private _bearing = round (_gunPos getDir _targetPos);
        private _nearestTown = [_targetPos] call ALIVE_fnc_taskGetNearestLocationName;

        [_taskID, [_targetID]] call ALIVE_fnc_taskLockProfiles;

        // the dialog
        private _dialogOptions = [ALIVE_generatedTasks, "FireMission"] call ALIVE_fnc_hashGet;
        private _dialogOption = +(selectRandom (_dialogOptions select 1));
        private _grid = mapGridPosition _targetPos;

        private _dialog = [_dialogOption, "Parent"] call ALIVE_fnc_hashGet;
        [_dialog, "title", format [[_dialog, "title"] call ALIVE_fnc_hashGet, _nearestTown]] call ALIVE_fnc_hashSet;

        _dialog = [_dialogOption, "Fire"] call ALIVE_fnc_hashGet;
        [_dialog, "title", format [[_dialog, "title"] call ALIVE_fnc_hashGet, _grid]] call ALIVE_fnc_hashSet;
        [_dialog, "description", format [[_dialog, "description"] call ALIVE_fnc_hashGet, _grid, _what, _rounds, _dist, _bearing]] call ALIVE_fnc_hashSet;
        private _chat = [_dialog, "chat_start"] call ALIVE_fnc_hashGet;
        private _msg = _chat select 1;
        _msg set [1, format [_msg select 1, _grid, _what, _rounds, _bearing, _dist]];
        _chat set [1, _msg];
        private _readBack = _chat select 2;
        _readBack set [1, format [_readBack select 1, _grid]];
        _chat set [2, _readBack];
        [_dialog, "chat_start", _chat] call ALIVE_fnc_hashSet;

        private _state = ["Created", "Assigned"] select (_taskCurrent == "Y");
        private _tasks = [];
        private _taskIDs = [];

        _dialog = [_dialogOption, "Parent"] call ALIVE_fnc_hashGet;
        _tasks pushBack [_taskID, _requestPlayerID, _taskSide, _targetPos, _taskFaction, [_dialog, "title"] call ALIVE_fnc_hashGet, [_dialog, "description"] call ALIVE_fnc_hashGet,
            _taskPlayers, _state, _taskApplyType, "N", "None", format ["%1-FireMission-Parent", _taskID], false];
        _taskIDs pushBack _taskID;

        _dialog = [_dialogOption, "Fire"] call ALIVE_fnc_hashGet;
        _tasks pushBack [format ["%1_c1", _taskID], _requestPlayerID, _taskSide, _targetPos, _taskFaction, [_dialog, "title"] call ALIVE_fnc_hashGet, [_dialog, "description"] call ALIVE_fnc_hashGet,
            _taskPlayers, _state, _taskApplyType, _taskCurrent, _taskID, format ["%1-FireMission-Fire", _taskID], false];
        _taskIDs pushBack format ["%1_c1", _taskID];

        _dialog = [_dialogOption, "Relocate"] call ALIVE_fnc_hashGet;
        _tasks pushBack [format ["%1_c2", _taskID], _requestPlayerID, _taskSide, _gunPos, _taskFaction, [_dialog, "title"] call ALIVE_fnc_hashGet, [_dialog, "description"] call ALIVE_fnc_hashGet,
            _taskPlayers, "Created", _taskApplyType, "N", _taskID, format ["%1-FireMission-Relocate", _taskID], true];
        _taskIDs pushBack format ["%1_c2", _taskID];

        private _taskParams = [] call ALIVE_fnc_hashCreate;
        [_taskParams, "nextTask", _taskIDs select 1] call ALIVE_fnc_hashSet;
        [_taskParams, "taskIDs", _taskIDs] call ALIVE_fnc_hashSet;
        [_taskParams, "dialog", _dialogOption] call ALIVE_fnc_hashSet;
        [_taskParams, "enemyFaction", _taskEnemyFaction] call ALIVE_fnc_hashSet;
        [_taskParams, "targetID", _targetID] call ALIVE_fnc_hashSet;
        [_taskParams, "gun", netId _gun] call ALIVE_fnc_hashSet;
        [_taskParams, "lastState", ""] call ALIVE_fnc_hashSet;

        if (_debug || {missionNamespace getVariable ["ALiVE_c2istar_debug", false]}) then {
            ["C2ISTAR - Task FireMission - %1 at %2 given %3 (%4) at %5, %6 km bearing %7, %8 rounds", typeOf _gun, mapGridPosition _gunPos, _targetID, _what, _grid, _dist, _bearing, _rounds] call ALiVE_fnc_Dump;
        };

        _result = [_tasks, _taskParams];
    };

    case "Parent": {};

    case "Fire": {
        _task params ["_taskID", "", "_taskSide", "_taskPosition", "_taskFaction", "", "", "_taskPlayersAll"];
        private _taskPlayers = _taskPlayersAll select 0;
        private _taskDialog = [_params, "dialog"] call ALIVE_fnc_hashGet;
        private _currentTaskDialog = [_taskDialog, _taskState] call ALIVE_fnc_hashGet;

        if !([_params, "chatStartDone_Fire", false] call ALIVE_fnc_hashGet) then {
            ["chat_start", _currentTaskDialog, _taskSide, _taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
            [_params, "chatStartDone_Fire", true] call ALIVE_fnc_hashSet;
            [_params, "fireStart", time] call ALIVE_fnc_hashSet;
        };

        // the gun it is fired from, kept for the relocation: whichever gun the crew is on now
        private _gun = [_taskPlayers] call _fnc_gun;
        if (!isNull _gun) then { [_params, "gun", netId _gun] call ALIVE_fnc_hashSet; [_params, "firePos", getPosATL _gun] call ALIVE_fnc_hashSet };

        private _targetID = [_params, "targetID", ""] call ALIVE_fnc_hashGet;
        private _target = [ALiVE_profileHandler, "getProfile", _targetID] call ALIVE_fnc_profileHandler;
        private _clear = isNil "_target" || {!([_taskPosition, _taskSide, 250, true] call ALIVE_fnc_isEnemyNear)};

        if (_clear) exitWith {
            private _taskIDs = [_params, "taskIDs"] call ALIVE_fnc_hashGet;
            [_params, "nextTask", _taskIDs select 2] call ALIVE_fnc_hashSet;
            [_params, "relocateStart", time] call ALIVE_fnc_hashSet;
            _task set [8, "Succeeded"];
            _task set [10, "N"];
            _result = _task;
            ["chat_success", _currentTaskDialog, _taskSide, _taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
            [_currentTaskDialog, _taskSide, _taskFaction] call ALIVE_fnc_taskCreateReward;
        };

        if (time - ([_params, "fireStart", time] call ALIVE_fnc_hashGet) > 1200) then {
            [_params, "nextTask", ""] call ALIVE_fnc_hashSet;
            _task set [8, "Failed"];
            _task set [10, "N"];
            _result = _task;
            ["chat_failed", _currentTaskDialog, _taskSide, _taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
        };
    };

    case "Relocate": {
        _task params ["_taskID", "", "_taskSide", "", "_taskFaction", "", "", "_taskPlayersAll"];
        private _taskPlayers = _taskPlayersAll select 0;
        private _taskDialog = [_params, "dialog"] call ALIVE_fnc_hashGet;
        private _currentTaskDialog = [_taskDialog, _taskState] call ALIVE_fnc_hashGet;

        if !([_params, "chatStartDone_Relocate", false] call ALIVE_fnc_hashGet) then {
            ["chat_start", _currentTaskDialog, _taskSide, _taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
            [_params, "chatStartDone_Relocate", true] call ALIVE_fnc_hashSet;
            if (isNil {[_params, "relocateStart"] call ALIVE_fnc_hashGet}) then { [_params, "relocateStart", time] call ALIVE_fnc_hashSet };
        };

        private _gun = ([_params, "gun", ""] call ALIVE_fnc_hashGet) call BIS_fnc_objectFromNetId;
        private _firePos = [_params, "firePos", []] call ALIVE_fnc_hashGet;
        if (isNull _gun || {!alive _gun} || {time - ([_params, "relocateStart", time] call ALIVE_fnc_hashGet) > 600}) exitWith {
            [_params, "nextTask", ""] call ALIVE_fnc_hashSet;
            _task set [8, "Failed"];
            _task set [10, "N"];
            _result = _task;
            ["chat_failed", _currentTaskDialog, _taskSide, _taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
        };
        if (_firePos isEqualTo [] || {(_gun distance2D _firePos) >= 300}) then {
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
