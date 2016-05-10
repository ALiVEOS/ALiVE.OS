#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(addCamera);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_addCamera

Description:
Adds a camera to a targets position
Optionally hides the target object from view

Parameters:
Object - source object
Boolean - hide source object
String - starting camera angle DEFAULT,LOW,EYE,HIGH,BIRDS_EYE,UAV,SATELITE

Returns:


Examples:
(begin example)
_camera = [_source,true,"HIGH"] call ALIVE_fnc_addCamera;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

ALIVE_cameraPOV = 0.700;
ALIVE_cameraTakenFrom = "";
ALIVE_cameraTakenFromView = "";

private ["_camera", "_position", "_source", "_angle", "_hideSource"];

_source = _this select 0;
_hideSource = if(count _this > 1) then {_this select 1} else {false};
_angle = if(count _this > 2) then {_this select 2} else {"DEFAULT"};

if(_hideSource) then
{
    hideObject _source;
};

_position = getPosATL _source;
_position = [_position, _angle] call ALIVE_fnc_setCameraAngle;

_camera = "camera" camCreate (_position);
_camera camPrepareFOV ALIVE_cameraPOV;
_camera