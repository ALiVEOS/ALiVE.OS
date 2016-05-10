#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(staticShot);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_staticShot

Description:
Static Shot

Parameters:
Object - camera
Object - shot target
Scalar - shot duration

Returns:


Examples:
(begin example)
[_camera,_target,10] call ALIVE_fnc_staticShot;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_camera", "_target", "_duration"];

_camera = _this select 0;
_target = _this select 1;
_duration = if(count _this > 2) then {_this select 2} else {5};

_camera camPrepareTarget _target;
_camera camCommitPrepared _duration;