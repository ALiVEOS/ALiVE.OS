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

params ["_camera", "_height", ["_duration", 5]];

private _position = getPosATL _camera;
private _Y = _position select 2;
_position set [2,_Y-_height];

_camera camPreparePos _position;
_camera camCommitPrepared _duration;