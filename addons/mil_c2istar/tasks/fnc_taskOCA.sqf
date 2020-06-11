#include "\x\alive\addons\mil_C2ISTAR\script_component.hpp"
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

        private ["_startTime","_taskEnemySide","_targetSector","_targetEntity","_targetBuilding","_targetTypes","_blacklist","_tasksCurrent"];

        _task params [["_taskID", "", [""]], ["_requestPlayerID", "", [""]], ["_taskSide", "", [""]], ["_taskFaction", "", [""]], "", ["_taskLocationType", "", [""]],
            ["_taskLocation", "", [""]], ["_taskPlayers", [], [[]]], ["_taskEnemyFaction", "", [""]], ["_taskCurrent", "", [""]], ["_taskApplyType", "", [""]], ["_taskBuildings", [], [objNull]]
        ];

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

        if (count _targetBuildings < 4 && _taskLocationType == "NULL") exitwith {["C2ISTAR - Task OCA - Wrong input for _targetBuilding!"] call ALiVE_fnc_Dump};

		// TODO - find airfield and nearest hangar/runway/helipad and aircraft

        _taskEnemySide = _taskEnemyFaction call ALiVE_fnc_factionSide;
        _taskEnemySide = [_taskEnemySide] call ALIVE_fnc_sideObjectToNumber;
        _taskEnemySide = [_taskEnemySide] call ALIVE_fnc_sideNumberToText;

       // establish the location for the task
       // get enemy location based on input

        if ((count _targetBuildings < 4) && _taskLocationType in ["Short","Medium","Long"]) then {

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
                    private _OCAClusters = [] call ALiVE_fnc_hashCreate;
					
					private _player = [_requestPlayerID] call ALIVE_fnc_getPlayerByUID;
					
					if (isNull _player) then {
						_player = selectRandom (_taskPlayers select 0);
						_player = [_player] call ALIVE_fnc_getPlayerByUID;
					};
					
                    private _objectives = [_objectives, [getposATL _player], {_Input0 distance ([_x, "center"] call ALiVE_fnc_HashGet)}, "ASCEND"] call ALiVE_fnc_SortBy;

                    {
                        private _found = false;
                        private _clusterID = [_x, "clusterID"] call ALIVE_fnc_hashGet;
                        private _cluster = [ALiVE_clustersMil, _clusterID] call ALiVE_fnc_HashGet;

                        if !(isNil "_cluster") then {
                            private _size = [_cluster,"size", 150] call ALiVE_fnc_hashGet;
                            private _buildings = [_cluster,"nodes",[]] call ALiVE_fnc_HashGet;
                            _targetBuildings = [];
                            {
                                if ( (tolower(typeof _x) find "hangar") != -1 || (tolower(typeof _x) find "helipad") != -1) then {
                                    private _nearBuildings = (position _x) nearObjects ["House", _size/2];
                                    {
                                        _targetBuildings pushbackUnique _x;
                                    } foreach _nearBuildings;
                                    if (count _targetBuildings > 0) then {
                                        // ["C2ISTAR - Task OCA - cluster %1 has a %3, found buildings %2",_clusterID, _nearBuildings, _x] call ALiVE_fnc_Dump;
                                    };
                                };
                                if (count _targetBuildings > 3) exitWith {
                                    // ["C2ISTAR - Task OCA - OPCOM objective at cluster %1 target buildings: %2",_clusterID, _targetBuildings] call ALiVE_fnc_Dump;
                                    _found = true;
                                };
                            } foreach _buildings;
                        };
                        if (_found) then {
                            ["C2ISTAR - Task OCA - OPCOM objective at cluster %1 has %2 target buildings.",_clusterID, count _targetBuildings] call ALiVE_fnc_Dump;
                            [_OCAClusters, _clusterID, +(_targetBuildings)] call ALiVE_fnc_hashSet;
                        };
                    } foreach _objectives;


                    // Choose cluster
                    if (count (_OCAClusters select 1) > 1) then {

                        private _totalIndexes = (count (_OCAClusters select 1))-1;
                        private _index = 0;
                        switch (_taskLocationType) do {
                            case ("Short") : {_index = floor(_totalIndexes/ceil(_totalIndexes*0.8)); _index = floor(random _index)};
                            case ("Medium") : {_index = floor(_totalIndexes/ceil(_totalIndexes*0.5))};
                            case ("Long") : {_index = floor(_totalIndexes/ceil(_totalIndexes*0.1))};
                        };

                        _targetBuildings = [_OCAClusters, ((_OCAClusters select 1) select _index)] call ALiVE_fnc_hashGet;
                        private _cluster = [ALiVE_clustersMil, ((_OCAClusters select 1) select _index)] call ALiVE_fnc_HashGet;
                        _taskLocation = [_cluster,"center"] call ALiVE_fnc_hashGet;
                    };
                } else {
                    ["C2ISTAR - Task OCA - Currently there are no OPCOM objectives available!"] call ALiVE_fnc_Dump;
                };
            };
        };

        if (isnil "_taskLocation") exitwith {["C2ISTAR - Task OCA - No location selected!"] call ALiVE_fnc_Dump};

		//still no suitable buildings? fuck off...
        if (count _targetBuildings < 3) exitwith {["C2ISTAR - Task OCA - There are no buildings or objectives to attack!"] call ALiVE_fnc_Dump};

        private["_targetPosition","_targetID","_targetDisplayType"];

		private _targetBuilding = _targetBuildings select 0;
        _targetPosition = getposATL _targetBuilding;
        _targetID = str(floor(_targetPosition select 0)) + str(floor(_targetPosition select 1));
        _targetDisplayType = getText(configfile >> "CfgVehicles" >> (typeOf _targetBuilding) >> "displayName");

        ["C2ISTAR - Task OCA - Building: %1 | Type: %2 | Pos: %3!", _targetBuildings, _targetDisplayType, _targetPosition] call ALiVE_fnc_Dump;

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

        _allDestroyed = if ({!alive _x} count _targets > 2) then {true} else {false};

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
