#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(followShot);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_followShot

Description:
Follow shot

Parameters:
Object - camera
Object - target
Scalar - shot duration
Boolean - hide target objects

Returns:


Examples:
(begin example)
[_camera,_target,10,false] call ALIVE_fnc_followShot;
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
private _dist = if(count _this > 4) then {_this select 4} else {5 * sizeof _target};
private _height = if(count _this > 5) then {_this select 5} else {1.7};
private _shift = if(count _this > 6) then {_this select 6} else {0.5 * sizeof _target};

_shift = if (random 1 < 0.5) then {0 - _shift};

if(_hideTarget) then
{
    hideObjectGlobal _target;
};

_camera camSetTarget _target;
_camera camSetRelPos [_shift, _dist, _height];
_camera camCommit 0;


