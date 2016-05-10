#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(anyPlayersInRangeIncludeAir);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_anyPlayersInRangeIncludeAir

Description:
Returns players within range of a position, including any players in planes or helicopters

Parameters:
Array - Position measuring from
Number - Distance being measured (optional)
Bool - Include Jets
Number - Jet spawn distance
Bool - Include Helicopter
Number - Helicopter spawn distance

Returns:
Boolean - Returns if players within range

Examples:
(begin example)
// No players in range
([_pos, 2500, 3500, 2500] call ALiVE_fnc_PlayersInRangeIncludeAir == false)
(end)

Author:
ARJay

Peer Reviewed:
---------------------------------------------------------------------------- */
private ["_position","_spawnDistance","_jetSpawnDistance","_helicopterSpawnDistance","_players","_player","_position","_InRange"];

PARAMS_1(_position);
DEFAULT_PARAM(1,_spawnDistance,1500);
DEFAULT_PARAM(2,_jetSpawnDistance,0);
DEFAULT_PARAM(3,_helicopterSpawnDistance,1500);

//Change that function below when ZEUS is stable
_players = allPlayers + allCurators;
//_players = allPlayers;
_InRange = [];

{
    if(
        (!(vehicle _x isKindOf "Plane") && {!(vehicle _x isKindOf "Helicopter")} && {(_x distance _position < _spawnDistance)}) ||
        {(vehicle _x isKindOf "Plane") && {(_x distance _position < _jetSpawnDistance)}} ||
        {(vehicle _x isKindOf "Helicopter") && {(_x distance _position < _helicopterSpawnDistance)}}
    ) then {
        _inRange pushback _x;
    };
} forEach _players;

_InRange