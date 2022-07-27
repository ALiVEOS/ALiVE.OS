#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(SideShot);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_sideShot

Description:
 side shot

Parameters:
Object - camera
Object - target
Scalar - shot duration
Boolean - hide target objects

Returns:


Examples:
(begin example)
[_camera,_target,10,false] call ALIVE_fnc_sideShot;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_camera", "_target", "_hideTarget", "_duration", "_startTime", "_currentTime", "_eventID"];

_camera = _this select 0;
_target = _this select 1;
_duration = if(count _this > 2) then {_this select 2} else {5};
_hideTarget = if(count _this > 3) then {_this select 3} else {false};
_dist = if(count _this > 4) then {_this select 4} else {-10};
_height = if(count _this > 5) then {_this select 5} else {1.7};

if(_hideTarget) then
{
    hideObjectGlobal _target;
};

_camera = _camera;
_target = _target;
_distance = _dist;
_height = _height max 0.4;

if ((random 1) < 0.5) then {
	_distance = 0 - _dist;
};

_camera camSetTarget _target;
_camera camSetRelPos [_distance,0,_height];
_camera camCommit 0;