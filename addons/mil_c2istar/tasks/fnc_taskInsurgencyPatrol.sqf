#include <\x\alive\addons\mil_C2ISTAR\script_component.hpp>
SCRIPT(taskInsurgencyPatrol);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskInsurgencyPatrol

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
	    "_taskApplyType","_taskEnemySide","_targetObjective","_targetPosition","_taskPlayers"];

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

        if (_taskID == "") exitwith {["C2ISTAR - Task InsurgencyPatrol - Wrong input for _taskID!"] call ALiVE_fnc_Dump};
        if (_requestPlayerID == "") exitwith {["C2ISTAR - Task InsurgencyPatrol - Wrong input for _requestPlayerID!"] call ALiVE_fnc_Dump};
        if (_taskFaction == "") exitwith {["C2ISTAR - Task InsurgencyPatrol - Wrong input for _taskFaction!"] call ALiVE_fnc_Dump};
        if (_taskLocationType == "") exitwith {["C2ISTAR - Task InsurgencyPatrol - Wrong input for _taskLocationType!"] call ALiVE_fnc_Dump};
        if (count _taskLocation == 0) exitwith {["C2ISTAR - Task InsurgencyPatrol - Wrong input for _taskLocation!"] call ALiVE_fnc_Dump};
        if (count _taskPlayers == 0) exitwith {["C2ISTAR - Task InsurgencyPatrol - Wrong input for _taskPlayers!"] call ALiVE_fnc_Dump};
        if (_taskEnemyFaction == "") exitwith {["C2ISTAR - Task InsurgencyPatrol - Wrong input for _taskEnemyFaction!"] call ALiVE_fnc_Dump};
        if (_taskApplyType == "") exitwith {["C2ISTAR - Task InsurgencyPatrol - Wrong input for _taskApplyType!"] call ALiVE_fnc_Dump};

        _taskEnemySide = _taskEnemyFaction call ALiVE_fnc_factionSide;
        _taskEnemySide = [_taskEnemySide] call ALIVE_fnc_sideObjectToNumber;
        _taskEnemySide = [_taskEnemySide] call ALIVE_fnc_sideNumberToText;

        // establish the location for the task
        // get insurgency objective

        _targetObjective = [_taskLocation,_taskLocationType,_taskEnemySide] call ALIVE_fnc_taskGetInsurgencyLocation;

        if(count _targetObjective == 0) exitwith {["C2ISTAR - Task InsurgencyPatrol - No targets found!"] call ALiVE_fnc_Dump};

        _targetObjective call ALIVE_fnc_inspectArray;
        _targetPosition = _targetObjective select 1;

		// ["pl %1 tar %2",getpos player, _targetPosition] call ALiVE_fnc_DumpR;

		if(count _targetPosition == 0) exitwith {["C2ISTAR - Task InsurgencyPatrol - No targets found!"] call ALiVE_fnc_Dump};

        if!(isNil "_targetPosition") then {

            private["_stagingPosition","_dialogOptions","_dialogOption"];

            // establish the staging position for the task

            _stagingPosition = [_targetPosition,"overwatch"] call ALIVE_fnc_taskGetSectorPosition;

            // select the random text

            _dialogOptions = [ALIVE_generatedTasks,"InsurgencyPatrol"] call ALIVE_fnc_hashGet;
            _dialogOptions = _dialogOptions select 1;
            _dialogOption = _dialogOptions call BIS_fnc_selectRandom;

            // format the dialog options

            private["_nearestTown","_dialog","_formatDescription","_formatChat","_formatMessage","_formatMessageText"];

            _nearestTown = [_targetPosition] call ALIVE_fnc_taskGetNearestLocationName;

            _dialog = [_dialogOption,"Travel"] call ALIVE_fnc_hashGet;

            _formatDescription = [_dialog,"description"] call ALIVE_fnc_hashGet;
            _formatDescription = format[_formatDescription,_nearestTown];
            [_dialog,"description",_formatDescription] call ALIVE_fnc_hashSet;

            _formatChat = [_dialog,"chat_start"] call ALIVE_fnc_hashGet;
            _formatMessage = _formatChat select 0;
            _formatMessageText = _formatMessage select 1;
            _formatMessageText = format[_formatMessageText,_nearestTown];
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
            _taskSource = format["%1-InsurgencyPatrol-Parent",_taskID];
            _newTask = [_taskID,_requestPlayerID,_taskSide,_targetPosition,_taskFaction,_taskTitle,_taskDescription,_taskPlayers,_state,_taskApplyType,"N","None",_taskSource,false];

            _tasks set [count _tasks,_newTask];
            _taskIDs set [count _taskIDs,_taskID];

            // create the travel task

            _dialog = [_dialogOption,"Travel"] call ALIVE_fnc_hashGet;
            _taskTitle = [_dialog,"title"] call ALIVE_fnc_hashGet;
            _taskDescription = [_dialog,"description"] call ALIVE_fnc_hashGet;
            _newTaskID = format["%1_c1",_taskID];
            _taskSource = format["%1-InsurgencyPatrol-Travel",_taskID];
            _newTask = [_newTaskID,_requestPlayerID,_taskSide,_stagingPosition,_taskFaction,_taskTitle,_taskDescription,_taskPlayers,_state,_taskApplyType,_taskCurrent,_taskID,_taskSource,false];

            _tasks set [count _tasks,_newTask];
            _taskIDs set [count _taskIDs,_newTaskID];

            // create the patrol task

            _dialog = [_dialogOption,"Patrol"] call ALIVE_fnc_hashGet;
            _taskTitle = [_dialog,"title"] call ALIVE_fnc_hashGet;
            _taskDescription = [_dialog,"description"] call ALIVE_fnc_hashGet;
            _newTaskID = format["%1_c2",_taskID];
            _taskSource = format["%1-InsurgencyPatrol-Patrol",_taskID];

            _taskTitle = format[_taskTitle,_nearestTown];
            _taskDescription = format[_taskDescription,_nearestTown];

            _newTask = [_newTaskID,_requestPlayerID,_taskSide,_targetPosition,_taskFaction,_taskTitle,_taskDescription,_taskPlayers,"Created",_taskApplyType,"N",_taskID,_taskSource,true];

            _tasks set [count _tasks,_newTask];
            _taskIDs set [count _taskIDs,_newTaskID];

            // store task data in the params for this task set

            _taskParams = [] call ALIVE_fnc_hashCreate;
            [_taskParams,"nextTask",_taskIDs select 1] call ALIVE_fnc_hashSet;
            [_taskParams,"taskIDs",_taskIDs] call ALIVE_fnc_hashSet;
            [_taskParams,"dialog",_dialogOption] call ALIVE_fnc_hashSet;
            [_taskParams,"enemyFaction",_taskEnemyFaction] call ALIVE_fnc_hashSet;
            [_taskParams,"supriseCreated",false] call ALIVE_fnc_hashSet;
            [_taskParams,"lastState",""] call ALIVE_fnc_hashSet;

            // return the created tasks and params

            _result = [_tasks,_taskParams];

        };

	};
	case "Parent":{

    };
	case "Travel":{

	    private["_taskID","_requestPlayerID","_taskSide","_taskPosition","_taskFaction","_taskTitle","_taskDescription","_taskPlayers",
	    "_destinationReached","_taskIDs","_lastState","_taskDialog","_currentTaskDialog"];

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

        if(_lastState != "Travel") then {

            ["chat_start",_currentTaskDialog,_taskSide,_taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;

            [_params,"lastState","Travel"] call ALIVE_fnc_hashSet;
        };

        _destinationReached = [_taskPosition,_taskPlayers,500] call ALIVE_fnc_taskHavePlayersReachedDestination;

        if(_destinationReached) then {

            _taskIDs = [_params,"taskIDs"] call ALIVE_fnc_hashGet;
            [_params,"nextTask",_taskIDs select 2] call ALIVE_fnc_hashSet;

            _task set [8,"Succeeded"];
            _task set [10, "N"];
            _result = _task;

        };

    };
    case "Patrol":{

        private["_taskID","_requestPlayerID","_taskSide","_taskPosition","_taskFaction","_taskTitle","_taskDescription","_taskPlayers",
        "_areaClear","_lastState","_taskDialog","_supriseCreated","_supriseCreated","_currentTaskDialog","_taskEnemyFaction","_taskEnemySide"];

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
        _supriseCreated = [_params,"supriseCreated"] call ALIVE_fnc_hashGet;
        _currentTaskDialog = [_taskDialog,_taskState] call ALIVE_fnc_hashGet;

        if(_lastState != "Patrol") then {

            ["chat_start",_currentTaskDialog,_taskSide,_taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;

            [_params,"lastState","Patrol"] call ALIVE_fnc_hashSet;
        };

        _areaClear = [_taskPosition,_taskPlayers,_taskSide,500] call ALIVE_fnc_taskIsAreaClearOfEnemies;

        if(_areaClear) then {

            [_params,"nextTask",""] call ALIVE_fnc_hashSet;

            _task set [8,"Succeeded"];
            _task set [10, "N"];
            _result = _task;

            ["chat_success",_currentTaskDialog,_taskSide,_taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;

            [_currentTaskDialog,_taskSide,_taskFaction] call ALIVE_fnc_taskCreateReward;

        }else{

            private["_taskEnemyFaction","_taskEnemySide","_diceRoll"];

            if!(_supriseCreated) then {

                _diceRoll = random 1;

                if(_diceRoll > 0.8) then {

                    _taskEnemyFaction = [_params,"enemyFaction"] call ALIVE_fnc_hashGet;
                    _taskEnemySide = _taskEnemyFaction call ALiVE_fnc_factionSide;

                    [_taskPosition,_taskEnemySide,_taskEnemyFaction] call ALIVE_fnc_taskCreateRandomMilLogisticsEvent;

                    [_params,"supriseCreated",true] call ALIVE_fnc_hashSet;

                };

            };

        };

    };
};

_result