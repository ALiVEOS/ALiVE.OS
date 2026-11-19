#include "\x\alive\addons\main\script_component.hpp"

SCRIPT(test_lambs);

/* ----------------------------------------------------------------------------
Integrate setting test (#1122). Covers ALiVE_fnc_lambs: the taskFor decision table, the
Guard / Integrate split in ALiVE_fnc_modConflicts "guard" and "unit", the order store and
order stamps, the despawn waypoint scrub, reserve lookup and remote op refusal.

Needs no LAMBS and no player: run it on a local host or a dedicated server with
    [] execVM "\x\alive\addons\main\tests\test_lambs.sqf";
and read the RPT for FAIL lines. Checks that need LAMBS loaded log "skip" without it.
Every global the test touches is put back as it was.
---------------------------------------------------------------------------- */

if (!isServer) exitWith { diag_log "test_lambs: run it on the server" };

private _fails = [];
private _fnc_check = {
    params ["_name", "_ok"];
    if (isNil "_ok") exitWith {
        _fails pushBack _name;
        diag_log format ["  FAIL  %1  (assertion threw or returned nothing)", _name];
    };
    if (_ok) then {
        diag_log format ["  pass  %1", _name];
    } else {
        _fails pushBack _name;
        diag_log format ["  FAIL  %1", _name];
    };
};
private _lambsLoaded = isClass (configFile >> "CfgPatches" >> "lambs_danger") && {!isNil "lambs_wp_fnc_taskReset"};

diag_log "=== LAMBS Integrate test ===";

// --- keep what we change ---------------------------------------------------
private _savedNames = ["ALiVE_MODCONFLICTS_MODE", "ALiVE_MODCONFLICTS_GUARD", "ALiVE_MODCONFLICTS_INTEGRATE", "ALiVE_lambs_on", "ALiVE_lambs_debug", "OPCOM_instances"];
private _saved = _savedNames apply { missionNamespace getVariable _x };
private _savedOrders = if (isNil "ALiVE_lambs_orders") then { nil } else { +ALiVE_lambs_orders };

// --- taskFor: the decision table (pure) ------------------------------------
// [kind, role, dist, foot, mounted, enemy, atOrder, done, buildings, hasDefend, starts]
private _t = { ["taskFor", _this] call ALiVE_fnc_lambs };
["taskFor: capture near, enemy close, on the order -> assault", (["capture", "MANEUVER", 250, 6, false, 100, true, false, 0, true, []] call _t) == "assault"] call _fnc_check;
["taskFor: capture, no enemy known -> nothing", (["capture", "MANEUVER", 250, 6, false, -1, true, false, 0, true, []] call _t) == ""] call _fnc_check;
["taskFor: capture, assault already had -> nothing on the way", (["capture", "MANEUVER", 250, 6, false, 100, true, false, 0, true, ["assault"]] call _t) == ""] call _fnc_check;
["taskFor: capture done, town, enemy close -> cqb", (["capture", "MANEUVER", 50, 6, false, 50, false, true, 5, true, ["assault"]] call _t) == "cqb"] call _fnc_check;
["taskFor: capture done, two buildings -> nothing", (["capture", "MANEUVER", 50, 6, false, 50, false, true, 2, true, []] call _t) == ""] call _fnc_check;
["taskFor: defend at the objective -> defend", (["defend", "MANEUVER", 30, 6, false, -1, false, true, 0, true, []] call _t) == "defend"] call _fnc_check;
["taskFor: defend without taskDefend -> nothing", (["defend", "MANEUVER", 30, 6, false, -1, false, true, 0, false, []] call _t) == ""] call _fnc_check;
["taskFor: recon on foot near -> overwatch", (["recon", "MANEUVER", 200, 4, false, -1, true, false, 0, true, []] call _t) == "overwatch"] call _fnc_check;
["taskFor: recon mounted -> nothing", (["recon", "MANEUVER", 200, 4, true, -1, true, false, 0, true, []] call _t) == ""] call _fnc_check;
["taskFor: attack within range -> hunt", (["attack", "RESERVE", 300, 6, false, -1, false, false, 0, true, []] call _t) == "hunt"] call _fnc_check;
["taskFor: attack far -> nothing", (["attack", "MANEUVER", 2000, 6, false, -1, false, false, 0, true, []] call _t) == ""] call _fnc_check;
["taskFor: sad near -> sad", (["sad", "MANEUVER", 100, 6, false, -1, false, false, 0, true, []] call _t) == "sad"] call _fnc_check;
["taskFor: ambush -> nothing", (["ambush", "MANEUVER", 10, 6, false, 50, true, false, 0, true, []] call _t) == ""] call _fnc_check;
["taskFor: reserve -> nothing", (["reserve", "MANEUVER", 10, 6, false, 50, true, false, 0, true, []] call _t) == ""] call _fnc_check;
["taskFor: creep near -> creep", (["creep", "MANEUVER", 50, 4, false, -1, false, false, 0, true, []] call _t) == "creep"] call _fnc_check;
["taskFor: STATIC never gets a task", (["attack", "STATIC", 10, 6, false, 10, true, true, 9, true, []] call _t) == ""] call _fnc_check;
["taskFor: one man on foot gets no task", (["attack", "MANEUVER", 10, 1, true, 10, true, true, 9, true, []] call _t) == ""] call _fnc_check;

