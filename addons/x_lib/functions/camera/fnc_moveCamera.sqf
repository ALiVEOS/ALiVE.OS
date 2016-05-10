#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(moveCamera);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_moveCamera

Description:
Move camera

Parameters:
Object - camera
Object - target
String - angle DEFAULT,LOW,EYE,HIGH,BIRDS_EYE,UAV,SATELITE
Scalar - shot duration
Boolean - hide target

Returns:


Examples:
(begin example)
[_camera,_target,"HIGH",10,false] call ALIVE_fnc_moveCamera;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_camera", "_target", "_angle", "_duration", "_position", "_hideTargets"];

_camera = _this select 0;
_target = _this select 1;
_angle = if(count _this > 2) then {_this select 2} else {"DEFAULT"};
_duration = if(count _this > 3) then {_this select 3} else {5};
_hideTargets = if(count _this > 4) then {_this select 4} else {false};

if(_hideTargets) then
{
    hideObject _target;
};

_position = getPosATL _target;
_position = [_position, _angle] call ALIVE_fnc_setCameraAngle;

_camera camPreparePos _position;
_camera camCommitPrepared _duration;