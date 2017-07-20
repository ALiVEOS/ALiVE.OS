#include "\x\alive\addons\x_lib\script_component.hpp"

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_dirToText

Description:
    Converts azimuth to a cardinal point

Parameters:
    0 - Degree number [number]

Returns:
    Cardinal Point [String]

Attributes:
    N/A

Examples:
    N/A

See Also:

Author:
    Tupolov
---------------------------------------------------------------------------- */

private _ang = _this select 0;
_ang = _ang + 22.5;

if (_ang > 360) then {
	_ang = _ang - 360
};

private _points = ["North", "North East", "East", "South East", "South", "South West", "West", "North West"];

private _num = floor (_ang / 45);

_compass = _points select _num;

_compass
