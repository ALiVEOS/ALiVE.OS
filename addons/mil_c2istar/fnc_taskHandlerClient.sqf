#include "\x\alive\addons\mil_c2istar\script_component.hpp"
SCRIPT(taskHandlerClient);

/* ----------------------------------------------------------------------------
Function: MAINCLASS
Description:
Clientside task repository and handling

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Attributes:


Examples:
(begin example)

(end)

See Also:

Author:
ARJay
Jman

Peer reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClassHash
#define MAINCLASS ALIVE_fnc_taskHandlerClient
#define MTEMPLATE "ALiVE_TASKHANDLER_%1"

private ["_result"];

TRACE_1("taskHandlerClient - input",_this);

params [
    ["_logic", [], [[]]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,[],"",0,true,false]]
];
//_result = true;

if (count _logic == 0) exitwith {};

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

        _tasks = [_logic, "tasks"] call ALIVE_fnc_hashGet;

        _tasks call ALIVE_fnc_hashInspect;

        _result = _args;
    };
    case "init": {
        private["_tasksBySide","_tasksToDispatch"];

        // if server, initialise module game logic
        [_logic,"super"] call ALIVE_fnc_hashRem;
        [_logic,"class",MAINCLASS] call ALIVE_fnc_hashSet;
        TRACE_1("After module init",_logic);

        // set defaults
        [_logic,"debug",false] call ALIVE_fnc_hashSet;
        [_logic,"tasks",[] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet;

    };
    case "handleEvent": {
        private["_event","_type"];

        if(typeName _args == "ARRAY") then {

            _event = _args;
            _type = _event select 0;

            [_logic, _type, _event] call MAINCLASS;

            //["CLIENT TASK HANDLER HANDLE EVENT: %1",_event] call ALIVE_fnc_dump;

        };
    };
    case "TASK_CREATE": {
        private["_eventData"];

        _eventData = _args;

        //["TASK CREATE: %1",_eventData] call ALIVE_fnc_dump;

        [_logic, "registerTask", _eventData] call MAINCLASS;

    };
    case "TASK_UPDATE": {
        private["_eventData"];

        _eventData = _args;

        //["TASK UPDATE: %1",_eventData] call ALIVE_fnc_dump;

        [_logic, "updateTask", _eventData] call MAINCLASS;

    };
    case "TASK_DELETE": {
        private["_eventData","_taskID"];

        _eventData = _args;

        _taskID = _eventData select 1;

        //["TASK DELETE: %1",_eventData] call ALIVE_fnc_dump;

        [_logic, "unregisterTask", _taskID] call MAINCLASS;

    };
    case "registerTask": {
        private["_task","_taskID","_requestingPlayer","_position","_title","_description","_state","_current","_parent","_source","_taskObject","_tasks","_parentTask","_parentTaskObject"];

        if(typeName _args == "ARRAY") then {

            _task = _args;

            _taskID = _task select 1;
            _requestingPlayer = _task select 2;
            _position = _task select 3;
            _title = _task select 4;
            _description = _task select 5;
            _state = _task select 6;
            _current = _task select 7;
            _parent = _task select 8;
            _source = _task select 9;

            // A task this player already has is updated, not built a second time: a second createSimpleTask left the
            // first as an orphan in the list (A. Ares, 18 Oct)
            if !(isNil {[_logic, "getTask", _taskID] call MAINCLASS}) exitWith {
                [_logic, "updateTask", _task] call MAINCLASS;
            };
            // a task the server sends again (a player back on its list after leaving it) is wanted again, so it comes
            // off the removed list that stops late updates rebuilding it
            private _removed = [_logic, "removedTasks", []] call ALIVE_fnc_hashGet;
            if (_taskID in _removed) then { _removed deleteAt (_removed find _taskID); [_logic, "removedTasks", _removed] call ALIVE_fnc_hashSet };

            // A subtask whose parent hasn't reached this player yet waits for it (up to 10 s) rather than being made a
            // top-level task: an HVT task's "Eliminate the target" showed un-nested under "Assassinate the HVT"
            // (A. Ares, 18 Oct). One waiter per task: an event for it during the wait replaces the copy it will use,
            // so the task is built once, from its latest state.
            if (_parent != "None" && {isNil {[_logic, "getTask", _parent] call MAINCLASS}} && {!(_task param [11, false])}) exitWith {
                private _pending = [_logic, "pendingTasks", [] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashGet;
                private _waiting = !isNil {[_pending, _taskID] call ALIVE_fnc_hashGet};
                [_pending, _taskID, _task] call ALIVE_fnc_hashSet;
                [_logic, "pendingTasks", _pending] call ALIVE_fnc_hashSet;
                if (_waiting) exitWith {};
                [_logic, _taskID, _parent] spawn {
                    params ["_logic", "_taskID", "_parent"];
                    private _until = diag_tickTime + 10;
                    waitUntil { sleep 0.25; !(isNil {[_logic, "getTask", _parent] call ALiVE_fnc_taskHandlerClient}) || {diag_tickTime > _until} };
                    private _pending = [_logic, "pendingTasks"] call ALIVE_fnc_hashGet;
                    private _latest = [_pending, _taskID] call ALIVE_fnc_hashGet;
                    [_pending, _taskID] call ALIVE_fnc_hashRem;
                    if (isNil "_latest") exitWith {};
                    // removed while it waited (its task ended): nothing to build
                    if (_taskID in ([_logic, "removedTasks", []] call ALIVE_fnc_hashGet)) exitWith {};
                    private _late = +_latest; _late resize 12; _late set [11, true];
                    [_logic, "registerTask", _late] call ALiVE_fnc_taskHandlerClient;
                };
            };

            if(_parent != "None") then {
                _parentTask = [_logic,"getTask",_parent] call MAINCLASS;

                if !(isnil "_parentTask") then {
                    _parentTaskObject = _parentTask select 10;
                    _taskObject = player createSimpleTask [_title,_parentTaskObject];
                } else {
                    _taskObject = player createSimpleTask [_title];
                };
            }else{
                _taskObject = player createSimpleTask [_title];
            };

            // ALiVE's pin for the kind of task, read from its source ("<id>-<TaskType>-<Stage>"), so a stage shows its
            // parent's pin. Arma's own pin when the player picked it in Addon Options, or for a task with no type
            // (one a player placed by hand) or a type with no pin.
            if (missionNamespace getVariable ["ALiVE_prefTaskPins", "alive"] == "alive" && {_source isEqualType ""}) then {
                private _sourceParts = _source splitString "-";
                if (count _sourceParts >= 3) then {
                    private _pinType = format ["alive_pin_%1", toLower (_sourceParts select (count _sourceParts - 2))];
                    if (isClass (configFile >> "CfgTaskTypes" >> _pinType)) then { _taskObject setSimpleTaskType _pinType };
                };
            };

            _taskObject setSimpleTaskDescription [_description,_title,_title];
            // a task can start with no destination (a recruiter task until the man is found)
            if (_position isEqualType [] && {count _position >= 2}) then { _taskObject setSimpleTaskDestination _position };
            _taskObject setTaskState _state;

            switch(_state) do {
                case "Created": {
                    ["TaskCreated",["",_title]] call BIS_fnc_showNotification;
                };
                case "Assigned": {
                    ["TaskAssigned",["",_title]] call BIS_fnc_showNotification;
                };
                case "Succeeded": {
                    ["TaskSucceeded",["",_title]] call BIS_fnc_showNotification;
                    _current = "N";
                };
                case "Failed": {
                    ["TaskFailed",["",_title]] call BIS_fnc_showNotification;
                    _current = "N";
                };
                case "Canceled": {
                    ["TaskCanceled",["",_title]] call BIS_fnc_showNotification;
                    _current = "N";
                };
            };

            if(_current == "Y") then {
                player setCurrentTask _taskObject;
            };

            // Optional AO ellipse marker around the task position (#689).
            // Shown only when the task is Assigned AND set as the player's
            // current task; hidden for created-but-not-accepted /
            // completed / failed / canceled / non-current. Mission-maker
            // configures the radius via the C2ISTAR "Task AO Radius"
            // attribute; 0 (default) disables drawing entirely. Hook fires
            // for every c2istar-routed task (auto-generated, player-
            // requested via the c2istar menu, civic Hearts-and-Minds).
// AO refresh is driven by a CBA per-frame handler in XEH_postInit
// so it picks up current-task changes regardless of source (c2istar
// menu, BI task UI Assign button, scripted setCurrentTask).

            _task set [10,_taskObject];

            // store in main tasks hash
            _tasks = [_logic, "tasks"] call ALIVE_fnc_hashGet;
            [_tasks,_taskID,_task] call ALIVE_fnc_hashSet;

        };
    };
    case "updateTask": {
        private["_updatedTask","_taskID","_requestingPlayer","_position","_title","_description","_state","_current","_parent","_source","_taskObject","_tasks","_task"];

        if(typeName _args == "ARRAY") then {

            _updatedTask = _args;

            _taskID = _updatedTask select 1;
            _requestingPlayer = _updatedTask select 2;
            _position = _updatedTask select 3;
            _title = _updatedTask select 4;
            _description = _updatedTask select 5;
            _state = _updatedTask select 6;
            _current = _updatedTask select 7;
            _parent = _updatedTask select 8;
            _source = _updatedTask select 9;

            _task = [_logic, "getTask", _taskID] call MAINCLASS;

            if(isNil "_task") exitWith {
                // an update for a task this player doesn't have builds it, unless it or its parent was removed here
                // (a late update after the task ended made an orphan top-level task). A genuine re-send comes as a
                // create, which registerTask accepts whatever this list says.
                private _removed = [_logic, "removedTasks", []] call ALIVE_fnc_hashGet;
                if !(_taskID in _removed || {_parent in _removed}) then {
                    [_logic, "registerTask", _updatedTask] call MAINCLASS;
                };
            };

            _taskObject = _task select 10;

            // Read the previously-stored state + position so the update
            // path can decide whether visible side-effects (notification
            // toast, BI task-state setter, destination move) need to fire.
            // The centroid-drift live-tracking in task types like
            // taskDestroyInfantry fires TASK_UPDATE every ~100m of target
            // movement; without these guards each update re-fires the
            // "TaskAssigned" toast and re-calls setTaskState/Destination
            // which surfaces as notification spam and (suspected) BI
            // task-marker duplication when timing races trigger a
            // registerTask fallthrough.
            private _previousState = _task select 6;
            private _previousPosition = _task select 3;

            _taskObject setSimpleTaskDescription [_description,_title,_title];

            // Only call setSimpleTaskDestination when the position actually
            // changed. Cuts the work for centroid-drift updates that didn't
            // pass the 100 m threshold (defensive — those shouldn't reach
            // here in the first place) and prevents the BI engine from
            // briefly re-rendering the pin at every TASK_UPDATE.
            if (typeName _position == "ARRAY" && {count _position >= 2}) then {
                if (!(typeName _previousPosition == "ARRAY" && {count _previousPosition >= 2})
                    || {(_previousPosition distance2D _position) > 0.5}) then {
                    _taskObject setSimpleTaskDestination _position;
                };
            };

            // setTaskState is the BI hook that fires the engine's own
            // notification + task-list update. Only call it on a state
            // CHANGE so position-only updates don't re-fire the chain.
            if (_previousState != _state) then {
                _taskObject setTaskState _state;

                switch(_state) do {
                    case "Created": {
                        ["TaskCreated",["",_title]] call BIS_fnc_showNotification;
                    };
                    case "Assigned": {
                        ["TaskAssigned",["",_title]] call BIS_fnc_showNotification;
                    };
                    case "Succeeded": {
                        ["TaskSucceeded",["",_title]] call BIS_fnc_showNotification;
                        _current = "N";
                    };
                    case "Failed": {
                        ["TaskFailed",["",_title]] call BIS_fnc_showNotification;
                        _current = "N";
                    };
                    case "Canceled": {
                        ["TaskCanceled",["",_title]] call BIS_fnc_showNotification;
                        _current = "N";
                    };
                };
            };

            if(_current == "Y") then {
                player setCurrentTask _taskObject;
            };

            // Refresh AO marker against the task's new state - hides
            // when state moves off Assigned or the task is no longer
            // current. See registerTask above for the hook details.
// AO refresh is driven by a CBA per-frame handler in XEH_postInit
// so it picks up current-task changes regardless of source (c2istar
// menu, BI task UI Assign button, scripted setCurrentTask).

            _updatedTask set [10,_taskObject];

            // update in main tasks hash
            _tasks = [_logic, "tasks"] call ALIVE_fnc_hashGet;
            [_tasks,_taskID,_updatedTask] call ALIVE_fnc_hashSet;

        };
    };
    case "unregisterTask": {
        private["_task","_taskID","_tasks","_taskObject"];

        if(typeName _args == "STRING") then {

            _taskID = _args;

            // remembered as removed, so a late event can't build it again (kept to the last 200)
            private _removed = [_logic, "removedTasks", []] call ALIVE_fnc_hashGet;
            _removed pushBackUnique _taskID;
            if (count _removed > 200) then { _removed deleteRange [0, count _removed - 200] };
            [_logic, "removedTasks", _removed] call ALIVE_fnc_hashSet;

            _task = [_logic, "getTask", _taskID] call MAINCLASS;
            if (isNil "_task") exitWith {};

            // its subtasks go with it: removing only the parent left them in the list as top-level tasks
            _tasks = [_logic, "tasks"] call ALIVE_fnc_hashGet;
            private _children = [];
            { if ((_x param [8, ""]) isEqualTo _taskID) then { _children pushBack (_x select 1) } } forEach (_tasks select 2);
            { [_logic, "unregisterTask", _x] call MAINCLASS } forEach _children;

            _taskObject = _task select 10;

            player removeSimpleTask _taskObject;

            // remove from main tasks hash
            _tasks = [_logic, "tasks"] call ALIVE_fnc_hashGet;
            [_tasks,_taskID] call ALIVE_fnc_hashRem;
            [_logic, "tasks", _tasks] call ALIVE_fnc_hashSet;

        };
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
    default {
        _result = [_logic, _operation, _args] call SUPERCLASS;
    };
};
TRACE_1("taskHandlerClient - output",_result);

if !(isnil "_result") then {_result} else {nil};