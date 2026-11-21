#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(anyPlayersInRangeIncludeAir);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_anyPlayersInRangeIncludeAir

Description:
Return if any players are within range of a position, including any players in
planes or helicopters. Optionally also tests player-controlled UAVs against a
UAV-specific spawn radius - a UAV that has a player connected via UAV terminal
counts as a spawn source at the UAV's own position, independent of the
controlling player's physical character location.

Parameters:
Array - Position measuring from
Number - Distance being measured (optional, default 1500)
Number - Jet spawn distance (optional, default 0 = disabled)
Number - Helicopter spawn distance (optional, default 1500)
Number - UAV spawn distance (optional, default 0 = disabled). When >0,
         each UAV that has a connected player is checked against this radius.
         Back-compat: callers that omit this arg get the prior behaviour
         (no UAV check).
Boolean - Spawn check (optional, default false). When true, a helicopter above
         150 km/h and 10 m counts at the Virtual AI System's fast helicopter
         radius, when that is set and smaller, as it does for profiles. Despawn
         checks leave it false so nothing vanishes under a passing helicopter.

Returns:
Boolean - Returns if players within range

Examples:
(begin example)
// No players in range (no UAV check)
([_pos, 2500, 3500, 2500] call ALiVE_fnc_anyPlayersInRangeIncludeAir == false)

// With UAV check at 2300m radius
([_pos, 2500, 3500, 2500, 2300] call ALiVE_fnc_anyPlayersInRangeIncludeAir)
(end)

Author:
ARJay, Jman

Peer Reviewed:
---------------------------------------------------------------------------- */
private ["_position","_spawnDistance","_jetSpawnDistance","_helicopterSpawnDistance","_uavSpawnDistance","_spawnClaim","_players","_player","_position","_anyInRange"];

PARAMS_1(_position);
DEFAULT_PARAM(1,_spawnDistance,1500);
DEFAULT_PARAM(2,_jetSpawnDistance,0);
DEFAULT_PARAM(3,_helicopterSpawnDistance,1500);
DEFAULT_PARAM(4,_uavSpawnDistance,0);
DEFAULT_PARAM(5,_spawnClaim,false);

private _fastRadius = missionNamespace getVariable ["ALIVE_spawnRadiusHeliFast", 0];
private _fastHeli = _spawnClaim && {_fastRadius > 0} && {_fastRadius < _helicopterSpawnDistance};

// #918: drop headless clients (they sit in allPlayers) so an HC doesn't trigger spawning
_players = allPlayers - entities "HeadlessClient_F";
if (!isnil "ALIVE_profileSystem" && { [ALIVE_profileSystem,"zeusSpawn"] call ALiVE_fnc_hashGet }) then {
    _players append (allCurators select {isPlayer (getAssignedCuratorUnit _x)});
};

_anyInRange = false;

scopeName "main";

{
    if(
        (!(vehicle _x isKindOf "Plane") && {!(vehicle _x isKindOf "Helicopter")} && {(_x distance _position < _spawnDistance)}) ||
        {(vehicle _x isKindOf "Plane") && {(_x distance _position < _jetSpawnDistance)}} ||
        {(vehicle _x isKindOf "Helicopter") && {(_x distance _position) < (
            if (_fastHeli && {speed (vehicle _x) > 150} && {((getPos (vehicle _x)) select 2) > 10}) then { _fastRadius } else { _helicopterSpawnDistance }
        )}}
    ) then {
        _anyInRange = true;
        breakTo "main";
    };
} forEach _players;

// UAV check: player-controlled UAVs trigger spawning at the UAV's own
// position. Skipped when _uavSpawnDistance is 0 (default) so callers that
// don't pass the 5th arg retain the prior behaviour.
if (_uavSpawnDistance > 0) then {
    {
        if (_x distance _position < _uavSpawnDistance) then {
            _anyInRange = true;
            breakTo "main";
        };
    } forEach (allUnitsUAV select {isUavConnected _x});
};

_anyInRange
