#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(zoomShot);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_zoomShot

Description:
Zoom in shot

Parameters:
Object - camera
Object - target
Scalar - shot duration
Boolean - hide target objects

Returns:


Examples:
(begin example)
[_camera,_target,10,false] call ALIVE_fnc_zoomShot;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

params ["_camera", "_target", ["_duration", 5], ["_hideTarget", false]];

if(_hideTarget) then { hideObject _target; };

private _cameraPosition = getPosATL _camera;
private _targetPosition = getPosATL _target;

if((_targetPosition select 2) > (_cameraPosition select 2)) then {
    _cameraPosition set [2,(_targetPosition select 2) + (_cameraPosition select 2)];
};

_camera camPrepareTarget _target;
_camera camPreparePos [(_targetPosition select 0)-30,(_targetPosition select 1)+20, _cameraPosition select 2];
_camera camCommitPrepared 0;
_camera camPrepareFOV 0.100;
_camera camCommitPrepared _duration;
sleep _duration;
_camera camPrepareFOV ALIVE_cameraPOV;