#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(createLiveFeedCamera);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_createLiveFeedCamera

Description:
Create Live Feed

Parameters:
Object - source object
Object - target object
Boolean - hide target object
String - starting camera angle DEFAULT,LOW,EYE,HIGH,BIRDS_EYE,UAV,SATELITE

Returns:


Examples:
(begin example)
_camera = [_source,_target,false,"HIGH"] call ALIVE_fnc_createLiveFeedCamera;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

ALIVE_cameraPOV = 0.700;

private ["_camera", "_position"];
params ["_source", "_target", ["_hideSource", false], ["_angle", "DEFAULT"]];

if(_hideSource) then { hideObject _source; };

_position = position _source;
_position = [_position, _angle] call ALIVE_fnc_setCameraAngle;

[_position, _target, player] call BIS_fnc_liveFeed;
BIS_liveFeed camPrepareFOV ALIVE_cameraPOV;
BIS_liveFeed