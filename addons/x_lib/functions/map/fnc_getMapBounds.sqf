#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(getMapBounds);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_getMapSize

Description:
Get the world bounds of a given map

Parameters:
None

Returns:
Scalar Map Size

Examples:
(begin example)
// get bounds of map 
_size = [] call ALIVE_fnc_getMapBounds;
(end)

See Also:


Author:
ARJay
---------------------------------------------------------------------------- */

private ["_result","_err"];

_result = getNumber(configFile >> "CfgWorlds" >> worldName >> "MapSize");

if(_result == 0) then {
	_result = getArray(configFile >> "CfgWorlds" >> worldName >> "centerPosition");
	_result = sqrt((_result select 0) ^ 2 + (_result select 1) ^ 2) / 0.68;
};
_err = format["get map bounds config entry not vaild - %1",_result];
ASSERT_TRUE(typeName _result == "SCALAR",_err);

// if there are manual set map bounds in static data load those instead.
if!(isNil "ALIVE_mapBounds") then {
    if(worldName in (ALIVE_mapBounds select 1)) then {
        _result = [ALIVE_mapBounds, worldName] call ALIVE_fnc_hashGet;
    };
};

["ALiVE MAP BOUNDS: %1",_result] call ALIVE_fnc_dump;

_result;
