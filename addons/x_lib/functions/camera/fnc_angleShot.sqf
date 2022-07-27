#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(angleShot);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_angleShot

Description:
Chase angle shot

Parameters:
Object - camera
Object - target
Scalar - shot duration
Boolean - hide target objects

Returns:


Examples:
(begin example)
[_camera,_target,10,false] call ALIVE_fnc_angleShot;
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

private _shift = _dist;

if(_hideTarget) then
{
    hideObjectGlobal _target;
};

if ((random 1) < 0.5) then {
	_shift = 0 - _dist;
};

if ((random 1) < 0.5) then {
	_dist = 0 - _dist;
};

_camera camSetTarget _target;
_camera camSetRelPos [_shift, _dist, _height];
_camera camCommit 0;


