#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(dollyZoomShot);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_dollyZoomShot

Description:


Parameters:
Object - camera
Object - target1
Object - target2
Scalar - shot duration
Boolean - hide target objects

Returns:


Examples:
(begin example)
[_camera,_target, 10, false] call ALIVE_fnc_ALIVE_fnc_dollyZoomShot;
(end)

See Also:

Author:
Tupolov
---------------------------------------------------------------------------- */

private ["_camera", "_target", "_hideTarget", "_duration"];

_camera = _this select 0;
_target = _this select 1;
_duration = if(count _this > 3) then {_this select 3} else {5};
_hideTarget = if(count _this > 4) then {_this select 4} else {false};

if(_hideTarget) then
{
    hideObjectGlobal _target;
};

// Set up position in front of target
_camera camSetTarget _target;
_camera camSetRelPos [0,5,1.7];

// Set final position closer to the target
private _finalPos = _target getrelpos [1,getDir _target];

_camera camPrepareTarget _target;
_camera camPreparePos _finalPos;
_camera camCommitPrepared 0;
_camera camPrepareFOV 1;
_camera camCommitPrepared _duration;
sleep _duration;
_camera camPrepareFOV ALIVE_cameraPOV;