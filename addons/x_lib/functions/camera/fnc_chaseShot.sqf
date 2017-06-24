#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(chaseShot);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_chaseShot

Description:
Chase shot

Parameters:
Object - camera
Object - target
Scalar - shot duration
Boolean - hide target objects

Returns: Nothing


Examples:
(begin example)
[_camera,_target,10,false] call ALIVE_fnc_chaseShot;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_startTime", "_currentTime", "_eventID"];
params ["_camera", "_target", ["_duration", 5], ["_hideTarget", false], ["_dist", -10], ["_height", 2]];

// diag_log str(_this);

if(_hideTarget) then { hideObject _target; };

_startTime = time;
_currentTime = _startTime;

CHASE_camera = _camera;
CHASE_target = _target;
CHASE_distance = _dist;
CHASE_height = _height;

_eventID = addMissionEventHandler ["Draw3D", {
    CHASE_camera camSetTarget CHASE_target;
    CHASE_camera camSetRelPos [0,CHASE_distance,CHASE_height];
    CHASE_camera camCommit 0;
}];

waitUntil { sleep 1; _currentTime = time; ((_currentTime - _startTime) >= _duration)};

removeMissionEventHandler ["Draw3D",_eventID];