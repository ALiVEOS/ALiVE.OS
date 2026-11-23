#include "\x\alive\addons\sys_GC\script_component.hpp"
SCRIPT(GCAbandoned);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_GCAbandoned

Description:
Garbage Collector, Abandoned Vehicles: every 60 seconds, the enemy land vehicle
profiles that are abandoned (ALiVE_fnc_vehicleAbandoned) and have no player
within the set distance are removed, or turned into wrecks, as the module sets.
With ACE and RHS a knocked-out tank is often left standing after its crew bail
out instead of blowing up; this is what clears those hulls.

Enemy means a side hostile to every side a player is on; with no player in the
mission nothing is touched. Never touched: player-side and civilian vehicles,
held reserves and artillery, and vehicles players have used (a player getting
in takes a vehicle off the profile system, so it is never seen here).
Player logistics, MHQ and combat support vehicles are not profiles either.

It also keeps the crew-lost mark the abandoned test reads: a profile seen with a
crew and later without one gets ALiVE_crewLost, kept in a save, and the time.

Parameters:
    _logic - OBJECT - the Garbage Collector module (mode, delay and distance set by its start)

Returns:
    Nothing (runs until the mission ends)

See Also:
    ALiVE_fnc_vehicleAbandoned, ALiVE_fnc_GC

Author:
    Jman
---------------------------------------------------------------------------- */

params [["_logic", objNull, [objNull]]];
if (!isServer || {isNull _logic}) exitWith {};

private _mode = _logic getVariable ["abandonedMode", "off"];
private _delay = _logic getVariable ["abandonedDelay", 900];
private _distance = _logic getVariable ["abandonedDistance", 1000];
["Garbage Collector - abandoned vehicles: %1 after %2 min without a crew, none within %3 m of a player", _mode, round (_delay / 60), _distance] call ALiVE_fnc_dump;

if (isNil "ALiVE_GC_crewLostAt") then { ALiVE_GC_crewLostAt = createHashMap };
private _seenCrewed = createHashMap;

waitUntil { sleep 5; !isNil "ALIVE_profileHandler" };

while { true } do {
    sleep 60;
    private _players = allPlayers - entities "HeadlessClient_F";
    private _playerSides = [];
    { _playerSides pushBackUnique side group _x } forEach _players;
    private _removed = 0; private _wrecked = 0; private _waiting = 0;

    private _ids = [ALIVE_profileHandler, "getProfilesByType", "vehicle"] call ALIVE_fnc_profileHandler;
    if (isNil "_ids") then { _ids = [] };
    {
        private _p = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
        if (isNil "_p") then { continue };
        if !(([_p, "objectType", ""] call ALIVE_fnc_hashGet) in ["Car", "Tank", "Armored", "Truck"]) then { continue };
        private _id = _x;
        private _crewed = !(([_p, "entitiesInCommandOf", []] call ALIVE_fnc_hashGet) isEqualTo []) || {!(([_p, "entitiesInCargoOf", []] call ALIVE_fnc_hashGet) isEqualTo [])};
        if (_crewed) then { _seenCrewed set [_id, true]; continue };

        // the crew-lost mark: crewed before and empty now, or brought back by a load
        private _lost = [_p, "ALiVE_crewLost", false] call ALIVE_fnc_hashGet;
        if (!_lost && {_id in _seenCrewed}) then { [_p, "ALiVE_crewLost", true] call ALIVE_fnc_hashSet; _lost = true };
        if (_lost && {!(_id in ALiVE_GC_crewLostAt)}) then { ALiVE_GC_crewLostAt set [_id, time] };

        if (_mode == "off" || {_playerSides isEqualTo []}) then { continue };
        private _side = switch (toUpper ([_p, "side", ""] call ALIVE_fnc_hashGet)) do { case "EAST": {east}; case "WEST": {west}; case "GUER": {resistance}; default {civilian} };
        if (_side == civilian || {(_playerSides findIf { (_side getFriend _x) >= 0.6 }) >= 0}) then { continue };
        if ([_p, "ALiVE_reserveLocked", false] call ALIVE_fnc_hashGet) then { continue };
        if ([_p, "ALiVE_artyHold", false] call ALIVE_fnc_hashGet) then { continue };
        if !([_p, _delay] call ALiVE_fnc_vehicleAbandoned) then { continue };

        private _pos = [_p, "position", [0,0,0]] call ALIVE_fnc_hashGet;
        if ((_players findIf { (_x distance2D _pos) < _distance }) >= 0) then { _waiting = _waiting + 1; continue };

        private _veh = [_p, "vehicle", objNull] call ALIVE_fnc_hashGet;
        private _active = !isNull _veh && {[_p, "active", false] call ALIVE_fnc_hashGet};
        if (_mode == "wreck") then {
            if (!_active) then {
                _veh = createVehicle [[_p, "vehicleClass", ""] call ALIVE_fnc_hashGet, [_pos#0, _pos#1, 0], [], 0, "CAN_COLLIDE"];
                _veh setDir ([_p, "direction", 0] call ALIVE_fnc_hashGet);
            };
            [ALIVE_profileHandler, "unregisterProfile", _p] call ALIVE_fnc_profileHandler;
            if (!isNull _veh) then {
                _veh setVariable [QGVAR(IGNORE), true, true];   // kept as battle damage, never collected
                _veh setDamage [1, false];
            };
            _wrecked = _wrecked + 1;
        } else {
            [ALIVE_profileHandler, "unregisterProfile", _p] call ALIVE_fnc_profileHandler;
            if (!isNull _veh) then { deleteVehicle _veh };
            _removed = _removed + 1;
        };
        ALiVE_GC_crewLostAt deleteAt _id;
        _seenCrewed deleteAt _id;
    } forEach +_ids;

    if (_removed + _wrecked > 0) then {
        ["Garbage Collector - abandoned vehicles: %1 removed, %2 turned into wrecks, %3 waiting for players to move away", _removed, _wrecked, _waiting] call ALiVE_fnc_dump;
    };
};
