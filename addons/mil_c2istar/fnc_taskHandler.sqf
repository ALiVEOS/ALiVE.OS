#include <\x\alive\addons\mil_C2ISTAR\script_component.hpp>
SCRIPT(taskHandler);

/* ----------------------------------------------------------------------------
Function: MAINCLASS
Description:
Task repository and handling

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Attributes:


Examples:
(begin example)
// create a task handler
_logic = [nil, "create"] call ALIVE_fnc_taskHandler;

// init task handler
_result = [_logic, "init"] call ALIVE_fnc_taskHandler;

(end)

See Also:

Author:
ARJay

Peer reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClassHash
#define MAINCLASS ALIVE_fnc_taskHandler

private ["_result"];

TRACE_1("taskHandler - input",_this);

params [
    ["_logic", objNull, [objNull,[]]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,[],"",0,true,false]]
];
//_result = true;

#define MTEMPLATE "ALiVE_TASKHANDLER_%1"

switch(_operation) do {
    case "destroy": {
        [_logic, "debug", false] call MAINCLASS;
        if (isServer) then {
                [_logic, "destroy"] call SUPERCLASS;
        };
    };
    case "debug": {
        private["_tasks"];

        if(typeName _args != "BOOL") then {
                _args = [_logic,"debug"] call ALIVE_fnc_hashGet;
        } else {
                [_logic,"debug",_args] call ALIVE_fnc_hashSet;
        };
        ASSERT_TRUE(typeName _args == "BOOL",str _args);

        _result = _args;
    };
    case "init": {
        if (isServer) then {
            private["_tasksBySide","_autoGenerateSides","_tasksToDispatch"];

            // if server, initialise module game logic
            [_logic,"super"] call ALIVE_fnc_hashRem;
            [_logic,"class",MAINCLASS] call ALIVE_fnc_hashSet;
            TRACE_1("After module init",_logic);

            // set defaults
            [_logic,"debug",false] call ALIVE_fnc_hashSet;
            [_logic,"autoGenerate",false] call ALIVE_fnc_hashSet;
            [_logic,"tasks",[] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet;
            [_logic,"tasksBySide",[] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet;
            [_logic,"tasksByPlayer",[] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet;
            [_logic,"tasksByGroup",[] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet;
            [_logic,"tasksToDispatch",[] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet;
            [_logic,"activeTasks",[] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet;
            [_logic,"managedTasks",[] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet;
            [_logic,"managedTaskParams",[] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet;
            [_logic,"isManaging",false] call ALIVE_fnc_hashSet;
            [_logic,"listenerID",""] call ALIVE_fnc_hashSet;

            _tasksBySide = [] call ALIVE_fnc_hashCreate;
            [_tasksBySide, "EAST", [] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet;
            [_tasksBySide, "WEST", [] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet;
            [_tasksBySide, "GUER", [] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet;
            [_tasksBySide, "CIV", [] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet;
            [_logic,"tasksBySide",_tasksBySide] call ALIVE_fnc_hashSet;

            _autoGenerateSides = [] call ALIVE_fnc_hashCreate;
            [_autoGenerateSides, "EAST", [false,""]] call ALIVE_fnc_hashSet;
            [_autoGenerateSides, "WEST", [false,""]] call ALIVE_fnc_hashSet;
            [_autoGenerateSides, "GUER", [false,""]] call ALIVE_fnc_hashSet;
            [_autoGenerateSides, "CIV", [false,""]] call ALIVE_fnc_hashSet;
            [_logic,"autoGenerateSides",_autoGenerateSides] call ALIVE_fnc_hashSet;

            _tasksToDispatch = [] call ALIVE_fnc_hashCreate;
            [_tasksToDispatch, "create", [] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet;
            [_tasksToDispatch, "update", [] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet;
            [_tasksToDispatch, "delete", [] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet;
            [_logic,"tasksToDispatch",_tasksToDispatch] call ALIVE_fnc_hashSet;

            waituntil {!(isnil "ALIVE_profileSystemInit")};

            [_logic,"listen"] call MAINCLASS;
        };
    };
    case "loadTaskData": {
        private["_data","_taskID","_task","_newTask"];

        if(_args) then {

            _data = call ALIVE_fnc_taskHandlerLoadData;

            if(typeName _data == "ARRAY") then {

                {
                    _taskID = _x;

                    _task = _data select 2 select _forEachIndex;

                    _newTask = [];
                    _newTask set [0,_taskID];
                    _newTask set [1,[_task,"c2req_id"] call ALIVE_fnc_hashGet];
                    _newTask set [2,[_task,"c2task_side"] call ALIVE_fnc_hashGet];
                    _newTask set [3,[_task,"c2task_pos"] call ALIVE_fnc_hashGet];
                    _newTask set [4,[_task,"c2task_fac"] call ALIVE_fnc_hashGet];
                    _newTask set [5,[_task,"c2task_tit"] call ALIVE_fnc_hashGet];
                    _newTask set [6,[_task,"c2task_des"] call ALIVE_fnc_hashGet];
                    _newTask set [7,[_task,"c2task_pla"] call ALIVE_fnc_hashGet];
                    _newTask set [8,[_task,"c2task_sta"] call ALIVE_fnc_hashGet];
                    _newTask set [9,[_task,"c2task_app"] call ALIVE_fnc_hashGet];
                    _newTask set [10,[_task,"c2task_cur"] call ALIVE_fnc_hashGet];
                    _newTask set [11,[_task,"c2task_par"] call ALIVE_fnc_hashGet];
                    _newTask set [12,[_task,"c2task_sou"] call ALIVE_fnc_hashGet];
                    _newTask set [13,[_task,"c2task_all"] call ALIVE_fnc_hashGet];
                    _newTask set [14,[_task,"_rev"] call ALIVE_fnc_hashGet];
                    _newTask set [15,[_task,"_id"] call ALIVE_fnc_hashGet];

                    [_logic, "registerTask", _newTask] call MAINCLASS;

                    [_logic, "updateTaskState", _newTask] call MAINCLASS;


                } forEach (_data select 1);
            };

        };
    };
    case "exportTaskData": {

        private["_tasks","_data","_taskID","_task","_taskHash","_taskSource"];

        _tasks = [_logic,"tasks"] call ALIVE_fnc_hashGet;

        _data = [] call ALIVE_fnc_hashCreate;

        {

            /*
            _taskID = _task select 0;
            _requestPlayerID = _task select 1;
            _side = _task select 2;
            _position = _task select 3;
            _faction = _task select 4;
            _title = _task select 5;
            _description = _task select 6;
            _players = _task select 7;
            _state = _task select 8;
            _applyType = _task select 9;
            _current = _task select 10;
            _parent = _task select 11;
            _source = _task select 12;
            _allowMapEditing = _task select 13;
            */

            _taskID = _x;
            _task = [_logic, "getTask", _taskID] call MAINCLASS;
            _taskSource = _task select 12;

            if(_taskSource == "PLAYER") then {

                _taskHash = [] call ALIVE_fnc_hashCreate;

                [_taskHash,"c2task_id",_taskID] call ALIVE_fnc_hashSet;
                [_taskHash,"c2req_id",_task select 1] call ALIVE_fnc_hashSet;
                [_taskHash,"c2task_side",_task select 2] call ALIVE_fnc_hashSet;
                [_taskHash,"c2task_pos",_task select 3] call ALIVE_fnc_hashSet;
                [_taskHash,"c2task_fac",_task select 4] call ALIVE_fnc_hashSet;
                [_taskHash,"c2task_tit",_task select 5] call ALIVE_fnc_hashSet;
                [_taskHash,"c2task_des",_task select 6] call ALIVE_fnc_hashSet;
                [_taskHash,"c2task_pla",_task select 7] call ALIVE_fnc_hashSet;
                [_taskHash,"c2task_sta",_task select 8] call ALIVE_fnc_hashSet;
                [_taskHash,"c2task_app",_task select 9] call ALIVE_fnc_hashSet;
                [_taskHash,"c2task_cur",_task select 10] call ALIVE_fnc_hashSet;
                [_taskHash,"c2task_par",_task select 11] call ALIVE_fnc_hashSet;
                [_taskHash,"c2task_sou",_task select 12] call ALIVE_fnc_hashSet;
                [_taskHash,"c2task_all",_task select 13] call ALIVE_fnc_hashSet;

                if!(_task select 14 == "") then {
                    [_taskHash,"_rev",_task select 14] call ALIVE_fnc_hashSet;
                    [_taskHash,"_id",_task select 15] call ALIVE_fnc_hashSet;
                };

                [_data,_taskID,_taskHash] call ALIVE_fnc_hashSet;

            };

        } forEach (_tasks select 1);

        _result = _data;

    };
    case "listen": {
        private["_listenerID"];

        _listenerID = [ALIVE_eventLog, "addListener",[_logic, ["TASKS_UPDATE","TASK_CREATE","TASK_UPDATE","TASK_DELETE","TASKS_SYNC","TASK_GENERATE","TASKS_AUTO_GENERATE"]]] call ALIVE_fnc_eventLog;
        [_logic,"listenerID",_listenerID] call ALIVE_fnc_hashSet;
    };
    case "handleEvent": {
        private["_event","_type","_eventData"];

        if(typeName _args == "ARRAY") then {

            _event = _args;
            _type = [_event, "type"] call ALIVE_fnc_hashGet;
            _eventData = [_event, "data"] call ALIVE_fnc_hashGet;

            [_logic, _type, _eventData] call MAINCLASS;

        };
    };
    case "TASKS_UPDATE": {
        private["_debug","_eventData"];

        _debug = [_logic,"debug"] call ALIVE_fnc_hashGet;

        _eventData = _args;

        // DEBUG -------------------------------------------------------------------------------------
        if(_debug) then {
            ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
            ["ALiVE Task Handler - Update Tasks event received"] call ALIVE_fnc_dump;
            _eventData call ALIVE_fnc_inspectArray;
        };
        // DEBUG -------------------------------------------------------------------------------------

        [_logic, "updateTaskState", _eventData] call MAINCLASS;

    };
    case "TASK_CREATE": {
        private["_debug","_eventData"];

        _debug = [_logic,"debug"] call ALIVE_fnc_hashGet;

        _eventData = _args;

        // DEBUG -------------------------------------------------------------------------------------
        if(_debug) then {
            ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
            ["ALiVE Task Handler - Create Task event received"] call ALIVE_fnc_dump;
            _eventData call ALIVE_fnc_inspectArray;
        };
        // DEBUG -------------------------------------------------------------------------------------

        [_logic, "registerTask", _eventData] call MAINCLASS;

        [_logic, "updateTaskState", _eventData] call MAINCLASS;

    };
    case "TASK_UPDATE": {
        private["_debug","_eventData"];

        _debug = [_logic,"debug"] call ALIVE_fnc_hashGet;

        _eventData = _args;

        // DEBUG -------------------------------------------------------------------------------------
        if(_debug) then {
            ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
            ["ALiVE Task Handler - Update Task event received"] call ALIVE_fnc_dump;
            _eventData call ALIVE_fnc_inspectArray;
        };
        // DEBUG -------------------------------------------------------------------------------------

        [_logic, "updateTask", _eventData] call MAINCLASS;

        [_logic, "updateTaskState", _eventData] call MAINCLASS;

    };
    case "TASK_DELETE": {
        private["_debug","_eventData","_taskID"];

        _debug = [_logic,"debug"] call ALIVE_fnc_hashGet;

        _eventData = _args;

        // DEBUG -------------------------------------------------------------------------------------
        if(_debug) then {
            ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
            ["ALiVE Task Handler - Delete Task event received"] call ALIVE_fnc_dump;
            _eventData call ALIVE_fnc_inspectArray;
        };
        // DEBUG -------------------------------------------------------------------------------------

        _taskID = _eventData select 0;

        [_logic, "unregisterTask", _taskID] call MAINCLASS;

        [_logic, "updateTaskState", _eventData] call MAINCLASS;

    };
    case "TASKS_SYNC": {
        private["_debug","_eventData"];

        _debug = [_logic,"debug"] call ALIVE_fnc_hashGet;

        _eventData = _args;

        // DEBUG -------------------------------------------------------------------------------------
        if(_debug) then {
            ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
            ["ALiVE Task Handler - Sync Task event received"] call ALIVE_fnc_dump;
            _eventData call ALIVE_fnc_inspectArray;
        };
        // DEBUG -------------------------------------------------------------------------------------

        [_logic, "syncTasks", _eventData] call MAINCLASS;

    };
    case "TASK_GENERATE": {
        private["_debug","_eventData"];

        _debug = [_logic,"debug"] call ALIVE_fnc_hashGet;

        _eventData = _args;

        // DEBUG -------------------------------------------------------------------------------------
        if(_debug) then {
            ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
            ["ALiVE Task Handler - Generate Task event received"] call ALIVE_fnc_dump;
            _eventData call ALIVE_fnc_inspectArray;
        };
        // DEBUG -------------------------------------------------------------------------------------

        [_logic, "generateTask", _eventData] call MAINCLASS;

    };
    case "TASKS_AUTO_GENERATE": {
        private["_debug","_eventData"];

        _debug = [_logic,"debug"] call ALIVE_fnc_hashGet;

        _eventData = _args;

        // DEBUG -------------------------------------------------------------------------------------
        if(_debug) then {
            ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
            ["ALiVE Task Handler - Auto Generate Tasks event received"] call ALIVE_fnc_dump;
            _eventData call ALIVE_fnc_inspectArray;
        };
        // DEBUG -------------------------------------------------------------------------------------

        [_logic, "autoGenerateTasks", _eventData] call MAINCLASS;

    };
    case "autoGenerateTasks": {
        private["_debug","_taskData","_taskID","_requestPlayerID","_taskSide","_taskFaction","_taskEnemyFaction","_taskAutoGenerate","_autoGenerateSides",
        "_tasksBySide","_activeTasks","_countActive","_sideTasks"];

        if(typeName _args == "ARRAY") then {

            _debug = [_logic,"debug"] call ALIVE_fnc_hashGet;

            _taskData = _args;

            _taskID = _taskData select 0;
            _requestPlayerID = _taskData select 1;
            _taskSide = _taskData select 2;
            _taskFaction = _taskData select 3;
            _taskEnemyFaction = _taskData select 4;
            _taskAutoGenerate = _taskData select 5;

            _autoGenerateSides = [_logic,"autoGenerateSides"] call ALIVE_fnc_hashGet;
            [_autoGenerateSides,_taskSide,[_taskAutoGenerate,_taskEnemyFaction]] call ALIVE_fnc_hashSet;

            _tasksBySide = [_logic, "tasksBySide"] call ALIVE_fnc_hashGet;
            _sideTasks = [_tasksBySide,_taskSide] call ALIVE_fnc_hashGet;

            _activeTasks = [_logic,"activeTasks"] call ALIVE_fnc_hashGet;
            _countActive = 0;

            {
                _taskID = _x;
                if(_taskID in (_activeTasks select 1)) then {
                    _countActive = _countActive + 1;
                };
            } forEach (_sideTasks select 1);

            if(_countActive == 0) then {

                private["_sidePlayers","_taskType","_locationTypes","_taskLocationType","_taskLocation","_taskCurrent","_taskApplyType","_task"];

                _sidePlayers = [_taskSide] call ALiVE_fnc_getPlayersDataSource;
                _sidePlayers = [_sidePlayers select 1,_sidePlayers select 0];

                _taskType = selectRandom ALIVE_autoGeneratedTasks;

                //_locationTypes = ["Short","Medium","Long"];
                //_taskLocationType = selectRandom _locationTypes;
                _taskLocationType = "Short";
                _taskLocation = [];

                _taskCurrent = "Y";
                _taskApplyType = "Side";

                _task = [_taskID,_requestPlayerID,_taskSide,_taskFaction,_taskType,_taskLocationType,_taskLocation,_sidePlayers,_taskEnemyFaction,_taskCurrent,_taskApplyType];


                // DEBUG -------------------------------------------------------------------------------------
                if(_debug) then {
                    ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
                    ["ALiVE Task Handler - Auto generate task for side: %1",_taskSide] call ALIVE_fnc_dump;
                    _task call ALIVE_fnc_inspectArray;
                };
                // DEBUG -------------------------------------------------------------------------------------


                [_logic,"generateTask",_task] call MAINCLASS;
            };

        };

    };
    case "generateTask": {

        private["_debug","_taskData","_taskID","_requestPlayerID","_taskSide","_taskFaction","_taskType","_taskLocationType",
        "_taskLocation","_taskPlayers","_taskEnemyFaction","_taskCurrent","_taskApplyType","_player","_position","_taskSet",
        "_managedTaskParams"];

        if(typeName _args == "ARRAY") then {

            _debug = [_logic,"debug"] call ALIVE_fnc_hashGet;

            _taskData = _args;

            _taskID = _taskData select 0;
            _requestPlayerID = _taskData select 1;
            _taskSide = _taskData select 2;
            _taskFaction = _taskData select 3;
            _taskType = _taskData select 4;
            _taskLocationType = _taskData select 5;
            _taskLocation = _taskData select 6;
            _taskPlayers = _taskData select 7;
            _taskEnemyFaction = _taskData select 8;
            _taskCurrent = _taskData select 9;
            _taskApplyType = _taskData select 10;

            if((_taskLocationType == "Short") || (_taskLocationType == "Medium") || (_taskLocationType == "Long")) then {
                _player = [_requestPlayerID] call ALIVE_fnc_getPlayerByUID;

                if (isNull _player) then {
                    _player = selectRandom (_taskPlayers select 0);
                    _player = [_player] call ALIVE_fnc_getPlayerByUID;
                };
                
	            _position = position _player;
	            _taskData set [6,_position];
            };

            _taskSet = ["init", _taskID, _taskData, [], _debug] call (call compile format["ALIVE_fnc_task%1",_taskType]);

            if!(isNil "_taskSet") then {
                if(count _taskSet > 0) then {

                    _managedTaskParams = [_logic,"managedTaskParams"] call ALIVE_fnc_hashSet;
                    if!(_taskID in (_managedTaskParams select 1)) then {
                        [_managedTaskParams,_taskID,_taskSet select 1] call ALIVE_fnc_hashSet;
                    };

                    {
                        [_logic, "registerTask", _x] call MAINCLASS;
                        [_logic, "updateTaskState", _x] call MAINCLASS;
                    } forEach (_taskSet select 0);

                }else{

                    private["_autoGenerateSides","_sideAutoGeneration","_generate"];

                    _autoGenerateSides = [_logic,"autoGenerateSides"] call ALIVE_fnc_hashGet;
                    _sideAutoGeneration = [_autoGenerateSides,_taskSide] call ALIVE_fnc_hashGet;

                    if(_sideAutoGeneration select 0) then {

                        sleep 10;

                        _generate = [format["%1_%2",_taskSide,(time+1)],_requestPlayerID,_taskSide,_taskFaction,_taskEnemyFaction,true];

                        [_logic,"autoGenerateTasks",_generate] call MAINCLASS;
                    };

                };
            }else{

                private["_autoGenerateSides","_sideAutoGeneration","_generate"];

                _autoGenerateSides = [_logic,"autoGenerateSides"] call ALIVE_fnc_hashGet;
                _sideAutoGeneration = [_autoGenerateSides,_taskSide] call ALIVE_fnc_hashGet;

                if(_sideAutoGeneration select 0) then {

                    sleep 10;

                    _generate = [format["%1_%2",_taskSide,(time+1)],_requestPlayerID,_taskSide,_taskFaction,_taskEnemyFaction,true];

                    [_logic,"autoGenerateTasks",_generate] call MAINCLASS;
                };

            }

        };

    };
    case "syncTasks": {

        if(typeName _args == "ARRAY") then {

            [_logic,_args] spawn {

                private["_eventData","_debug","_playerID","_groupID","_player","_playerTasks","_groupTasks","_sideTasks","_dispatchTasks","_dispatchIDs","_player","_playerSide","_parentTasks"];

                _logic = _this select 0;
                _eventData = _this select 1;

                _debug = [_logic,"debug"] call ALIVE_fnc_hashGet;

                _playerID = _eventData select 0;
                _groupID = _eventData select 1;

                _player = [_playerID] call ALIVE_fnc_getPlayerByUID;

                _groupID = [_groupID, " ", "_"] call CBA_fnc_replace;

                waitUntil {
                    sleep 1;
                    ((str side _player) != "UNKNOWN")
                };

                _playerSide = side _player;
                _playerSide = [_playerSide] call ALIVE_fnc_sideObjectToNumber;
                _playerSide = [_playerSide] call ALIVE_fnc_sideNumberToText;

                _playerTasks = [_logic, "getTasksByPlayer", _playerID] call MAINCLASS;
                _groupTasks = [_logic, "getTasksByGroup", _groupID] call MAINCLASS;
                _sideTasks = [_logic, "getTasksBySide", _playerSide] call MAINCLASS;


                // DEBUG -------------------------------------------------------------------------------------
                if(_debug) then {
                    ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
                    ["ALiVE Task Handler - Sync Connecting Player: %1 %2 %3 %4",_playerID,_groupID,_player,_playerSide] call ALIVE_fnc_dump;
                };
                // DEBUG -------------------------------------------------------------------------------------


                _dispatchTasks = [];
                _dispatchIDs = [];

                if!(isNil "_sideTasks") then {

                    if(count _sideTasks > 0) then {

                        {
                            private ["_taskID","_applyType"];
                            _taskID = _x select 0;
                            _applyType = _x select 9;

                            if(_applyType == "Side") then {
                                _dispatchTasks set [count _dispatchTasks,_x];
                                _dispatchIDs set [count _dispatchIDs,_taskID];

                                // DEBUG -------------------------------------------------------------------------------------
                                if(_debug) then {
                                    ["ALiVE Task Handler - Sync Side Task: %1",_x] call ALIVE_fnc_dump;
                                };
                                // DEBUG -------------------------------------------------------------------------------------

                            };

                        } forEach _sideTasks;

                    };
                };

                if!(isNil "_playerTasks") then {
                    if(count _playerTasks > 0) then {

                        {
                            private ["_taskID","_taskSide"];
                            _taskID = _x select 0;
                            _taskSide = _x select 2;

                            if(_playerSide == _taskSide) then {

                                if!(_taskID in _dispatchIDs) then {
                                    _dispatchTasks set [count _dispatchTasks,_x];
                                    _dispatchIDs set [count _dispatchIDs,_taskID];

                                    // DEBUG -------------------------------------------------------------------------------------
                                    if(_debug) then {
                                        ["ALiVE Task Handler - Sync Player Task: %1",_x] call ALIVE_fnc_dump;
                                    };
                                    // DEBUG -------------------------------------------------------------------------------------

                                };

                            };
                        } forEach _playerTasks;

                    };
                };

                if!(isNil "_groupTasks") then {
                    if(count _groupTasks > 0) then {

                        {
                            private ["_taskID"];
                            _taskID = _x select 0;

                            if!(_taskID in _dispatchIDs) then {
                                _dispatchTasks set [count _dispatchTasks,_x];
                                _dispatchIDs set [count _dispatchIDs,_taskID];

                                // DEBUG -------------------------------------------------------------------------------------
                                if(_debug) then {
                                    ["ALiVE Task Handler - Sync Group Task: %1",_x] call ALIVE_fnc_dump;
                                };
                                // DEBUG -------------------------------------------------------------------------------------
                            };
                        } forEach _groupTasks;

                    };
                };

                if(count _dispatchTasks > 0) then {

                    _player = [_playerID] call ALIVE_fnc_getPlayerByUID;

                    // dispatch tasks to player

                    // create the top level parent tasks first

                    _parentTasks = [];

                    {

                        private ["_task","_taskID","_requestPlayerID","_position","_title","_description","_state","_event","_current","_source","_parent"];

                        _task = _x;
                        _taskID = _task select 0;
                        _requestPlayerID = _task select 1;
                        _position = _task select 3;
                        _title = _task select 5;
                        _description = _task select 6;
                        _state = _task select 8;
                        _current = _task select 10;
                        _parent = _task select 11;
                        _source = _task select 12;

                        if(_parent == "None") then {

                            _event = ["TASK_CREATE",_taskID,_requestPlayerID,_position,_title,_description,_state,_current,_parent,_source];

                            if !(isNull _player) then {
                                if((isServer && isMultiplayer) || isDedicated) then {
                                    _event remoteExec ["ALIVE_fnc_taskHandlerEventToClient",_player];
                                }else{
                                    _event call ALIVE_fnc_taskHandlerEventToClient;
                                };
                            };

                            _parentTasks set [count _parentTasks, _taskID];
                            _dispatchTasks set [_forEachIndex,"DELETE"];

                        };

                    } forEach _dispatchTasks;

                    _dispatchTasks = _dispatchTasks - ["DELETE"];

                    /*
                    ["DISPATCHED TOP LEVEL TASKS"] call ALIVE_fnc_dump;
                    _parentTasks call ALIVE_fnc_inspectArray;
                    _dispatchTasks call ALIVE_fnc_inspectArray;
                    */

                    sleep 4;

                    {

                        private ["_task","_taskID","_requestPlayerID","_position","_title","_description","_state","_event","_current","_source","_parent"];

                        _task = _x;
                        _taskID = _task select 0;
                        _requestPlayerID = _task select 1;
                        _position = _task select 3;
                        _title = _task select 5;
                        _description = _task select 6;
                        _state = _task select 8;
                        _current = _task select 10;
                        _parent = _task select 11;
                        _source = _task select 12;

                        if(_parent in _parentTasks) then {

                            _event = ["TASK_CREATE",_taskID,_requestPlayerID,_position,_title,_description,_state,_current,_parent,_source];

                            if !(isNull _player) then {
                                if((isServer && isMultiplayer) || isDedicated) then {
                                    _event remoteExec ["ALIVE_fnc_taskHandlerEventToClient",_player];
                                }else{
                                    _event call ALIVE_fnc_taskHandlerEventToClient;
                                };
                            };

                            _parentTasks set [count _parentTasks, _taskID];
                            _dispatchTasks set [_forEachIndex,"DELETE"];

                        };

                    } forEach _dispatchTasks;

                    _dispatchTasks = _dispatchTasks - ["DELETE"];

                    /*
                    ["DISPATCHED SUB LEVEL TASKS"] call ALIVE_fnc_dump;
                    _parentTasks call ALIVE_fnc_inspectArray;
                    _dispatchTasks call ALIVE_fnc_inspectArray;
                    */

                    sleep 4;

                    {

                        private ["_task","_taskID","_requestPlayerID","_position","_title","_description","_state","_event","_current","_source","_parent"];

                        _task = _x;

                        if(_task != 'DELETE') then {

                            _taskID = _task select 0;
                            _requestPlayerID = _task select 1;
                            _position = _task select 3;
                            _title = _task select 5;
                            _description = _task select 6;
                            _state = _task select 8;
                            _current = _task select 10;
                            _parent = _task select 11;
                            _source = _task select 12;

                            if!(_parent in _parentTasks) then {

                                {
                                    private ["_fTask","_fTaskID","_fRequestPlayerID","_fPosition","_fTitle","_fDescription","_fState","_fCurrent","_fParent","_fSource","_fEvent"];

                                    _fTask = _x;
                                    _fTaskID = _fTask select 0;

                                    if(_fTaskID == _parent) exitWith {
                                        _fRequestPlayerID = _fTask select 1;
                                        _fPosition = _fTask select 3;
                                        _fTitle = _fTask select 5;
                                        _fDescription = _fTask select 6;
                                        _fState = _fTask select 8;
                                        _fCurrent = _fTask select 10;
                                        _fParent = _fTask select 11;
                                        _fSource = _fTask select 12;

                                        _fEvent = ["TASK_CREATE",_fTaskID,_fRequestPlayerID,_fPosition,_fTitle,_fDescription,_fState,_fCurrent,_fParent,_fSource];

                                        if !(isNull _player) then {
                                            if((isServer && isMultiplayer) || isDedicated) then {
                                                _fEvent remoteExec ["ALIVE_fnc_taskHandlerEventToClient",_player];
                                            }else{
                                                _fEvent call ALIVE_fnc_taskHandlerEventToClient;
                                            };
                                        };

                                        _parentTasks set [count _parentTasks, _taskID];
                                        _dispatchTasks set [_forEachIndex,"DELETE"];
                                    };

                                } forEach _dispatchTasks;

                            }else{

                                _event = ["TASK_CREATE",_taskID,_requestPlayerID,_position,_title,_description,_state,_current,_parent,_source];

                                if !(isNull _player) then {
                                    if((isServer && isMultiplayer) || isDedicated) then {
                                        _event remoteExec ["ALIVE_fnc_taskHandlerEventToClient",_player];
                                    }else{
                                        _event call ALIVE_fnc_taskHandlerEventToClient;
                                    };
                                };

                            };

                        };

                    } forEach _dispatchTasks;

                    _dispatchTasks = _dispatchTasks - ["DELETE"];

                    /*
                    ["DISPATCHED REMAINING TASKS"] call ALIVE_fnc_dump;
                    _parentTasks call ALIVE_fnc_inspectArray;
                    _dispatchTasks call ALIVE_fnc_inspectArray;
                    */

                };

            };

        };

    };
    case "registerTask": {
        private["_task","_taskID","_taskSide","_taskPlayers","_taskApplyType","_tasks","_tasksBySide","_sideTasks",
        "_tasksByPlayer","_tasksByGroup","_group","_groupTasks","_playerTasks","_player","_tasksToDispatch","_createTasks",
        "_taskCurrent","_activeTasks","_activeTasksToRemove","_activeTaskID","_activeTask","_taskSource","_managedTasks",
        "_isManaging","_sidePlayers","_groupPlayerOptions","_groupPlayerValues","_currentGroupPlayers","_currentGroupPlayerOptions","_currentGroupPlayerValues"];

        if(typeName _args == "ARRAY") then {

            /*
            _taskID = _task select 0;
            _requestPlayerID = _task select 1;
            _side = _task select 2;
            _position = _task select 3;
            _faction = _task select 4;
            _title = _task select 5;
            _description = _task select 6;
            _players = _task select 7;
            _state = _task select 8;
            _applyType = _task select 9;
            _current = _task select 10;
            _parent = _task select 11;
            _source = _task select 12;
            _allowMapEditing = _task select 13;
            */

            _task = _args;
            _taskID = _task select 0;
            _taskSide = _task select 2;
            _taskPlayers = _task select 7 select 0;
            _taskApplyType = _task select 9;
            _taskCurrent = _task select 10;
            _taskSource = _task select 12;

            // if the task is set to side application
            // replace the current player list with all
            // players from the side
            if(_taskApplyType == "Side") then {
                _sidePlayers = [_taskSide] call ALiVE_fnc_getPlayersDataSource;
                _task set [7, [_sidePlayers select 1,_sidePlayers select 0]];
                _taskPlayers = _sidePlayers select 1;
            };

            // if the task is set to group application
            // replace the current player list with all
            // players from the groups
            if(_taskApplyType == "Group") then {

                _groupPlayerOptions = [];
                _groupPlayerValues = [];

                {
                    _currentGroupPlayers = [_x] call ALiVE_fnc_getPlayersInGroupDataSource;
                    _currentGroupPlayerOptions = _currentGroupPlayers select 0;
                    _currentGroupPlayerValues = _currentGroupPlayers select 1;

                    {
                        if!(_x in _groupPlayerOptions) then {
                            _groupPlayerOptions set [count _groupPlayerOptions, _x];
                        };
                    } forEach _currentGroupPlayerOptions;

                    {
                        if!(_x in _groupPlayerValues) then {
                            _groupPlayerValues set [count _groupPlayerValues, _x];
                        };
                    } forEach _currentGroupPlayerValues;

                } forEach _taskPlayers;

                _task set [7, [_groupPlayerValues,_groupPlayerOptions]];
                _taskPlayers = _groupPlayerValues;

            };

            // store in main tasks hash
            _tasks = [_logic, "tasks"] call ALIVE_fnc_hashGet;
            [_tasks,_taskID,_task] call ALIVE_fnc_hashSet;

            // store in tasks by side hash
            _tasksBySide = [_logic, "tasksBySide"] call ALIVE_fnc_hashGet;
            _sideTasks = [_tasksBySide, _taskSide] call ALIVE_fnc_hashGet;
            [_sideTasks, _taskID, _taskID] call ALIVE_fnc_hashSet;

            // store in tasks by player hash
            _tasksByPlayer = [_logic, "tasksByPlayer"] call ALIVE_fnc_hashGet;

            // prepare tasks to dispatch
            _tasksToDispatch = [_logic,"tasksToDispatch"] call ALIVE_fnc_hashGet;
            _createTasks = [_tasksToDispatch,"create"] call ALIVE_fnc_hashGet;

            // if the task is set to current
            // store it in the active task array
            // remove any tasks for this side that are active
            if(_taskCurrent == "Y") then {

                _activeTasks = [_logic,"activeTasks"] call ALIVE_fnc_hashGet;

                /*

                _activeTasksToRemove = [];
                {
                    _activeTaskID = _x;
                    if(_activeTaskID in (_sideTasks select 1)) then {
                        _activeTasksToRemove set [count _activeTasksToRemove,_activeTaskID];
                    }
                } forEach (_activeTasks select 2);

                {
                    [_activeTasks,_x] call ALIVE_fnc_hashRem;
                    _activeTask = [_logic, "getTask", _x] call MAINCLASS;
                    _activeTask set [10,"N"];
                } forEach _activeTasksToRemove;
                */

                [_activeTasks,_taskID,_taskID] call ALIVE_fnc_hashSet;

                // the task source is not player created
                // it must be a managed task
                // start management if not already started
                // and add the task to the management queue
                if(_taskSource != "PLAYER") then {
                    _managedTasks = [_logic,"managedTasks"] call ALIVE_fnc_hashGet;
                    [_managedTasks,_taskID,_taskID] call ALIVE_fnc_hashSet;

                    _isManaging = [_logic,"isManaging"] call ALIVE_fnc_hashGet;
                    if!(_isManaging) then {
                        [_logic,"startManagement"] call MAINCLASS;
                    };
                };
            };

            {

                _player = _x;

                if(_player in (_tasksByPlayer select 1)) then {

                    _playerTasks = [_tasksByPlayer, _player] call ALIVE_fnc_hashGet;

                }else{

                    [_tasksByPlayer, _player, [] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet;
                    _playerTasks = [_tasksByPlayer, _player] call ALIVE_fnc_hashGet;

                };

                // prepare task for dispatch to this player
                [_createTasks,_player,_task] call ALIVE_fnc_hashSet;

                // store the task by player
                [_playerTasks,_taskID,_taskID] call ALIVE_fnc_hashSet;
                [_tasksByPlayer, _player, _playerTasks] call ALIVE_fnc_hashSet;

            } forEach _taskPlayers;


            // store in tasks by group hash
            if(_taskApplyType == "Group") then {

                _tasksByGroup = [_logic, "tasksByGroup"] call ALIVE_fnc_hashGet;

                {

                    _player = [_x] call ALIVE_fnc_getPlayerByUID;

                    if !(isNull _player) then {
                        _group = group _player;

                        _group = [format["%1",_group], " ", "_"] call CBA_fnc_replace;

                        if(_group in (_tasksByGroup select 1)) then {

                            _groupTasks = [_tasksByGroup, _group] call ALIVE_fnc_hashGet;

                        }else{

                            [_tasksByGroup, _group, [] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet;
                            _groupTasks = [_tasksByGroup, _group] call ALIVE_fnc_hashGet;

                        };

                        [_groupTasks,_taskID,_taskID] call ALIVE_fnc_hashSet;
                        [_tasksByGroup, _group, _groupTasks] call ALIVE_fnc_hashSet;
                    };

                } forEach _taskPlayers;
            };

        };
    };
    case "updateTask": {
        private["_updatedTask","_updatedTaskPlayers","_taskApplyType","_taskSide","_taskState","_taskID","_task","_previousTaskPlayers",
        "_previousTaskApplyType","_tasks","_tasksBySide","_sideTasks","_tasksByPlayer","_player","_group","_countRemoved",
        "_previousGroups","_updatedGroups","_tasksToDispatch","_updateTasks","_deleteTasks",
        "_taskCurrent","_activeTasks","_activeTasksToRemove","_activeTaskID","_tasksBySide","_sideTasks",
        "_activeTask","_previousTaskCurrent","_taskSource","_managedTasks","_isManaging","_sidePlayers",
        "_groupPlayerOptions","_groupPlayerValues","_currentGroupPlayers","_currentGroupPlayerOptions",
        "_currentGroupPlayerValues","_createTasks"];

        if(typeName _args == "ARRAY") then {

            _updatedTask = _args;
            _updatedTaskPlayers = _updatedTask select 7 select 0;
            _taskApplyType = _updatedTask select 9;
            _taskSide = _updatedTask select 2;
            _taskState = _updatedTask select 8;
            _taskCurrent = _updatedTask select 10;
            _taskSource = _updatedTask select 12;

            _taskID = _updatedTask select 0;
            _task = [_logic, "getTask", _taskID] call MAINCLASS;
            _previousTaskPlayers = _task select 7 select 0;
            _previousTaskApplyType = _task select 9;
            _previousTaskCurrent = _task select 10;

            // prepare tasks to dispatch
            _tasksToDispatch = [_logic,"tasksToDispatch"] call ALIVE_fnc_hashGet;
            _createTasks = [_tasksToDispatch,"create"] call ALIVE_fnc_hashGet;
            _updateTasks = [_tasksToDispatch,"update"] call ALIVE_fnc_hashGet;
            _deleteTasks = [_tasksToDispatch,"delete"] call ALIVE_fnc_hashGet;

            // if the task is set to side application
            // replace the current player list with all
            // players from the side
            if(_taskApplyType == "Side") then {
                _sidePlayers = [_taskSide] call ALiVE_fnc_getPlayersDataSource;
                _updatedTask set [7, [_sidePlayers select 1,_sidePlayers select 0]];
                _updatedTaskPlayers = _sidePlayers select 1;
            };

            // if the task is set to group application
            // replace the current player list with all
            // players from the groups
            if(_taskApplyType == "Group") then {

                _groupPlayerOptions = [];
                _groupPlayerValues = [];

                {
                    _currentGroupPlayers = [_x] call ALiVE_fnc_getPlayersInGroupDataSource;
                    _currentGroupPlayerOptions = _currentGroupPlayers select 0;
                    _currentGroupPlayerValues = _currentGroupPlayers select 1;

                    {
                        if!(_x in _groupPlayerOptions) then {
                            _groupPlayerOptions set [count _groupPlayerOptions, _x];
                        };
                    } forEach _currentGroupPlayerOptions;

                    {
                        if!(_x in _groupPlayerValues) then {
                            _groupPlayerValues set [count _groupPlayerValues, _x];
                        };
                    } forEach _currentGroupPlayerValues;

                } forEach _updatedTaskPlayers;

                _updatedTask set [7, [_groupPlayerValues,_groupPlayerOptions]];
                _updatedTaskPlayers = _groupPlayerValues;

            };

            // if the task is set to group application
            // replace the current player list with all
            // players from the side
            if(_taskApplyType == "Group") then {
                {

                } forEach _updatedTaskPlayers;
            };

            // if the task is set to current
            // store it in the active task array
            // remove any other tasks for this side that are active
            if(_taskCurrent == "Y" || _taskState == "Assigned") then {

                _activeTasks = [_logic,"activeTasks"] call ALIVE_fnc_hashGet;

                /*
                _tasksBySide = [_logic, "tasksBySide"] call ALIVE_fnc_hashGet;
                _activeTasks = [_logic,"activeTasks"] call ALIVE_fnc_hashGet;
                _activeTasksToRemove = [];
                {
                    _activeTaskID = _x;
                    if(_activeTaskID in (_sideTasks select 1)) then {
                        _activeTasksToRemove set [count _activeTasksToRemove,_activeTaskID];
                    }
                } forEach (_activeTasks select 1);

                [_activeTasksToRemove] call ALIVE_fnc_inspectArray;

                {
                    [_activeTasks,_x] call ALIVE_fnc_hashRem;
                    _activeTask = [_logic, "getTask", _x] call MAINCLASS;
                    _activeTask set [10,"N"];
                } forEach _activeTasksToRemove;
                */

                [_activeTasks,_taskID,_taskID] call ALIVE_fnc_hashSet;

                // the task source is not player created
                // it must be a managed task
                // start management if not already started
                // and add the task to the management queue
                if(_taskSource != "PLAYER") then {
                    _managedTasks = [_logic,"managedTasks"] call ALIVE_fnc_hashGet;
                    [_managedTasks,_taskID,_taskID] call ALIVE_fnc_hashSet;

                    _isManaging = [_logic,"isManaging"] call ALIVE_fnc_hashGet;
                    if!(_isManaging) then {
                        [_logic,"startManagement"] call MAINCLASS;
                    };
                };
            };

            // if the task was previously current and
            // is now not current remove from the active tasks array
            if(_taskCurrent == "N" || _taskState == "Succeeded" || _taskState == "Failed" || _taskState == "Cancelled") then {
                _activeTasks = [_logic,"activeTasks"] call ALIVE_fnc_hashGet;
                if(_taskID in (_activeTasks select 1)) then {
                    [_activeTasks,_taskID] call ALIVE_fnc_hashRem;
                };
            };

            private ["_playerTasks"];

            _countRemoved = 0;

            // remove the task from removed players
            _tasksByPlayer = [_logic, "tasksByPlayer"] call ALIVE_fnc_hashGet;
            {

                _player = _x;

                if!(_player in _updatedTaskPlayers) then {

                    // remove task
                    _playerTasks = [_tasksByPlayer, _player] call ALIVE_fnc_hashGet;
                    [_playerTasks,_taskID] call ALIVE_fnc_hashRem;
                    [_tasksByPlayer, _player, _playerTasks] call ALIVE_fnc_hashSet;

                    // prepare task for dispatch to this player
                    [_deleteTasks,_player,_task] call ALIVE_fnc_hashSet;

                    _countRemoved = _countRemoved + 1;

                };

            } forEach _previousTaskPlayers;

            private ["_group","_tasksByGroup","_groupTasks"];

            // if some players have been removed need to also remove
            // the group if no other players from that group are selected
            if(_countRemoved > 0) then {

                if(_previousTaskApplyType == "Group") then {

                    if(_taskApplyType == "Group") then {

                        _previousGroups = [];

                        {

                            _player = [_x] call ALIVE_fnc_getPlayerByUID;

                            if !(isNull _player) then {
                                _group = group _player;

                                _group = [format["%1",_group], " ", "_"] call CBA_fnc_replace;

                                if!(_group in _previousGroups) then {
                                    _previousGroups set [count _previousGroups, _group];
                                };

                            };

                        } forEach _previousTaskPlayers;

                        _updatedGroups = [];

                        {

                            _player = [_x] call ALIVE_fnc_getPlayerByUID;

                            if !(isNull _player) then {
                                _group = group _player;

                                _group = [format["%1",_group], " ", "_"] call CBA_fnc_replace;

                                if!(_group in _updatedGroups) then {
                                    _updatedGroups set [count _updatedGroups, _group];
                                };

                            };

                        } forEach _updatedTaskPlayers;

                        _tasksByGroup = [_logic, "tasksByGroup"] call ALIVE_fnc_hashGet;

                        {

                            if!(_x in _updatedGroups) then {

                                if(_x in (_tasksByGroup select 1)) then {

                                    // remove task
                                    _groupTasks = [_tasksByGroup, _x] call ALIVE_fnc_hashGet;
                                    [_groupTasks,_taskID] call ALIVE_fnc_hashRem;
                                    [_tasksByGroup, _x, _groupTasks] call ALIVE_fnc_hashSet;

                                };

                            };

                        } forEach _previousGroups;

                    };

                };

            };

            private ["_playerTasks"];

            // update in tasks by player hash
            {
                _player = _x;

                if(_player in (_tasksByPlayer select 1)) then {

                    _playerTasks = [_tasksByPlayer, _player] call ALIVE_fnc_hashGet;

                    // prepare task for dispatch to this player
                    [_updateTasks,_player,_updatedTask] call ALIVE_fnc_hashSet;

                }else{

                    [_tasksByPlayer, _player, [] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet;
                    _playerTasks = [_tasksByPlayer, _player] call ALIVE_fnc_hashGet;

                    // prepare task for dispatch to this player
                    [_createTasks,_player,_updatedTask] call ALIVE_fnc_hashSet;

                };

                [_playerTasks,_taskID,_taskID] call ALIVE_fnc_hashSet;
                [_tasksByPlayer, _player, _playerTasks] call ALIVE_fnc_hashSet;

            } forEach _updatedTaskPlayers;

            private ["_playerTasks","_group","_tasksByGroup","_groupTasks"];

            // if the previous version of the task was for groups
            // and now has been set to individuals
            if(_previousTaskApplyType == "Group") then {

                if(_taskApplyType == "Individual" || _taskApplyType == "Side") then {

                    _tasksByGroup = [_logic, "tasksByGroup"] call ALIVE_fnc_hashGet;

                    {

                        _player = [_x] call ALIVE_fnc_getPlayerByUID;

                        if !(isNull _player) then {
                            _group = group _player;

                            _group = [format["%1",_group], " ", "_"] call CBA_fnc_replace;

                            if(_group in (_tasksByGroup select 1)) then {

                                // remove task
                                _groupTasks = [_tasksByGroup, _group] call ALIVE_fnc_hashGet;
                                [_groupTasks,_taskID] call ALIVE_fnc_hashRem;
                                [_tasksByGroup, _group, _groupTasks] call ALIVE_fnc_hashSet;

                            };

                        };

                    } forEach _previousTaskPlayers;

                };
            };

            private ["_tasksByGroup","_groupTasks","_group"];

            // if the previous version of the task was for individuals
            // and now has been set to groups
            if(_previousTaskApplyType == "Individual" || _previousTaskApplyType == "Side") then {

                if(_taskApplyType == "Group") then {

                    _tasksByGroup = [_logic, "tasksByGroup"] call ALIVE_fnc_hashGet;

                    {

                        _player = [_x] call ALIVE_fnc_getPlayerByUID;

                        if !(isNull _player) then {
                            _group = group _player;

                            _group = [format["%1",_group], " ", "_"] call CBA_fnc_replace;

                            if(_group in (_tasksByGroup select 1)) then {

                                _groupTasks = [_tasksByGroup, _group] call ALIVE_fnc_hashGet;

                            }else{

                                [_tasksByGroup, _group, [] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet;
                                _groupTasks = [_tasksByGroup, _group] call ALIVE_fnc_hashGet;

                            };

                            [_groupTasks,_taskID,_taskID] call ALIVE_fnc_hashSet;
                            [_tasksByGroup, _group, _groupTasks] call ALIVE_fnc_hashSet;

                        };

                    } forEach _updatedTaskPlayers;

                };
            };

            // update in main tasks hash
            _tasks = [_logic, "tasks"] call ALIVE_fnc_hashGet;
            [_tasks,_taskID,_updatedTask] call ALIVE_fnc_hashSet;

            // update in tasks by side hash
            _tasksBySide = [_logic, "tasksBySide"] call ALIVE_fnc_hashGet;
            _sideTasks = [_tasksBySide, _taskSide] call ALIVE_fnc_hashGet;
            [_sideTasks, _taskID, _taskID] call ALIVE_fnc_hashSet;

        };
    };
    case "unregisterTask": {
        private["_taskData","_taskID","_task","_taskSide","_tasks","_tasksBySide","_sideTasks","_tasksByGroup","_group","_groupTasks",
        "_tasksByPlayer","_player","_playerTasks","_tasksToDispatch","_deleteTasks","_taskPlayers","_activeTasks"];

        if(typeName _args == "STRING") then {

            _taskID = _args;
            _task = [_logic, "getTask", _taskID] call MAINCLASS;

            _taskSide = _task select 2;
            _taskPlayers = _task select 7 select 0;

            // prepare tasks to dispatch
            _tasksToDispatch = [_logic,"tasksToDispatch"] call ALIVE_fnc_hashGet;
            _deleteTasks = [_tasksToDispatch,"delete"] call ALIVE_fnc_hashGet;

            {

                _player = _x;

                // prepare task for dispatch to this player
                [_deleteTasks,_player,_task] call ALIVE_fnc_hashSet;

            } forEach _taskPlayers;

            // remove from main tasks hash
            _tasks = [_logic, "tasks"] call ALIVE_fnc_hashGet;
            [_tasks,_taskID] call ALIVE_fnc_hashRem;
            [_logic, "tasks", _tasks] call ALIVE_fnc_hashSet;

            // remove from tasks by side hash
            _tasksBySide = [_logic, "tasksBySide"] call ALIVE_fnc_hashGet;
            _sideTasks = [_tasksBySide, _taskSide] call ALIVE_fnc_hashGet;
            [_sideTasks,_taskID] call ALIVE_fnc_hashRem;
            [_tasksBySide, _taskSide, _sideTasks] call ALIVE_fnc_hashSet;

            // remove from tasks by groups hash
            _tasksByGroup = [_logic, "tasksByGroup"] call ALIVE_fnc_hashGet;

            {
                _group = _x;
                _groupTasks = [_tasksByGroup,_group] call ALIVE_fnc_hashGet;
                [_groupTasks,_taskID] call ALIVE_fnc_hashRem;
                [_tasksByGroup, _group, _groupTasks] call ALIVE_fnc_hashSet;
            } forEach (_tasksByGroup select 1);

            // remove from tasks from player hash
            _tasksByPlayer = [_logic, "tasksByPlayer"] call ALIVE_fnc_hashGet;

            {
                _player = _x;
                _playerTasks = [_tasksByPlayer,_player] call ALIVE_fnc_hashGet;
                [_playerTasks,_taskID] call ALIVE_fnc_hashRem;
                [_tasksByPlayer, _player, _playerTasks] call ALIVE_fnc_hashSet;
            } forEach (_tasksByPlayer select 1);

            // remove from active tasks
            _activeTasks = [_logic,"activeTasks"] call ALIVE_fnc_hashGet;
            if(_taskID in (_activeTasks select 1)) then {
                [_activeTasks,_taskID] call ALIVE_fnc_hashRem;
            };

        };
    };
    case "updateTaskState": {
        private["_task","_taskID","_playerID","_taskSide","_debug","_tasksBySide","_sideTasks","_event","_tasksToDispatch",
        "_createTasks","_updateTasks","_deleteTasks","_autoGenerateSides","_autoGenerateSide"];

        if(typeName _args == "ARRAY") then {

            _task = _args;
            _playerID = _task select 1;
            _taskSide = _task select 2;

            _debug = [_logic,"debug"] call ALIVE_fnc_hashGet;
            _tasksBySide = [_logic, "tasksBySide"] call ALIVE_fnc_hashGet;
            _sideTasks = [_logic, "getTasksBySide", _taskSide] call MAINCLASS;
            _tasksToDispatch = [_logic,"tasksToDispatch"] call ALIVE_fnc_hashGet;
            _createTasks = [_tasksToDispatch,"create"] call ALIVE_fnc_hashGet;
            _updateTasks = [_tasksToDispatch,"update"] call ALIVE_fnc_hashGet;
            _deleteTasks = [_tasksToDispatch,"delete"] call ALIVE_fnc_hashGet;
            _autoGenerateSides = [_logic,"autoGenerateSides"] call ALIVE_fnc_hashGet;
            _autoGenerateSide = [_autoGenerateSides,_taskSide] call ALIVE_fnc_hashGet;

            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {

                private ["_tasks","_tasksByGroup","_tasksByPlayer","_activeTasks","_managedTasks"];
                _tasks = [_logic, "tasks"] call ALIVE_fnc_hashGet;
                _tasksByGroup = [_logic, "tasksByGroup"] call ALIVE_fnc_hashGet;
                _tasksByPlayer = [_logic, "tasksByPlayer"] call ALIVE_fnc_hashGet;
                _activeTasks = [_logic, "activeTasks"] call ALIVE_fnc_hashGet;
                _managedTasks = [_logic, "managedTasks"] call ALIVE_fnc_hashGet;

                ["TASK STATE UPDATED!!"] call ALIVE_fnc_dump;
                ["TASK STATE:"] call ALIVE_fnc_dump;
                _tasks call ALIVE_fnc_inspectHash;
                ["TASK BY SIDE STATE:"] call ALIVE_fnc_dump;
                _tasksBySide call ALIVE_fnc_inspectHash;
                ["SIDE TASKS: %1",_sideTasks] call ALIVE_fnc_dump;
                ["TASK BY GROUP STATE:"] call ALIVE_fnc_dump;
                _tasksByGroup call ALIVE_fnc_inspectHash;
                ["TASK BY PLAYER STATE:"] call ALIVE_fnc_dump;
                _tasksByPlayer call ALIVE_fnc_inspectHash;
                ["TASKS TO DISPATCH:"] call ALIVE_fnc_dump;
                _tasksToDispatch call ALIVE_fnc_inspectHash;
                ["ACTIVE TASKS:"] call ALIVE_fnc_dump;
                _activeTasks call ALIVE_fnc_inspectHash;
                ["MANAGED TASKS:"] call ALIVE_fnc_dump;
                _managedTasks call ALIVE_fnc_inspectHash;
                ["AUTO GENERATE SIDES:"] call ALIVE_fnc_dump;
                _autoGenerateSides call ALIVE_fnc_inspectHash;

            };
            // DEBUG -------------------------------------------------------------------------------------

            // dispatch create events
            {

                private ["_player","_task","_taskID","_requestPlayerID","_position","_title","_description","_state","_event","_current","_parent","_source"];

                _player = [_x] call ALIVE_fnc_getPlayerByUID;
                _task = [_createTasks,_x] call ALIVE_fnc_hashGet;

                _taskID = _task select 0;
                _requestPlayerID = _task select 1;
                _position = _task select 3;
                _title = _task select 5;
                _description = _task select 6;
                _state = _task select 8;
                _current = _task select 10;
                _parent = _task select 11;
                _source = _task select 12;

                _event = ["TASK_CREATE",_taskID,_requestPlayerID,_position,_title,_description,_state,_current,_parent,_source];

                if !(isNull _player) then {
                    if((isServer && isMultiplayer) || isDedicated) then {
                        _event remoteExec ["ALIVE_fnc_taskHandlerEventToClient",_player];
                    }else{
                        _event call ALIVE_fnc_taskHandlerEventToClient;
                    };
                };

            } forEach (_createTasks select 1);

            // dispatch update events
            {

                private ["_player","_task","_taskID","_requestPlayerID","_position","_title","_description","_state","_event","_current","_parent","_source"];

                _player = [_x] call ALIVE_fnc_getPlayerByUID;
                _task = [_updateTasks,_x] call ALIVE_fnc_hashGet;

                _taskID = _task select 0;
                _requestPlayerID = _task select 1;
                _position = _task select 3;
                _title = _task select 5;
                _description = _task select 6;
                _state = _task select 8;
                _current = _task select 10;
                _parent = _task select 11;
                _source = _task select 12;

                _event = ["TASK_UPDATE",_taskID,_requestPlayerID,_position,_title,_description,_state,_current,_parent,_source];

                if !(isNull _player) then {
                    if((isServer && isMultiplayer) || isDedicated) then {
                        _event remoteExec ["ALIVE_fnc_taskHandlerEventToClient",_player];
                    }else{
                        _event call ALIVE_fnc_taskHandlerEventToClient;
                    };
                };

            } forEach (_updateTasks select 1);

            // dispatch delete events
            {

                private ["_player","_task","_taskID","_requestPlayerID","_position","_title","_description","_state","_event","_current","_parent","_source"];

                _player = [_x] call ALIVE_fnc_getPlayerByUID;
                _task = [_deleteTasks,_x] call ALIVE_fnc_hashGet;

                _taskID = _task select 0;
                _requestPlayerID = _task select 1;
                _position = _task select 3;
                _title = _task select 5;
                _description = _task select 6;
                _state = _task select 8;
                _current = _task select 10;
                _parent = _task select 11;
                _source = _task select 12;

                _event = ["TASK_DELETE",_taskID,_requestPlayerID,_position,_title,_description,_state,_current,_parent,_source];

                if !(isNull _player) then {
                    if((isServer && isMultiplayer) || isDedicated) then {
                        _event remoteExec ["ALIVE_fnc_taskHandlerEventToClient",_player];
                    }else{
                        _event call ALIVE_fnc_taskHandlerEventToClient;
                    };
                };

            } forEach (_deleteTasks select 1);

            [_tasksToDispatch,"create",[] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet;
            [_tasksToDispatch,"update",[] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet;
            [_tasksToDispatch,"delete",[] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet;

            _event = ['TASKS_UPDATED', [_playerID,[_sideTasks,_autoGenerateSide]], "TASK_HANDLER"] call ALIVE_fnc_event;
            [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;

        };
    };
    case "startManagement": {

        private ["_debug","_handle"];

        _debug = [_logic,"debug"] call ALIVE_fnc_hashGet;

        // DEBUG -------------------------------------------------------------------------------------
        if(_debug) then {
            ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
            ["ALiVE Task Handler - Task Manager Started"] call ALIVE_fnc_dump;
        };
        // DEBUG -------------------------------------------------------------------------------------

        // spawn the manager thread
        _handle = [_logic, _debug] spawn {

            private ["_logic","_debug","_managedTasks","_activeTasks","_managedTasksToRemove","_managedTaskID","_managedTaskParams",
            "_taskSide","_taskSource","_taskParent","_taskParams","_taskID","_task","_nextTask","_taskState","_autoGenerateSides",
            "_sideAutoGeneration"];

            _logic = _this select 0;
            _debug = _this select 1;

            // start the manager loop
            waituntil {

                _managedTasks = [_logic,"managedTasks"] call ALIVE_fnc_hashGet;
                _activeTasks = [_logic,"activeTasks"] call ALIVE_fnc_hashGet;
                _managedTaskParams = [_logic,"managedTaskParams"] call ALIVE_fnc_hashSet;

                _managedTasksToRemove = [];

                {
                    _managedTaskID = _x;
                    if!(_managedTaskID in (_activeTasks select 1)) then {
                        _managedTasksToRemove set [count _managedTasksToRemove,_x];
                    };
                } forEach (_managedTasks select 1);

                {
                    [_managedTasks,_x] call ALIVE_fnc_hashRem;
                } forEach _managedTasksToRemove;

                if(count (_managedTasks select 1) > 0) then {

                    // for each of the tasks
                    {
                        _taskID = _x;
                        _task = [_logic, "getTask", _taskID] call MAINCLASS;
                        _taskSide = _task select 2;
                        _taskSource = _task select 12;
                        _taskSource = [_taskSource, "-"] call CBA_fnc_split;

                        _taskParams = [_managedTaskParams,_taskSource select 0] call ALIVE_fnc_hashGet;


                        // DEBUG -------------------------------------------------------------------------------------
                        if(_debug) then {
                            ["ALiVE Task Handler - Manage Task:"] call ALIVE_fnc_dump;
                            _task call ALIVE_fnc_inspectArray;
                            _taskParams call ALIVE_fnc_inspectHash;
                        };
                        // DEBUG -------------------------------------------------------------------------------------


                        _task = [_taskSource select 2, _taskID, _task, _taskParams, _debug] call (call compile format["ALIVE_fnc_task%1",_taskSource select 1]);

                        if(count _task > 0) then {

                            [_logic, "updateTask", _task] call MAINCLASS;
                            [_logic, "updateTaskState", _task] call MAINCLASS;

                            _nextTask = [_taskParams,"nextTask"] call ALIVE_fnc_hashGet;

                            // if the task has returned an update
                            // and there is a next task set in the params
                            // continue on to the next task

                            if(_nextTask != "") then {

                                _task = [_logic, "getTask", _nextTask] call MAINCLASS;
                                _task set [8, "Assigned"];
                                _task set [10, "Y"];

                                [_logic, "updateTask", _task] call MAINCLASS;
                                [_logic, "updateTaskState", _task] call MAINCLASS;

                            }else{

                                _taskState = _task select 8;

                                _task = [_logic, "getTask", _taskSource select 0] call MAINCLASS;
                                _task set [8, _taskState];
                                _task set [10, "N"];

                                [_logic, "updateTask", _task] call MAINCLASS;
                                [_logic, "updateTaskState", _task] call MAINCLASS;

                                _autoGenerateSides = [_logic,"autoGenerateSides"] call ALIVE_fnc_hashGet;
                                _sideAutoGeneration = [_autoGenerateSides,_taskSide] call ALIVE_fnc_hashGet;

                                if(_sideAutoGeneration select 0) then {

                                    sleep 10;

                                    private ["_requestPlayerID","_taskFaction","_taskEnemyFaction","_generate"];

                                    _requestPlayerID = _task select 1;
                                    _taskFaction = _task select 4;
                                    _taskEnemyFaction = [_taskParams,"enemyFaction"] call ALIVE_fnc_hashGet;

                                    _generate = [format["%1_%2",_taskSide,time],_requestPlayerID,_taskSide,_taskFaction,_taskEnemyFaction,true];

                                    [_logic,"autoGenerateTasks",_generate] call MAINCLASS;
                                };

                            }

                        };

                    } forEach (_managedTasks select 2);

                }else{

                    [_logic, "stopManagement"] call MAINCLASS;

                };

                sleep 10;

                false
            };
        };

        [_logic,"isManaging",true] call ALIVE_fnc_hashSet;
        [_logic,"managerHandle",_handle] call ALIVE_fnc_hashSet;

    };
    case "stopManagement": {

        private ["_debug","_handle"];

        _debug = [_logic,"debug"] call ALIVE_fnc_hashGet;
        _handle = [_logic,"managerHandle"] call ALIVE_fnc_hashGet;

        if!(scriptDone _handle) then {
            terminate _handle;
        };

        [_logic,"isManaging",false] call ALIVE_fnc_hashSet;
        [_logic,"managerHandle",objNull] call ALIVE_fnc_hashSet;

        // DEBUG -------------------------------------------------------------------------------------
        if(_debug) then {
            ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
            ["ALiVE Task Handler - Task Manager Stopped"] call ALIVE_fnc_dump;
        };
        // DEBUG -------------------------------------------------------------------------------------

    };
    case "getTask": {
        private["_taskID","_tasks","_taskIndex"];

        if(typeName _args == "STRING") then {
            _taskID = _args;
            _tasks = [_logic, "tasks"] call ALIVE_fnc_hashGet;
            _taskIndex = _tasks select 1;
            if(_taskID in _taskIndex) then {
                _result = [_tasks, _taskID] call ALIVE_fnc_hashGet;
            }else{
                _result = nil;
            };
        };
    };
    case "getTasks": {
        _result = [_logic, "tasks"] call ALIVE_fnc_hashGet;
    };
    case "getTasksBySide": {
        private["_side","_tasksBySide","_sideTasks","_tasks"];

        if(typeName _args == "STRING") then {
            _side = _args;

            _tasksBySide = [_logic, "tasksBySide"] call ALIVE_fnc_hashGet;
            _sideTasks = [_tasksBySide, _side] call ALIVE_fnc_hashGet;

            _tasks = [];

            if!(isNil "_sideTasks") then {

                {
                    _tasks set [count _tasks, [_logic,"getTask",_x] call MAINCLASS];
                } forEach (_sideTasks select 1);

            };

            _result = _tasks;
        };
    };
    case "getTasksByPlayer": {
        private["_player","_tasksByPlayer","_playerTasks","_tasks","_task"];

        if(typeName _args == "STRING") then {
            _player = _args;

            _tasksByPlayer = [_logic, "tasksByPlayer"] call ALIVE_fnc_hashGet;
            _playerTasks = [_tasksByPlayer, _player] call ALIVE_fnc_hashGet;

            _tasks = [];

            if!(isNil "_playerTasks") then {

                {
                    _task = [_logic,"getTask",_x] call MAINCLASS;
                    _tasks set [count _tasks, _task];
                } forEach (_playerTasks select 1);

            };

            _result = _tasks;

        };
    };
    case "getTasksByGroup": {
        private["_group","_tasksByGroup","_groupTasks","_tasks","_task"];

        if(typeName _args == "STRING") then {
            _group = _args;

            _tasksByGroup = [_logic, "tasksByGroup"] call ALIVE_fnc_hashGet;

            _groupTasks = [_tasksByGroup, _group] call ALIVE_fnc_hashGet;

            _tasks = [];

            if!(isNil "_groupTasks") then {

                {
                    _task = [_logic,"getTask",_x] call MAINCLASS;
                    _tasks set [count _tasks, _task];
                } forEach (_groupTasks select 1);

            };

            _result = _tasks;
        };
    };
    default {
        _result = [_logic, _operation, _args] call SUPERCLASS;
    };
};
TRACE_1("taskHandler - output",_result);

if !(isnil "_result") then {_result} else {nil};