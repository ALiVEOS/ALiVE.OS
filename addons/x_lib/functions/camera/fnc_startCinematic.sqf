#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(startCinematic);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_startCinematic

Description:
Start cinematic

Parameters:
Object - camera
Boolean - transition instantly
Boolean - show cinema border

Returns:


Examples:
(begin example)
[_camera,false,true] call ALIVE_fnc_startCinematic;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

params ["_camera", ["_instant", false], ["_cinemaBorder", false]];

if(_cinemaBorder) then { showCinemaBorder true; };

if!(_instant) then {
    2000 cutText ["", "BLACK", 1];
    sleep 1; 2000 cutFadeOut 1; sleep 1;
};

_camera cameraEffect ["Internal", "Back"];