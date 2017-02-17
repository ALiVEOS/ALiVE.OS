#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(createLineMarker);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_createLineMarker
Description:
Creates a line marker

Parameters:
array - marker values

Returns:
bool

Examples:
(begin example)
            [
                _markerName,
                [_markerHash, QGVAR(startpos)] call ALiVE_fnc_hashGet,
                [_markerHash, QGVAR(endpos)] call ALiVE_fnc_hashGet,
                [_markerHash, QGVAR(width)] call ALiVE_fnc_hashGet,
                [_markerHash, QGVAR(color)] call ALiVE_fnc_hashGet,
                [_markerHash, QGVAR(alpha)] call ALiVE_fnc_hashGet
            ] call ALIVE_fnc_createLineMarker;
(end)

See Also:
- <ALIVE_fnc_marker>

Author:
Tupolov

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

params ["_mkrname","_start","_end","_width","_color","_alpha"];

private _pos = [
    ((_start select 0) + (_end select 0)) / 2,
    ((_start select 1) + (_end select 1)) / 2,
    ((_start select 2) + (_end select 2)) / 2
];


private _tmp = [
    ((_end select 0) - (_start select 0)),
    ((_end select 1) - (_start select 1))
];

private _length = (_tmp select 0) * (_tmp select 0) + (_tmp select 1) * (_tmp select 1);
_length = sqrt _length;

private _angle = _tmp call CBA_fnc_vectDir;

/*
_difX = (_start select 0) - (_end select 0) +0.1;
_difY = (_start select 1) - (_end select 1) +0.1;
_lx = (_end select 0) + _difX / 2;
_ly = (_end select 1) + _difY / 2;
_dis = sqrt(_difX^2 + _difY^2);
_dir = atan (_difX / _difY);
_pos = [_lx,_ly,0];
*/

[_mkrname, _pos, "RECTANGLE", [_width, _length/2], _color, "", "", "Solid", _angle, _alpha] call ALiVE_fnc_createMarker;
