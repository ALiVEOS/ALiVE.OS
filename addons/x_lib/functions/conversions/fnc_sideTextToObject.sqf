#include <\x\alive\addons\x_lib\script_component.hpp>
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
ARJay, dixon13
---------------------------------------------------------------------------- */

_result = switch(_this select 0) do {
    case "WEST": { west };
    case "EAST": { east };
    case "GUER": { resistance };
    case "CIV": { civilian };
    case "ENEMY": { east };
    case "UNKNOWN": { civilian };
    default { civilian };
};

_result