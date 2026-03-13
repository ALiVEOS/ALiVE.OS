#include "\x\alive\addons\fnc_analysis\script_component.hpp"
SCRIPT(sectorDataDummy);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_sectorDataDummy

Description:
Create a dummy sector data hash with the full terrain/elevation/roads schema.

Parameters:
None

Returns:
Array - sector data hash

Examples:
(begin example)
_sectorData = [] call ALIVE_fnc_sectorDataDummy;
(end)

See Also:

Author:
OpenAI
---------------------------------------------------------------------------- */

private _sectorData = [] call ALIVE_fnc_hashCreate;
[_sectorData,"elevationSamplesLand",[]] call ALIVE_fnc_hashSet;
[_sectorData,"elevationSamplesSea",[]] call ALIVE_fnc_hashSet;
[_sectorData,"elevation",0] call ALIVE_fnc_hashSet;
[_sectorData,"flatEmpty",[]] call ALIVE_fnc_hashSet;
[_sectorData,"terrain","NONE"] call ALIVE_fnc_hashSet;

private _terrainSamples = [] call ALIVE_fnc_hashCreate;
[_terrainSamples,"land",[]] call ALIVE_fnc_hashSet;
[_terrainSamples,"sea",[]] call ALIVE_fnc_hashSet;
[_terrainSamples,"shore",[]] call ALIVE_fnc_hashSet;
[_sectorData,"terrainSamples",_terrainSamples] call ALIVE_fnc_hashSet;

private _bestPlaces = [] call ALIVE_fnc_hashCreate;
[_bestPlaces,"forest",[]] call ALIVE_fnc_hashSet;
[_bestPlaces,"exposedHills",[]] call ALIVE_fnc_hashSet;
[_sectorData,"bestPlaces",_bestPlaces] call ALIVE_fnc_hashSet;

private _roads = [] call ALIVE_fnc_hashCreate;
[_roads,"road",[]] call ALIVE_fnc_hashSet;
[_roads,"crossroad",[]] call ALIVE_fnc_hashSet;
[_roads,"terminus",[]] call ALIVE_fnc_hashSet;
[_sectorData,"roads",_roads] call ALIVE_fnc_hashSet;

_sectorData