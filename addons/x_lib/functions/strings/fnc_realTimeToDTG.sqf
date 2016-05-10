#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(realTimeToDTG);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_realTimeToDTG

Description:
	Formats a real time (from server) to a DTG specification
	
Parameters:
	None

Returns:
	Formatted date [string]

Attributes:
	N/A

Examples:
	N/A

See Also:

Notes:
	1. Format is DTG atm
	
Author:
	Naught
---------------------------------------------------------------------------- */

private ["_result","_year","_month","_day","_hour","_min","_datet"];

_datet = [] call ALIVE_fnc_getServerTime;
LOG(str _datet);
_day = parseNumber ([_datet, 0, 1] call bis_fnc_trimString);
_month = parseNumber ([_datet, 3, 4] call bis_fnc_trimString);
_year = parseNumber ([_datet, 6, 10] call bis_fnc_trimString);
_hour = parseNumber ([_datet, 11, 12] call bis_fnc_trimString);
_min = parseNumber ([_datet, 14, 15] call bis_fnc_trimString);
LOG(str _day);
LOG(str _hour);
LOG(str _min);

_result = [[_year,_month,_day,_hour,_min]] call ALIVE_fnc_dateToDTG;

_result