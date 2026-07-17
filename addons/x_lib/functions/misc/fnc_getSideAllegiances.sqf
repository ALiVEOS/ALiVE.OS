#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(getSideAllegiances);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_getSideAllegiances

Description:
Calculates which of the OTHER sides are enemy and which are friendly to a given
side. The queried side is never listed in either result - a caller that needs its
own side counted among the friendlies has to add it back itself.

Parameters:
text - side to get allegiances of

Returns:
array
    0: array of enemy sides (never includes the queried side)
    1: array of friendly sides (never includes the queried side)

Examples:
(begin example)
_allegiances = ["WEST"] call ALiVE_fnc_getSideAllegiances;
(end)

See Also:
- nil

Author:
SpyderBlack723
Jman
---------------------------------------------------------------------------- */

private _sideText = toupper (_this select 0);
private _sideObject = [_sideText] call ALiVE_fnc_sideTextToObject;

private _otherSides = (["EAST","WEST","GUER"] - [_sideText]) apply { [_x, [_x] call ALiVE_fnc_sideTextToObject]};

private _enemySides = _otherSides select { _sideObject getfriend (_x select 1) < 0.6};
private _friendlySides = _otherSides - _enemySides;

[
    _enemySides apply { _x select 0 },
    _friendlySides apply { _x select 0 }
]