#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(sideTextToObject);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_sideTextToObject

Description:
Return side object from side text

Parameters:
String - side

Returns:
Side

Examples:
(begin example)
// side text to object
_result = ["EAST"] call ALIVE_fnc_sideTextToObject;
(end)

See Also:

Author:
ARJay
Jman
---------------------------------------------------------------------------- */

private ["_side", "_result"];

_side = _this select 0;

// #897 - callers sometimes pass an already-converted side object; the string
// switch below would silently fall through to the civilian default for it,
// misreporting the side (which neutered enemy checks downstream)
if (_side isEqualType east) exitWith {_side};

switch(_side) do {
    case "WEST": {
        _result = west;
    };
    case "EAST": {
        _result = east;
    };
    case "GUER": {
        _result = resistance;
    };
    case "RESISTANCE": {
        _result = resistance;
    };
    case "CIV": {
        _result = civilian;
    };
    case "ENEMY": {
        _result = east;
    };
    case "UNKNOWN": {
        _result = civilian;
    };
    default {
        _result = civilian;
    };
};

_result
