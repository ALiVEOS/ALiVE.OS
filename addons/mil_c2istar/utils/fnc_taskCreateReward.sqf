#include <\x\alive\addons\mil_C2ISTAR\script_component.hpp>
SCRIPT(taskCreateReward);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskCreateReward

Description:
Create a reward for task completion

Parameters:

Returns:

Examples:
(begin example)
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_taskDialog","_taskSide","_taskFaction","_rewardData","_rewardType","_reward","_event"];

_taskDialog = _this select 0;
_taskSide = _this select 1;
_taskFaction = _this select 2;

_rewardData = [_taskDialog,"reward"] call ALIVE_fnc_hashGet;
_rewardType = _rewardData select 0;
_reward = _rewardData select 1;

switch(_rewardType) do {
    case "forcePool":{

        private ["_sideObject","_factionName","_forcePool","_message","_radioBroadcast"];

        if!(isNil "ALIVE_globalForcePool") then {

            // send radio broadcast
            _sideObject = [_taskSide] call ALIVE_fnc_sideTextToObject;
            _factionName = getText((_taskFaction call ALiVE_fnc_configGetFactionClass) >> "displayName");
            _forcePool = [ALIVE_globalForcePool,_taskFaction] call ALIVE_fnc_hashGet;

            if (isNil "_forcePool") then {
                private _factions = _taskSide call ALiVE_fnc_getSideFactions;
                {
                    _forcePool = [ALIVE_globalForcePool,_x] call ALIVE_fnc_hashGet;
                    if (!isnil "_forcePool") exitWith {};
                } foreach _factions;
            };

            if (!isNil "_forcePool") then {
                _forcePool = _forcePool + _reward;

                [ALIVE_globalForcePool,_taskFaction,_forcePool] call ALIVE_fnc_hashSet;

                // send a message to all side players from HQ
                _message = format["%1 available reinforcement level increased: %2",_factionName,_forcePool];
                _radioBroadcast = [objNull,_message,"side",_sideObject,false,false,false,true,"HQ"];
                [_taskSide,_radioBroadcast] call ALIVE_fnc_radioBroadcastToSide;
            };

        };
    };
};

 _event = ["TASK_SUCCEEDED", [_taskDialog,_taskSide,_taskFaction,_rewardData], "C2ISTAR"] call ALIVE_fnc_event;
[ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;