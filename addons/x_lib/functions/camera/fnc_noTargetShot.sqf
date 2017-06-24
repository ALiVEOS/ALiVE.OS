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
ARJay, dixon13
---------------------------------------------------------------------------- */

params ["_camera", ["_duration", 5]];
(_this select 0) camCommitPrepared _duration;