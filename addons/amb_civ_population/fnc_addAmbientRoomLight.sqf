#include "\x\alive\addons\amb_civ_population\script_component.hpp"
SCRIPT(addAmbientRoomLight);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_addAmbientRoomLight

Description:
Add ambient room light

Parameters:

Object - building to add light to

Returns:

Examples:
(begin example)
_light = [_building] call ALIVE_fnc_addAmbientRoomLight
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private _building = _this select 0;

private _colours = [[255,217,66],[255,162,41],[221,219,206]];
private _colour = _colours select (random((count _colours)-1));
private _brightness = random 10 / 100;

private _light = "#lightpoint" createVehicle getPos _building;

if(isMultiplayer) then
{
    [_building, _light, _brightness, _colour] remoteExec ["ALIVE_fnc_clientAddAmbientRoomLight"];
}
else
{
    _light setLightBrightness _brightness;
    _light setLightColor _colour;
    _light lightAttachObject [_building, [1,1,1]];
};

_light