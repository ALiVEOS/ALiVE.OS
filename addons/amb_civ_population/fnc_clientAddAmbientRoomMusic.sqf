#include "\x\alive\addons\amb_civ_population\script_component.hpp"
SCRIPT(clientAddAmbientRoomMusic);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_clientAddAmbientRoomMusic

Description:
Add ambient room music on a client

Parameters:

Object - building to add light to

Returns:

Examples:
(begin example)
_light = [_building, _light, _brightness, _colour] call ALIVE_fnc_clientAddAmbientRoomMusic
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

params ["_building","_source","_track"];

_source attachTo [_building,[1,1,1]];
hideObject _source;

_source say3d _track;