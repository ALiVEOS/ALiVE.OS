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

params ["_camera", "_target", ["_angle", "DEFAULT"], ["_duration", 5], ["_hideTargets", false]];

if(_hideTargets) then { hideObject _target; };

private _position = getPosATL _target;
_position = [_position, _angle] call ALIVE_fnc_setCameraAngle;

_camera camPreparePos _position;
_camera camCommitPrepared _duration;