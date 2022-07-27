#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(flyOverShot);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_flyOverShot

Description:
Fly Over Shot

Parameters:
Object - camera
Object - target
Scalar - shot duration
Boolean - hide target objects

Returns:


Examples:
(begin example)
[_camera,_target,10,false] call ALIVE_fnc_flyOverShot;
(end)

See Also:

Author:
Tupolov
---------------------------------------------------------------------------- */

private ["_camera", "_target", "_hideTarget", "_duration","_cameraPosition","_targetPosition"];

_camera = _this select 0;
_target = _this select 1;
_duration = if(count _this > 2) then {_this select 2} else {5};
_hideTarget = if(count _this > 3) then {_this select 3} else {false};
_dist = if(count _this > 4) then {_this select 4} else {50};
_height = if(count _this > 5) then {_this select 5} else {25};

if(_hideTarget) then
{
    hideObjectGlobal _target;
};

// Set camera position
_cameraPosition = (position _target) getPos [_dist, 0, _height];

// Create second target beyond our target
private _targetPosition = (position _target) getPos [_dist, 180, _height];
private _target2 = "RoadCone_L_F" createVehicle _targetPosition;
private _target2 hideObjectGlobal true;

_camera camPrepareTarget _target2;
_camera camPreparePos _cameraPosition;
_camera camCommitPrepared 0;
_camera camPreparePos _targetPosition;
_camera camCommitPrepared _duration;