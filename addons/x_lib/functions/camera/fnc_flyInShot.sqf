#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(flyInShot);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_flyInShot

Description:
Fly in Shot

Parameters:
Object - camera
Object - target
Scalar - shot duration
Boolean - hide target objects

Returns:


Examples:
(begin example)
[_camera,_target,10,false] call ALIVE_fnc_flyInShot;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_camera", "_target", "_hideTarget", "_duration","_cameraPosition","_targetPosition"];

_camera = _this select 0;
_target = _this select 1;
_duration = if(count _this > 2) then {_this select 2} else {5};
_hideTarget = if(count _this > 3) then {_this select 3} else {false};

if(_hideTarget) then
{
    hideObject _target;
};

_cameraPosition = getPosATL _camera;
_targetPosition = getPosATL _target;

if((_targetPosition select 2) > (_cameraPosition select 2)) then {
    _cameraPosition set [2,(_targetPosition select 2) + (_cameraPosition select 2)];
};

_camera camPrepareTarget _target;
_camera camPreparePos [(_targetPosition select 0)- 40,(_targetPosition select 1)+40, _cameraPosition select 2];
_camera camCommitPrepared 0;
_camera camPreparePos [(_targetPosition select 0)- 3,(_targetPosition select 1)+3, 2];
_camera camCommitPrepared _duration;