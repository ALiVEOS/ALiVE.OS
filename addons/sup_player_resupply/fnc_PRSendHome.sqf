#include "\x\alive\addons\sup_player_resupply\script_component.hpp"
SCRIPT(PRSendHome);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_PRSendHome

Description:
Send home the men Player Combat Logistics delivered into a player's group (#691).
They leave the group as a group of their own, head 1.5 km away from the player,
away from the nearest enemy, and are removed once no player is within 600 m
(300 m after 15 minutes, for a player who follows them). Runs on the server.

Parameters:
Object - the player whose delivered men go home

Returns:
Nothing

Examples:
(begin example)
[player] remoteExecCall ["ALIVE_fnc_PRSendHome", 2];
(end)

See Also:
- <ALIVE_fnc_PRMenuDef>

Author:
Jman
---------------------------------------------------------------------------- */

params [["_player", objNull, [objNull]]];

if (!isServer || {isNull _player}) exitWith {};

private _men = (units group _player) select { alive _x && {!isPlayer _x} && {_x getVariable ["ALiVE_PR_rented", false]} };
if (_men isEqualTo []) exitWith {};

// Vehicles that came with them (every man aboard is one of them) go with them; any other they
// were riding in, a player's say, they get out of.
private _own = [];
{
    private _v = vehicle _x;
    if (_v != _x) then {
        if (((crew _v) findIf { !(_x in _men) }) < 0) then { _own pushBackUnique _v } else { unassignVehicle _x; moveOut _x };
    };
} forEach _men;

private _group = createGroup [side group _player, true];
_men joinSilent _group;
{ _x setVariable ["ALiVE_PR_rented", nil, true] } forEach _men;

// Away from the nearest enemy within 2 km, or anywhere if there's none.
private _pos = getPosATL _player;
private _enemies = (_pos nearEntities ["CAManBase", 2000]) select { alive _x && {((side group _x) getFriend (side _group)) < 0.6} };
private _dir = if (_enemies isEqualTo []) then { random 360 } else {
    _enemies = [_enemies, [_pos], { _input0 distance2D _x }, "ASCEND"] call BIS_fnc_sortBy;
    (_enemies select 0) getDir _pos
};
// On land: the first heading round from that one, a quarter turn at a time, that ends ashore.
private _dest = _pos getPos [1500, _dir];
{
    private _try = _pos getPos [1500, _dir + _x];
    if (!surfaceIsWater _try) exitWith { _dest = _try };
} forEach [0, 45, -45, 90, -90, 135, -135, 180];
private _wp = _group addWaypoint [_dest, 0];
_wp setWaypointType "MOVE";
_wp setWaypointSpeed "FULL";
_group setBehaviour "AWARE";

[format [localize "STR_ALIVE_PR_SENDHOME_DONE", count _men]] remoteExecCall ["systemChat", _player];

[_group, _own] spawn {
    params ["_group", "_own"];
    private _t0 = time;
    waitUntil {
        sleep 10;
        private _alive = (units _group) select { alive _x };
        private _reach = if (time - _t0 > 900) then { 300 } else { 600 };
        (_alive isEqualTo []) || {(time - _t0 > 30) && {(allPlayers findIf { alive _x && {(_x distance2D (leader _group)) < _reach} }) < 0}}
    };
    { deleteVehicle _x } forEach (units _group);
    { if ((crew _x) isEqualTo []) then { deleteVehicle _x } } forEach _own;
    deleteGroup _group;
};
