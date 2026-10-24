#include "\x\alive\addons\mil_c2istar\script_component.hpp"
SCRIPT(taskStopSaboteur);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskStopSaboteur

Description:
Stop a saboteur before he blows a building in a town. The task spawns its own
man (never virtualised, so he keeps going while players are far off) wearing a
bomb vest. He waits until a task player is within 1.5 km of the target, then
walks to it, plants charges inside, runs clear and sets them off. He holds the
detonator: kill him or detain him (the Detain hold action, or ACE handcuffs)
before then and the charges never go off.

Succeeded: he is dead or held, and a task player is within 500 m.
Failed: the charges went off, or the building was destroyed.
Canceled: he was removed, could not reach the building, or the task was loaded
from a save (the man and his charges do not survive a load).

Parameters:
0: STRING - task state ("init" / "Parent" / "Stop")
1: STRING - task ID
2: ARRAY  - task data (init) or task array (stages)
3: ARRAY  - task params hash (stages)
4: BOOL   - debug

Returns:
ARRAY - init: [tasks, params]; stages: the changed task array, or []

Author:
Jman
---------------------------------------------------------------------------- */

params ["_taskState", "_taskID", "_task", "_params", "_debug"];

private _result = [];

// a task player this close to the target sets him off
#define SAB_WAKE_RANGE 1500
// a task player this close to him or the target lets a kill count
#define SAB_CONFIRM_RANGE 500

// held by players: the task's own Detain, ALiVE's detain, ACE handcuffs or surrender, or down
private _isHeld = {
    params ["_u"];
    (_u getVariable ["detained", false])
    || {_u getVariable ["ace_captives_isHandcuffed", false]}
    || {_u getVariable ["ace_captives_isSurrendering", false]}
    || {_u getVariable ["ACE_isUnconscious", false]}
    || {lifeState _u isEqualTo "INCAPACITATED"}
};

private _cleanup = {
    params ["_taskParams", "_keepMan"];
    private _script = [_taskParams, "script", scriptNull] call ALIVE_fnc_hashGet;
    if (!isNil "_script" && {_script isEqualType scriptNull} && {!scriptDone _script}) then { terminate _script };
    { if (!isNull _x) then { deleteVehicle _x } } forEach ([_taskParams, "charges", []] call ALIVE_fnc_hashGet);
    [_taskParams, "charges", []] call ALIVE_fnc_hashSet;
    private _man = [_taskParams, "saboteur", objNull] call ALIVE_fnc_hashGet;
    if (!isNil "_man" && {_man isEqualType objNull} && {!isNull _man} && {!_keepMan}) then {
        // gone once no player can see it happen
        [_man] spawn {
            params ["_man"];
            waitUntil { sleep 10; isNull _man || {(allPlayers findIf { (_x distance2D _man) < 500 }) < 0} };
            if (!isNull _man) then { deleteVehicle _man };
        };
    };
};