// --- Guard and Integrate in ALiVE_fnc_modConflicts ------------------------------
private _grp = createGroup [east, true];
private _unit = _grp createUnit ["O_Soldier_F", [0, 0, 0], [], 0, "NONE"];
ALiVE_MODCONFLICTS_GUARD = [["lambs_danger_disableGroupAI"], [], ["lambs_danger_disableAI"]];
ALiVE_MODCONFLICTS_INTEGRATE = [["lambs_danger_disableGroupAI"], [], ["lambs_danger_disableAI"]];

ALiVE_MODCONFLICTS_MODE = "GUARD";
["guard", [_grp, "PROFILE"]] call ALiVE_fnc_modConflicts;
["guard: Guard sets the LAMBS group switch on a profiled group (U23)", _grp getVariable ["lambs_danger_disableGroupAI", false]] call _fnc_check;
["guard: Guard does not mark the group for LAMBS", !(_grp getVariable ["ALiVE_lambs_run", false])] call _fnc_check;

_grp setVariable ["lambs_danger_disableGroupAI", nil, true];
ALiVE_MODCONFLICTS_MODE = "WARN";
["guard", [_grp, "PROFILE"]] call ALiVE_fnc_modConflicts;
["guard: Warn sets nothing", isNil { _grp getVariable "lambs_danger_disableGroupAI" }] call _fnc_check;

// Integrate with LAMBS not active here: plain Guard
ALiVE_MODCONFLICTS_MODE = "INTEGRATE";
ALiVE_lambs_on = false;
["guard", [_grp, "PROFILE"]] call ALiVE_fnc_modConflicts;
["guard: Integrate without LAMBS active guards as Guard", _grp getVariable ["lambs_danger_disableGroupAI", false]] call _fnc_check;

// Integrate with LAMBS active: a profiled group is left to LAMBS, any other group is guarded
if (_lambsLoaded) then {
    ALiVE_lambs_on = true;
    _grp setVariable ["lambs_danger_disableGroupAI", nil, true];
    ["guard", [_grp, "PROFILE"]] call ALiVE_fnc_modConflicts;
    ["guard: Integrate leaves a profiled group's LAMBS switch alone", isNil { _grp getVariable "lambs_danger_disableGroupAI" }] call _fnc_check;
    ["guard: Integrate marks the profiled group for LAMBS", _grp getVariable ["ALiVE_lambs_run", false]] call _fnc_check;
    private _other = createGroup [east, true];
    ["guard", [_other]] call ALiVE_fnc_modConflicts;
    ["guard: Integrate still guards a group with no role (CQB, roadblocks, Combat Support)", _other getVariable ["lambs_danger_disableGroupAI", false]] call _fnc_check;
    deleteGroup _other;
} else {
    diag_log "  skip  guard: Integrate with LAMBS active (LAMBS not loaded)";
};

