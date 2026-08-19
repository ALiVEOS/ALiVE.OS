#include "\x\alive\addons\mil_c2istar\script_component.hpp"
SCRIPT(taskLaze);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskLaze

Description:
ATO laze-assist player task. Raised by mil_ato when a Strike sortie is genuinely
inbound against a building target (the aircraftStart branch that already spawns
the LaserTargetW/E decoys). The player is asked to designate the marked building
with a laser designator while the air strike runs. The sortie does the killing:
the task SUCCEEDS when the tracked building is destroyed and FAILS when the strike
window expires. The player's laser designation is an assist/spot objective only -
it fires a one-shot radio confirmation and never gates completion. No laser-guided
/ SALH homing is involved anywhere (the #735 scope decision).

Task data array (_task):
    0  taskID
    1  requestPlayerID ("ATO")
    2  taskSide (side text)
    3  taskFaction
    4  taskType ("Laze")
    5  taskLocationType ("NULL")
    6  destination (target position)
    7  sidePlayers
    8  enemyFaction
    9  current ("Y")
    10 applyType ("Side")
    11 [targetBuilding]
    12 [decoyLasers, windowSeconds]   <- ATO sortie pairing payload

Parameters:
    0: STRING - task state ("init" / "Parent" / "Designate")
    1: STRING - task id
    2: ARRAY  - task data
    3: HASH   - persistent task params
    4: BOOL   - debug

Returns:
    ARRAY

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

        private _taskID = _task param [0, "", [""]];
        private _requestPlayerID = _task param [1, "", [""]];
        private _taskSide = _task param [2, "", [""]];
        private _taskFaction = _task param [3, "", [""]];
        private _taskType = _task param [4, "", [""]];
        private _taskLocationType = _task param [5, "", [""]];
        private _taskLocation = _task param [6, [], [[]]];
        private _taskPlayers = _task param [7, [], [[]]];
        private _taskEnemyFaction = _task param [8, "", [""]];
        private _taskCurrent = _task param [9, "", [""]];
        private _taskApplyType = _task param [10, "", [""]];
        private _targetBuildings = _task param [11, [], [[]]];

        if (_debug) then {
            ["ALIVE_fnc_taskLaze Task inputs: %1 | %2 | %3 | %4 | %5 | %6 | %7 | %8 | %9 | %10 | %11 | %12",
                _taskID,_requestPlayerID,_taskSide,_taskFaction,_taskLocationType,_taskLocation,
                _taskPlayers,_taskEnemyFaction,_taskCurrent,_taskApplyType,_taskType,_targetBuildings
            ] call ALiVE_fnc_Dump;
        };

        if (_taskID == "") exitwith {["C2ISTAR - Task Laze - Wrong input for _taskID!"] call ALiVE_fnc_Dump};
        if (_requestPlayerID == "") exitwith {["C2ISTAR - Task Laze - Wrong input for _requestPlayerID!"] call ALiVE_fnc_Dump};
        if (_taskFaction == "") exitwith {["C2ISTAR - Task Laze - Wrong input for _taskFaction!"] call ALiVE_fnc_Dump};
        if (count _taskPlayers == 0) exitwith {["C2ISTAR - Task Laze - Wrong input for _taskPlayers!"] call ALiVE_fnc_Dump};
        if (_taskEnemyFaction == "") exitwith {["C2ISTAR - Task Laze - Wrong input for _taskEnemyFaction!"] call ALiVE_fnc_Dump};
        if (_taskApplyType == "") exitwith {["C2ISTAR - Task Laze - Wrong input for _taskApplyType!"] call ALiVE_fnc_Dump};

        // This task only ever exists paired to a live sortie - there is no target
        // auto-resolution fallback (unlike SEAD/DestroyVehicles).
        if (count _task <= 12) exitwith {["C2ISTAR - Task Laze - No sortie payload, aborting! %1",_task] call ALiVE_fnc_Dump};
        if (count _targetBuildings == 0) exitwith {["C2ISTAR - Task Laze - No target object, aborting!"] call ALiVE_fnc_Dump};

        private _targetBuilding = _targetBuildings select 0;
        if (isNull _targetBuilding || {!alive _targetBuilding}) exitwith {["C2ISTAR - Task Laze - Target already gone, aborting!"] call ALiVE_fnc_Dump};

        private _sortiePayload = _task select 12;
        private _lazeDecoys = _sortiePayload param [0,[]];
        private _windowSeconds = (_sortiePayload param [1,900]) max 900;

        private _targetPosition = getposATL _targetBuilding;
        private _targetDisplayType = getText(configfile >> "CfgVehicles" >> (typeOf _targetBuilding) >> "displayName");
        if (_targetDisplayType == "") then {_targetDisplayType = "enemy position";};
        private _nearestTown = [_targetPosition] call ALIVE_fnc_taskGetNearestLocationName;

        // select the random dialog set (guard against a stale addons/main PBO that
        // predates the "Laze" dialog block, so we abort cleanly instead of erroring)
        private _dialogData = [ALIVE_generatedTasks,"Laze",[]] call ALIVE_fnc_hashGet;
        if (count _dialogData < 2) exitwith {["C2ISTAR - Task Laze - No 'Laze' dialog data found (rebuild addons/main), aborting!"] call ALiVE_fnc_Dump};
        private _dialogOptions = _dialogData select 1;
        private _dialogOption = +(selectRandom _dialogOptions);

        // Pre-format the Designate chat_start now (the work state broadcasts it by
        // key, so the %2 town placeholder has to be resolved at creation time -
        // same pattern as fnc_taskDestroyBuilding.sqf).
        private _dialogDesignate = [_dialogOption,"Designate"] call ALIVE_fnc_hashGet;
        private _formatChat = [_dialogDesignate,"chat_start"] call ALIVE_fnc_hashGet;
        if !(_formatChat isEqualTo []) then {
            private _formatMessage = _formatChat select 0;
            _formatMessage set [1, format[_formatMessage select 1, _targetDisplayType, _nearestTown]];
            _formatChat set [0,_formatMessage];
            [_dialogDesignate,"chat_start",_formatChat] call ALIVE_fnc_hashSet;
        };

        private _state = if (_taskCurrent == 'Y') then {"Assigned"} else {"Created"};

        private _tasks = [];
        private _taskIDs = [];

        // parent task
        private _dialogParent = [_dialogOption,"Parent"] call ALIVE_fnc_hashGet;
        private _parentTitle = format[[_dialogParent,"title"] call ALIVE_fnc_hashGet, _targetDisplayType, _nearestTown];
        private _parentDesc = format[[_dialogParent,"description"] call ALIVE_fnc_hashGet, _targetDisplayType, _nearestTown];
        private _parentSource = format["%1-Laze-Parent",_taskID];
        _tasks pushback [_taskID,_requestPlayerID,_taskSide,_targetPosition,_taskFaction,_parentTitle,_parentDesc,_taskPlayers,_state,_taskApplyType,"N","None",_parentSource,false];
        _taskIDs pushback _taskID;

        // child "Designate" task
        private _childTitle = format[[_dialogDesignate,"title"] call ALIVE_fnc_hashGet, _targetDisplayType, _nearestTown];
        private _childDesc = format[[_dialogDesignate,"description"] call ALIVE_fnc_hashGet, _targetDisplayType, _nearestTown];
        private _childID = format["%1_c2",_taskID];
        private _childSource = format["%1-Laze-Designate",_taskID];
        _tasks pushback [_childID,_requestPlayerID,_taskSide,_targetPosition,_taskFaction,_childTitle,_childDesc,_taskPlayers,_state,_taskApplyType,_taskCurrent,_taskID,_childSource,true];
        _taskIDs pushback _childID;

        // store task data in the params for this task set
        private _taskParams = [] call ALIVE_fnc_hashCreate;
        [_taskParams,"nextTask",_childID] call ALIVE_fnc_hashSet;
        [_taskParams,"taskIDs",_taskIDs] call ALIVE_fnc_hashSet;
        [_taskParams,"dialog",_dialogOption] call ALIVE_fnc_hashSet;
        [_taskParams,"enemyFaction",_taskEnemyFaction] call ALIVE_fnc_hashSet;
        [_taskParams,"targets",[_targetBuilding]] call ALIVE_fnc_hashSet;
        [_taskParams,"lazeDecoys",_lazeDecoys] call ALIVE_fnc_hashSet;
        [_taskParams,"expiryTime",time + _windowSeconds] call ALIVE_fnc_hashSet;
        [_taskParams,"lazeConfirmed",false] call ALIVE_fnc_hashSet;
        [_taskParams,"lastState",""] call ALIVE_fnc_hashSet;

        if (_debug) then {["C2ISTAR - Task Laze - Building: %1 | Type: %2 | Pos: %3 | Window: %4s",_targetBuilding,_targetDisplayType,_targetPosition,_windowSeconds] call ALiVE_fnc_Dump;};

        _result = [_tasks,_taskParams];
    };
    case "Parent":{

    };
    case "Designate":{

        private _taskID = _task select 0;
        private _taskSide = _task select 2;
        private _taskPosition = _task select 3;
        private _taskFaction = _task select 4;
        private _taskTitle = _task select 5;
        private _taskPlayers = _task select 7 select 0;

        private _lastState = [_params,"lastState"] call ALIVE_fnc_hashGet;
        private _taskDialog = [_params,"dialog"] call ALIVE_fnc_hashGet;
        private _currentTaskDialog = [_taskDialog,_taskState] call ALIVE_fnc_hashGet;
        private _targets = [_params,"targets"] call ALIVE_fnc_hashGet;
        private _lazeDecoys = [_params,"lazeDecoys",[]] call ALIVE_fnc_hashGet;
        private _expiryTime = [_params,"expiryTime",0] call ALIVE_fnc_hashGet;
        private _lazeConfirmed = [_params,"lazeConfirmed",false] call ALIVE_fnc_hashGet;

        // clears nextTask so taskHandler tears the finished task down instead of
        // re-running it every tick (matches the sibling task terminate pattern)
        private _fnc_terminate = {
            params ["_stateOut","_broadcast"];
            [_params,"nextTask",""] call ALIVE_fnc_hashSet;
            _task set [8,_stateOut];
            _task set [10,"N"];
            _result = _task;
            [_taskPlayers,_taskID] call ALIVE_fnc_taskDeleteMarkersForPlayers;
            if (_broadcast != "") then {
                [_broadcast,_currentTaskDialog,_taskSide,_taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
            };
        };

        // vacuous guard (defensive - Laze always tracks exactly one target)
        if (count _targets == 0) exitWith { ["Succeeded","chat_success"] call _fnc_terminate; };

        // one-shot task-start radio
        if (_lastState != "Designate") then {
            ["chat_start",_currentTaskDialog,_taskSide,_taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
            [_params,"lastState","Designate"] call ALIVE_fnc_hashSet;
        };

        // COMPLETION: the sortie destroyed the tracked building. Checked BEFORE
        // expiry so a strike landing on the deadline tick still succeeds. The util
        // treats null-or-dead as destroyed, which matters because mil_ato's KILLED
        // handler deleteVehicle's the building.
        private _targetsState = [_targets] call ALIVE_fnc_taskGetStateOfObjects;
        private _allDestroyed = [_targetsState,"allDestroyed"] call ALIVE_fnc_hashGet;

        if (_allDestroyed) then {

            ["Succeeded","chat_success"] call _fnc_terminate;
            [_currentTaskDialog,_taskSide,_taskFaction] call ALIVE_fnc_taskCreateReward;

        } else {

            if (time > _expiryTime) then {

                // strike window closed - the sortie was shot down, aborted, missed,
                // or never flew. Fail cleanly rather than hang forever.
                ["Failed","chat_failed"] call _fnc_terminate;

            } else {

                // ASSIST-ONLY player laze detection, adapted from
                // sup_combatsupport/scripts/NEO_radio/functions/misc/fn_casScriptedAttack.sqf:330-351.
                // A confirmed player designation fires a one-shot "good lase" radio
                // only. It NEVER gates, accelerates or triggers completion, and nothing
                // steers ordnance onto the player's laser (no SALH / homing - #735).
                if !(_lazeConfirmed) then {
                    private _sideObj = [_taskSide] call ALIVE_fnc_sideTextToObject;
                    // match by class convention - `side` on a laser object is unreliable
                    private _ownLaserClass = if (_sideObj getFriend WEST > 0.6) then {"LaserTargetW"} else {"LaserTargetE"};
                    private _laseR = 1500;
                    // route 1: laser objects near the target, excluding this sortie's own
                    // decoys AND every scripted laser. A scripted laser is attachTo'd to a
                    // dummy/vehicle; a player's designator dot never is, so isNull attachedTo
                    // keeps only genuine player designations (closes cross-sortie / combat
                    // support laser leakage the decoy list alone cannot see).
                    private _pLazes = (nearestObjects [_taskPosition, ["LaserTargetBase"], _laseR]) select {
                        !(_x in _lazeDecoys) && {isNull (attachedTo _x)} && {_x isKindOf _ownLaserClass}
                    };
                    // route 2: ask each same-or-allied-side player's engine laserTarget directly
                    if (_pLazes isEqualTo []) then {
                        {
                            private _lt = laserTarget _x;
                            if (!isNull _lt && {isNull (attachedTo _lt)} && {_lt distance2D _taskPosition <= _laseR} && {!(_lt in _lazeDecoys)}) exitWith { _pLazes = [_lt]; };
                        } forEach (allPlayers select { (side _x) == _sideObj || {(_sideObj getFriend (side _x)) >= 0.6} });
                    };
                    if !(_pLazes isEqualTo []) then {
                        [_params,"lazeConfirmed",true] call ALIVE_fnc_hashSet;
                        ["chat_laze",_currentTaskDialog,_taskSide,_taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
                    };
                };

                // refresh markers (single tracked target, alive here since not allDestroyed)
                private _taskEnemyFaction = [_params,"enemyFaction"] call ALIVE_fnc_hashGet;
                private _taskEnemySide = _taskEnemyFaction call ALiVE_fnc_factionSide;
                {
                    private _position = getposATL _x;
                    private _objectType = getText(configfile >> "CfgVehicles" >> (typeOf _x) >> "displayName");
                    [_position,_taskEnemySide,_taskPlayers,_taskID,"building",_objectType,_taskTitle] call ALIVE_fnc_taskCreateMarkersForPlayers;
                } forEach ([_targetsState,"targets"] call ALIVE_fnc_hashGet);
            };
        };
    };
};

_result
