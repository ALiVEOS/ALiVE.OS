#include <\x\alive\addons\fnc_analysis\script_component.hpp>
SCRIPT(sectorAnalysisUnits);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_sectorAnalysisUnits

Description:
Perform analysis on an array of sectors

Parameters:
None

Returns:
...

Examples:
(begin example)
// add units within sector data to passed sector objects
_result = [_sectors] call ALIVE_fnc_sectorAnalysisUnits;
(end)

See Also:


Author:
ARJay
---------------------------------------------------------------------------- */

private ["_sectors","_err","_sector","_result","_centerPosition","_bounds","_dimensions","_units","_id","_detectionRadius"];

_sectors = _this select 0;
_err = format["sector analysis units requires an array of sectors - %1",_sectors];
ASSERT_TRUE(typeName _sectors == "ARRAY",_err);

{
	_sector = _x;

	_centerPosition = [_sector, "center"] call ALIVE_fnc_sector;
	_id = [_sector, "id"] call ALIVE_fnc_sector;
	_bounds = [_sector, "bounds"] call ALIVE_fnc_sector;
	_dimensions = [_sector, "dimensions"] call ALIVE_fnc_sector;
	
	// detection radius get the diagonal of the sector
	// this gives a circumference that fits the sector within it
	_detectionRadius = floor(((_bounds select 0) distance (_bounds select 2)) / 2);
	
	// get all near units
	_units = [_centerPosition, _detectionRadius] call ALIVE_fnc_getNearUnits;
	
	// remove dead units	
	_units = [_units] call ALIVE_fnc_unitArrayFilterDead;
	
	// the search for units is done by a circular detection
	// sectors are square so some units will be outside the sector 
	// but inside the detection radius, filter them out
	_units = [_units, _sector] call ALIVE_fnc_unitArrayFilterInSector;
	
	// sort the units into a hash of units by side
	_units = [_units] call ALIVE_fnc_unitArraySortSide;
	
	// store the result of the analysis on the sector instance
	[_sector, "data", ["units",_units]] call ALIVE_fnc_sector;
	
} forEach _sectors;