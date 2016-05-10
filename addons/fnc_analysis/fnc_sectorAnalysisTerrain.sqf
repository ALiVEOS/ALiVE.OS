#include <\x\alive\addons\fnc_analysis\script_component.hpp>
SCRIPT(sectorAnalysisTerrain);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_sectorAnalysisTerrain

Description:
Perform analysis on an array of sectors

Parameters:
None

Returns:
...

Examples:
(begin example)
// add terrain type data to passed sector objects
_result = [_sectors] call ALIVE_fnc_sectorAnalysisTerrain;
(end)

See Also:


Author:
ARJay
---------------------------------------------------------------------------- */

private ["_sectors","_err","_sector","_result","_centerPosition","_bounds","_dimensions","_quadrantWidth","_terrain","_terrainData","_countIsWater","_direction","_position","_id"];

_sectors = _this select 0;
_err = format["sector analysis terrain requires an array of sectors - %1",_sectors];
ASSERT_TRUE(typeName _sectors == "ARRAY",_err);

{
	_sector = _x;

	_centerPosition = [_sector, "center"] call ALIVE_fnc_sector;
	_id = [_sector, "id"] call ALIVE_fnc_sector;
	_bounds = [_sector, "bounds"] call ALIVE_fnc_sector;
	_dimensions = [_sector, "dimensions"] call ALIVE_fnc_sector;
	
	_quadrantWidth = (_dimensions select 0) / 2;
	
	_countIsWater = 0;
	
	_terrain = "";
	_terrainData = [] call ALIVE_fnc_hashCreate;
	[_terrainData,"sea",[]] call ALIVE_fnc_hashSet;
	[_terrainData,"land",[]] call ALIVE_fnc_hashSet;
	[_terrainData,"shore",[]] call ALIVE_fnc_hashSet;
	
	if(surfaceIsWater _centerPosition) then {
		_countIsWater = _countIsWater + 1;
	};
	
	{
		_direction = _x getDir _centerPosition;
		_position = _x getPos [_quadrantWidth, _direction];
		if(surfaceIsWater _position) then {
			_countIsWater = _countIsWater + 1;
		};
	} forEach _bounds;
	
	if(_countIsWater == 5) then {
		_terrain = "SEA";
		[_terrainData,"sea",[_centerPosition]] call ALIVE_fnc_hashSet;
	};
	
	if(_countIsWater == 0) then {
		_terrain = "LAND";
		[_terrainData,"land",[_centerPosition]] call ALIVE_fnc_hashSet;
	};
	
	if(_countIsWater > 0 && _countIsWater < 5) then {
		_terrain = "SHORE";
		[_terrainData,"shore",[_centerPosition]] call ALIVE_fnc_hashSet;
	};
		
	// store the result of the analysis on the sector instance
	[_sector, "data", ["terrainSamples",_terrainData]] call ALIVE_fnc_sector;
	[_sector, "data", ["terrain",_terrain]] call ALIVE_fnc_sector;
	
} forEach _sectors;