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

Returns: Nothing


Examples:
(begin example)
[_camera,_target,10,false] call ALIVE_fnc_chaseSideShot;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_hideTarget", "_duration", "_startTime", "_currentTime", "_eventID"];

params ["_camera", "_target", ["_duration", 5], ["_hideTarget", false]];

if(_hideTarget) then { hideObject _target; };

_startTime = time;
_currentTime = _startTime;

CHASE_camera = _camera;
CHASE_target = _target;

_eventID = addMissionEventHandler ["Draw3D", {
    CHASE_camera camSetTarget CHASE_target;
    CHASE_camera camSetRelPos [-10,0,2];
    CHASE_camera camCommit 0;
}];

waitUntil { sleep 1; _currentTime = time; ((_currentTime - _startTime) >= _duration)};

removeMissionEventHandler ["Draw3D",_eventID];