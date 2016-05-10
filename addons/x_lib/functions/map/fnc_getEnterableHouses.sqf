#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(getEnterableHouses);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_getEnterableHouses

Description:
Returns an array of all enterable Houses in a given radius

Parameters:
Array - Central position 
Number - Search raidus

Returns:
Array - List of all enterable houses in area

Examples:
(begin example)
// get array of all enterable houses across the map
_center = getArray (configFile >> "CfgWorlds" >> worldName >> "centerPosition");
_spawnhouses = [_center, (_center select 0) min (_center select 1)] call ALIVE_fnc_getEnterableHouses;
(end)

See Also:
- <ALIVE_fnc_getObjectsByType>
- <ALIVE_fnc_getAllEnterableHouses>
- <ALIVE_fnc_isHouseEnterable>

Author:
Wolffy.au
---------------------------------------------------------------------------- */

private ["_position","_radius","_enterable","_err"];

PARAMS_2(_position,_radius);
_err = "position or radius not valid";
ASSERT_DEFINED("_position",_err);
ASSERT_DEFINED("_radius",_err);
ASSERT_TRUE(typeName _position == "ARRAY",_err);
ASSERT_TRUE(typeName _radius == "SCALAR",_err);

_enterable = [];
{
	if([_x] call ALIVE_fnc_isHouseEnterable) then{
		_enterable pushback _x;
	};
} forEach (_position nearObjects ["House", _radius]);
_err = "enterable array not valid";
ASSERT_TRUE(typeName _enterable == "ARRAY",_err);

_enterable;