switch (_taskState) do {
    case "init": {
        _task params [
            "_taskID",
            "_requestPlayerID",
            "_taskSide",
            "_taskFaction",
            "",
            "_taskLocationType",
            "_taskLocation",
            "_taskPlayers",
            "_taskEnemyFaction",
            "_taskCurrent",
            "_taskApplyType"
        ];

        if (_taskID == "") exitWith {["C2ISTAR - Task StopSaboteur - Wrong input for _taskID!"] call ALiVE_fnc_Dump};
        if (count _taskLocation == 0) exitWith {["C2ISTAR - Task StopSaboteur - Wrong input for _taskLocation!"] call ALiVE_fnc_Dump};
        if (count _taskPlayers == 0) exitWith {["C2ISTAR - Task StopSaboteur - Wrong input for _taskPlayers!"] call ALiVE_fnc_Dump};

        private _tasksCurrent = ([ALiVE_TaskHandler, "tasks", ["", [], [], nil]] call ALiVE_fnc_HashGet) select 2;

        // the town: a civilian settlement as the civic tasks pick one, else a named place
        private _center = [];
        private _clusterData = [_taskLocation, _taskLocationType, _taskSide, -100000, 100000, _taskFaction, _tasksCurrent, true] call ALIVE_fnc_taskGetCivilianCluster;
        if (_clusterData isNotEqualTo []) then {
            _center = [_clusterData select 0, "center", []] call ALIVE_fnc_hashGet;
        };
        if (_center isEqualTo []) then {
            private _places = nearestLocations [_taskLocation, ["NameVillage", "NameCity", "NameCityCapital"], 6000];
            if (_places isNotEqualTo []) then { _center = locationPosition (selectRandom (_places select [0, 4])) };
        };
        if (_center isEqualTo []) exitWith {["C2ISTAR - Task StopSaboteur - no town near %1", _taskLocation] call ALiVE_fnc_Dump};

        // the target: a building that can be destroyed, with room inside to plant
        private _buildings = (_center nearObjects ["House", 250]) select {
            alive _x
            && {damage _x < 0.5}
            && {!(_x isKindOf "Lamps_Base_F")}
            && {getText (configFile >> "CfgVehicles" >> typeOf _x >> "destrType") != "DestructNo"}
            && {count (_x buildingPos -1) >= 2}
        };
        if (_buildings isEqualTo []) exitWith {["C2ISTAR - Task StopSaboteur - no building to target near %1", mapGridPosition _center] call ALiVE_fnc_Dump};
        _buildings = [_buildings, [], { count (_x buildingPos -1) }, "DESCEND"] call ALiVE_fnc_SortBy;
        private _building = selectRandom (_buildings select [0, 5]);
        private _targetPos = getPosATL _building;
        _targetPos set [2, 0];
        private _buildingName = getText (configFile >> "CfgVehicles" >> typeOf _building >> "displayName");
        if (_buildingName == "") then { _buildingName = "building" };
        private _town = [_targetPos] call ALIVE_fnc_taskGetNearestLocationName;
        if (_town == "") then { _town = "the town" };

        // where he starts: 500 to 800 m out, on open ground
        private _start = [_targetPos, 500, 800, 2, 0, 0.3, 0, [], [[], []]] call BIS_fnc_findSafePos;
        if (_start isEqualTo [] || {(_start distance2D _targetPos) < 400} || {(_start distance2D _targetPos) > 900}) then {
            _start = [_targetPos, 600, random 360] call BIS_fnc_relPos;
        };
        _start set [2, 0];

        private _group = createGroup [civilian, true];
        private _man = _group createUnit [selectRandom ([] call ALiVE_fnc_taskGetCivilianClasses), _start, [], 0, "NONE"];
        if (isNull _man) exitWith {["C2ISTAR - Task StopSaboteur - could not create the saboteur"] call ALiVE_fnc_Dump};
        removeAllWeapons _man;
        // the vest the Insurgency's bombers wear, so he can be told from the townsfolk
        private _vestRaw = missionNamespace getVariable ["ALIVE_civCommandSuicideVest", ""];
        if (_vestRaw == "") then { _vestRaw = "V_ALiVE_Suicide_Vest" };
        _man addVest (selectRandom ([[_vestRaw, " ", ""] call CBA_fnc_replace, ","] call CBA_fnc_split));
        _man addMagazines ["DemoCharge_Remote_Mag", 2];
        [_man, "STR_ALIVE_TARGETID_SABOTEUR"] call ALiVE_fnc_giveTargetPapers;
        // the civilian brain and its orders leave him to the task (it never makes him captive, which would read as held)
        _man setVariable ["ALiVE_advciv_blacklist", true, true];
        _man setVariable ["ALiVE_advciv_active", false, true];
        _man setBehaviour "CARELESS";
        _man disableAI "AUTOTARGET";
        _man disableAI "TARGET";
        _man setVariable ["ALIVE_Task_SabPhase", "WAIT", true];

        // the blacklist hides ALiVE's own Detain from him, so he gets one of his own
        [
            _man,
            "Detain",
            "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_secure_ca.paa",
            "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_secure_ca.paa",
            "alive _target && {_this distance2D _target < 3} && {!(_target getVariable ['detained', false])}",
            "alive _target && {_caller distance2D _target < 3}",
            {},
            {},
            {
                params ["_target", "_caller"];
                _target setVariable ["detained", true, true];
                [_target, "AmovPercMstpSsurWnonDnon"] remoteExec ["switchMove", 0];
                ["Task Update", format ["%1 detained the saboteur.", name _caller]] remoteExec ["ALIVE_fnc_taskSubtitle", side (group _caller)];
            },
            {},
            [],
            3
        ] remoteExec ["BIS_fnc_holdActionAdd", [0, -2] select isDedicated, _man];

        private _dialogOptions = [ALIVE_generatedTasks, "StopSaboteur"] call ALIVE_fnc_hashGet;
        if (isNil "_dialogOptions") exitWith {
            deleteVehicle _man;
            ["C2ISTAR - Task StopSaboteur - dialog registry missing"] call ALiVE_fnc_Dump;
        };
        private _dialogOption = +(selectRandom (_dialogOptions select 1));

        // %1 the town, %2 the building
        {
            private _dialog = [_dialogOption, _x] call ALIVE_fnc_hashGet;
            [_dialog, "title", format [[_dialog, "title"] call ALIVE_fnc_hashGet, _town, _buildingName]] call ALIVE_fnc_hashSet;
            [_dialog, "description", format [[_dialog, "description"] call ALIVE_fnc_hashGet, _town, _buildingName]] call ALIVE_fnc_hashSet;
        } forEach ["Parent", "Stop"];
        private _stopDialog = [_dialogOption, "Stop"] call ALIVE_fnc_hashGet;
        {
            private _chat = +([_stopDialog, _x] call ALIVE_fnc_hashGet);
            private _line = +(_chat select 0);
            _line set [1, format [_line select 1, _town, _buildingName]];
            _chat set [0, _line];
            [_stopDialog, _x, _chat] call ALIVE_fnc_hashSet;
        } forEach ["chat_start", "chat_success", "chat_failed"];

        private _state = if (_taskCurrent == "Y") then { "Assigned" } else { "Created" };
        private _tasks = [];
        private _taskIDs = [];

        private _dialog = [_dialogOption, "Parent"] call ALIVE_fnc_hashGet;
        _tasks pushBack [_taskID, _requestPlayerID, _taskSide, _targetPos, _taskFaction, [_dialog, "title"] call ALIVE_fnc_hashGet, [_dialog, "description"] call ALIVE_fnc_hashGet, _taskPlayers, _state, _taskApplyType, "N", "None", format ["%1-StopSaboteur-Parent", _taskID], false];
        _taskIDs pushBack _taskID;

        private _stopID = format ["%1_c1", _taskID];
        _tasks pushBack [_stopID, _requestPlayerID, _taskSide, _targetPos, _taskFaction, [_stopDialog, "title"] call ALIVE_fnc_hashGet, [_stopDialog, "description"] call ALIVE_fnc_hashGet, _taskPlayers, "Created", _taskApplyType, _taskCurrent, _taskID, format ["%1-StopSaboteur-Stop", _taskID], true];
        _taskIDs pushBack _stopID;

        private _taskParams = [] call ALIVE_fnc_hashCreate;
        [_taskParams, "nextTask", _stopID] call ALIVE_fnc_hashSet;
        [_taskParams, "taskIDs", _taskIDs] call ALIVE_fnc_hashSet;
        [_taskParams, "dialog", _dialogOption] call ALIVE_fnc_hashSet;
        [_taskParams, "targetPos", _targetPos] call ALIVE_fnc_hashSet;
        [_taskParams, "building", _building] call ALIVE_fnc_hashSet;
        [_taskParams, "saboteur", _man] call ALIVE_fnc_hashSet;
        [_taskParams, "charges", []] call ALIVE_fnc_hashSet;
        [_taskParams, "town", _town] call ALIVE_fnc_hashSet;
        [_taskParams, "lastState", ""] call ALIVE_fnc_hashSet;

        // his part: wait, walk in, plant, run, fire. Each step first checks he is still alive and free.
        private _script = [_man, _building, [_taskSide] call ALIVE_fnc_sideTextToObject, _taskParams, _isHeld] spawn {
            params ["_man", "_building", "_side", "_taskParams", "_isHeld"];
            private _free = { alive _man && {!([_man] call _isHeld)} };
            private _say = { ["C2ISTAR - Task StopSaboteur - %1", _this] call ALiVE_fnc_Dump };
            private _bPos = getPosATL _building;

            waitUntil {
                sleep 5;
                !(call _free) || {((allPlayers select { side (group _x) == _side }) findIf { (_x distance2D _bPos) < SAB_WAKE_RANGE }) > -1}
            };
            if !(call _free) exitWith {};

            // the way in: the building's first position, else its middle
            private _door = _building buildingPos 0;
            if (_door isEqualTo [0, 0, 0]) then { _door = _bPos };
            _man setVariable ["ALIVE_Task_SabPhase", "MOVE", true];
            _man setSpeedMode "LIMITED";
            format ["on the move, %1 m from the target", round (_man distance2D _bPos)] call _say;
            private _t = time;
            waitUntil {
                if (call _free) then { [_man, _door] call ALiVE_fnc_doMoveRemote };
                sleep 10;
                !(call _free) || {(_man distance2D _door) < 8} || {(time - _t) > 900}
            };
            if !(call _free) exitWith {};
            if ((_man distance2D _door) >= 8) exitWith {
                _man setVariable ["ALIVE_Task_SabPhase", "STUCK", true];
                format ["could not reach the target (%1 m short)", round (_man distance2D _door)] call _say;
            };

            _man setVariable ["ALIVE_Task_SabPhase", "PLANT", true];
            private _spots = _building buildingPos -1;
            if (_spots isEqualTo []) then { _spots = [_door] };
            private _charges = [];
            for "_i" from 1 to (3 min (count _spots)) do {
                if !(call _free) exitWith {};
                private _spot = _spots deleteAt (floor random count _spots);
                [_man, _spot] call ALiVE_fnc_doMoveRemote;
                private _t2 = time;
                waitUntil { sleep 1; !(call _free) || {(_man distance _spot) < 2.5} || {(time - _t2) > 25} };
                if !(call _free) exitWith {};
                [_man, "PutDown"] remoteExec ["playActionNow", _man];
                sleep 2;
                if !(call _free) exitWith {};
                private _c = "DemoCharge_Remote_Ammo_Scripted" createVehicle (getPosATL _man);
                _c setPosATL (getPosATL _man);
                _charges pushBack _c;
                [_taskParams, "charges", +_charges] call ALIVE_fnc_hashSet;
            };
            if !(call _free) exitWith {};
            format ["%1 charges planted", count _charges] call _say;

            // clear of the blast, then fire
            _man setVariable ["ALIVE_Task_SabPhase", "RUN", true];
            _man setSpeedMode "FULL";
            private _away = _bPos getPos [90 + random 40, (_bPos getDir _man) + 180 + (random 60 - 30)];
            _t = time;
            waitUntil {
                if (call _free) then { [_man, _away] call ALiVE_fnc_doMoveRemote };
                sleep 3;
                !(call _free) || {(_man distance2D _bPos) > 60} || {(time - _t) > 60}
            };
            if !(call _free) exitWith {};
            _man setVariable ["ALIVE_Task_SabPhase", "ARMED", true];
            _t = time;
            waitUntil { sleep 1; !(call _free) || {(time - _t) > 10} };
            if !(call _free) exitWith {};
            { if (!isNull _x) then { _x setDamage 1 } } forEach _charges;
            _man setVariable ["ALIVE_Task_SabPhase", "DETONATED", true];
            format ["detonated, building alive %1 damage %2", alive _building, damage _building] call _say;
        };
        [_taskParams, "script", _script] call ALIVE_fnc_hashSet;

        // the task can also go without its Stop stage running (deleted, or a different order asked of the commander):
        // then he and his charges go too, so no building blows up for a task nobody has
        [_taskID, _taskParams, _cleanup] spawn {
            params ["_taskID", "_taskParams", "_cleanup"];
            private _man = [_taskParams, "saboteur", objNull] call ALIVE_fnc_hashGet;
            private _seen = false;
            private _gone = false;
            waitUntil {
                sleep 10;
                private _listed = _taskID in (([ALiVE_TaskHandler, "tasks", ["", [], [], nil]] call ALIVE_fnc_hashGet) select 1);
                if (_listed) then { _seen = true };
                _gone = _seen && {!_listed};
                _gone || {isNull _man}
            };
            if (_gone) then { [_taskParams, false] call _cleanup };
        };

        ["C2ISTAR - Task StopSaboteur %1: %2 in %3, saboteur %4 m out", _taskID, _buildingName, _town, round (_start distance2D _targetPos)] call ALiVE_fnc_Dump;

        _result = [_tasks, _taskParams];
    };

    case "Parent": {
    };

    case "Stop": {
        _task params ["_taskID", "", "_taskSide", "_taskPosition", "_taskFaction", "", "", "_taskPlayers"];
        _taskPlayers = _taskPlayers select 0;

        private _lastState = [_params, "lastState", ""] call ALIVE_fnc_hashGet;
        private _currentTaskDialog = [[_params, "dialog"] call ALIVE_fnc_hashGet, "Stop"] call ALIVE_fnc_hashGet;
        private _man = [_params, "saboteur", objNull] call ALIVE_fnc_hashGet;
        private _building = [_params, "building", objNull] call ALIVE_fnc_hashGet;
        private _targetPos = [_params, "targetPos", _taskPosition] call ALIVE_fnc_hashGet;
        if (isNil "_man" || {!(_man isEqualType objNull)}) then { _man = objNull };
        if (isNil "_building" || {!(_building isEqualType objNull)}) then { _building = objNull };

        if (_lastState != "Stop") then {
            ["chat_start", _currentTaskDialog, _taskSide, _taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
            [_params, "lastState", "Stop"] call ALIVE_fnc_hashSet;
        };

        private _phase = if (isNull _man) then { "" } else { _man getVariable ["ALIVE_Task_SabPhase", ""] };
        private _end = "";
        switch (true) do {
            case (_phase == "DETONATED"): { _end = "Failed" };
            case (!isNull _building && {!alive _building || {damage _building >= 0.9}}): { _end = "Failed" };
            // removed, or a save loaded (objects do not survive one), or he never got there
            case (isNull _man): { _end = "Canceled" };
            case (_phase == "STUCK"): { _end = "Canceled" };
            case (!alive _man || {[_man] call _isHeld}): {
                // a kill or an arrest counts once a task player is there to see it
                private _sideObj = [_taskSide] call ALIVE_fnc_sideTextToObject;
                private _near = (allPlayers select { side (group _x) == _sideObj }) findIf {
                    (_x distance2D _man) < SAB_CONFIRM_RANGE || {(_x distance2D _targetPos) < SAB_CONFIRM_RANGE}
                };
                if (_near > -1) then { _end = "Succeeded" };
            };
        };
        if (_end == "") exitWith {};

        [_params, "nextTask", ""] call ALIVE_fnc_hashSet;
        _task set [8, _end];
        _task set [10, "N"];
        _result = _task;
        [_taskPlayers, _taskID] call ALIVE_fnc_taskDeleteMarkersForPlayers;
        ["C2ISTAR - Task StopSaboteur %1: %2 (phase %3)", _taskID, _end, _phase] call ALiVE_fnc_Dump;

        switch (_end) do {
            case "Succeeded": {
                // a held man stays put with the players; the charges, if any, are made safe
                if (alive _man) then {
                    doStop _man;
                    _man disableAI "MOVE";
                };
                [_params, false] call _cleanup;
                ["chat_success", _currentTaskDialog, _taskSide, _taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
                [_currentTaskDialog, _taskSide, _taskFaction] call ALIVE_fnc_taskCreateReward;
            };
            case "Failed": {
                [_params, false] call _cleanup;
                ["chat_failed", _currentTaskDialog, _taskSide, _taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
            };
            default {
                [_params, false] call _cleanup;
            };
        };
    };
};

_result
