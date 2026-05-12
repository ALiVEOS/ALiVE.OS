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
