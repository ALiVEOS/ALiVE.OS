#include <\x\alive\addons\fnc_analysis\script_component.hpp>
SCRIPT(sectorAnalysisClustersMil);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_sectorAnalysisClustersMil

Description:
Perform analysis on an array of sectors

Parameters:
None

Returns:
...

Examples:
(begin example)
// add units within sector data to passed sector objects
_result = [_sectors] call ALIVE_fnc_sectorAnalysisClustersMil;
(end)

See Also:


Author:
ARJay
---------------------------------------------------------------------------- */

private ["_sectors","_err","_worldName","_file","_sector","_result","_centerPosition","_id","_bounds","_dimensions",
"_cluster","_clusterCenter","_clusterID","_consolidated","_air","_heli","_clusters"];

_sectors = _this select 0;
_err = format["sector analysis units requires an array of sectors - %1",_sectors];
ASSERT_TRUE(typeName _sectors == "ARRAY",_err);

if(isNil "ALIVE_clustersMil" && isNil "ALIVE_loadedMilClusters") then {
	//["LOADING MO DATA"] call ALIVE_fnc_dump;
	//[true] call ALIVE_fnc_timer;
	
	_worldName = toLower(worldName);			
	_file = format["\x\alive\addons\mil_placement\clusters\clusters.%1_mil.sqf", _worldName];		
	call compile preprocessFileLineNumbers _file;
	ALIVE_loadedMilClusters = true;
	
	//[] call ALIVE_fnc_timer;
	//["MO DATA LOADED"] call ALIVE_fnc_dump;
};

{
	_sector = _x;

	_centerPosition = [_sector, "center"] call ALIVE_fnc_sector;
	_id = [_sector, "id"] call ALIVE_fnc_sector;
	_bounds = [_sector, "bounds"] call ALIVE_fnc_sector;
	_dimensions = [_sector, "dimensions"] call ALIVE_fnc_sector;
	
	_consolidated = [];
	_air = [];
	_heli = [];
		
	{
		_cluster = _x;
		_clusterCenter = [_cluster, "center"] call ALIVE_fnc_hashGet;
		
		if([_sector, "within", _clusterCenter] call ALIVE_fnc_sector) then {
			_clusterID = [_cluster, "clusterID"] call ALIVE_fnc_hashGet;
			_consolidated set [count _consolidated, [_clusterCenter,_clusterID]];
		};
	} forEach (ALIVE_clustersMil select 2);
	
	{
		_cluster = _x;
		_clusterCenter = [_cluster, "center"] call ALIVE_fnc_hashGet;
		
		if([_sector, "within", _clusterCenter] call ALIVE_fnc_sector) then {
			_clusterID = [_cluster, "clusterID"] call ALIVE_fnc_hashGet;
			_air set [count _air, [_clusterCenter,_clusterID]];
		};
	} forEach (ALIVE_clustersMilAir select 2);
	
	{
		_cluster = _x;
		_clusterCenter = [_cluster, "center"] call ALIVE_fnc_hashGet;
		
		if([_sector, "within", _clusterCenter] call ALIVE_fnc_sector) then {
			_clusterID = [_cluster, "clusterID"] call ALIVE_fnc_hashGet;
			_heli set [count _heli, [_clusterCenter,_clusterID]];
		};
	} forEach (ALIVE_clustersMilHeli select 2);
	
	_clusters = [] call ALIVE_fnc_hashCreate;
	[_clusters, "consolidated", _consolidated] call ALIVE_fnc_hashSet;
	[_clusters, "air", _air] call ALIVE_fnc_hashSet;
	[_clusters, "heli", _heli] call ALIVE_fnc_hashSet;
	
	// store the result of the analysis on the sector instance
	[_sector, "data", ["clustersMil",_clusters]] call ALIVE_fnc_sector;
	
} forEach _sectors;