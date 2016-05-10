#include <\x\alive\addons\fnc_analysis\script_component.hpp>
SCRIPT(gridAnalysisProfileVehicle);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_gridAnalysisProfileVehicle

Description:
Perform analysis of profile positions on passed grid

Parameters:
None

Returns:
...

Examples:
(begin example)
// add profile units to sector data
_result = [_grid] call ALIVE_fnc_gridAnalysisProfileVehicle;
(end)

See Also:


Author:
ARJay
---------------------------------------------------------------------------- */

private ["_grid","_err","_profilesBySide","_sectors","_updatedSectors","_sideProfiles","_side","_profiles",
"_profile","_profileID","_profileType","_profileActive","_vehicle","_position","_sector","_sectorData","_sideProfile"];

_grid = _this select 0;


// reset existing analysis data

//["RESET SECTORS"] call ALIVE_fnc_dump;
//[true] call ALIVE_fnc_timer;

_sectors = [_grid, "sectors"] call ALIVE_fnc_sectorGrid;
_updatedSectors = [];

{
	_sector = _x;
    
    _sectorData = [_sector, "data", ["",[],[],nil]] call ALIVE_fnc_HashGet;
	//_sectorData = _sector select 2 select 0; //[_sector, "data"] call ALIVE_fnc_sector;
			
	//_sectorData call ALIVE_fnc_inspectHash;
	
    if (count (_sectorData select 1) > 0) then {
		if("entitiesBySide" in (_sectorData select 1)) then {
			_sideProfiles = [_sectorData, "entitiesBySide"] call ALIVE_fnc_hashGet;
			[_sideProfiles, "EAST", []] call ALIVE_fnc_hashSet;
			[_sideProfiles, "WEST", []] call ALIVE_fnc_hashSet;
			[_sideProfiles, "CIV", []] call ALIVE_fnc_hashSet;
			[_sideProfiles, "GUER", []] call ALIVE_fnc_hashSet;
			
			[_sector, "data", ["entitiesBySide",_sideProfiles]] call ALIVE_fnc_sector;
		};
	};
} forEach _sectors;

//[] call ALIVE_fnc_timer;

// run analysis on all profiles

//["ANALYSE PROFILES"] call ALIVE_fnc_dump;
//[true] call ALIVE_fnc_timer;

_profiles = [ALIVE_profileHandler, "profiles"] call ALIVE_fnc_hashGet;

{
	_profile = _x;
	
	_profileID = _profile select 2 select 4; //[_profile,"profileID"] call ALIVE_fnc_hashGet;
	_profileType = _profile select 2 select 5; //[_profile,"type"] call ALIVE_fnc_hashGet;
	_profileActive = _profile select 2 select 1; //[_profile, "active"] call ALIVE_fnc_hashGet;
	_side = _profile select 2 select 3; //[_profile, "active"] call ALIVE_fnc_hashGet;
	
	if(_profileType == "vehicle") then {
	
		if(_profileActive) then {
			_vehicle = _profile select 2 select 10; //[_profile,"leader"] call ALIVE_fnc_hashGet;
			_position = getPosATL _vehicle;
		} else {
			_position = _profile select 2 select 2; //[_profile, "position"] call ALIVE_fnc_hashGet;
		};		
	
		_sector = [_grid, "positionToSector", _position] call ALIVE_fnc_sectorGrid;
        _sectorData = [_sector, "data", ["",[],[],nil]] call ALIVE_fnc_HashGet;
		//_sectorData = _sector select 2 select 0; //[_sector, "data"] call ALIVE_fnc_sector;
				
		//_sectorData call ALIVE_fnc_inspectHash;
		
        if (count (_sectorData select 1) > 0) then {
			if("vehiclesBySide" in (_sectorData select 1)) then {
				_sideProfiles = [_sectorData, "vehiclesBySide"] call ALIVE_fnc_hashGet;
				_sideProfile = [_sideProfiles, _side] call ALIVE_fnc_hashGet;
			}else{
				_sideProfiles = [] call ALIVE_fnc_hashCreate;
				[_sideProfiles, "EAST", []] call ALIVE_fnc_hashSet;
				[_sideProfiles, "WEST", []] call ALIVE_fnc_hashSet;
				[_sideProfiles, "CIV", []] call ALIVE_fnc_hashSet;
				[_sideProfiles, "GUER", []] call ALIVE_fnc_hashSet;
				
				[_sector, "data", ["vehiclesBySide",_sideProfiles]] call ALIVE_fnc_sector; 
				
				_sideProfile = [_sideProfiles, _side] call ALIVE_fnc_hashGet;			
			};
			
			_sideProfile set [count _sideProfile, [_profileID,_position]];
			
			// store the result of the analysis on the sector instance
			[_sector, "data", ["vehiclesBySide",_sideProfiles]] call ALIVE_fnc_sector;
			
			if!(_sector in _updatedSectors) then {
				_updatedSectors set [count _updatedSectors, _sector];
			};
        };
	};
	
} forEach (_profiles select 2);

//[] call ALIVE_fnc_timer;

_updatedSectors