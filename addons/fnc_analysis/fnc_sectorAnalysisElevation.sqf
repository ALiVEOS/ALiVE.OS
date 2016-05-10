#include <\x\alive\addons\fnc_analysis\script_component.hpp>
SCRIPT(sectorAnalysisElevation);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_sectorAnalysisElevation

Description:
Perform analysis on an array of sectors

Parameters:
None

Returns:
...

Examples:
(begin example)
// add elevation data to passed sector objects
_result = [] call ALIVE_fnc_sectorAnalysisElevation;
(end)

See Also:


Author:
ARJay
---------------------------------------------------------------------------- */

private ["_sectors","_err","_sector","_result","_centerPosition","_bounds","_dimensions","_elevation","_elevationData","_markers","_m","_id","_sectorData","_terrainData"];

_sectors = _this select 0;
_err = format["sector analysis elevation requires an array of sectors - %1",_sectors];
ASSERT_TRUE(typeName _sectors == "ARRAY",_err);

{
	_sector = _x;

	_centerPosition = [_sector, "center"] call ALIVE_fnc_sector;
	_id = [_sector, "id"] call ALIVE_fnc_sector;
	_bounds = [_sector, "bounds"] call ALIVE_fnc_sector;
	_dimensions = [_sector, "dimensions"] call ALIVE_fnc_sector;
	_sectorData = [_sector, "data"] call ALIVE_fnc_sector;
	_terrainData = [_sectorData, "terrain"] call ALIVE_fnc_hashGet;
	
	_elevationData = [];
	_markers = [];
	
	if(_terrainData == "SEA") then {
		_m = [_centerPosition] call ALIVE_fnc_spawnDebugMarker;
		hideObject _m;
		_markers set [count _markers, _m];
		_elevation = ((getPosATL _m) select 2);
		_elevation = _elevation - (_elevation * 2);
		_elevationData set [count _elevationData, [_centerPosition,_elevation]];
		
	} else {
		_m = [_centerPosition] call ALIVE_fnc_spawnDebugMarker;
		hideObject _m;
		_markers set [count _markers, _m];
		_elevation = ((getPosASL _m) select 2);
		_elevationData set [count _elevationData, [_centerPosition,_elevation]];
	};
	
	{
		deleteVehicle _x;
	} forEach _markers;
	
	// store the result of the analysis on the sector instance
	[_sector, "data", ["elevationSamples",_elevationData]] call ALIVE_fnc_sector;
	[_sector, "data", ["elevation",_elevation]] call ALIVE_fnc_sector;
	
} forEach _sectors;