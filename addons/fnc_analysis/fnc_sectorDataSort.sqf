#include <\x\alive\addons\fnc_analysis\script_component.hpp>
SCRIPT(sectorDataSort);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_sectorDataSort

Description:
Sorts the various sector data keys

Parameters:
Hash - Sector data hash
String - Data key to sort
Array - sort args

Returns:
Sorted data

Examples:
(begin example)
// sort elevation data
_sortedElevationData = [_sectorData, "elevation", []] call ALIVE_fnc_sectorDataSort;

// sort best places forest positions
_sortedForestPositions = [_sectorData, "bestPlaces", [getPos player,"forest"]] call ALIVE_fnc_sectorDataSort;

// sort flat empty positions
_sortedFlatEmptyPositions = [_sectorData, "flatEmpty", [getPos player]] call ALIVE_fnc_sectorDataSort;
(end)

See Also:


Author:
ARJay
---------------------------------------------------------------------------- */

private ["_sectorData","_key","_args","_err","_data","_sortedData"];
	
_sectorData = _this select 0;
_key = _this select 1;
_args = _this select 2;

_err = format["sector data sort requires an hash - %1",_sectorData];
ASSERT_TRUE(typeName _sectorData == "ARRAY",_err);
_err = format["sector data sort a string key - %1",_key];
ASSERT_TRUE(typeName _key == "STRING",_err);
_err = format["sector data sort a args array - %1",_args];
ASSERT_TRUE(typeName _args == "ARRAY",_err);


switch (_key) do {
	case "flatEmpty": {
		private ["_position","_order"];
		
		_position = _args select 0;
		_order = if(count _args > 1) then {_args select 1} else {"ASCEND"};
		
		_data = [_sectorData, _key] call ALIVE_fnc_hashGet;		
		_sortedData = [_data,[],{_position distance _x},_order] call ALiVE_fnc_SortBy;
		
		_sortedData
	};
	case "elevationLand": {
		private ["_order"];
		
		_order = if(count _args > 0) then {_args select 0} else {"ASCEND"};
		
		_data = [_sectorData, "elevationSamplesLand"] call ALIVE_fnc_hashGet;		
		_sortedData = [_data,[],{_x select 1},_order] call ALiVE_fnc_SortBy;
		
		_sortedData
	};
	case "elevationSea": {
		private ["_order"];
		
		_order = if(count _args > 0) then {_args select 0} else {"ASCEND"};
		
		_data = [_sectorData, "elevationSamplesSea"] call ALIVE_fnc_hashGet;		
		_sortedData = [_data,[],{_x select 1},_order] call ALiVE_fnc_SortBy;
		
		_sortedData
	};
	case "terrain": {
		private ["_position","_terrainKey","_order","_terrainData"];
		
		_position = _args select 0;
		_terrainKey = _args select 1;
		_order = if(count _args > 2) then {_args select 2} else {"ASCEND"};
		
		_data = [_sectorData, "terrainSamples"] call ALIVE_fnc_hashGet;		
		_terrainData = [_data, _terrainKey] call ALIVE_fnc_hashGet;		
		_sortedData = [_terrainData,[],{_position distance _x},_order] call ALiVE_fnc_SortBy;
		
		_sortedData
	};
	case "roads": {
		private ["_position","_roadKey","_order","_roadData"];
		
		_position = _args select 0;
		_roadKey = _args select 1;
		_order = if(count _args > 2) then {_args select 2} else {"ASCEND"};
		
		_data = [_sectorData, _key] call ALIVE_fnc_hashGet;		
		_roadData = [_data, _roadKey] call ALIVE_fnc_hashGet;		
		_sortedData = [_roadData,[],{_position distance (_x select 0)},_order] call ALiVE_fnc_SortBy;
		
		_sortedData
	};
	case "bestPlaces": {
		private ["_position","_placeKey","_order","_placeData"];
		
		_position = _args select 0;
		_placeKey = _args select 1;
		_order = if(count _args > 2) then {_args select 2} else {"ASCEND"};
		
		_data = [_sectorData, _key] call ALIVE_fnc_hashGet;		
		_placeData = [_data, _placeKey] call ALIVE_fnc_hashGet;		
		_sortedData = [_placeData,[],{_position distance _x},_order] call ALiVE_fnc_SortBy;
		
		_sortedData
	};
	case "entitiesBySide": {
		private ["_position","_sideKey","_order","_placeData","_sideData"];
		
		_position = _args select 0;
		_sideKey = _args select 1;
		_order = if(count _args > 2) then {_args select 2} else {"ASCEND"};
		
		_data = [_sectorData, _key] call ALIVE_fnc_hashGet;		
		_sideData = [_data, _sideKey] call ALIVE_fnc_hashGet;			
		_sortedData = [_sideData,[],{_position distance (_x select 1)},_order] call ALiVE_fnc_SortBy;
		
		_sortedData
	};
	case "vehiclesBySide": {
		private ["_position","_sideKey","_order","_placeData","_sideData"];
		
		_position = _args select 0;
		_sideKey = _args select 1;
		_order = if(count _args > 2) then {_args select 2} else {"ASCEND"};
		
		_data = [_sectorData, _key] call ALIVE_fnc_hashGet;		
		_sideData = [_data, _sideKey] call ALIVE_fnc_hashGet;			
		_sortedData = [_sideData,[],{_position distance (_x select 1)},_order] call ALiVE_fnc_SortBy;
		
		_sortedData
	};
};