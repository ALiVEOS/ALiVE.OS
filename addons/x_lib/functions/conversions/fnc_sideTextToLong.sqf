#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(sideTextToLong);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_sideTextToLong

Description:
Return side long descriptinve text from side text

Parameters:
String - side

Returns:
Side

Examples:
(begin example)
// side text to object
_result = ["EAST"] call ALIVE_fnc_sideTextToLong;
(end)

See Also:

Author:
ARJay, dixon13
---------------------------------------------------------------------------- */

_result = switch(_this select 0) do {
    case "WEST": { "BLUFOR" };
    case "EAST": { "OPFOR" };
    case "GUER": { "Independent" };
    case "CIV": { "Civilian" };
    default { "Civilian" };
};

_result