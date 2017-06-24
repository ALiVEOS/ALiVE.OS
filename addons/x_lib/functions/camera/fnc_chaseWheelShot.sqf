#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(chaseWheelShot);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_chaseWheelShot

Description:
Chase wheel shot

Parameters:
Object - camera
Object - target
Scalar - shot duration
Boolean - hide target objects

Returns: Nothing


Examples:
(begin example)
[_camera,_target,10,false] call ALIVE_fnc_chaseWheelShot;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_startTime", "_currentTime", "_eventID", "_bounds", "_p1", "_p2"];

params ["_camera", "_target", ["_duration", 5], ["_hideTarget", false]];

if(_hideTarget) then { hideObject _target; };

_startTime = time;
_currentTime = _startTime;

CHASE_camera = _camera;
CHASE_target = _target;

_bounds = boundingBoxReal _target;
_p1 = _bounds select 0;
_p2 = _bounds select 1;
CHASE_width = (abs ((_p2 select 0) - (_p1 select 0))) / 2;

_eventID = addMissionEventHandler ["Draw3D", {
    CHASE_camera attachTo [CHASE_target, [-CHASE_width,0,-1.2]];
    _camera camCommitPrepared 0;
}];

waitUntil { sleep 1; _currentTime = time; ((_currentTime - _startTime) >= _duration)};

removeMissionEventHandler ["Draw3D",_eventID];