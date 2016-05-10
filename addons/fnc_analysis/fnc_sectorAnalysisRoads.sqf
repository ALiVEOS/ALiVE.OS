#include <\x\alive\addons\fnc_analysis\script_component.hpp>
SCRIPT(sectorAnalysisRoads);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_sectorAnalysisRoads

Description:
Perform analysis on an array of sectors to store road position data

Parameters:
Array - array of sectors

Returns:
...

Examples:
(begin example)
// add roads data to passed sector objects
_result = [_sectors] call ALIVE_fnc_sectorAnalysisRoads;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_sectors","_err","_sector","_result","_centerPosition","_id","_bounds","_dimensions","_radius","_roads","_nearRoads","_road","_roadsConnectedTo","_connectedRoad","_direction",
"_standardRoads","_crossRoads","_terminusRoads","_position"];

_sectors = _this select 0;
_err = format["sector analysis terrain requires an array of sectors - %1",_sectors];
ASSERT_TRUE(typeName _sectors == "ARRAY",_err);

{
	_sector = _x;

	_centerPosition = [_sector, "center"] call ALIVE_fnc_sector;
	_id = [_sector, "id"] call ALIVE_fnc_sector;
	_bounds = [_sector, "bounds"] call ALIVE_fnc_sector;
	_dimensions = [_sector, "dimensions"] call ALIVE_fnc_sector;
	
	_radius = _dimensions select 0;
	
	_roads = [] call ALIVE_fnc_hashCreate;
	
	_standardRoads = [];
	_crossRoads = [];
	_terminusRoads = [];
	
	_nearRoads = _centerPosition nearRoads _radius;
	
	{
		_road = _x;		
		_position = getPosASL _road;
		_direction = 0;
		_roadsConnectedTo = roadsConnectedTo _road;
		if(count _roadsConnectedTo > 0) then {
		
			if(count _roadsConnectedTo == 1) then {
				_terminusRoads set [count _terminusRoads, [_position,_direction]];
			};
			
			if(count _roadsConnectedTo > 2) then {
				_crossRoads set [count _crossRoads, [_position,_direction]];
			};
			
			_connectedRoad = _roadsConnectedTo select 0;
			_direction = _road getRelDir _connectedRoad;
		};
		
		//["Road: %1 Pos: %2 Dir: %3 [%4] Roads Connected %5",_road,_position,_direction,(count _roadsConnectedTo),_roadsConnectedTo] call ALIVE_fnc_dump;
		
		_standardRoads set [count _standardRoads, [_position,_direction]];
	} forEach _nearRoads;
	
	[_roads,"road",_standardRoads] call ALIVE_fnc_hashSet;
	[_roads,"crossroad",_crossRoads] call ALIVE_fnc_hashSet;
	[_roads,"terminus",_terminusRoads] call ALIVE_fnc_hashSet;
	
	// store the result of the analysis on the sector instance
	[_sector, "data", ["roads",_roads]] call ALIVE_fnc_sector;
	
} forEach _sectors;