#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(compileReadableDate);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_compileReadableDate

Description:
Returns a readable date and time

Parameters:
nothing

Returns:
Array - Array of date and time

Examples:
(begin example)
[_date,time] = call ALiVE_fnc_compileReadableDate;
(end)

See Also:
- nil

Author:
Highhead

Peer reviewed:
nil
---------------------------------------------------------------------------- */
private ["_month", "_day", "_hour", "_minute"];

_month = str (date select 1);
_day = str (date select 2);
_hour = str (date select 3);
_minute = str (date select 4);

if (date select 1 < 10) then {_month = format ["0%1", str (date select 1)]};
if (date select 2 < 10) then {_day = format ["0%1", str (date select 2)]};
if (date select 3 < 10) then {_hour = format ["0%1", str (date select 3)]};
if (date select 4 < 10) then {_minute = format ["0%1", str (date select 4)]};

private ["_time", "_date"];

_time = format ["%1:%2", _hour, _minute];
_date = format ["%1-%2-%3", str (date select 0), _month, _day];

[_date,_time];
