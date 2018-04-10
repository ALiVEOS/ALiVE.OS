#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(closeUpShot);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_closeUpShot

Description:
ChaseTarget

Parameters:
Object - camera
Object - target1
Scalar - shot duration
Boolean - hide target objects

Returns:


Examples:
(begin example)
[_camera,_target1, 10, false] call ALIVE_fnc_closeUpShot;
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
    hideObject _target;
};

private _startTime = time;
private _currentTime = _startTime;

CHASE_camera = _camera;
CHASE_pos = _target1;
CHASE_target = _target2;
CHASE_distance = _dist;
CHASE_height = _height;

CHASE_shift = if (random 1 > 0.5) then {-0.2} else {0.2};

private  _eventID = addMissionEventHandler ["Draw3D", {
	    CHASE_camera camSetTarget CHASE_pos;
	    CHASE_camera camSetRelPos [CHASE_shift,CHASE_distance,CHASE_height];
	    CHASE_camera camSetDir (CHASE_pos vectorFromTo CHASE_target);
	    CHASE_camera camCommit 0;
}];


waitUntil { sleep 1; _currentTime = time; ((_currentTime - _startTime) >= _duration)};

removeMissionEventHandler ["Draw3D",_eventID];