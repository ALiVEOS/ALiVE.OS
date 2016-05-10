#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(panShot);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_panShot

Description:
Pans a given camera between to targets you supply
Optionally hides the target objects from view

Parameters:
Object - camera
Object - target 1
Object - target 2
Scalar - shot duration
Boolean - hide target objects

Returns:


Examples:
(begin example)
[_camera,_target1,_target2,10,false] call ALIVE_fnc_panShot;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_camera", "_target1", "_target2", "_hideTargets", "_duration"];

_camera = _this select 0;
_target1 = _this select 1;
_target2 = _this select 2;
_duration = if(count _this > 3) then {_this select 3} else {5};
_hideTargets = if(count _this > 4) then {_this select 4} else {false};

if(_hideTargets) then
{
    hideObject _target1;
    hideObject _target2;
};

_camera camPrepareTarget _target1;
_camera camCommitPrepared _duration;

_camera camPrepareTarget _target2;
_camera camCommitPrepared _duration;