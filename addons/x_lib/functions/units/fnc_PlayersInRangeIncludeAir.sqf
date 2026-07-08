#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(anyPlayersInRangeIncludeAir);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_PlayersInRangeIncludeAir

Description:
Returns the list of players within range of a position, including any in planes
or helicopters. Optionally also includes player-controlled UAVs whose UAV
position is within a UAV-specific spawn radius (each such UAV is appended
to the returned list as a spawn-source entity). Zeus curators count as
spawn sources only when the Profile System's "Zeus Spawn Virtual Groups"
option is enabled; headless clients are never counted.

Parameters:
Array - Position measuring from
Number - Distance being measured (optional, default 1500)
Number - Jet spawn distance (optional, default 0 = disabled)
Number - Helicopter spawn distance (optional, default 1500)
Number - UAV spawn distance (optional, default 0 = disabled). When >0,
         each connected UAV within range is appended to the result.
         Back-compat: callers that omit this arg get the prior behaviour
         (UAVs never included).

Returns:
Array - Players (and optionally UAVs) within range

Examples:
(begin example)
// No players in range (no UAV check)
([_pos, 2500, 3500, 2500] call ALiVE_fnc_PlayersInRangeIncludeAir == false)
(end)

Author:
ARJay, Jman

Peer Reviewed:
---------------------------------------------------------------------------- */
private ["_position","_spawnDistance","_jetSpawnDistance","_helicopterSpawnDistance","_uavSpawnDistance","_players","_player","_position","_InRange"];

PARAMS_1(_position);
DEFAULT_PARAM(1,_spawnDistance,1500);
DEFAULT_PARAM(2,_jetSpawnDistance,0);
DEFAULT_PARAM(3,_helicopterSpawnDistance,1500);
DEFAULT_PARAM(4,_uavSpawnDistance,0);

// #918: drop headless clients (they sit in allPlayers) so an HC doesn't trigger spawning
_players = allPlayers - entities "HeadlessClient_F";
// Zeus curators count as spawn sources only when the Profile System's
// "Zeus Spawn Virtual Groups" option is enabled - same gate as
// ALiVE_fnc_anyPlayersInRangeIncludeAir, so CQB activation and the
// despawn checks read the same option. No Profile System module placed
// -> ALIVE_profileSystem is nil -> curators not counted (lazy-eval safe).
if (!isnil "ALIVE_profileSystem" && { [ALIVE_profileSystem,"zeusSpawn"] call ALiVE_fnc_hashGet }) then {
    _players append allCurators;
};
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

// UAV inclusion: connected UAVs count as spawn sources at the UAV's own
// position. Skipped when _uavSpawnDistance is 0 (default) so callers that
// don't pass the 5th arg retain the prior behaviour.
if (_uavSpawnDistance > 0) then {
    {
        if (_x distance _position < _uavSpawnDistance) then {
            _InRange pushback _x;
        };
    } forEach (allUnitsUAV select {isUavConnected _x});
};

_InRange
