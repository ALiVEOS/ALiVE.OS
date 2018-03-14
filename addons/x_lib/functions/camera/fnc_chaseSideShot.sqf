#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(chaseSideShot);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_chaseSideShot

Description:
Chase side shot

Parameters:
Object - camera
Object - target
Scalar - shot duration
Boolean - hide target objects

Returns:


Examples:
(begin example)
[_camera,_target,10,false] call ALIVE_fnc_chaseSideShot;
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
_dist = if(count _this > 4) then {_this select 4} else {-10};
_height = if(count _this > 5) then {_this select 5} else {1.7};

if(_hideTarget) then
{
    hideObject _target;
};

_startTime = time;
_currentTime = _startTime;

CHASE_camera = _camera;
CHASE_target = _target;
CHASE_distance = _dist;
CHASE_height = _height max 0.4;

_eventID = addMissionEventHandler ["Draw3D", {
    CHASE_camera camSetTarget CHASE_target;
    CHASE_camera camSetRelPos [CHASE_distance,0,CHASE_height];
    CHASE_camera camCommit 0;
}];

waitUntil { sleep 1; _currentTime = time; ((_currentTime - _startTime) >= _duration)};

removeMissionEventHandler ["Draw3D",_eventID];