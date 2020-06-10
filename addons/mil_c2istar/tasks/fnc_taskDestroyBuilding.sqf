#include "\x\alive\addons\mil_C2ISTAR\script_component.hpp"
SCRIPT(taskDestroyBuilding);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskDestroyBuilding

Description:
ATO Task

Parameters:

Returns:

Examples:
(begin example)
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_taskState","_taskID","_task","_params","_debug","_result","_nextState"];

_taskState = _this select 0;
_taskID = _this select 1;
_task = _this select 2;
_params = _this select 3;
_debug = _this select 4;
_result = [];

switch (_taskState) do {
    case "init":{

        private ["_startTime","_taskEnemySide","_targetSector","_targetEntity","_taskPlayers","_targetTypes","_blacklist"];

        private _taskID = [_task, 0, "", [""]] call BIS_fnc_param;
        private _requestPlayerID = [_task, 1, "", [""]] call BIS_fnc_param;
        private _taskSide = [_task, 2, "", [""]] call BIS_fnc_param;
        private _taskFaction = [_task, 3, "", [""]] call BIS_fnc_param;
        private _taskType = [_task, 4, "", [""]] call BIS_fnc_param;
        private _taskLocationType = [_task, 5, "", [""]] call BIS_fnc_param;
        private _taskLocation = [_task, 6, [], [[]]] call BIS_fnc_param;
        private _taskPlayers = [_task, 7, [], [[]]] call BIS_fnc_param;
        private _taskEnemyFaction = [_task, 8, "", [""]] call BIS_fnc_param;
        private _taskCurrent = [_task, 9, "", [""]] call BIS_fnc_param;
        private _taskApplyType = [_task, 10, "", [""]] call BIS_fnc_param;
        private _targetBuildings = [_task, 11, [], [objnull,[]]] call BIS_fnc_param;
        private _tasksCurrent = ([ALiVE_TaskHandler,"tasks",["",[],[],nil]] call ALiVE_fnc_HashGet) select 2;

        private _targetBuilding = switch (typeName _targetBuildings) do {
            case ("ARRAY") : {
                if (count _targetBuildings > 0) then {
                    _targetBuildings select 0
                } else {
                    nearestBuilding _taskLocation;
                };
            };
        };
        
        if (_debug) then {
            //Inputs
            ["ALIVE_fnc_taskDestroyBuilding Task inputs: %1 | %2 | %3 | %4 | %5 | %6 | %7 | %8 | %9 | %10 | %11 | %12",
                _taskID,
                _requestPlayerID,
                _taskSide,
                _taskFaction,
                _taskLocationType,
                _taskLocation,
                _taskPlayers,
                _taskEnemyFaction,
                _taskCurrent,
                _taskApplyType,
                _taskType,
                _targetBuilding
            ] call ALiVE_fnc_Dump;
        };

        if (_taskID == "") exitwith {["C2ISTAR - Task DestroyBuilding - Wrong input for _taskID!"] call ALiVE_fnc_Dump};
        if (_requestPlayerID == "") exitwith {["C2ISTAR - Task DestroyBuilding - Wrong input for _requestPlayerID!"] call ALiVE_fnc_Dump};
        if (_taskFaction == "") exitwith {["C2ISTAR - Task DestroyBuilding - Wrong input for _taskFaction!"] call ALiVE_fnc_Dump};
        if (_taskLocationType == "") exitwith {["C2ISTAR - Task DestroyBuilding - Wrong input for _taskLocationType!"] call ALiVE_fnc_Dump};
        if (count _taskLocation == 0) exitwith {["C2ISTAR - Task DestroyBuilding - Wrong input for _taskLocation!"] call ALiVE_fnc_Dump};
        if (count _taskPlayers == 0) exitwith {["C2ISTAR - Task DestroyBuilding - Wrong input for _taskPlayers!"] call ALiVE_fnc_Dump};
        if (_taskEnemyFaction == "") exitwith {["C2ISTAR - Task DestroyBuilding - Wrong input for _taskEnemyFaction!"] call ALiVE_fnc_Dump};
        if (_taskApplyType == "") exitwith {["C2ISTAR - Task DestroyBuilding - Wrong input for _taskApplyType!"] call ALiVE_fnc_Dump};
        if (!alive _targetBuilding) exitwith {["C2ISTAR - Task DestroyBuilding - Wrong input for _targetBuilding!"] call ALiVE_fnc_Dump};

        _taskEnemySide = _taskEnemyFaction call ALiVE_fnc_factionSide;
        _taskEnemySide = [_taskEnemySide] call ALIVE_fnc_sideObjectToNumber;
        _taskEnemySide = [_taskEnemySide] call ALIVE_fnc_sideNumberToText;

        // establish the location for the task
        // get enemy location based on input

        if (isnil "_taskLocation") exitwith {["C2ISTAR - Task DestroyBuilding - No location selected!"] call ALiVE_fnc_Dump};

        private["_targetPosition","_targetID","_targetDisplayType"];

        _targetPosition = getposATL _targetBuilding;
        _targetID = str(floor(_targetPosition select 0)) + str(floor(_targetPosition select 1));
        _targetDisplayType = getText(configfile >> "CfgVehicles" >> (typeOf _targetBuilding) >> "displayName");

        ["C2ISTAR - Task DestroyBuilding - Building: %1 | Type: %2 | Pos: %3!",_targetBuilding,_targetDisplayType,_targetPosition] call ALiVE_fnc_Dump;

        private["_stagingPosition","_dialogOptions","_dialogOption","_buildingType","_reward"];

        //["Sorting buildings by type and adding reward..."] call ALiVE_fnc_DumpR;
        private _points = 0;
        private _list = [];
        {
            private ["_object","_model"];

            _object = _x;
            _model = getText(configfile >> "CfgVehicles" >> typeOf _object >> "model");

            if (!(isnil "_object") && {!isNull _object}) then {

                {
                    private _type = _x select 0;
                    private _typeText = _x select 1;
                    private _points = _x select 2;
                    private _actType = missionNamespace getVariable _type;

                    if (
                        !(isnil "_actType") &&
                        {
                            {([toLower (_model), toLower _x] call CBA_fnc_find) > -1} count _actType > 0 ||
                            {{([toLower (typeOf _object), toLower _x] call CBA_fnc_find) > -1} count _actType > 0} //Remove when all indexes have been rebuilt with CLIT
                        }
                    ) exitwith {
                        _buildingType = _typeText;
                        _reward = _points;
                    };

                    _buildingType = "location";
                    _reward = 10;

                } foreach [
                    ["ALIVE_militaryHQBuildingTypes","HQ building",50],
                    ["ALIVE_militarySupplyBuildingTypes","military supply building",30],
                    ["ALIVE_militaryBuildingTypes","military building",20],
                    ["ALIVE_airBuildingTypes","air installation",30],
                    ["ALIVE_militaryAirBuildingTypes","military air installation",30],
                    ["ALIVE_civilianAirBuildingTypes","civilian air installation",20],
                    ["ALIVE_militaryHeliBuildingTypes","military rotary-wing installation",20],
                    ["ALIVE_civilianHeliBuildingTypes","civilian helicopter installation",20],
                    ["ALIVE_militaryParkingBuildingTypes","military logistics building",20],
                    ["ALIVE_civilianCommsBuildingTypes","communications site",30],
                    ["ALIVE_civilianHQBuildingTypes","civilian HQ building",50],
                    ["ALIVE_civilianPowerBuildingTypes","power supply building",30],
                    ["ALIVE_civilianMarineBuildingTypes","marine installation",20],
                    ["ALIVE_civilianFuelBuildingTypes","fuel supply building",30],
                    ["ALIVE_civilianPopulationBuildingTypes","civilian population building",10],
                    ["ALIVE_civilianRailBuildingTypes","rail constructions",30],
                    ["ALIVE_civilianConstructionBuildingTypes","construction site",10],
                    ["ALIVE_civilianSettlementBuildingTypes","civilian settlement building",10]
                ];
            };
        } foreach [_targetBuilding];

        // select the random text
        _dialogOptions = [ALIVE_generatedTasks,"DestroyBuilding"] call ALIVE_fnc_hashGet;
        _dialogOptions = _dialogOptions select 1;
        _dialogOption = +(selectRandom _dialogOptions);

        // format the dialog options
        private["_nearestTown","_dialog","_formatDescription","_formatChat","_formatMessage","_formatMessageText"];

        _nearestTown = [_targetPosition] call ALIVE_fnc_taskGetNearestLocationName;

        _dialog = [_dialogOption,"Destroy"] call ALIVE_fnc_hashGet;

        _formatChat = [_dialog,"chat_start"] call ALIVE_fnc_hashGet;
        _formatMessage = _formatChat select 0;
        _formatMessageText = _formatMessage select 1;
        _formatMessageText = format[_formatMessageText,_nearestTown,_targetDisplayType,_buildingType];
        _formatMessage set [1,_formatMessageText];
        _formatChat set [0,_formatMessage];
        [_dialog,"chat_start",_formatChat] call ALIVE_fnc_hashSet;

        // create the tasks
        private["_state","_tasks","_taskIDs","_dialog","_taskTitle","_taskDescription","_newTask","_newTaskID","_taskParams","_taskSource"];

        if(_taskCurrent == 'Y')then {
            _state = "Assigned";
        }else{
            _state = "Created";
        };

        _tasks = [];
        _taskIDs = [];

        // create the parent task
        _dialog = [_dialogOption,"Parent"] call ALIVE_fnc_hashGet;

        _taskTitle = [_dialog,"title"] call ALIVE_fnc_hashGet;
        _taskDescription = [_dialog,"description"] call ALIVE_fnc_hashGet;
        _taskSource = format["%1-DestroyBuilding-Parent",_taskID];

        _taskTitle = format[_taskTitle,_nearestTown];
        _taskDescription = format[_taskDescription,_nearestTown,_buildingType];
        _newTask = [_taskID,_requestPlayerID,_taskSide,_targetPosition,_taskFaction,_taskTitle,_taskDescription,_taskPlayers,_state,_taskApplyType,"N","None",_taskSource,false];

        _tasks pushback _newTask;
        _taskIDs pushback _taskID;

        // create the destroy task
        _dialog = [_dialogOption,"Destroy"] call ALIVE_fnc_hashGet;

        _taskTitle = [_dialog,"title"] call ALIVE_fnc_hashGet;
        _taskDescription = [_dialog,"description"] call ALIVE_fnc_hashGet;
        _newTaskID = format["%1_c2",_taskID];
        _taskSource = format["%1-DestroyBuilding-Destroy",_taskID];

        _taskTitle = format[_taskTitle,_buildingType];
        _taskDescription = format[_taskDescription,_nearestTown,_targetDisplayType,_buildingType];

        _newTask = [_newTaskID,_requestPlayerID,_taskSide,_targetPosition,_taskFaction,_taskTitle,_taskDescription,_taskPlayers,_state,_taskApplyType,_taskCurrent,_taskID,_taskSource,true];

        _tasks pushback _newTask;
        _taskIDs pushback _newTaskID;

        // store task data in the params for this task set
        _taskParams = [] call ALIVE_fnc_hashCreate;
        [_taskParams,"nextTask",_taskIDs select 1] call ALIVE_fnc_hashSet;
        [_taskParams,"taskIDs",_taskIDs] call ALIVE_fnc_hashSet;
        [_taskParams,"dialog",_dialogOption] call ALIVE_fnc_hashSet;
        [_taskParams,"enemyFaction",_taskEnemyFaction] call ALIVE_fnc_hashSet;
        [_taskParams,"targets",[_targetBuilding]] call ALIVE_fnc_hashSet;
        [_taskParams,"lastState",""] call ALIVE_fnc_hashSet;

        // return the created tasks and params
        _result = [_tasks,_taskParams];
    };
    case "Parent":{

    };
    case "Destroy":{

        private [
            "_taskID","_requestPlayerID","_taskSide","_taskPosition","_taskFaction","_taskTitle","_taskDescription","_taskPlayers",
            "_entityProfiles","_entitiesState","_allDestroyed","_lastState","_taskDialog","_vehicles","_currentTaskDialog","_targets",
            "_taskEnemyFaction","_taskEnemySide","_targetsState"
        ];

        _taskID = _task select 0;
        _requestPlayerID = _task select 1;
        _taskSide = _task select 2;
        _taskPosition = _task select 3;
        _taskFaction = _task select 4;
        _taskTitle = _task select 5;
        _taskDescription = _task select 6;
        _taskPlayers = _task select 7 select 0;

        _lastState = [_params,"lastState"] call ALIVE_fnc_hashGet;
        _taskDialog = [_params,"dialog"] call ALIVE_fnc_hashGet;
        _currentTaskDialog = [_taskDialog,_taskState] call ALIVE_fnc_hashGet;
        _targets = [_params,"targets"] call ALIVE_fnc_hashGet;

        if(_lastState != "Destroy") then {

            ["chat_start",_currentTaskDialog,_taskSide,_taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;

            [_params,"lastState","Destroy"] call ALIVE_fnc_hashSet;
        };

        _targetsState = [_targets] call ALIVE_fnc_taskGetStateOfObjects;
        _allDestroyed = [_targetsState,"allDestroyed"] call ALIVE_fnc_hashGet;

        if(_allDestroyed) then {

            [_params,"nextTask",""] call ALIVE_fnc_hashSet;

            _task set [8,"Succeeded"];
            _task set [10, "N"];
            _result = _task;

            [_taskPlayers,_taskID] call ALIVE_fnc_taskDeleteMarkersForPlayers;

            ["chat_success",_currentTaskDialog,_taskSide,_taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;

            [_currentTaskDialog,_taskSide,_taskFaction] call ALIVE_fnc_taskCreateReward;

        } else {

            private["_taskEnemyFaction","_taskEnemySide","_profiles","_position","_objectType"];

            _taskEnemyFaction = [_params,"enemyFaction"] call ALIVE_fnc_hashGet;
            _taskEnemySide = _taskEnemyFaction call ALiVE_fnc_factionSide;

            _targets = [_targetsState,"targets"] call ALIVE_fnc_hashGet;

            {
                _position = getposATL _x;
                _objectType = getText(configfile >> "CfgVehicles" >> (typeOf _x) >> "displayName");
                [_position,_taskEnemySide,_taskPlayers,_taskID,"building",_objectType] call ALIVE_fnc_taskCreateMarkersForPlayers;

            } forEach _targets;
        };

    };
};

_result
