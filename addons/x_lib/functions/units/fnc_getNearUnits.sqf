#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(getNearUnits);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_getNearUnits

Description:
Gets an array of units within radius, also gets units who are crew of vehicles

Parameters:
Array - Position center point for search
Scalar - Radius of search

Returns:
Array of units

Examples:
(begin example)
// get near units
_units = [getPos player, 500] call ALIVE_fnc_getNearUnits;
(end)

See Also:


Author:
ARJay
---------------------------------------------------------------------------- */

private ["_position","_radius","_units","_vehicles","_err"];
	
_position = _this select 0;
_radius = _this select 1;

_err = format["near units requires a position array - %1",_position];
ASSERT_TRUE(typeName _position == "ARRAY",_err);
_err = format["near units requires a radius scalar - %1",_radius];
ASSERT_TRUE(typeName _radius == "SCALAR",_err);

_units = _position nearEntities [["CAManBase"], _radius];
_vehicles = _position nearEntities [["Helicopter","Ship","Car","TANK","Truck","Motorcycle"], _radius];

{
	_units = _units + crew _x;
	
} forEach _vehicles;

_units