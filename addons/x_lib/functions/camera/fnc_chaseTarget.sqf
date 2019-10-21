#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(ChaseTarget);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_ChaseTarget

Description:
Position camera behind a unit and point camera at the 2nd target

Parameters:
Object - camera
Object - target1
Object - target2
Scalar - shot duration
Boolean - hide target objects

Returns:


Examples:
(begin example)
[_camera, _target1, _target2, 10, false] call ALIVE_fnc_ChaseTarget;
(end)

See Also:

Author:
Tupolov
---------------------------------------------------------------------------- */

private _camera = _this select 0;
private _target1 = _this select 1;
private _target2 = _this select 2;
private _duration = if(count _this > 3) then {_this select 3} else {5};
private _hideTarget = if(count _this > 4) then {_this select 4} else {false};
private _dist = if(count _this > 5) then {_this select 5} else {-10};
private  _height = if(count _this > 6) then {_this select 6} else {2};


if(_hideTarget) then
{
    hideObjectGlobal _target;
};

private _startTime = time;
private _currentTime = _startTime;

CHASE_camera = _camera;
CHASE_pos = _target1;
CHASE_target = _target2;
CHASE_distance = _dist;
CHASE_height = _height max 0.4;

CHASE_shift = if (random 1 > 0.5) then {-0.3} else {0.4};

private  _eventID = addMissionEventHandler ["Draw3D", {
	    CHASE_camera camSetTarget CHASE_pos;
	    CHASE_camera camSetRelPos [CHASE_shift,CHASE_distance,CHASE_height];
	    CHASE_camera camCommit 0;
	    CHASE_camera camSetTarget CHASE_target;
	    CHASE_camera camCommit 0;
}];

//	    CHASE_camera camSetDir (position CHASE_pos vectorFromTo position CHASE_target);

waitUntil { sleep 1; _currentTime = time; ((_currentTime - _startTime) >= _duration)};

removeMissionEventHandler ["Draw3D",_eventID];