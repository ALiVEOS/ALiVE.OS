#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(dateToDTG);
/*
	Function: ALiVE_fnc_dateToDTG
	Author(s): Tupolov
	Description:
		Formats a passed date to specification
	Parameters:
		0 - Date [array]
		1 - Format [string]
	Returns:
		Formatted date [string]
	Notes:
		1. Date is in format [year, month, day, hour, minute].
		2. Format is DTG atm
*/
/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_dateToDTG

Description:
	Formats a passed date to specification
	
Parameters:
	0 - Date [array]
	1 - Format [string]

Returns:
	Formatted date [string]

Attributes:
	N/A

Examples:
	N/A

See Also:

Notes:
	1. Date is in format [year, month, day, hour, minute].
	2. Format is DTG atm

Author:
	Tupolov
---------------------------------------------------------------------------- */

private ["_in", "_format", "_min", "_hour", "_sec", "_msec","_year","_month","_day"];

_in = _this select 0;

if (count _this > 1) then
{
	_format = _this select 1
} else
{
	_format = "DDHHMMZMONYY"
};

_year = _in select 0;
_month = _in select 1;
_day = _in select 2;
_hour = _in select 3;
_min = _in select 4;

_months = ["JAN","FEB","MAR","APR","MAY","JUN","JUL","AUG","SEP","OCT","NOV","DEC"];

_year = [str _year, 2, 4] call bis_fnc_trimString;
_month = _months select (_month -1);
_day = (if (_day <= 9) then {"0"} else {""}) + str _day;
_hour = (if (_hour <= 9) then {"0"} else {""}) + str _hour;
_min = (if (_min <= 9) then {"0"} else {""}) +  str _min;

switch _format do
{
	case "DDHHMMZMONYY": {format["%1%2%3%4%5%6",_day,_hour,_min,"Z",_month,_year]};
}

