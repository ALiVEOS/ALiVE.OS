#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(noTargetShot);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_noTargetShot

Description:
No target shot

Parameters:
Object - camera
Scalar - shot duration

Returns:


Examples:
(begin example)
[_camera,10] call ALIVE_fnc_noTargetShot;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_camera", "_duration"];

_camera = _this select 0;
_duration = if(count _this > 1) then {_this select 1} else {5};

_camera camCommitPrepared _duration;