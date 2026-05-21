#include "\x\alive\addons\sys_profile\script_component.hpp"
SCRIPT(debugVirtualisedProfiles);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_debugVirtualisedProfiles

Description:
    Server-side periodic walker over ALIVE_profileHandler's registered
    profiles, broadcasting a snapshot to admin / Zeus clients for live
    mission visibility into virtualised profile positions.

    Backs GitHub issue #863 (debug info for virtualised groups).

    Snapshot shape per profile:
      [_profileID, _type, _position, _side, _faction, _active,
       _vehicleClass, _unitClasses, _waypointCount]

    Activation: requires `ALiVE_debugVirtualisedProfiles = true` to be
    set (typically via debug console). When the global is false / nil
    the PFH no-ops, so it costs nothing in production missions.

    Throttle: 5s tick. Each tick walks all registered profiles
    (typical mission has 100-500), serialises minimum fields, fires
    one remoteExec per call. Per-client work is small (delete prior
    local markers, create new ones).

    Admin / Zeus gating is applied on the CLIENT side. The server
    broadcasts to all clients; non-admin clients early-exit before
    creating any local markers. Cheap on the wire (one remoteExec)
    vs. filtering recipients server-side (which would need a
    per-tick allPlayers + admin scan).

Parameters:
    None - reads globals.

Returns:
    Nothing - registers a CBA_fnc_addPerFrameHandler on first call.

Author:
    Jman
---------------------------------------------------------------------------- */

if (!isServer) exitWith {};
if (!isNil "ALiVE_debugVirtProfilesPFH") exitWith {};

ALiVE_debugVirtProfilesPFH = [{
    if (isNil "ALiVE_debugVirtualisedProfiles" || {!ALiVE_debugVirtualisedProfiles}) exitWith {};
    if (isNil "ALIVE_profileHandler") exitWith {};

    private _profiles = [ALIVE_profileHandler, "getProfiles"] call ALIVE_fnc_profileHandler;
    if (isNil "_profiles" || {typeName _profiles != "ARRAY"}) exitWith {};
    if (count _profiles < 3) exitWith {};

    private _profileValues = _profiles select 2;
    private _snapshot = [];

    {
        private _p = _x;
        if (typeName _p == "ARRAY" && {count _p >= 3}) then {
            private _id  = [_p, "profileID", ""] call ALIVE_fnc_hashGet;
            private _typ = [_p, "type", ""] call ALIVE_fnc_hashGet;
            private _pos = [_p, "position", [0,0,0]] call ALIVE_fnc_hashGet;
            private _sde = [_p, "side", ""] call ALIVE_fnc_hashGet;
            private _fac = [_p, "faction", ""] call ALIVE_fnc_hashGet;
            private _act = [_p, "active", false] call ALIVE_fnc_hashGet;

            // type-specific fields - branch on _typ. entity has
            // unitClasses + waypoints, vehicle has vehicleClass.
            private _vcl = "";
            private _ucl = [];
            private _wpc = 0;
            if (_typ == "vehicle") then {
                _vcl = [_p, "vehicleClass", ""] call ALIVE_fnc_hashGet;
            } else {
                if (_typ == "entity") then {
                    _ucl = [_p, "unitClasses", []] call ALIVE_fnc_hashGet;
                    private _wps = [_p, "waypoints", []] call ALIVE_fnc_hashGet;
                    _wpc = count _wps;
                };
            };

            if (_id != "" && {count _pos >= 2}) then {
                _snapshot pushBack [_id, _typ, _pos, _sde, _fac, _act, _vcl, _ucl, _wpc];
            };
        };
    } forEach _profileValues;

    // Broadcast to all machines (target 0). Includes the server
    // itself, which matters in SP / listen-host where the admin
    // player IS the server - target -2 (everyone except server)
    // would exclude them. Non-admin / non-Zeus clients self-filter
    // in the receiver. Server-side filtering would require an
    // allPlayers + admin lookup per tick; cheaper to send
    // unconditionally and let clients drop the message.
    [_snapshot] remoteExec ["ALiVE_fnc_debugVirtualisedProfilesClient", 0];

    // Server-side tick-confirm diag. Gated on the same global as the
    // PFH itself; silent in production.
    if (ALiVE_debugVirtualisedProfiles) then {
        ["[ALiVE VirtDebug] server tick: broadcast %1 profiles", count _snapshot] call ALiVE_fnc_dump;
    };
}, 5, []] call CBA_fnc_addPerFrameHandler;
