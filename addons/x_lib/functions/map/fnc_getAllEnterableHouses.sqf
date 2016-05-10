#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(getAllEnterableHouses);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_getAllEnterableHouses

Description:
Returns an array of all enterable Houses on the map

Returns:
Array - List of all enterable houses across the map

Examples:
(begin example)
// get array of all enterable houses across the map
_spawnhouses = call ALIVE_fnc_getAllEnterableHouses;
(end)

See Also:
- <ALIVE_fnc_getObjectsByType>
- <ALIVE_fnc_getMaxBuildingPositions>
- <ALIVE_fnc_getEnterableHouses>

Author:
Wolffy.au
---------------------------------------------------------------------------- */

private ["_center","_allhouses"];

ISNILS(GVAR(getAllEnterableHouses),[]);
_allhouses = GVAR(getAllEnterableHouses);

if(count _allhouses == 0) then {
	_center = getArray (configFile >> "CfgWorlds" >> worldName >> "centerPosition");
	_allhouses = [_center, (((_center select 0) max (_center select 1)) * sqrt(2))*2] call ALIVE_fnc_getEnterableHouses;
	
	GVAR(getAllEnterableHouses) = _allhouses;
};

_allhouses;
