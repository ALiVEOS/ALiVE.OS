#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(removeCamera);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_removeCamera

Description:
Removes a camera

Parameters:
Object - camera

Returns:


Examples:
(begin example)
[_camera] call ALIVE_fnc_removeCamera;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_camera"];

_camera = _this select 0;

camDestroy _camera;