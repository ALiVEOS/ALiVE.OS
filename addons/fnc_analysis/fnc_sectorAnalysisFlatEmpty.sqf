#include <\x\alive\addons\fnc_analysis\script_component.hpp>
SCRIPT(sectorAnalysisFlatEmpty);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_sectorAnalysisFlatEmpty

Description:
Perform analysis on an array of sectors using the find empty command

Parameters:
Array - array of sectors
Scalar - the max positions to find within the sector
String - vehicle class to use to find empty position for

Returns:
...

Examples:
(begin example)
// add flat empty data to passed sector objects
_result = [_sectors] call ALIVE_fnc_sectorAnalysisFlatEmpty;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_sectors","_maxPositions","_vehicleClass","_sector","_result","_centerPosition","_dimensions","_radius","_emptyPositions","_position","_err"];

_sectors = _this select 0;
_vehicleClass = if(count _this > 1) then {_this select 1} else {"false"};
_err = format["sector analysis flat empty requires an array of sectors - %1",_sectors];
ASSERT_TRUE(typeName _sectors == "ARRAY",_err);

{
	_sector = _x;
	_centerPosition = [_sector, "center"] call ALIVE_fnc_sector;
	_dimensions = [_sector, "dimensions"] call ALIVE_fnc_sector;
	
	_radius = _dimensions select 0;
	
	_emptyPositions = [];
	
	if!(_vehicleClass == "false") then {
		_position = _centerPosition findEmptyPosition[1, _radius, _vehicleClass];
	}else{
		_position = _centerPosition findEmptyPosition[1, _radius];
	};	
	
	if(count _position > 0) then {
		// minDistance, precicePos, maxGradient, gradientRadius, onWater, onShore
		_position = _position isFlatEmpty[1,1,0.5,2,0,false];
		_emptyPositions = [_position];	
	};	
	
	// store the result of the analysis on the sector instance
	[_sector, "data", ["flatEmpty",_emptyPositions]] call ALIVE_fnc_sector;
	
} forEach _sectors;