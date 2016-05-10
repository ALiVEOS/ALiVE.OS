#include "\x\alive\addons\x_lib\script_component.hpp"

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_getMapInfo

Description:
	Gets general information about the current map.
	
Parameters:
	None.

Returns:
	Map Information [array]
		0 - Map Center [array]
		1 - Map Edge (top-right point) [array]
		2 - Maximum radius from center [number]
		3 - Minimum radius from center [number]

Attributes:
	N/A

Examples:
	N/A

See Also:

Author:
	Naught
---------------------------------------------------------------------------- */

private ["_mapCenter"];
_mapCenter = getArray(configFile >> "CfgWorlds" >> worldName >> "centerPosition");
_mapCenter set [2,0]; // 2d position

[
	_mapCenter, // Center
	[(_mapCenter select 0) * 2, (_mapCenter select 1) * 2, 0], // Top-right point
	(((_mapCenter select 0) max (_mapCenter select 1)) * sqrt(2)), // Max radius
	(((_mapCenter select 0) min (_mapCenter select 1)) * sqrt(2)) // Min radius
]