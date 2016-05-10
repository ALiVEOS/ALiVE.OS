#include <\x\alive\addons\mil_C2ISTAR\script_component.hpp>
SCRIPT(taskInsurgencyDestroyAssets);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskInsurgencyDestroyAssets

Description:
Assault Task

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

	    private["_taskID","_requestPlayerID","_taskSide","_taskFaction","_taskLocationType","_taskLocation","_taskEnemyFaction","_taskCurrent",
	    "_taskApplyType","_taskEnemySide","_targetObjective","_targetPosition","_targetHQ","_targetDepot","_targetFactory","_targetBuildings",
	    "_taskPlayers","_selectedBuilding"];

        _taskID = _task select 0;
        _requestPlayerID = _task select 1;
        _taskSide = _task select 2;
        _taskFaction = _task select 3;
        _taskLocationType = _task select 5;
        _taskLocation = _task select 6;
        _taskPlayers = _task select 7;
        _taskEnemyFaction = _task select 8;
        _taskCurrent = _taskData select 9;
        _taskApplyType = _taskData select 10;

        if (_taskID == "") exitwith {["C2ISTAR - Task InsurgencyDestroyAssets - Wrong input for _taskID!"] call ALiVE_fnc_Dump};
        if (_requestPlayerID == "") exitwith {["C2ISTAR - Task InsurgencyDestroyAssets - Wrong input for _requestPlayerID!"] call ALiVE_fnc_Dump};
        if (_taskFaction == "") exitwith {["C2ISTAR - Task InsurgencyDestroyAssets - Wrong input for _taskFaction!"] call ALiVE_fnc_Dump};
        if (_taskLocationType == "") exitwith {["C2ISTAR - Task InsurgencyDestroyAssets - Wrong input for _taskLocationType!"] call ALiVE_fnc_Dump};
        if (count _taskLocation == 0) exitwith {["C2ISTAR - Task InsurgencyDestroyAssets - Wrong input for _taskLocation!"] call ALiVE_fnc_Dump};
        if (count _taskPlayers == 0) exitwith {["C2ISTAR - Task InsurgencyDestroyAssets - Wrong input for _taskPlayers!"] call ALiVE_fnc_Dump};
        if (_taskEnemyFaction == "") exitwith {["C2ISTAR - Task InsurgencyDestroyAssets - Wrong input for _taskEnemyFaction!"] call ALiVE_fnc_Dump};
        if (_taskApplyType == "") exitwith {["C2ISTAR - Task InsurgencyDestroyAssets - Wrong input for _taskApplyType!"] call ALiVE_fnc_Dump};

        _taskEnemySide = _taskEnemyFaction call ALiVE_fnc_factionSide;
        _taskEnemySide = [_taskEnemySide] call ALIVE_fnc_sideObjectToNumber;
        _taskEnemySide = [_taskEnemySide] call ALIVE_fnc_sideNumberToText;

        // establish the location for the task
        // get insurgency objective

        _targetObjective = [_taskLocation,_taskLocationType,_taskEnemySide] call ALIVE_fnc_taskGetInsurgencyLocation;

        if(count _targetObjective == 0) exitwith {["C2ISTAR - Task InsurgencyDestroyAssets - No targets found!"] call ALiVE_fnc_Dump};

        _targetObjective call ALIVE_fnc_inspectArray;
        _targetPosition = _targetObjective select 1;
        _targetHQ = _targetObjective select 3;
        _targetDepot = _targetObjective select 4;
        _targetFactory = _targetObjective select 5;

		// ["pl %1 tar %2",getpos player, _targetPosition] call ALiVE_fnc_DumpR;

		if(count _targetPosition == 0) exitwith {["C2ISTAR - Task InsurgencyDestroyAssets - No targets found!"] call ALiVE_fnc_Dump};

		if(count _targetPosition == 0) exitwith {["C2ISTAR - Task InsurgencyDestroyAssets - No targets found!"] call ALiVE_fnc_Dump};

		if(count _targetHQ == 0 && count _targetDepot == 0 && count _targetFactory == 0) exitwith {["C2ISTAR - Task InsurgencyDestroyAssets - No targets found!"] call ALiVE_fnc_Dump};

		_targetBuildings = [];

		if(count _targetHQ > 0) then {
            _targetBuilding = [];
            _targetBuilding pushBack ["Recruitment HQ",_targetHQ];
            _targetBuildings pushBack _targetBuilding;
        };

        if(count _targetDepot > 0) then {
            _targetBuilding = [];
            _targetBuilding pushBack ["Arms Cache",_targetDepot];
            _targetBuildings pushBack _targetBuilding;
        };

        if(count _targetFactory > 0) then {
            _targetBuilding = [];
            _targetBuilding pushBack ["IED Factory",_targetFactory];
            _targetBuildings pushBack _targetBuilding;
        };

        _selectedBuilding = _targetBuildings call BIS_fnc_selectRandom;
        _selectedBuilding = _selectedBuilding select 0;

        _selectedBuilding call ALIVE_fnc_inspectArray;

        if!(isNil "_selectedBuilding") then {

            private["_targetBuildingType","_targetBuildingPosition","_targetBuilding"];

            _targetBuildingType = _selectedBuilding select 0;
            _targetBuildingPosition = _selectedBuilding select 1 select 0;
            _targetBuilding = _selectedBuilding select 1 select 1;

            _targetBuilding = nearestObject [_targetBuildingPosition,_targetBuilding];

            private["_dialogOptions","_dialogOption"];

            // select the random text

            _dialogOptions = [ALIVE_generatedTasks,"InsurgencyDestroyAssets"] call ALIVE_fnc_hashGet;
            _dialogOptions = _dialogOptions select 1;
            _dialogOption = _dialogOptions call BIS_fnc_selectRandom;

            // format the dialog options

            private["_nearestTown","_dialog","_formatTitle","_formatDescription","_formatChat","_formatMessage","_formatMessageText"];

            _nearestTown = [_targetBuildingPosition] call ALIVE_fnc_taskGetNearestLocationName;

            _dialog = [_dialogOption,"Parent"] call ALIVE_fnc_hashGet;

            _formatTitle = [_dialog,"title"] call ALIVE_fnc_hashGet;
            _formatTitle = format[_formatTitle,_targetBuildingType];
            [_dialog,"title",_formatTitle] call ALIVE_fnc_hashSet;

            _formatDescription = [_dialog,"description"] call ALIVE_fnc_hashGet;
            _formatDescription = format[_formatDescription,_targetBuildingType,_nearestTown];
            [_dialog,"description",_formatDescription] call ALIVE_fnc_hashSet;


            _dialog = [_dialogOption,"Destroy"] call ALIVE_fnc_hashGet;

            _formatTitle = [_dialog,"title"] call ALIVE_fnc_hashGet;
            _formatTitle = format[_formatTitle,_targetBuildingType];
            [_dialog,"title",_formatTitle] call ALIVE_fnc_hashSet;

            _formatDescription = [_dialog,"description"] call ALIVE_fnc_hashGet;
            _formatDescription = format[_formatDescription,_targetBuildingType,_nearestTown];
            [_dialog,"description",_formatDescription] call ALIVE_fnc_hashSet;

            _formatChat = [_dialog,"chat_start"] call ALIVE_fnc_hashGet;
            _formatMessage = _formatChat select 0;
            _formatMessageText = _formatMessage select 1;
            _formatMessageText = format[_formatMessageText,_targetBuildingType,_nearestTown];
            _formatMessage set [1,_formatMessageText];
            _formatChat set [0,_formatMessage];
            [_dialog,"chat_start",_formatChat] call ALIVE_fnc_hashGet;

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
            _taskSource = format["%1-InsurgencyDestroyAssets-Parent",_taskID];
            _newTask = [_taskID,_requestPlayerID,_taskSide,_targetBuildingPosition,_taskFaction,_taskTitle,_taskDescription,_taskPlayers,_state,_taskApplyType,"N","None",_taskSource,false];

            _tasks set [count _tasks,_newTask];
            _taskIDs set [count _taskIDs,_taskID];

            // create the destroy task

            _dialog = [_dialogOption,"Destroy"] call ALIVE_fnc_hashGet;
            _taskTitle = [_dialog,"title"] call ALIVE_fnc_hashGet;
            _taskDescription = [_dialog,"description"] call ALIVE_fnc_hashGet;
            _newTaskID = format["%1_c2",_taskID];
            _taskSource = format["%1-InsurgencyDestroyAssets-Destroy",_taskID];

            _taskTitle = format[_taskTitle,_nearestTown];
            _taskDescription = format[_taskDescription,_nearestTown];

            _newTask = [_newTaskID,_requestPlayerID,_taskSide,_targetBuildingPosition,_taskFaction,_taskTitle,_taskDescription,_taskPlayers,"Created",_taskApplyType,_taskCurrent,_taskID,_taskSource,true];

            _tasks set [count _tasks,_newTask];
            _taskIDs set [count _taskIDs,_newTaskID];

            // store task data in the params for this task set

            _taskParams = [] call ALIVE_fnc_hashCreate;
            [_taskParams,"nextTask",_taskIDs select 1] call ALIVE_fnc_hashSet;
            [_taskParams,"taskIDs",_taskIDs] call ALIVE_fnc_hashSet;
            [_taskParams,"dialog",_dialogOption] call ALIVE_fnc_hashSet;
            [_taskParams,"enemyFaction",_taskEnemyFaction] call ALIVE_fnc_hashSet;
            [_taskParams,"targets",[_targetBuilding]] call ALIVE_fnc_hashSet;
            [_taskParams,"targetTypes",[_targetBuildingType]] call ALIVE_fnc_hashSet;
            [_taskParams,"lastState",""] call ALIVE_fnc_hashSet;

            // return the created tasks and params

            _result = [_tasks,_taskParams];

        };

	};
	case "Parent":{

    };
    case "Destroy":{

        private["_taskID","_requestPlayerID","_taskSide","_taskPosition","_taskFaction","_taskTitle","_taskDescription","_taskPlayers",
        "_lastState","_taskDialog","_currentTaskDialog","_targets","_targetTypes","_targetsState","_allDestroyed","_taskEnemyFaction",
        "_taskEnemySide","_targets","_position"];

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
        _targetTypes = [_params,"targetTypes"] call ALIVE_fnc_hashGet;

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

            /*
            private["_taskEnemyFaction","_taskEnemySide","_profiles","_position","_objectType"];

            _taskEnemyFaction = [_params,"enemyFaction"] call ALIVE_fnc_hashGet;
            _taskEnemySide = _taskEnemyFaction call ALiVE_fnc_factionSide;

            _targets = [_targetsState,"targets"] call ALIVE_fnc_hashGet;

            {
                _position = getposATL _x;
                _objectType = _targetTypes select _forEachIndex;
                [_position,_taskEnemySide,_taskPlayers,_taskID,"building",_objectType] call ALIVE_fnc_taskCreateMarkersForPlayers;

            } forEach _targets;
            */
        };

    };
};

_result