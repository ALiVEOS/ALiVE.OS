#include "\x\alive\addons\x_lib\script_component.hpp"

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_formatDate

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
	2. Format parameters are as follows:
	%1 = Year
	%2 = Month
	%3 = Day
	%4 = Hour
	%5 = Minute

Author:
	Naught
---------------------------------------------------------------------------- */

private ["_date", "_month"];
_date = _this select 0;

_month = switch (_date select 1) do {
	case 1: {"January"};
	case 2: {"February"};
	case 3: {"March"};
	case 4: {"April"};
	case 5: {"May"};
	case 6: {"June"};
	case 7: {"July"};
	case 8: {"August"};
	case 9: {"September"};
	case 10: {"October"};
	case 11: {"November"};
	case 12: {"December"};
	default {"Month"};
};

format[(_this select 1),
	(_date select 0),
	_month,
	(_date select 2),
	([(_date select 3), 2] call ALiVE_fnc_formatNumber),
	([(_date select 4), 2] call ALiVE_fnc_formatNumber)
];
