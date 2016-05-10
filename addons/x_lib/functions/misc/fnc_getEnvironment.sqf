#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(getEnvironment);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_getEnvironment
Description:
Gets current environment (day state, time, etc)

Parameters:
Nil

Returns:
Array - Environment settings

Examples:
(begin example)
// Create instance
_env = call ALIVE_fnc_getEnvironment;
(end)

Author:
ARJay

Peer reviewed:
nil
---------------------------------------------------------------------------- */

private ["_date","_dateString","_sunOrMoon","_hour","_minute","_sunSet","_sunRise","_dayState"];

_date = date;
_dateString = format["%1-%2-%3", _date select 0, _date select 1, _date select 2];

_sunOrMoon = sunOrMoon;

//["SUN OR MOON: %1",_sunOrMoon] call ALIVE_fnc_dump;

_hour = _date select 3;
_minute = _date select 4;
_dayState = "DAY";

//["TIME: %1:%2",_hour,_minute] call ALIVE_fnc_dump;

if(_sunOrMoon < 1) then {
    _dayState = "EVENING";
    if((_hour >= 23) || (_hour < 6)) then {
        _dayState = "NIGHT";
    };
};

//["DAY STATE: %1",_dayState] call ALIVE_fnc_dump;

ALIVE_currentEnvironment = [_dayState, _hour, _minute];

ALIVE_currentEnvironment