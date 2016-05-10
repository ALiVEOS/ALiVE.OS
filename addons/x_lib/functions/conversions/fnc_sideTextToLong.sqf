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
ARJay
---------------------------------------------------------------------------- */

private ["_side", "_result"];
	
_side = _this select 0;

switch(_side) do {
	case "WEST": {
		_result = "BLUFOR";
	};
	case "EAST": {
		_result = "OPFOR";
	};
	case "GUER": {
		_result = "Independent";
	};
	case "CIV": {
		_result = "Civilian";
	};
    default {
        _result = "Civilian";
    };
};

_result