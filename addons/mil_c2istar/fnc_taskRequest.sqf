#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(taskRequest);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_taskRequest

Description:
Send a task request to C2ISTAR

Parameters:
string - requesting side
string - requesting faction
string - type of task
array - targets (can be objects or string representing profile ID)
string - module or playerID making request
boolean - integrate with C2ISTAR auto task generation

Returns:
Boolean - if request was sent

Examples:
(begin example)
["WEST","BLU_F","CaptureObjective",["OPF-entity_14"],"OPCOM",true] call ALiVE_fnc_taskRequest;
(end)

See Also:
- nil

Author:
Tupolov

Peer reviewed:
nil
---------------------------------------------------------------------------- */
private _args = _this;

private _side = _args select 0; // Calling side
private _faction = _args select 1; // Calling faction
private _type = _args select 2; // Type of task
private _targets = _args select 3; // array of objects or profile IDs
private _playerID = _args select 4; // module name or player ID
private _strategic = _args select 5; // If this should integrate with C2ISTAR auto task generation functionality

["ALIVE PLAYER TASK REQUEST %1", _this] call ALIVE_fnc_dump;

// Check faction has strategic tasks turned on
private _autoGenerateStrategicTasks = false;

if (isNil "ALIVE_MIL_C2ISTAR") exitwith {
    ["ALIVE PLAYER TASK REQUEST FAILED! NO C2ISTAR MODULE AVAILABLE!"] call ALIVE_fnc_dump;

    _autoGenerateStrategicTasks
};

private _logic = ALIVE_MIL_C2ISTAR;

if (_strategic) then {
    // Check auto task generation is turned on for side and faction
    switch (_side) do {
        case "GUER": {
            private _autoGenerateINDFOR = [_logic, "autoGenerateIndfor"] call ALiVE_fnc_C2ISTAR;
            private _autoGenerateINDFORFaction = [_logic, "autoGenerateIndforFaction"] call ALiVE_fnc_C2ISTAR;
            if (_autoGenerateINDFOR == "Strategic" && {_faction == _autoGenerateINDFORFaction}) then {_autoGenerateStrategicTasks = true};
        };
        case "EAST": {
            private _autoGenerateOPFOR = [_logic, "autoGenerateOpfor"] call ALiVE_fnc_C2ISTAR;
            private _autoGenerateOPFORFaction = [_logic, "autoGenerateOpforFaction"] call ALiVE_fnc_C2ISTAR;
            if (_autoGenerateOPFOR == "Strategic" && {_faction == _autoGenerateOPFORFaction}) then {_autoGenerateStrategicTasks = true};
        };
        default {
            private _autoGenerateBLUFOR = [_logic, "autoGenerateBlufor"] call ALiVE_fnc_C2ISTAR;
            private _autoGenerateBLUFORFaction = [_logic, "autoGenerateBluforFaction"] call ALiVE_fnc_C2ISTAR;
            if (_autoGenerateBLUFOR == "Strategic" && {_faction == _autoGenerateBLUFORFaction}) then {_autoGenerateStrategicTasks = true};
        };
    };

} else {
    _autoGenerateStrategicTasks = true;
};

if (_autoGenerateStrategicTasks) then {

    if (isNil QGVAR(playerRequests)) then {
        GVAR(playerRequests) = [] call ALiVE_fnc_hashCreate;
    };

    // Check to see if this target has already been handed to players
    private _target = nil;
    private _currentTargets = [GVAR(playerRequests),_type,[]] call ALiVE_fnc_hashGet;

    {
        if !(_x in _currentTargets) exitWith {
            _target = _x;
        };
    } foreach _targets;

    if !(isNil "_target") then {

        _currentTargets pushback _target;

        private _destination = [];
        private _enemyFaction = "OPF_F";

        // Target could be profiled aircraft, profile AA, non-profiled AA, building, HQ
        if (typeName _target == "STRING") then {
            private _targetProfile = [ALiVE_profileHandler, "getProfile", _target] call ALiVE_fnc_ProfileHandler;
            _targetProfile call ALiVE_fnc_inspecthash;
            if !(isNil "_targetProfile") then {
                _destination = [_targetProfile, "position"] call ALiVE_fnc_hashGet;
                _enemyFaction = [_targetProfile, "faction"] call ALiVE_fnc_hashGet;
            };
        } else {
            _destination = position _target;
            _enemyFaction = faction _target;
        };

        private _requestID = format["%1_%2",_faction,floor(time)];

        // All players in side
        private _sidePlayers = [_side] call ALiVE_fnc_getPlayersDataSource;
        _sidePlayers = [_sidePlayers select 1, _sidePlayers select 0];

        private _current = "Y";
        private _apply = "Side";

        if ([_logic,"debug"] call ALiVE_fnc_C2ISTAR) then {
            ["CREATING PLAYER TASK %1 %2", _args, [_requestID,_playerID,_side,_faction,_type,"Map",_destination,_sidePlayers,_enemyFaction,_current,_apply,[_target]]] call ALIVE_fnc_dump;
        };

        private _targetArray = [_target];

        private _taskData = [_requestID,_playerID,_side,_faction,_type,"Map",_destination,_sidePlayers,_enemyFaction,_current,_apply,_targetArray];

        [GVAR(playerRequests), _type, _currentTargets] call ALiVE_fnc_hashSet;

        private _event = ["TASK_GENERATE", _taskData, "C2ISTAR"] call ALIVE_fnc_event;
        [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;

    } else {
        _autoGenerateStrategicTasks = false;
    };
};

_autoGenerateStrategicTasks