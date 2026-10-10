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
Jman
---------------------------------------------------------------------------- */

params ["_building","_source","_track"];

_source attachTo [_building,[1,1,1]];
hideObjectGlobal _source;

[_source, _track] call (missionNamespace getVariable ["ALiVE_CivPop_fnc_sayAmbient", { (_this select 0) say3D (_this select 1) }]); // Ambient Sound Volume (#638)