#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(sideTextToNumber);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_sideTextToNumber

Description:
Return side number from side text

Parameters:
String - side

Returns:
Scalar

Examples:
(begin example)
// side text to object
_result = ["EAST"] call ALIVE_fnc_sideTextToNumber;
(end)

See Also:

Author:
ARJay, dixon13
---------------------------------------------------------------------------- */

_result = switch(_this select 0) do {
    case "WEST": { 1 };
    case "EAST": { 0 };
    case "GUER": { 2 };
    case "CIV": { 3 };
    default { 3 };
};

_result