#include <\x\alive\addons\amb_civ_population\script_component.hpp>
SCRIPT(clientAddAmbientRoomLight);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_clientAddAmbientRoomLight

Description:
Add ambient room light on a client

Parameters:

Object - building to add light to

Returns:

Examples:
(begin example)
_light = [_building, _light, _brightness, _colour] call ALIVE_fnc_clientAddAmbientRoomLight
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

params ["_building","_light","_brightness","_colour"];

if (hasInterface) then {
    _light setLightBrightness _brightness;
    _light setLightColor _colour;
    _light lightAttachObject [_building, [1,1,1]];
};