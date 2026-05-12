/* ----------------------------------------------------------------------------
XEH_postInit for sys_profile

Registers a Map mission event handler so that debug markers are rebuilt for
every registered profile the moment the player opens the map. Without this,
stationary profiles never refresh their markers — createDebugMarkers is
visibleMap-gated (added to fix issue #838) and the position-change refresh
path is both throttled and skipped for profiles that don't move.

Server-only: the profile simulator runs server-side and createMarker is global.
On dedicated MP the server has no map UI so this EH never fires, which is fine
because visibleMap is permanently false on dedicated and no markers would be
created anyway. On SP / listen server the server machine is the map user, so
the refresh triggers correctly.

Author:
Jman
---------------------------------------------------------------------------- */
#include "script_component.hpp"

if (!isServer) exitWith {};

// #863 - register the admin / Zeus-visible debug-snapshot PFH. The PFH
// no-ops unless `ALiVE_debugVirtualisedProfiles` is true, so production
// missions pay nothing. Enable in debug console:
//   ALiVE_debugVirtualisedProfiles = true; publicVariable "ALiVE_debugVirtualisedProfiles";
[] call ALiVE_fnc_debugVirtualisedProfiles;

addMissionEventHandler ["Map", {
    params ["_mapIsOpened"];
    if (!_mapIsOpened) exitWith {};
    if (isNil "ALIVE_profileHandler") exitWith {};

    // Only bother if debug is actually on — nothing to refresh otherwise.
    private _debugOn = [ALIVE_profileHandler, "debug"] call ALIVE_fnc_profileHandler;
    if (!_debugOn) exitWith {};

    // Re-toggle debug: the existing case "debug" path in fnc_profileHandler
    // enumerates every registered profile, deletes its markers, then (because
    // we pass true) recreates them. This is the map-open full-refresh sweep.
    [ALIVE_profileHandler, "debug", true] call ALIVE_fnc_profileHandler;
}];

// Post-death AI linger: when a player dies in an actively spawned area and
// respawns elsewhere, the spawn radius moves with them and nearby AI virtualise
// mid-combat. This handler stamps every profile within ALIVE_postDeathRadius
// of the death position with a postDeathLingerUntil timestamp; the despawn
// paths in fnc_profileVehicle and fnc_profileEntity honour that stamp.
// The despawn paths also extend the stamp when combat is still ongoing, so
// firefights aren't yanked into the virtual layer partway through.
addMissionEventHandler ["EntityKilled", {
    params ["_killed"];
    // Only react to player deaths on the server where the profile handler runs.
    if (!isPlayer _killed) exitWith {};
    if (isNil "ALIVE_profileHandler") exitWith {};
    if (isNil "ALIVE_postDeathGrace" || {isNil "ALIVE_postDeathRadius"}) exitWith {};

    private _deathPos = getPosASL _killed;
    private _until = diag_tickTime + ALIVE_postDeathGrace;

    // getNearProfiles with ["all","all"] returns every entity AND vehicle
    // profile within the radius. Stamp each; the despawn hot paths read this.
    private _near = [_deathPos, ALIVE_postDeathRadius, ["all","all"]] call ALIVE_fnc_getNearProfiles;
    {
        [_x, "postDeathLingerUntil", _until] call ALIVE_fnc_hashSet;
    } forEach _near;
}];