// --- orders and stamps -----------------------------------------------------------
ALiVE_lambs_on = true;
private _gO = createGroup [east, true];
_gO setVariable ["ALiVE_lambs_stamp", 0, true];
ALiVE_lambs_active set ["test_lambs_p1", _gO];
["order", ["test_lambs_p1", "attack", [100, 100, 0], "test_lambs_target", -1]] call ALiVE_fnc_lambs;
private _o = _gO getVariable ["ALiVE_lambs_order", []];
["order: stored on the server", ("test_lambs_p1" in ALiVE_lambs_orders)] call _fnc_check;
["order: copied to the group with the kind", (_o param [0, ""]) == "attack"] call _fnc_check;
["order: a new order bumps the stamp", (_gO getVariable ["ALiVE_lambs_stamp", 0]) == 1 && {(_o param [3, -1]) == 1}] call _fnc_check;
["order", ["test_lambs_p1", "ambush", [100, 100, 0], "obj", time + 60]] call ALiVE_fnc_lambs;
["order: an ambush keeps the group quiet", _gO getVariable ["ALiVE_lambs_mute", false]] call _fnc_check;
private _fakeProfile = [] call ALiVE_fnc_hashCreate;
[_fakeProfile, "profileID", "test_lambs_p1"] call ALiVE_fnc_hashSet;
["reordered", [_fakeProfile]] call ALiVE_fnc_lambs;
["reordered: the stored order goes", !("test_lambs_p1" in ALiVE_lambs_orders)] call _fnc_check;
["reordered: the group's order goes and the stamp moves", (_gO getVariable ["ALiVE_lambs_order", [0]]) isEqualTo [] && {(_gO getVariable ["ALiVE_lambs_stamp", 0]) == 3}] call _fnc_check;
ALiVE_lambs_active deleteAt "test_lambs_p1";
deleteGroup _gO;

ALiVE_lambs_on = false;
["order", ["test_lambs_p2", "attack", [1, 1, 0], "x", -1]] call ALiVE_fnc_lambs;
["order: nothing is stored with Integrate off", !("test_lambs_p2" in ALiVE_lambs_orders)] call _fnc_check;

// --- despawn scrub -------------------------------------------------------------
private _wpOrder = [[500, 500, 0], 15] call ALIVE_fnc_createProfileWaypoint;
private _wpHunt = [[700, 700, 0], 15] call ALIVE_fnc_createProfileWaypoint;
private _wpHold = [[500, 500, 0], 15, "HOLD"] call ALIVE_fnc_createProfileWaypoint;
[_wpHold, "name", "ALiVE_lambs_defend"] call ALiVE_fnc_hashSet;
private _wpReinforce = [[800, 800, 0], 15] call ALIVE_fnc_createProfileWaypoint;
[_wpReinforce, "name", "LAMBS_Reinforce_SAD"] call ALiVE_fnc_hashSet;
private _p = [] call ALiVE_fnc_hashCreate;
[_p, "profileID", "test_lambs_p3"] call ALiVE_fnc_hashSet;
[_p, "waypoints", [_wpOrder, _wpHunt, _wpHold, _wpReinforce]] call ALiVE_fnc_hashSet;
[_p, "lambsKeep", [[[500, 500, 0], "MOVE"]]] call ALiVE_fnc_hashSet;
["scrub", [_p]] call ALiVE_fnc_lambs;
private _left = [_p, "waypoints", []] call ALiVE_fnc_hashGet;
["scrub: only the commander's waypoint is kept", count _left == 1 && {(_left select 0) isEqualTo _wpOrder}] call _fnc_check;
["scrub: the note is cleared", ([_p, "lambsKeep", [0]] call ALiVE_fnc_hashGet) isEqualTo []] call _fnc_check;
[_p, "waypoints", [_wpOrder, _wpReinforce]] call ALiVE_fnc_hashSet;
["scrub", [_p]] call ALiVE_fnc_lambs;
["scrub: without a note, named LAMBS waypoints still go", count ([_p, "waypoints", []] call ALiVE_fnc_hashGet) == 1] call _fnc_check;

