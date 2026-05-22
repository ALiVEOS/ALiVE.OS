#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(isHeldObjective);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_isHeldObjective

Description:
True if the given OPCOM objective hash counts as a friendly-held reserve at
this instant. Used by mil_logistics's HELI_INSERT routing to pick a viable
heli-insert anchor and by mil_c2istar's COP overlay to surface held-objective
intel to commanders. Both callers MUST share the same predicate so the visual
overlay matches the actual delivery routing decisions.

Predicate (three conjunctive checks):

  1. The objective's `tacom_state` hash entry is "reserve" — OPCOM has
     already flagged this objective as a held reserve in its own state
     machine. Any other tacom_state (assault / defend / patrol / none /
     etc.) disqualifies regardless of the other two checks.

  2. At least one section profile is still registered with
     ALIVE_profileHandler — confirms the OPCOM units originally assigned
     to hold the objective haven't been wiped out. If no section is
     assigned yet (count _section == 0) the check is skipped — trust
     tacom_state alone.

  3. Fewer than 3 enemy units within `_enemyRadius` (default 300m).
     Two-source check covers both spawned units (nearEntities) and
     virtualised profiles (ALiVE_fnc_getNearProfiles). Without the
     virtualised side, an enemy-occupied objective whose attackers are
     virtualised looks "empty" to nearEntities, the predicate falsely
     passes, and HELI_INSERT routes reinforcements straight into hostile
     territory (mil_logistics #fix 2026-05-01).

The 3-enemy threshold is the same value mil_logistics has used since
2026-05-01; raising it makes the predicate stricter (treats objectives
as lost on a single enemy scout).

Parameters:
    0: HASH   - OPCOM objective hash (the entries pushed onto `objectives`
                by ALiVE_fnc_OPCOM `case "createobjective"`).
    1: STRING - Friendly side text: "WEST" / "EAST" / "GUER".
    2: NUMBER - Optional. Enemy-presence radius in metres. Default 300.

Returns:
    BOOL - true iff the objective passes all three checks.

Examples:
(begin example)
private _held = [_obj, "WEST"] call ALiVE_fnc_isHeldObjective;
if (_held) then { ... };
(end)

Author:
ARJay, Jman
---------------------------------------------------------------------------- */

params [
    ["_obj",         objNull, [objNull, []]],
    ["_side",        "",      [""]],
    ["_enemyRadius", 300,     [0]]
];

if (isNil "_obj") exitWith { false };

// ----- Check 1: tacom_state == "reserve" -------------------------------------
private _objState = "";
if ("tacom_state" in (_obj select 1)) then {
    _objState = [_obj, "tacom_state", "none"] call ALIVE_fnc_hashGet;
};
if (_objState != "reserve") exitWith { false };

// ----- Check 2: at least one section profile still alive ---------------------
private _section = [_obj, "section", []] call ALIVE_fnc_hashGet;
private _hasAliveProfiles = false;
if (count _section > 0) then {
    {
        private _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
        if (!isNil "_profile") exitWith { _hasAliveProfiles = true; };
    } forEach _section;
} else {
    // No section assigned yet - trust tacom_state alone.
    _hasAliveProfiles = true;
};
if (!_hasAliveProfiles) exitWith { false };

// ----- Check 3: <3 enemy units within _enemyRadius ---------------------------
// Two-source: spawned units (nearEntities) + virtualised profiles
// (ALIVE_fnc_getNearProfiles). Without the virtualised side, an enemy-occupied
// objective whose attackers are virtualised reads as empty and the predicate
// falsely passes.
private _objPos = [_obj, "center"] call ALIVE_fnc_hashGet;
private _sideObj = [_side] call ALIVE_fnc_sideTextToObject;

private _nearUnits = _objPos nearEntities [["Man","Car","Tank"], _enemyRadius];
private _enemyNear = _nearUnits select { side _x != _sideObj && side _x != civilian };

// getNearProfiles' categorySide takes side text strings ("EAST"/"WEST"/"GUER"),
// not side objects.
private _enemySides = ["EAST","WEST","GUER"] - [_side];
private _enemyProfiles = [_objPos, _enemyRadius, [_enemySides, "entity"], true] call ALIVE_fnc_getNearProfiles;

// Filter out civilian-side profiles defensively in case a faction registry
// quirk leaves a civ profile flagged with a non-friendly side.
_enemyProfiles = _enemyProfiles select {
    ((_x select 2 select 3) != "CIV") && {(_x select 2 select 3) != "CIVILIAN"}
};

private _enemyTotal = (count _enemyNear) + (count _enemyProfiles);
if (_enemyTotal >= 3) exitWith { false };

true
