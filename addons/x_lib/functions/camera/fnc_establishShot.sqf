#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(establishShot);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_establishShot

Description:
Establishing Shot, location is based on where the xStream Logic is placed

Parameters:
Object - camera
Object - target
Scalar - shot duration
Boolean - hide target objects

Returns:


Examples:
(begin example)
[_camera,_target, 10, false] call ALIVE_fnc_establishShot;
(end)

See Also:

Author:
Tupolov
---------------------------------------------------------------------------- */

private _camera = _this select 0;
private _target = _this select 1;
private _duration = if(count _this > 2) then {_this select 2} else {6};
private _hideTarget = if(count _this > 3) then {_this select 3} else {false};
private _dist = if(count _this > 4) then {_this select 4} else {100};
private  _height = if(count _this > 5) then {_this select 5} else {20};
private _dir = if(count _this > 6) then {_this select 6} else {random 360};

if(_hideTarget) then
{
    hideObjectGlobal _target;
};

private _cameraPosition = _target getpos [_dist,_dir];
_cameraPosition set [2, _height];

_camera camSetTarget _target;
_camera camSetPos _cameraPosition;
_camera camCommit 0;