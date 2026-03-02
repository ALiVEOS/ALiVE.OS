#include "\x\alive\addons\mil_C2ISTAR\script_component.hpp"
SCRIPT(taskApplyPopulationEffect);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskApplyPopulationEffect

Description:
Apply a local civilian hostility shift in favor of the tasking side.

Parameters:

Returns:

Examples:
(begin example)
[_position, "WEST", 10] call ALIVE_fnc_taskApplyPopulationEffect;
(end)

See Also:

Author:
OpenAI
---------------------------------------------------------------------------- */

params [
    ["_position", [], [[]]],
    ["_taskSide", "", [""]],
    ["_value", 0, [0]]
];

if (_position isEqualTo [] || {_value <= 0}) exitWith {false};

private _sideText = switch (typeName _taskSide) do {
    case "SIDE": {
        private _sideNumber = [_taskSide] call ALIVE_fnc_sideObjectToNumber;
        [_sideNumber] call ALIVE_fnc_sideNumberToText;
    };
    case "STRING": {
        toUpper _taskSide
    };
    default {
        ""
    };
};

if !(_sideText in ["EAST", "WEST", "GUER"]) exitWith {false};

private _otherSides = ["EAST", "WEST", "GUER"] - [_sideText];

[_position, [_sideText], _value * -1] call ALIVE_fnc_updateSectorHostility;
[_position, _otherSides, _value] call ALIVE_fnc_updateSectorHostility;

true
