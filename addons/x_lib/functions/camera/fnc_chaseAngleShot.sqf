#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(chaseAngleShot);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_chaseAngleShot

Description:
Chase angle shot

Parameters:
Object - camera
Object - target
Scalar - shot duration
Boolean - hide target objects

Returns: Nothing


Examples:
(begin example)
[_camera,_target,10,false] call ALIVE_fnc_chaseAngleShot;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_startTime", "_currentTime", "_eventID"];
params ["_camera", "_target", ["_duration", 5], ["_hideTarget", false]];

if(_hideTarget) then { hideObject _target; };

_startTime = time;
_currentTime = _startTime;

CHASE_camera = _camera;
CHASE_target = _target;

_eventID = addMissionEventHandler ["Draw3D", {
    CHASE_camera camSetTarget CHASE_target;
    CHASE_camera camSetRelPos [-10,-10,2];
    CHASE_camera camCommit 0;
}];

waitUntil { sleep 1; _currentTime = time; ((_currentTime - _startTime) >= _duration)};

removeMissionEventHandler ["Draw3D",_eventID];