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

private ["_camera","_instant"];

_camera = _this select 0;
_instant = if(count _this > 1) then {_this select 1} else {false};

if!(_instant) then {
    2000 cutText ["", "BLACK", 1];
    sleep 1;
    2000 cutFadeOut 1;

    sleep 1;
};

_camera cameraEffect ["Terminate", "Back"];