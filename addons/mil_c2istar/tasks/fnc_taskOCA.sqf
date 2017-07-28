#include <\x\alive\addons\mil_C2ISTAR\script_component.hpp>
SCRIPT(taskOCA);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskOCA
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

        private [
            "_taskID","_requestPlayerID","_taskSide","_taskFaction","_taskLocationType","_taskLocation","_taskEnemyFaction","_taskCurrent",
            "_taskApplyType","_startTime","_taskEnemySide","_targetSector","_targetEntity","_taskPlayers","_targetBuilding","_targetBuildings",
            "_targetTypes","_blacklist","_tasksCurrent"
        ];

        _taskID = [_task, 0, "", [""]] call BIS_fnc_param;
        _requestPlayerID = [_task, 1, "", [""]] call BIS_fnc_param;
        _taskSide = [_task, 2, "", [""]] call BIS_fnc_param;
        _taskFaction = [_task, 3, "", [""]] call BIS_fnc_param;
        _taskLocationType = [_task, 5, "", [""]] call BIS_fnc_param;
        _taskLocation = [_task, 6, [], [[]]] call BIS_fnc_param;
        _taskPlayers = [_task, 7, [], [[]]] call BIS_fnc_param;
        _taskEnemyFaction = [_task, 8, "", [""]] call BIS_fnc_param;
        _taskCurrent = [_taskData, 9, "", [""]] call BIS_fnc_param;
        _taskApplyType = [_taskData, 10, "", [""]] call BIS_fnc_param;
        _targetBuildings = [_taskData, 11, [], [objnull]] call BIS_fnc_param;

        _tasksCurrent = ([ALiVE_TaskHandler,"tasks",["",[],[],nil]] call ALiVE_fnc_HashGet) select 2;

        /*
        //Inputs
        ["%1 | %2 | %3 | %4 | %5 | %6 | %7 | %8 | %9 | %10",
            _taskID,
            _requestPlayerID,
            _taskSide,
            _taskFaction,
            _taskLocationType,
            _taskLocation,
            _taskPlayers,
            _taskEnemyFaction,
            _taskCurrent,
            _taskApplyType
        ] call ALiVE_fnc_Dump;
        */

        if (_taskID == "") exitwith {["C2ISTAR - Task OCA - Wrong input for _taskID!"] call ALiVE_fnc_Dump};
        if (_requestPlayerID == "") exitwith {["C2ISTAR - Task OCA - Wrong input for _requestPlayerID!"] call ALiVE_fnc_Dump};
        if (_taskFaction == "") exitwith {["C2ISTAR - Task OCA - Wrong input for _taskFaction!"] call ALiVE_fnc_Dump};
        if (_taskLocationType == "") exitwith {["C2ISTAR - Task OCA - Wrong input for _taskLocationType!"] call ALiVE_fnc_Dump};
        if (count _taskLocation == 0) exitwith {["C2ISTAR - Task OCA - Wrong input for _taskLocation!"] call ALiVE_fnc_Dump};
        if (count _taskPlayers == 0) exitwith {["C2ISTAR - Task OCA - Wrong input for _taskPlayers!"] call ALiVE_fnc_Dump};
        if (_taskEnemyFaction == "") exitwith {["C2ISTAR - Task OCA - Wrong input for _taskEnemyFaction!"] call ALiVE_fnc_Dump};
        if (_taskApplyType == "") exitwith {["C2ISTAR - Task OCA - Wrong input for _taskApplyType!"] call ALiVE_fnc_Dump};
        
        if (count _targetBuildings < 5 && _taskLocationType == "NULL") exitwith {["C2ISTAR - Task OCA - Wrong input for _targetBuilding!"] call ALiVE_fnc_Dump};

		// TODO - find airfield and nearest hangar/runway/helipad and aircraft
		
        _taskEnemySide = _taskEnemyFaction call ALiVE_fnc_factionSide;
        _taskEnemySide = [_taskEnemySide] call ALIVE_fnc_sideObjectToNumber;
        _taskEnemySide = [_taskEnemySide] call ALIVE_fnc_sideNumberToText;

       // establish the location for the task
       // get enemy location based on input

        if ((count _targetBuildings < 5) && _taskLocationType in ["Short","Medium","Long"]) then {

            if (!isnil "OPCOM_instances") then {

                //["Selecting Task location from OPCOMs"] call ALiVE_fnc_DumpR;
                private _triggerStates = ["defend","defending","reserve","reserving","idle","unassigned"];
                private _objectives = [];
                {
                    private _OPCOM = _x;
                    private _OPCOM_factions = [_OPCOM,"factions",""] call ALiVE_fnc_HashGet;
                    private _OPCOM_side = [_OPCOM,"side",""] call ALiVE_fnc_HashGet;

                    //["Looking up correct OPCOM %1 for faction %2",_OPCOM_factions,_taskEnemyFaction] call ALiVE_fnc_DumpR;
                    if ({_x == _taskEnemyFaction} count _OPCOM_factions > 0) then {
                        private _OPCOM_objectives = [_OPCOM,"objectives",[]] call ALiVE_fnc_HashGet;

                        //["Looking up correct ones in %1 objectives for faction %2",count _OPCOM_objectives,_taskEnemyFaction] call ALiVE_fnc_DumpR;
                        {
                            private _OPCOM_objective = _x;
                            private _OPCOM_objective_state = [_OPCOM_objective,"opcom_state",""] call ALiVE_fnc_HashGet;
                            private _OPCOM_objective_center = [_OPCOM_objective,"center",[0,0,0]] call ALiVE_fnc_HashGet;

                            //["Matching state %1 in triggerstates %2 tasks %3 faction %4!",_OPCOM_objective_state,_triggerStates,_tasksCurrent,_taskFaction] call ALiVE_fnc_DumpR;
                            if (
                                    _OPCOM_objective_state in _triggerStates &&
                                    {(({(_x select 4) == _taskFaction && {(_x select 3) distance _OPCOM_objective_center < 500}} count _tasksCurrent) == 0)}
                            ) then {
                                    _objectives pushback _OPCOM_objective;
                            };
                        } foreach _OPCOM_objectives;
                    };
                } foreach OPCOM_instances;

                if (count _objectives > 0) then {
                    private _objectives = [_objectives,[getposATL _player],{_Input0 distance ([_x,"center"] call ALiVE_fnc_HashGet)},"ASCEND",{

                        private _id = [_x,"opcomID",""] call ALiVE_fnc_HashGet;
                        private _pos = [_x,"center"] call ALiVE_fnc_HashGet;
                        private _opcom = [objNull,"getOPCOMbyid",_id] call ALiVE_fnc_OPCOM;
                        private _side = [_opcom,"side",""] call ALiVE_fnc_HashGet;

                        !([_pos,_side,500,true] call ALiVE_fnc_isEnemyNear);
                    }] call ALiVE_fnc_SortBy;

                    private _totalIndexes = (count _objectives)-1;
                    private _index = 0;

                    if (count _objectives > 1) then {
                        switch (_taskLocationType) do {
                            case ("Short") : {_index = floor(_totalIndexes/ceil(_totalIndexes*0.8)); _index = floor(random _index)};
                            case ("Medium") : {_index = floor(_totalIndexes/ceil(_totalIndexes*0.5))};
                            case ("Long") : {_index = floor(_totalIndexes/ceil(_totalIndexes*0.1))};
                        };
                    };

                    private _taskLocation = [_objectives select _index,"center"] call ALiVE_fnc_HashGet;
                    private _clusterID = [_objectives select _index,"clusterID",""] call ALiVE_fnc_HashGet;
                    private _type = [_objectives select _index,"objectiveType",""] call ALiVE_fnc_HashGet;

                    _targetTypes = [
                        "ALIVE_clustersMilAir",
                        "ALIVE_clustersMilHeli"
                    ];

                    {
                        private _clusters = _x;

                        if (!(isnil {call compile _clusters}) && {_clusterID in ((call compile _clusters) select 1)}) then {

                            private _cluster = [call compile _clusters,_clusterID] call ALiVE_fnc_HashGet;
                            private _clusterLocation = [_cluster,"center"] call ALiVE_fnc_HashGet;

                            _clusterLocation resize 2;
                            _taskLocation resize 2;

                            if (_clusterLocation distance _taskLocation < 15) exitwith {

                                _targetBuildings = +([_cluster,"nodes",[]] call ALiVE_fnc_HashGet);
                                
								{ // ADD RUNWAY, HELIPAD, HANGAR
									if !(_x isKindOf "House_F") then {_targetBuildings set [_foreachIndex,objNull]};
                                } foreach _targetBuildings;
                                
                                _targetBuildings = _targetBuildings - [objNull];
                            };
                        };

                        if (!isnil "_targetBuildings" && {count _targetBuildings > 4}) exitwith {};
                    } foreach _targetTypes;

                    ["C2ISTAR - Task OCA - OPCOM index %2 selected as objective at position %1",_taskLocation,_index] call ALiVE_fnc_Dump;
                    ["C2ISTAR - Task OCA - Buildings in %3 cluster %2: %1",_targetBuildings,_clusterID,_type] call ALiVE_fnc_Dump;
                } else {
                    ["C2ISTAR - Task OCA - Currently there are no OPCOM objectives available, using map locations!"] call ALiVE_fnc_Dump;

                    _taskLocation = position (selectRandom (nearestLocations [getArray (configFile >> "CfgWorlds" >> worldName >> "centerPosition"), ["Airport"], 30000]));
                };
            };
        };

        if (isnil "_taskLocation") exitwith {["C2ISTAR - Task OCA - No location selected!"] call ALiVE_fnc_Dump};

		//still no suitable buildings? fuck off...
        if (count _targetBuildings == 0) exitwith {["C2ISTAR - Task OCA - There are no buildings to attack at the target area!"] call ALiVE_fnc_Dump};

        private["_targetPosition","_targetID","_targetDisplayType"];

		private _targetBuilding = _targetBuildings select 0;
        _targetPosition = getposATL _targetBuilding;
        _targetID = str(floor(_targetPosition select 0)) + str(floor(_targetPosition select 1));
        _targetDisplayType = getText(configfile >> "CfgVehicles" >> (typeOf _targetBuilding) >> "displayName");

        ["C2ISTAR - Task OCA - Building: %1 | Type: %2 | Pos: %3!",_targetBuildings,_targetDisplayType,_targetPosition] call ALiVE_fnc_Dump;

        private["_stagingPosition","_dialogOptions","_dialogOption","_buildingType","_reward"];

        // select the random text
        _dialogOptions = [ALIVE_generatedTasks,"OCA"] call ALIVE_fnc_hashGet;
        _dialogOptions = _dialogOptions select 1;
        _dialogOption = +(selectRandom _dialogOptions);

        // format the dialog options
        private["_nearestTown","_dialog","_formatDescription","_formatChat","_formatMessage","_formatMessageText"];

        _nearestTown = [_targetPosition] call ALIVE_fnc_taskGetNearestLocationName;

        _dialog = [_dialogOption,"Destroy"] call ALIVE_fnc_hashGet;

        _formatChat = [_dialog,"chat_start"] call ALIVE_fnc_hashGet;
        _formatMessage = _formatChat select 0;
        _formatMessageText = _formatMessage select 1;
        _formatMessageText = format[_formatMessageText,_nearestTown];
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
        _taskSource = format["%1-OCA-Parent",_taskID];

        _taskTitle = format[_taskTitle,_nearestTown];
        _taskDescription = format[_taskDescription,_nearestTown];
        _newTask = [_taskID,_requestPlayerID,_taskSide,_targetPosition,_taskFaction,_taskTitle,_taskDescription,_taskPlayers,_state,_taskApplyType,"N","None",_taskSource,false];

        _tasks pushback _newTask;
        _taskIDs pushback _taskID;

        // create the destroy task
        _dialog = [_dialogOption,"Destroy"] call ALIVE_fnc_hashGet;

        _taskTitle = [_dialog,"title"] call ALIVE_fnc_hashGet;
        _taskDescription = [_dialog,"description"] call ALIVE_fnc_hashGet;
        _newTaskID = format["%1_c2",_taskID];
        _taskSource = format["%1-OCA-Destroy",_taskID];

        _taskTitle = format[_taskTitle,_nearestTown];
        _taskDescription = format[_taskDescription,_nearestTown];

        _newTask = [_newTaskID,_requestPlayerID,_taskSide,_targetPosition,_taskFaction,_taskTitle,_taskDescription,_taskPlayers,_state,_taskApplyType,_taskCurrent,_taskID,_taskSource,true];

        _tasks pushback _newTask;
        _taskIDs pushback _newTaskID;

        // store task data in the params for this task set
        _taskParams = [] call ALIVE_fnc_hashCreate;
        [_taskParams,"nextTask",_taskIDs select 1] call ALIVE_fnc_hashSet;
        [_taskParams,"taskIDs",_taskIDs] call ALIVE_fnc_hashSet;
        [_taskParams,"dialog",_dialogOption] call ALIVE_fnc_hashSet;
        [_taskParams,"enemyFaction",_taskEnemyFaction] call ALIVE_fnc_hashSet;
        [_taskParams,"targets",_targetBuildings] call ALIVE_fnc_hashSet;
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

        _targetsState = if ([!alive _x] count _targets > 4) then {true} else {false};
        _allDestroyed = [_targetsState,"allDestroyed"] call ALIVE_fnc_hashGet;

        if(_allDestroyed) then {

            [_params,"nextTask",""] call ALIVE_fnc_hashSet;

            _task set [8,"Succeeded"];
            _task set [10, "N"];
            _result = _task;

            [_taskPlayers,_taskID] call ALIVE_fnc_taskDeleteMarkersForPlayers;

            ["chat_success",_currentTaskDialog,_taskSide,_taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;

            [_currentTaskDialog,_taskSide,_taskFaction] call ALIVE_fnc_taskCreateReward;

        };

    };
};

_result
