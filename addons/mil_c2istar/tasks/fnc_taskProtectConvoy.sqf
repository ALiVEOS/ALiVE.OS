#include "\x\alive\addons\mil_c2istar\script_component.hpp"
SCRIPT(taskProtectConvoy);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskProtectConvoy

Description:
Escort task riding a real LOGCOM resupply truck. The convoy's own side is asked
to screen the truck's route and keep it alive until it reaches the asset it is
resupplying. Outcome is read from the mil_logistics convoy-state latch
(ALIVE_MLConvoyTaskStates), keyed by a unique convoyID:
    "arrived"   -> Succeeded  (supplies delivered)
    "destroyed" -> Failed     (truck killed en route)
    "aborted"   -> Canceled   (AI pathing / timeout / target lost)

The mirror-image DestroyVehicles task rides the same truck for a hostile side.

Author:
Jman
---------------------------------------------------------------------------- */

private ["_taskState","_taskID","_task","_params","_debug","_result"];

_taskState = _this select 0;
_taskID = _this select 1;
_task = _this select 2;
_params = _this select 3;
_debug = _this select 4;
_result = [];

switch (_taskState) do {
    case "init":{

        private["_requestPlayerID","_taskSide","_taskFaction","_taskLocationType","_taskLocation","_taskEnemyFaction",
        "_taskCurrent","_taskApplyType","_convoyObjects","_payload","_convoyID","_destPos","_popEffect"];

        _taskID = _task select 0;
        _requestPlayerID = _task select 1;
        _taskSide = _task select 2;
        _taskFaction = _task select 3;
        _taskLocationType = _task select 5;
        _taskLocation = _task select 6;
        _taskPlayers = _task select 7;
        _taskEnemyFaction = _task select 8;
        _taskCurrent = _task select 9;
        _taskApplyType = _task select 10;

        if (_taskID == "") exitwith {["C2ISTAR - Task ProtectConvoy - Wrong input for _taskID!"] call ALiVE_fnc_Dump};
        if (_requestPlayerID == "") exitwith {["C2ISTAR - Task ProtectConvoy - Wrong input for _requestPlayerID!"] call ALiVE_fnc_Dump};
        if (_taskFaction == "") exitwith {["C2ISTAR - Task ProtectConvoy - Wrong input for _taskFaction!"] call ALiVE_fnc_Dump};
        if (_taskLocationType == "") exitwith {["C2ISTAR - Task ProtectConvoy - Wrong input for _taskLocationType!"] call ALiVE_fnc_Dump};
        if (count _taskLocation == 0) exitwith {["C2ISTAR - Task ProtectConvoy - Wrong input for _taskLocation!"] call ALiVE_fnc_Dump};
        if (count _taskPlayers == 0) exitwith {["C2ISTAR - Task ProtectConvoy - Wrong input for _taskPlayers!"] call ALiVE_fnc_Dump};
        if (_taskApplyType == "") exitwith {["C2ISTAR - Task ProtectConvoy - Wrong input for _taskApplyType!"] call ALiVE_fnc_Dump};

        // the convoy objects (index 11) and metadata (index 12) are mandatory -
        // this task can only exist off a live mil_logistics dispatch
        if (count _task <= 12) exitwith {["C2ISTAR - Task ProtectConvoy - No convoy payload! Aborting..."] call ALiVE_fnc_Dump};

        _convoyObjects = _task select 11;
        _payload = _task select 12;
        if (count _payload < 3) exitwith {["C2ISTAR - Task ProtectConvoy - No convoy payload! Aborting..."] call ALiVE_fnc_Dump};
        _convoyID = _payload select 0;
        _destPos = _payload select 1;
        _popEffect = _payload select 2;

        // pick a dialog variant

        private["_dialogOptions","_dialogOption","_nearestTown","_dialog","_formatDescription","_formatChat","_formatMessage","_formatMessageText"];

        _dialogOptions = [ALIVE_generatedTasks,"ProtectConvoy"] call ALIVE_fnc_hashGet;
        _dialogOptions = _dialogOptions select 1;
        _dialogOption = +(selectRandom _dialogOptions);

        // format the dialog copy against the destination

        _nearestTown = [_destPos] call ALIVE_fnc_taskGetNearestLocationName;

        _dialog = [_dialogOption,"Parent"] call ALIVE_fnc_hashGet;
        _formatDescription = [_dialog,"description"] call ALIVE_fnc_hashGet;
        _formatDescription = format[_formatDescription,_nearestTown];
        [_dialog,"description",_formatDescription] call ALIVE_fnc_hashSet;

        _dialog = [_dialogOption,"Escort"] call ALIVE_fnc_hashGet;
        _formatDescription = [_dialog,"description"] call ALIVE_fnc_hashGet;
        _formatDescription = format[_formatDescription,_nearestTown];
        [_dialog,"description",_formatDescription] call ALIVE_fnc_hashSet;

        _formatChat = [_dialog,"chat_start"] call ALIVE_fnc_hashGet;
        _formatMessage = _formatChat select 0;
        _formatMessageText = _formatMessage select 1;
        _formatMessageText = format[_formatMessageText,_nearestTown];
        _formatMessage set [1,_formatMessageText];
        _formatChat set [0,_formatMessage];
        [_dialog,"chat_start",_formatChat] call ALIVE_fnc_hashSet;

        // create the tasks

        private["_state","_tasks","_taskIDs","_taskTitle","_taskDescription","_newTask","_newTaskID","_taskParams","_taskSource"];

        if(_taskCurrent == 'Y')then {
            _state = "Assigned";
        }else{
            _state = "Created";
        };

        _tasks = [];
        _taskIDs = [];

        // parent task

        _dialog = [_dialogOption,"Parent"] call ALIVE_fnc_hashGet;
        _taskTitle = [_dialog,"title"] call ALIVE_fnc_hashGet;
        _taskDescription = [_dialog,"description"] call ALIVE_fnc_hashGet;
        _taskSource = format["%1-ProtectConvoy-Parent",_taskID];
        _newTask = [_taskID,_requestPlayerID,_taskSide,_destPos,_taskFaction,_taskTitle,_taskDescription,_taskPlayers,_state,_taskApplyType,"N","None",_taskSource,false];

        _tasks pushback _newTask;
        _taskIDs pushback _taskID;

        // escort child task

        _dialog = [_dialogOption,"Escort"] call ALIVE_fnc_hashGet;
        _taskTitle = [_dialog,"title"] call ALIVE_fnc_hashGet;
        _taskDescription = [_dialog,"description"] call ALIVE_fnc_hashGet;
        _newTaskID = format["%1_c2",_taskID];
        _taskSource = format["%1-ProtectConvoy-Escort",_taskID];
        _newTask = [_newTaskID,_requestPlayerID,_taskSide,_destPos,_taskFaction,_taskTitle,_taskDescription,_taskPlayers,_state,_taskApplyType,_taskCurrent,_taskID,_taskSource,true];

        _tasks pushback _newTask;
        _taskIDs pushback _newTaskID;

        // store task data in the params for this task set

        _taskParams = [] call ALIVE_fnc_hashCreate;
        [_taskParams,"nextTask",_taskIDs select 1] call ALIVE_fnc_hashSet;
        [_taskParams,"taskIDs",_taskIDs] call ALIVE_fnc_hashSet;
        [_taskParams,"dialog",_dialogOption] call ALIVE_fnc_hashSet;
        [_taskParams,"enemyFaction",_taskEnemyFaction] call ALIVE_fnc_hashSet;
        [_taskParams,"convoyObjects",_convoyObjects] call ALIVE_fnc_hashSet;
        [_taskParams,"convoyID",_convoyID] call ALIVE_fnc_hashSet;
        [_taskParams,"destPos",_destPos] call ALIVE_fnc_hashSet;
        [_taskParams,"popEffect",_popEffect] call ALIVE_fnc_hashSet;
        [_taskParams,"supportEffectPosition",_destPos] call ALIVE_fnc_hashSet;
        [_taskParams,"supportValue",10] call ALIVE_fnc_hashSet;
        [_taskParams,"cooldownDuration",3000] call ALIVE_fnc_hashSet;
        [_taskParams,"taskType","ProtectConvoy"] call ALIVE_fnc_hashSet;
        [_taskParams,"clusterID",""] call ALIVE_fnc_hashSet;
        [_taskParams,"nullTicks",0] call ALIVE_fnc_hashSet;
        [_taskParams,"lastState",""] call ALIVE_fnc_hashSet;

        // NOTE: no taskLockProfiles - the target is a raw truck object, not a
        // profile ID, so there are no crew entities to flag as busy.

        _result = [_tasks,_taskParams];

    };
    case "Parent":{

    };
    case "Escort":{

        private["_taskSide","_taskPosition","_taskFaction","_taskTitle","_lastState","_taskDialog","_currentTaskDialog",
        "_convoyObjects","_convoyID","_destPos","_popEffect","_convoyState","_anyAlive","_anyNonNull","_fnc_terminate","_nullTicks"];

        _taskID = _task select 0;
        _taskSide = _task select 2;
        _taskPosition = _task select 3;
        _taskFaction = _task select 4;
        _taskTitle = _task select 5;
        _taskPlayers = _task select 7 select 0;

        _lastState = [_params,"lastState"] call ALIVE_fnc_hashGet;
        _taskDialog = [_params,"dialog"] call ALIVE_fnc_hashGet;
        _currentTaskDialog = [_taskDialog,_taskState] call ALIVE_fnc_hashGet;
        _convoyObjects = [_params,"convoyObjects"] call ALIVE_fnc_hashGet;
        _convoyID = [_params,"convoyID"] call ALIVE_fnc_hashGet;
        _destPos = [_params,"destPos"] call ALIVE_fnc_hashGet;
        _popEffect = [_params,"popEffect"] call ALIVE_fnc_hashGet;

        if(_lastState != "Escort") then {
            ["chat_start",_currentTaskDialog,_taskSide,_taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
            [_params,"lastState","Escort"] call ALIVE_fnc_hashSet;
        };

        // read the mil_logistics latch (default "enroute" until the monitor writes)
        _convoyState = ([ALIVE_MLConvoyTaskStates, _convoyID, ["enroute",0]] call ALIVE_fnc_hashGet) select 0;

        _anyAlive = false;
        _anyNonNull = false;
        {
            if (!isNull _x) then {
                _anyNonNull = true;
                if (alive _x) then { _anyAlive = true; };
            };
        } forEach _convoyObjects;

        // fast-path: truck died before the ML monitor could latch "destroyed"
        if (_convoyState == "enroute" && _anyNonNull && {!_anyAlive}) then { _convoyState = "destroyed"; };

        // clears nextTask so taskHandler tears the finished task down instead of
        // resurrecting it every 10s; applies the one-shot hostility swing when
        // this task owns the population effect
        _fnc_terminate = {
            params ["_stateOut","_broadcast","_outcome"];
            [_params,"nextTask",""] call ALIVE_fnc_hashSet;
            _task set [8,_stateOut];
            _task set [10,"N"];
            _result = _task;
            [_taskPlayers,_taskID] call ALIVE_fnc_taskDeleteMarkersForPlayers;
            [_taskID] call ALIVE_fnc_taskReleaseTaskLocks;
            if (_broadcast != "") then {
                [_broadcast,_currentTaskDialog,_taskSide,_taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
            };
            if (_outcome != "" && {_popEffect isEqualTo true}) then {
                [_destPos, _taskSide, 10, ["", "ProtectConvoy", 3000, _outcome]] call ALIVE_fnc_taskApplyPopulationEffect;
            };
        };

        switch (_convoyState) do {
            case "arrived":{
                ["Succeeded","chat_success","success"] call _fnc_terminate;
                [_currentTaskDialog,_taskSide,_taskFaction] call ALIVE_fnc_taskCreateReward;
                if (_debug) then {["C2ISTAR - Task ProtectConvoy - Convoy %1 state %2 -> Succeeded",_convoyID,_convoyState] call ALiVE_fnc_dump;};
            };
            case "destroyed":{
                ["Failed","chat_failed","failure"] call _fnc_terminate;
                if (_debug) then {["C2ISTAR - Task ProtectConvoy - Convoy %1 state %2 -> Failed",_convoyID,_convoyState] call ALiVE_fnc_dump;};
            };
            case "aborted":{
                ["Canceled","",""] call _fnc_terminate;
                if (_debug) then {["C2ISTAR - Task ProtectConvoy - Convoy %1 state %2 -> Canceled",_convoyID,_convoyState] call ALiVE_fnc_dump;};
            };
            default {
                // still enroute
                if (!_anyNonNull) then {
                    // convoy objects all deleted but no terminal latch - the ML
                    // monitor thread likely died; cancel after 3 idle ticks
                    _nullTicks = ([_params,"nullTicks",0] call ALIVE_fnc_hashGet) + 1;
                    [_params,"nullTicks",_nullTicks] call ALIVE_fnc_hashSet;
                    if (_nullTicks >= 3) then {
                        ["Canceled","",""] call _fnc_terminate;
                        if (_debug) then {["C2ISTAR - Task ProtectConvoy - Convoy %1 vanished with no latch -> Canceled",_convoyID] call ALiVE_fnc_dump;};
                    };
                } else {
                    [_params,"nullTicks",0] call ALIVE_fnc_hashSet;
                    {
                        if (alive _x) then {
                            [getPos _x,_taskSide,_taskPlayers,_taskID,"vehicle",typeOf _x,_taskTitle] call ALIVE_fnc_taskCreateMarkersForPlayers;
                        };
                    } forEach _convoyObjects;
                };
            };
        };

    };
};

_result
