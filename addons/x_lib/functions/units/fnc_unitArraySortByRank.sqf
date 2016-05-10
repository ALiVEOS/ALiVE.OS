#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(unitArraySortByRank);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_unitArraySortByRank

Description:
Sort a unit array by rank

Parameters:
Array - units

Returns:
Array

Examples:
(begin example)
// sort units by rank
_result = [_units] call ALIVE_fnc_unitArraySortByRank;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_units","_sortedUnits","_getRank","_result"];
	
_units = _this select 0;

_getRank = {
	private ["_unit", "_rank", "_value"];	
	_unit = _this select 0;
	_rank = rank _unit;
	_value = 0;
	
	switch(_rank) do {
		case "PRIVATE":{
			_value = 7;
		};
		case "CORPORAL":{
			_value = 6;
		};
		case "SERGEANT":{
			_value = 5;
		};
		case "LIEUTENANT":{
			_value = 4;
		};
		case "CAPTAIN":{
			_value = 3;
		};
		case "MAJOR":{
			_value = 2;
		};
		case "COLONEL":{
			_value = 1;
		};
	};
	
	if!(alive _unit) then {
		_value = 100;
	};
	
	_value
};

_sortedUnits = [_units, {
	([_this] call _getRank)
}] call ALIVE_fnc_shellSort;

_sortedUnits