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
ARJay
---------------------------------------------------------------------------- */

private ["_side", "_result"];
	
_side = _this select 0;

switch(_side) do {
	case "WEST": {
		_result = 1;
	};
	case "EAST": {
		_result = 0;
	};
	case "GUER": {
		_result = 2;
	};
	case "CIV": {
		_result = 3;
	};
    default {
        _result = 3;
    };
};

_result