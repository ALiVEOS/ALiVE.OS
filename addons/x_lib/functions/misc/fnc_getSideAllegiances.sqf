#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(getSideAllegiances);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_getSideAllegiances

Description:
Calculates enemy and friendly sides for a given side

Parameters:
text - side to get allegiances of

Returns:
array
    0: array of enemy sides 
    1: array of friendly sides

Examples:
(begin example)
_allegiances = ["WEST"] call ALiVE_fnc_aALiVE_fnc_getSideAllegiancesddActionGlobal;
(end)

See Also:
- nil

Author:
SpyderBlack723
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