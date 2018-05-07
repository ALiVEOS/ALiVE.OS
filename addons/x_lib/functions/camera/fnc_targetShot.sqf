#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(targetShot);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_targetShot

Description:
Position camera behind a unit and point camera at the 2nd target

Parameters:
Object - camera
Object - target1
Object - target2
Scalar - shot duration
Boolean - hide target objects

Returns:


Examples:
(begin example)
[_camera, _target1, _target2, 10, false] call ALIVE_fnc_targetShot;
(end)

See Also:

Author:
Tupolov
---------------------------------------------------------------------------- */

private _camera = _this select 0;
private _target1 = _this select 1;
private _target2 = _this select 2;
private _duration = if(count _this > 3) then {_this select 3} else {5};
private _hideTarget = if(count _this > 4) then {_this select 4} else {false};
private _dist = if(count _this > 5) then {_this select 5} else {-10};
private  _height = if(count _this > 6) then {_this select 6} else {2};


if(_hideTarget) then
{
    hideObject _target;
};

_camera = _camera;
_pos = _target1;
_target = _target2;
_distance = _dist;
_height = _height max 0.4;

_shift = if (random 1 > 0.5) then {-0.3} else {0.4};

_camera camSetTarget _pos;
_camera camSetRelPos [_shift,_distance,_height];
_camera camCommit 0;
_camera camSetTarget _target;
_camera camCommit 0;