// --- reserve lookup --------------------------------------------------------------
private _opcom = [] call ALiVE_fnc_hashCreate;
[_opcom, "ProfileIDsReserve", ["test_lambs_r1"]] call ALiVE_fnc_hashSet;
OPCOM_instances = [_opcom];
["isReserve: a profile in a reserve list", ["isReserve", ["test_lambs_r1"]] call ALiVE_fnc_lambs] call _fnc_check;
["isReserve: any other profile", !(["isReserve", ["test_lambs_r2"]] call ALiVE_fnc_lambs)] call _fnc_check;
private _rp = [] call ALiVE_fnc_hashCreate;
[_rp, "profileID", "test_lambs_r1"] call ALiVE_fnc_hashSet;
["classify: a reserve profile is RESERVE", (["classify", [_rp]] call ALiVE_fnc_lambs) == "RESERVE"] call _fnc_check;
private _gp = [] call ALiVE_fnc_hashCreate;
[_gp, "profileID", "test_lambs_g1"] call ALiVE_fnc_hashSet;
[_gp, "activeCommands", [["ALIVE_fnc_garrison", "spawn", [200, "true", [0, 0, 0]]]]] call ALiVE_fnc_hashSet;
["classify: a garrisoned profile is STATIC", (["classify", [_gp]] call ALiVE_fnc_lambs) == "STATIC"] call _fnc_check;
[_gp, "profileID", "test_lambs_r1"] call ALiVE_fnc_hashSet;
["classify: a garrisoned reserve stays RESERVE (it answers LAMBS reinforce calls)", (["classify", [_gp]] call ALiVE_fnc_lambs) == "RESERVE"] call _fnc_check;
[_gp, "activeCommands", []] call ALiVE_fnc_hashSet;
[_gp, "profileID", "test_lambs_g1"] call ALiVE_fnc_hashSet;
["classify: the garrison moved on is MANEUVER again", (["classify", [_gp]] call ALiVE_fnc_lambs) == "MANEUVER"] call _fnc_check;
[_rp, "isSPE", true] call ALiVE_fnc_hashSet;
["classify: an SPE profile is STATIC", (["classify", [_rp]] call ALiVE_fnc_lambs) == "STATIC"] call _fnc_check;

// --- inactive: every op is quiet -----------------------------------------------
ALiVE_lambs_on = false;
["active: false with Integrate off", !(["active"] call ALiVE_fnc_lambs)] call _fnc_check;
["creep: refused with Integrate off, so the IED squad is guarded", !(["creep", [_grp, [0, 0, 0]]] call ALiVE_fnc_lambs)] call _fnc_check;
["attach", [_grp, []]] call ALiVE_fnc_lambs;
["attach: nothing with Integrate off", (_grp getVariable ["ALiVE_lambs", []]) isEqualTo []] call _fnc_check;

// --- tidy up -------------------------------------------------------------------
deleteVehicle _unit;
deleteGroup _grp;
{ missionNamespace setVariable [_x, _saved select _forEachIndex] } forEach _savedNames;
if (!isNil "_savedOrders") then { ALiVE_lambs_orders = _savedOrders };

diag_log format ["=== LAMBS Integrate test: %1 ===", ["all passed", format ["%1 FAILED: %2", count _fails, _fails]] select (_fails isNotEqualTo [])];
