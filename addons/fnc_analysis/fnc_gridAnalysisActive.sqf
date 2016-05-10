#include <\x\alive\addons\fnc_analysis\script_component.hpp>
SCRIPT(gridAnalysisActive);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_gridAnalysisActive

Description:
Perform analysis of player positions on passed grid

Parameters:
None

Returns:
...

Examples:
(begin example)
// add profile units to sector data
_result = [_grid] call ALIVE_fnc_gridAnalysisActive;
(end)

See Also:


Author:
ARJay
---------------------------------------------------------------------------- */

private ["_grid","_err","_sectors","_updatedSectors","_sector","_sectorData",
"_position","_active","_player"];

_grid = _this select 0;


// reset existing analysis data

//["RESET SECTORS"] call ALIVE_fnc_dump;
//[true] call ALIVE_fnc_timer;

_sectors = [_grid, "sectors"] call ALIVE_fnc_sectorGrid;
_updatedSectors = [];

{
	_sector = _x;
	
	_sectorData = _sector select 2 select 0; //[_sector, "data"] call ALIVE_fnc_sector;

	if("active" in (_sectorData select 1)) then {
		[_sector, "data", ["active",[]]] call ALIVE_fnc_sector;
	};

} forEach _sectors;

//[] call ALIVE_fnc_timer;

// run analysis on all profiles

//["ANALYSE PLAYER POSITIONS"] call ALIVE_fnc_dump;
//[true] call ALIVE_fnc_timer;

{
	_player = _x;
	_position = getPosATL _player;

	_sector = [_grid, "positionToSector", _position] call ALIVE_fnc_sectorGrid;
    _sectorData = [_sector,"data",["",[],[],nil]] call ALIVE_fnc_hashGet;
    //_sectorData = _sector select 2 select 0; //[_sector, "data"] call ALIVE_fnc_sector;

	if (count (_sectorData select 1) > 0) then {
        
		_active = [_sectorData, "active",[]] call ALIVE_fnc_hashGet;
	
	    _active set [count _active, [_player,_position]];
	
	    // store the result of the analysis on the sector instance
	    [_sector, "data", ["active",_active]] call ALIVE_fnc_sector;
	
	    if!(_sector in _updatedSectors) then {
	        _updatedSectors set [count _updatedSectors, _sector];
	    };
    };
} forEach allPlayers;

//[] call ALIVE_fnc_timer;

_updatedSectors