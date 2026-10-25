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

    // The Map EH can fire before visibleMap becomes true. Wait for the
    // engine's map state before rebuilding visibleMap-gated markers.
    [
        { visibleMap },
        {
            // Only bother if debug is actually on — nothing to refresh otherwise.
            // Re-toggle debug: the existing case "debug" path in fnc_profileHandler
            // enumerates every registered profile, deletes its markers, then (because
            // we pass true) recreates them. This is the map-open full-refresh sweep.
            if (!isNil "ALIVE_profileHandler" && {[ALIVE_profileHandler,"debug"] call ALiVE_fnc_profileHandler}) then {
                [ALIVE_profileHandler, "debug", true] call ALIVE_fnc_profileHandler;
            };

            // The Civilian Population module's debug draws its civilians the same
            // visibleMap-gated way, so they need the same sweep: without it a civilian
            // only showed if the map happened to be open when he spawned, despawned
            // or moved, and virtual ones that never changed state never showed
            // (Rob_FZ1 on Discord, 25 Oct). The flag is read from the hash: asking the
            // agent handler for it rebuilds every marker on the way.
            if (!isNil "ALIVE_agentHandler" && {[ALIVE_agentHandler,"debug",false] call ALIVE_fnc_hashGet}) then {
                [ALIVE_agentHandler, "debug", true] call ALIVE_fnc_agentHandler;
            };
        }
    ] call CBA_fnc_waitUntilAndExecute;
}];

// Post-death AI linger: when a player dies in an actively spawned area and
// respawns elsewhere, the spawn radius moves with them and nearby AI virtualise
// mid-combat. This handler stamps every profile within ALIVE_postDeathRadius
// of the death position with a postDeathLingerUntil timestamp; the despawn
// paths in fnc_profileVehicle and fnc_profileEntity honour that stamp.
// The despawn paths also extend the stamp when combat is still ongoing, so
// firefights aren't yanked into the virtual layer partway through. The time of
// the death is kept too, so those extensions stop after five.
addMissionEventHandler ["EntityKilled", {
    params ["_killed"];
    // Only react to player deaths on the server where the profile handler runs.
    if (!isPlayer _killed) exitWith {};
    if (isNil "ALIVE_profileHandler") exitWith {};
    if (isNil "ALIVE_postDeathGrace" || {isNil "ALIVE_postDeathRadius"}) exitWith {};

    private _deathPos = getPosASL _killed;
    private _now = diag_tickTime;
    private _until = _now + ALIVE_postDeathGrace;

    // getNearProfiles with ["all","all"] returns every entity AND vehicle
    // profile within the radius. Stamp each; the despawn hot paths read this.
    private _near = [_deathPos, ALIVE_postDeathRadius, ["all","all"]] call ALIVE_fnc_getNearProfiles;
    {
        [_x, "postDeathLingerUntil", _until] call ALIVE_fnc_hashSet;
        [_x, "postDeathStampedAt", _now] call ALIVE_fnc_hashSet;
    } forEach _near;
}];
