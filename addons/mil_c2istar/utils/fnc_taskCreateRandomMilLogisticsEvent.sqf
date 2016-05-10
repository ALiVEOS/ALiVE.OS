#include <\x\alive\addons\mil_C2ISTAR\script_component.hpp>
SCRIPT(taskCreateRandomMilLogisticsEvent);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskCreateRandomMilLogisticsEvent

Description:
Mark a position for players

Parameters:

Returns:

Examples:
(begin example)
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_taskPosition","_taskSide","_taskFaction","_types","_type","_forceMakeup","_event","_eventID"];

_taskPosition = _this select 0;
_taskSide = _this select 1;
_taskFaction = _this select 2;

_types = ["AIRDROP","STANDARD","HELI_INSERT"];
_type = _types call BIS_fnc_selectRandom;

switch(_type) do {
    case "AIRDROP":{

        _forceMakeup = [
            floor(1 + random(2)), // infantry
            0, // motorised
            0, // mechanised
            0, // armour
            0, // plane
            0  // heli
        ];

    };
    case "STANDARD":{

        _forceMakeup = [
            floor(1 + random(2)), // infantry
            floor(random(2)), // motorised
            floor(random(2)), // mechanised
            floor(random(2)), // armour
            floor(random(2)), // plane
            floor(random(2))  // heli
        ];

    };
    case "HELI_INSERT":{

        _forceMakeup = [
            floor(1 + random(2)), // infantry
            0, // motorised
            0, // mechanised
            0, // armour
            0, // plane
            0  // heli
        ];

    };
};

_event = ['LOGCOM_REQUEST', [_taskPosition,_taskFaction,_taskSide,_forceMakeup,_type],"OPCOM"] call ALIVE_fnc_event;
_eventID = [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;

