#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(vehicleCountEmptyPositions);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_vehicleCountEmptyPositions

Description:
Count empty vehicle positions

Parameters:
Vehicle - The vehicle

Returns:
Array of empty positions

Examples:
(begin example)
// get empty positions array
_result = [_vehicle] call ALIVE_fnc_vehicleCountEmptyPositions;
(end)

See Also:
ALIVE_getEmptyVehiclePositions

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_vehicle", "_positions", "_result"];
	
_vehicle = _this select 0;

_result = 0;

_positions = [_vehicle] call ALIVE_fnc_vehicleGetEmptyPositions;

{
	if(typeName _x == "ARRAY") then {
		_result = _result + count _x;
	} else {
		_result = _result + _x;
	};	
} forEach _positions;

_result