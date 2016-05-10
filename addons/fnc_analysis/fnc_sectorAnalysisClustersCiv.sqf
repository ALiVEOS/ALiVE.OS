#include <\x\alive\addons\fnc_analysis\script_component.hpp>
SCRIPT(sectorAnalysisClustersCiv);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_sectorAnalysisClustersCiv

Description:
Perform analysis on an array of sectors

Parameters:
None

Returns:
...

Examples:
(begin example)
// add units within sector data to passed sector objects
_result = [_sectors] call ALIVE_fnc_sectorAnalysisClustersCiv;
(end)

See Also:


Author:
ARJay
---------------------------------------------------------------------------- */

private ["_sectors","_err","_worldName","_file","_sector","_result","_centerPosition","_id","_bounds","_dimensions",
"_cluster","_clusterCenter","_clusterID","_consolidated","_air","_heli"];

_sectors = _this select 0;
_err = format["sector analysis units requires an array of sectors - %1",_sectors];
ASSERT_TRUE(typeName _sectors == "ARRAY",_err);

if(isNil "ALIVE_clustersCiv" && isNil "ALIVE_loadedCivClusters") then {
	//["LOADING MO DATA"] call ALIVE_fnc_dump;
	//[true] call ALIVE_fnc_timer;
	
	_worldName = toLower(worldName);			
	_file = format["\x\alive\addons\civ_placement\clusters\clusters.%1_civ.sqf", _worldName];		
	call compile preprocessFileLineNumbers _file;
	ALIVE_loadedCivClusters = true;
	
	//[] call ALIVE_fnc_timer;
	//["MO DATA LOADED"] call ALIVE_fnc_dump;
};

{
	_sector = _x;

	_centerPosition = [_sector, "center"] call ALIVE_fnc_sector;
	_id = [_sector, "id"] call ALIVE_fnc_sector;
	_bounds = [_sector, "bounds"] call ALIVE_fnc_sector;
	_dimensions = [_sector, "dimensions"] call ALIVE_fnc_sector;

	private ["_consolidated","_power","_comms","_marine","_rail","_fuel","_construction","_settlement","_clusters"];

	
	_consolidated = [];
	_power = [];
	_comms = [];
	_marine = [];
	_rail = [];
	_fuel = [];
	_construction = [];
	_settlement = [];
		
	{
		_cluster = _x;
		_clusterCenter = [_cluster, "center"] call ALIVE_fnc_hashGet;
		
		if([_sector, "within", _clusterCenter] call ALIVE_fnc_sector) then {
			_clusterID = [_cluster, "clusterID"] call ALIVE_fnc_hashGet;
			_consolidated set [count _consolidated, [_clusterCenter,_clusterID]];
		};
	} forEach (ALIVE_clustersCiv select 2);
	
	{
		_cluster = _x;
		_clusterCenter = [_cluster, "center"] call ALIVE_fnc_hashGet;
		
		if([_sector, "within", _clusterCenter] call ALIVE_fnc_sector) then {
			_clusterID = [_cluster, "clusterID"] call ALIVE_fnc_hashGet;
			_power set [count _power, [_clusterCenter,_clusterID]];
		};
	} forEach (ALIVE_clustersCivPower select 2);
	
	{
		_cluster = _x;
		_clusterCenter = [_cluster, "center"] call ALIVE_fnc_hashGet;
		
		if([_sector, "within", _clusterCenter] call ALIVE_fnc_sector) then {
			_clusterID = [_cluster, "clusterID"] call ALIVE_fnc_hashGet;
			_comms set [count _comms, [_clusterCenter,_clusterID]];
		};
	} forEach (ALIVE_clustersCivComms select 2);
	
	{
		_cluster = _x;
		_clusterCenter = [_cluster, "center"] call ALIVE_fnc_hashGet;
		
		if([_sector, "within", _clusterCenter] call ALIVE_fnc_sector) then {
			_clusterID = [_cluster, "clusterID"] call ALIVE_fnc_hashGet;
			_marine set [count _marine, [_clusterCenter,_clusterID]];
		};
	} forEach (ALIVE_clustersCivMarine select 2);
	
	/*
	{
		_cluster = _x;
		_clusterCenter = [_cluster, "center"] call ALIVE_fnc_hashGet;
		
		if([_sector, "within", _clusterCenter] call ALIVE_fnc_sector) then {
			_clusterID = [_cluster, "clusterID"] call ALIVE_fnc_hashGet;
			_rail set [count _rail, [_clusterCenter,_clusterID]];
		};
	} forEach (ALIVE_clustersCivRail select 2);
	*/
	
	{
		_cluster = _x;
		_clusterCenter = [_cluster, "center"] call ALIVE_fnc_hashGet;
		
		if([_sector, "within", _clusterCenter] call ALIVE_fnc_sector) then {
			_clusterID = [_cluster, "clusterID"] call ALIVE_fnc_hashGet;
			_fuel set [count _fuel, [_clusterCenter,_clusterID]];
		};
	} forEach (ALIVE_clustersCivFuel select 2);
	
	{
		_cluster = _x;
		_clusterCenter = [_cluster, "center"] call ALIVE_fnc_hashGet;
		
		if([_sector, "within", _clusterCenter] call ALIVE_fnc_sector) then {
			_clusterID = [_cluster, "clusterID"] call ALIVE_fnc_hashGet;
			_construction set [count _construction, [_clusterCenter,_clusterID]];
		};
	} forEach (ALIVE_clustersCivConstruction select 2);
	
	{
		_cluster = _x;
		_clusterCenter = [_cluster, "center"] call ALIVE_fnc_hashGet;
		
		if([_sector, "within", _clusterCenter] call ALIVE_fnc_sector) then {
			_clusterID = [_cluster, "clusterID"] call ALIVE_fnc_hashGet;
			_settlement set [count _settlement, [_clusterCenter,_clusterID]];
		};
	} forEach (ALIVE_clustersCivSettlement select 2);
	
	_clusters = [] call ALIVE_fnc_hashCreate;
	[_clusters, "consolidated", _consolidated] call ALIVE_fnc_hashSet;
	[_clusters, "power", _power] call ALIVE_fnc_hashSet;
	[_clusters, "comms", _comms] call ALIVE_fnc_hashSet;
	[_clusters, "marine", _marine] call ALIVE_fnc_hashSet;
	[_clusters, "rail", _rail] call ALIVE_fnc_hashSet;
	[_clusters, "fuel", _fuel] call ALIVE_fnc_hashSet;
	[_clusters, "construction", _construction] call ALIVE_fnc_hashSet;
	[_clusters, "settlement", _settlement] call ALIVE_fnc_hashSet;
	
	// store the result of the analysis on the sector instance
	[_sector, "data", ["clustersCiv",_clusters]] call ALIVE_fnc_sector;
	
} forEach _sectors;