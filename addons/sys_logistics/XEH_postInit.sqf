#include "script_component.hpp"

// _id = [] spawn ALiVE_fnc_logisticsInit;

// ============================================================================
// ACE Fortify integration (#865)
// ----------------------------------------------------------------------------
// Forward ACEX Fortify object-placement and -deletion events into the ALiVE
// logistics object registry, so fortified items (sandbags, walls, hesco
// barriers, etc.) are tracked alongside player-deployed crates and visible
// to player resupply / logistics flows.
//
// Wiki had this as a recommended snippet for mission-makers to drop into
// their init.sqf. Promoting it into the addon so every ALiVE mission gets
// the integration automatically when ACEX Fortify is loaded - no per-
// mission boilerplate required.
//
// CfgPatches isClass gate keeps the handlers idle on missions without
// ACEX Fortify (the events would never fire anyway, but the gate means
// the registration cost is also zero on those missions).
//
// The inner !isNil guard catches missions that load ACEX Fortify but
// don't place a Player Logistics module - the event still fires but the
// integration safely no-ops.
// ============================================================================
if (isClass (configFile >> "CfgPatches" >> "acex_fortify")) then {
    ["acex_fortify_objectPlaced", {
        if (!isNil "ALiVE_SYS_LOGISTICS") then {
            [ALiVE_SYS_LOGISTICS, "updateObject", [(_this select 2)]] call ALIVE_fnc_logistics;
        };
    }] call CBA_fnc_addEventHandler;

    ["acex_fortify_objectDeleted", {
        if (!isNil "ALiVE_SYS_LOGISTICS") then {
            [ALiVE_SYS_LOGISTICS, "removeObject", [(_this select 2)]] call ALIVE_fnc_logistics;
        };
    }] call CBA_fnc_addEventHandler;
};

// ============================================================================
// ACE trenches
// ----------------------------------------------------------------------------
// A trench dug with ACE's entrenching tool is kept like a Fortify build, from
// the moment ACE says it has been dug all the way. One left half dug is not:
// put back on a load it would stand at its half-dug depth with no way to finish
// it, as ACE takes a trench with no progress of its own to be complete.
//
// ACE raises nothing when a trench is removed with the shovel, it just deletes
// it, so setEH gives every trench a Deleted handler that takes it back out of
// the store. Server only: the event reaches every machine, and the store and
// the handler both live on the server.
// ============================================================================
if (isServer && {isClass (configFile >> "CfgPatches" >> "ace_trenches")}) then {
    ["ace_trenches_finished", {
        params ["", ["_trench", objNull]];
        // ACE lifts the trench to its final height on the digger's machine just before it
        // says so, and the last move can arrive after the event. Read it a second later.
        [{
            params ["_trench"];
            if (isNil "ALiVE_SYS_LOGISTICS" || {isNull _trench}) exitWith {};
            [ALiVE_SYS_LOGISTICS, "updateObject", [_trench]] call ALIVE_fnc_logistics;
            [ALiVE_SYS_LOGISTICS, "setEH", [_trench]] call ALIVE_fnc_logistics;
        }, [_trench], 1] call CBA_fnc_waitAndExecute;
    }] call CBA_fnc_addEventHandler;
};
