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
     SKIPPED when `_requireReserve` is false ("controlled" mode): then any
     objective the side actually controls (checks 2+3) counts as held,
     even if OPCOM hasn't designated it a reserve. mil_logistics heli-insert
     routing uses the strict default (true); the COP overlay passes false so
     it surfaces every objective a side holds, not just reserve anchors.

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
     ENEMY means hostile, not "not ours". Both halves take their sides from
     ALiVE_fnc_getSideAllegiances, the mod's own 0.6 friendliness test and
     what mil_OPCOM and the air commander already ask, so an allied faction
     standing on an objective no longer makes it read as lost. Counting
     every other side made a true answer unreachable on any mission with a
     friendly second faction: the allies never leave, so the objective
     stayed unheld for the rest of the mission.

The 3-enemy threshold is the same value mil_logistics has used since
2026-05-01; raising it makes the predicate stricter (treats objectives
as lost on a single enemy scout).

Parameters:
    0: HASH   - OPCOM objective hash (the entries pushed onto `objectives`
                by ALiVE_fnc_OPCOM `case "createobjective"`).
    1: STRING - Friendly side text: "WEST" / "EAST" / "GUER". Case is not
                significant. Anything else is refused.
    2: NUMBER - Optional. Enemy-presence radius in metres. Default 300.
    3: BOOL   - Optional. Require tacom_state "reserve" (check 1). Default
                true (strict reserve-anchor predicate). Pass false for
                "controlled" mode (COP overlay) to drop check 1.

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
    ["_enemyRadius", 300,     [0]],
    ["_requireReserve", true, [true]]
];

// What this replaces tested isNil, which the params block above had already
// made impossible: a missing argument arrives as objNull, never as nil. So
// anything that was not an objective hash reached the body and threw, in one of
// two places depending on the mode: on (_obj select 1) below in strict mode, or
// on the section count once hashGet had turned the non-hash away, in controlled
// mode. Said out loud rather than refused quietly, because a silent false paints
// an objective as not held with nothing in the log to explain it.
if !([_obj] call ALIVE_fnc_isHash) exitWith {
    ["ALiVE_fnc_isHeldObjective - not an objective hash: %1", _obj] call ALiVE_fnc_dump;
    false
};

// The side is settled before anything reads it. getSideAllegiances uppercases
// its own input, but the spawned-unit half does not, and the list subtraction
// this used to do left "WEST" in the enemy list when handed "West", so a side's
// own virtualised profiles were counted against it.
_side = toUpper _side;
if !(_side in ["WEST", "EAST", "GUER"]) exitWith {
    ["ALiVE_fnc_isHeldObjective - %1 is not a side this can answer for", _side] call ALiVE_fnc_dump;
    false
};

// ----- Check 1: tacom_state == "reserve" (skipped in controlled mode) --------
// Strict (default): the objective must be an OPCOM-designated reserve anchor —
// what mil_logistics heli-insert routing needs. Controlled mode
// (_requireReserve false, COP overlay): skip this gate so any objective the
// side actually holds (checks 2+3) counts. Routed through a top-level sentinel
// so the function-level exitWith stays at function scope — an exitWith inside
// the then-block would only exit the block, not the function.
private _reserveOk = true;
if (_requireReserve) then {
    private _objState = "";
    if ("tacom_state" in (_obj select 1)) then {
        _objState = [_obj, "tacom_state", "none"] call ALIVE_fnc_hashGet;
    };
    _reserveOk = (_objState == "reserve");
};
if (!_reserveOk) exitWith { false };

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

// Who is hostile, asked once and used by both halves, so the two cannot drift
// apart. The helper answers in side TEXT, which is what getNearProfiles wants;
// the same answer mapped to side objects is what nearEntities wants. Civilians
// need no special case: the helper only ever reports the three combatant sides,
// so civilian cannot appear in either list. A renegade is named separately,
// being hostile to everyone and a member of no side.
([_side] call ALiVE_fnc_getSideAllegiances) params [["_enemySides", [], [[]]]];
private _enemySideObjs = _enemySides apply { [_x] call ALiVE_fnc_sideTextToObject };

private _nearUnits = _objPos nearEntities [["Man","Car","Tank"], _enemyRadius];
private _enemyNear = _nearUnits select {
    private _s = side _x;
    (_s in _enemySideObjs) || {_s isEqualTo sideEnemy}
};

// An empty hostile list is the right answer on a mission where nobody else is
// hostile, and it behaves: the side filter still engages for an empty array
// (only "all" switches it off) and then matches nothing rather than everything.
private _enemyProfiles = [_objPos, _enemyRadius, [_enemySides, "entity"], true] call ALIVE_fnc_getNearProfiles;

// There was a filter here stripping civilian-side profiles, against a faction
// registry leaving a civilian flagged with a non-friendly side. It cannot fire
// any more and so has gone: the profile search now matches only sides this
// helper named, and it names none but the three combatant ones.

private _enemyTotal = (count _enemyNear) + (count _enemyProfiles);
if (_enemyTotal >= 3) exitWith { false };

true
