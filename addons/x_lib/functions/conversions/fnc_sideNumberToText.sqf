#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(sideNumberToText);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_sideNumberToText

Description:
Return side text from side number (config)

Parameters:
Number - side

Returns:
Side

Examples:
(begin example)
// side number to text
_result = [1] call ALIVE_fnc_sideNumberToText;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

if (typeName(_this) != "ARRAY") then {_this = [_this]};

switch (_this select 0) do
{
	case 0: {"EAST"};
	case 1: {"WEST"};	
	case 2: {"GUER"};
	case 3: {"CIV"};
	default {""};
};
