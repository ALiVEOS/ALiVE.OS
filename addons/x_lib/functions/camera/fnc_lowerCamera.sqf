#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(lowerCamera);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_lowerCamera

Description:
Lower camera

Parameters:
Object - camera
Scalar - height
Scalar - shot duration

Returns:


Examples:
(begin example)
[_camera,10,10] call ALIVE_fnc_lowerCamera;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_camera", "_height", "_duration", "_position", "_Y"];

_camera = _this select 0;
_height = _this select 1;
_duration = if(count _this > 2) then {_this select 2} else {5};

_position = getPosATL _camera;
_Y = _position select 2;
_position set [2,_Y-_height];

_camera camPreparePos _position;
_camera camCommitPrepared _duration;