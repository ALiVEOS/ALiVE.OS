#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(stopCinematic);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_stopCinematic

Description:
Stop cinematic

Parameters:
Object - camera
Boolean - transition instantly

Returns:


Examples:
(begin example)
[_camera] call ALIVE_fnc_stopCinematic;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

params ["_camera", ["_instant", false]];

if!(_instant) then {
    2000 cutText ["", "BLACK", 1];
    sleep 1; 2000 cutFadeOut 1; sleep 1;
};
_camera cameraEffect ["Terminate", "Back"];