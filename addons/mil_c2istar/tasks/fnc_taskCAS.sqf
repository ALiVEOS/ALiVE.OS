#include "\x\alive\addons\mil_C2ISTAR\script_component.hpp"
SCRIPT(taskCAS);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskCAS

Description:
CAS

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

        if (_taskID == "") exitwith {["C2ISTAR - Task CAS - Wrong input for _taskID!"] call ALiVE_fnc_Dump};
        if (_requestPlayerID == "") exitwith {["C2ISTAR - Task CAS - Wrong input for _requestPlayerID!"] call ALiVE_fnc_Dump};
        if (_taskFaction == "") exitwith {["C2ISTAR - Task CAS - Wrong input for _taskFaction!"] call ALiVE_fnc_Dump};
        if (_taskLocationType == "") exitwith {["C2ISTAR - Task CAS - Wrong input for _taskLocationType!"] call ALiVE_fnc_Dump};
        if (count _taskLocation == 0) exitwith {["C2ISTAR - Task CAS - Wrong input for _taskLocation!"] call ALiVE_fnc_Dump};
        if (count _taskPlayers == 0) exitwith {["C2ISTAR - Task CAS - Wrong input for _taskPlayers!"] call ALiVE_fnc_Dump};
        if (_taskEnemyFaction == "") exitwith {["C2ISTAR - Task CAS - Wrong input for _taskEnemyFaction!"] call ALiVE_fnc_Dump};
        if (_taskApplyType == "") exitwith {["C2ISTAR - Task CAS - Wrong input for _taskApplyType!"] call ALiVE_fnc_Dump};

        _taskEnemySide = _taskEnemyFaction call ALiVE_fnc_factionSide;
        _taskEnemySide = [_taskEnemySide] call ALIVE_fnc_sideObjectToNumber;
        _taskEnemySide = [_taskEnemySide] call ALIVE_fnc_sideNumberToText;

        private _taskTargets = [];
        private _taskFriendly = "";

        if (count _this > 11) then {

            _taskTargets = _taskData select 11;
            _taskFriendly = _taskData select 12;

        } else {



            private _taskProfiles = [ALiVE_profileHandler, "getProfilesByType", "entity"] call ALIVE_fnc_profileHandler;

            // Get nearest enemies
            _taskTargets = [_taskProfiles,[_taskLocation,_taskEnemySide],{

                private ["_final"];

                _profile = [ALiVE_ProfileHandler, "getProfile",_x] call ALIVE_fnc_ProfileHandler;

                if (([_profile,"side"] call ALiVE_fnc_HashGet) == _Input1) then {
                    _final = ([_profile,"position"] call ALiVE_fnc_HashGet) distance _Input0
                } else {
                    _final = 999999
                };

                _final
            },"ASCEND"] call ALiVE_fnc_SortBy;


            // Get nearest friendlies to enemies
            if (count _taskTargets > 0) then {

                private _enemyProfile = [ALIVE_profileHandler,"getProfile", _taskTargets select 0] call ALIVE_fnc_profileHandler;

                if !(isNil "_enemyProfile") then {
                    _targetPosition = [_enemyProfile, "position",_taskLocation] call ALiVE_fnc_hashGet;

                    private _taskFriendlies = [_taskProfiles,[_targetPosition,_taskSide],{

                        private ["_final"];

                        _profile = [ALiVE_ProfileHandler, "getProfile",_x] call ALIVE_fnc_ProfileHandler;

                        if (([_profile,"side"] call ALiVE_fnc_HashGet) == _Input1) then {
                            _final = ([_profile,"position"] call ALiVE_fnc_HashGet) distance _Input0
                        } else {
                            _final = 999999
                        };

                        _final
                    },"ASCEND"] call ALiVE_fnc_SortBy;

                    _taskFriendly = if (count _taskFriendlies > 0) then {_taskFriendlies select 0} else {""};
                };
            };

        };

        if(count _taskTargets == 0 || _taskFriendly == "") exitwith {["C2ISTAR - Task CAS - No targets or friendlies found!"] call ALiVE_fnc_Dump};

        private _enemyProfile = [ALIVE_profileHandler,"getProfile", _taskTargets select 0] call ALIVE_fnc_profileHandler;
        _targetPosition = [_enemyProfile, "position",[]] call ALiVE_fnc_hashGet;

        // ["pl %1 tar %2",getpos player, _targetPosition] call ALiVE_fnc_DumpR;

        if (count _targetPosition == 0) exitwith {["C2ISTAR - Task CAS - No targets found!"] call ALiVE_fnc_Dump};

        private _taskFriendlyProfile = [ALIVE_profileHandler,"getProfile",_taskFriendly] call ALIVE_fnc_profileHandler;

        if !(isNil "_targetPosition" || isNil "_taskFriendlyProfile") then {

            // establish the information and positions for the task
            private _friendlyPosition = [_taskFriendlyProfile, "position"] call ALIVE_fnc_hashGet;

            // Pick a battle position 4km from enemy in direction of friendlies
            private _stagingPosition = _targetPosition getpos [4000, (_targetPosition getDir _friendlyPosition)];
            private _gridposition = mapGridPosition _stagingPosition;

            private _enemyDirection = [(_stagingPosition getDir _targetPosition)] call ALiVE_fnc_dirToText;
            private _friendlyGrid = mapGridPosition _friendlyPosition;

            private _dist = _targetPosition distance _stagingPosition;
            private _height = round((ATLToASL _targetPosition) select 2);
            private _enemyClass = [_enemyProfile,"vehicleClass","Infantry"] call ALIVE_fnc_hashGet;
            private _enemy = if (_enemyClass != "Infantry") then {_enemyClass call ALIVE_fnc_configGetVehicleClass} else {_enemyClass};
            private _friendlyDist = round(_friendlyPosition distance _targetPosition);
            private _friendlyRelPosText = [(_targetPosition getDir _friendlyPosition)] call ALiVE_fnc_dirToText;

            // select the random text
            private _dialogOptions = [ALIVE_generatedTasks,"CAS"] call ALIVE_fnc_hashGet;
            _dialogOptions = _dialogOptions select 1;
            private _dialogOption = +(selectRandom _dialogOptions);

            // format the dialog options
            private["_nearestTown","_dialog","_formatDescription","_formatChat","_formatMessage","_formatMessageText"];

            _nearestTown = [_targetPosition] call ALIVE_fnc_taskGetNearestLocationName;

            _dialog = [_dialogOption,"Travel"] call ALIVE_fnc_hashGet;

            _formatDescription = [_dialog,"description"] call ALIVE_fnc_hashGet;
            _formatDescription = format[_formatDescription,_gridposition];
            [_dialog,"description",_formatDescription] call ALIVE_fnc_hashSet;

            _formatChat = [_dialog,"chat_start"] call ALIVE_fnc_hashGet;

            _formatMessage = _formatChat select 0;
            _formatMessageText = _formatMessage select 1;
            _formatMessageText = format[_formatMessageText, _enemyDirection, mapGridPosition _friendlyPosition];
            _formatMessage set [1,_formatMessageText];
            _formatChat set [0,_formatMessage];
            [_dialog,"chat_start",_formatChat] call ALIVE_fnc_hashSet;

            _dialog = [_dialogOption,"CAS"] call ALIVE_fnc_hashGet;

            private _formatTitle = [_dialog,"title"] call ALIVE_fnc_hashGet;
            _formatTitle = format[_formatTitle,_nearestTown];
            [_dialog,"title",_formatTitle] call ALIVE_fnc_hashSet;

            _formatDescription = [_dialog,"description"] call ALIVE_fnc_hashGet;
            _formatDescription = format[_formatDescription, mapGridPosition _targetPosition];
            [_dialog,"description",_formatDescription] call ALIVE_fnc_hashSet;

            _formatChat = [_dialog,"chat_start"] call ALIVE_fnc_hashGet;
            _formatMessage = _formatChat select 1;
            _formatMessageText = _formatMessage select 1;
            _formatMessageText = format[_formatMessageText,_enemyDirection, round(_dist / 1000), _height, _enemy, mapGridPosition _targetPosition, _friendlyDist, _friendlyRelPosText];
            _formatMessage set [1,_formatMessageText];
            _formatChat set [1,_formatMessage];

            _formatMessage = _formatChat select 2;
            _formatMessageText = _formatMessage select 1;
            _formatMessageText = format[_formatMessageText, _enemy, _height, mapGridPosition _targetPosition, _friendlyDist, _friendlyRelPosText];
            _formatMessage set [1,_formatMessageText];
            _formatChat set [2,_formatMessage];

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
            _taskSource = format["%1-CAS-Parent",_taskID];
            _newTask = [_taskID,_requestPlayerID,_taskSide,_targetPosition,_taskFaction,_taskTitle,_taskDescription,_taskPlayers,_state,_taskApplyType,"N","None",_taskSource,false];

            _tasks pushback _newTask;
            _taskIDs pushback _taskID;

            // create the travel task

            _dialog = [_dialogOption,"Travel"] call ALIVE_fnc_hashGet;
            _taskTitle = [_dialog,"title"] call ALIVE_fnc_hashGet;
            _taskDescription = [_dialog,"description"] call ALIVE_fnc_hashGet;
            _newTaskID = format["%1_c1",_taskID];
            _taskSource = format["%1-CAS-Travel",_taskID];
            _newTask = [_newTaskID,_requestPlayerID,_taskSide,_stagingPosition,_taskFaction,_taskTitle,_taskDescription,_taskPlayers,_state,_taskApplyType,_taskCurrent,_taskID,_taskSource,false];

            _tasks pushback _newTask;
            _taskIDs pushback _newTaskID;

            // create the CAS task

            _dialog = [_dialogOption,"CAS"] call ALIVE_fnc_hashGet;
            _taskTitle = [_dialog,"title"] call ALIVE_fnc_hashGet;
            _taskDescription = [_dialog,"description"] call ALIVE_fnc_hashGet;
            _newTaskID = format["%1_c2",_taskID];
            _taskSource = format["%1-CAS-CAS",_taskID];

            _newTask = [_newTaskID,_requestPlayerID,_taskSide,_targetPosition,_taskFaction,_taskTitle,_taskDescription,_taskPlayers,"Created",_taskApplyType,"N",_taskID,_taskSource,true];

            _tasks pushback _newTask;
            _taskIDs pushback _newTaskID;

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

        _destinationReached = [_taskPosition,_taskPlayers,1000] call ALIVE_fnc_taskHavePlayersReachedDestination;

        if(_destinationReached) then {

            _taskIDs = [_params,"taskIDs"] call ALIVE_fnc_hashGet;
            [_params,"nextTask",_taskIDs select 2] call ALIVE_fnc_hashSet;

            _task set [8,"Succeeded"];
            _task set [10, "N"];
            _result = _task;

        };

    };
    case "CAS":{

        private["_taskID","_requestPlayerID","_taskSide","_taskPosition","_taskFaction","_taskTitle","_taskDescription","_taskPlayers","_lastState","_taskDialog","_supriseCreated","_supriseCreated","_currentTaskDialog","_taskEnemyFaction","_taskEnemySide"];

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

        if(_lastState != "CAS") then {

            ["chat_start",_currentTaskDialog,_taskSide,_taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;

            [_params,"lastState","CAS"] call ALIVE_fnc_hashSet;
        };

        private _enemyNear = [_taskPosition, _taskSide, 1000, true] call ALIVE_fnc_isEnemyNear;

        if !(_enemyNear) then {

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

                if(_diceRoll > 0.9) then {

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
