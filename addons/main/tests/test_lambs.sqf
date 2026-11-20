#include "\x\alive\addons\main\script_component.hpp"

SCRIPT(test_lambs);

/* ----------------------------------------------------------------------------
Integrate setting test (#1122). Covers ALiVE_fnc_lambs: the taskFor decision table, the
Guard / Integrate split in ALiVE_fnc_modConflicts "guard", the order store and order stamps
(spawned and virtual), the despawn waypoint scrub, reserve lookup, the headless client check,
the reinforce note and what ALiVE_fnc_lambsRemote lets in.

Needs no LAMBS and no player: run it on a local host or a dedicated server with
    [] execVM "\x\alive\addons\main\tests\test_lambs.sqf";
or through tests\test.sqf, and read the RPT for FAIL lines. Without LAMBS loaded the one LAMBS
function the checks look for is stubbed, so the Integrate checks run all the same.

Every change to a live global is made and put back inside one isNil, so nothing else runs while
the globals hold test values.
---------------------------------------------------------------------------- */

if (!isServer) exitWith { diag_log "test_lambs: run it on the server" };

ASSERT_DEFINED("ALiVE_fnc_lambs","ALiVE_fnc_lambs is not defined!");
ASSERT_DEFINED("ALiVE_fnc_lambsRemote","ALiVE_fnc_lambsRemote is not defined!");
ASSERT_DEFINED("ALiVE_fnc_modConflicts","ALiVE_fnc_modConflicts is not defined!");

diag_log "=== LAMBS Integrate test ===";

// [name, passed], filled inside the isNil and asserted after it
private _results = [];
private _fnc_check = {
    params ["_name", "_ok"];
    _results pushBack [_name, !isNil "_ok" && {_ok isEqualTo true}];
};

// the function makes its maps the first time it runs
["active"] call ALiVE_fnc_lambs;

isNil {
    // --- keep what we change -----------------------------------------------
    private _savedNames = ["ALiVE_MODCONFLICTS_MODE", "ALiVE_MODCONFLICTS_GUARD", "ALiVE_MODCONFLICTS_INTEGRATE", "ALiVE_lambs_on", "ALiVE_lambs_debug",
        "OPCOM_instances", "ALiVE_lambs_sameOrders", "ALiVE_lambs_with", "ALiVE_lambs_urgent", "ALiVE_lambs_keys", "lambs_wp_fnc_taskReset"];
    private _saved = _savedNames apply { missionNamespace getVariable _x };
    private _mapNames = ["ALiVE_lambs_stats", "ALiVE_lambs_orders", "ALiVE_lambs_active", "ALiVE_lambs_reinforcing", "ALiVE_lambs_times"];
    private _savedMaps = _mapNames apply { +(missionNamespace getVariable _x) };

    // without LAMBS the Integrate checks still run: "active" only looks for this function
    if (isNil "lambs_wp_fnc_taskReset") then { lambs_wp_fnc_taskReset = {} };
    ALiVE_lambs_debug = false;
    ALiVE_lambs_sameOrders = createHashMap;

    // the reports below are made as ALiVE_fnc_lambsRemote makes them, wherever the test is run from
    private _lambsDoor = true;

    // --- taskFor: the decision table (pure) ----------------------------------
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

    // --- Guard and Integrate in ALiVE_fnc_modConflicts --------------------------
    private _grp = createGroup [east, true];
    private _unit = _grp createUnit ["O_Soldier_F", [0, 0, 0], [], 0, "NONE"];
    ALiVE_MODCONFLICTS_GUARD = [["lambs_danger_disableGroupAI"], [], ["lambs_danger_disableAI"]];
    ALiVE_MODCONFLICTS_INTEGRATE = [["lambs_danger_disableGroupAI"], [], ["lambs_danger_disableAI"]];

    ALiVE_MODCONFLICTS_MODE = "GUARD";
    ALiVE_lambs_on = false;
    ["guard", [_grp, "PROFILE"]] call ALiVE_fnc_modConflicts;
    ["guard: Guard sets the LAMBS group switch on a profiled group (U23)", _grp getVariable ["lambs_danger_disableGroupAI", false]] call _fnc_check;
    ["guard: Guard does not mark the group for LAMBS", !(_grp getVariable ["ALiVE_lambs_run", false])] call _fnc_check;

    _grp setVariable ["lambs_danger_disableGroupAI", nil, true];
    ALiVE_MODCONFLICTS_MODE = "WARN";
    ["guard", [_grp, "PROFILE"]] call ALiVE_fnc_modConflicts;
    ["guard: Warn sets nothing", isNil { _grp getVariable "lambs_danger_disableGroupAI" }] call _fnc_check;

    // Integrate with LAMBS not active here: plain Guard
    ALiVE_MODCONFLICTS_MODE = "INTEGRATE";
    ["guard", [_grp, "PROFILE"]] call ALiVE_fnc_modConflicts;
    ["guard: Integrate without LAMBS active guards as Guard", _grp getVariable ["lambs_danger_disableGroupAI", false]] call _fnc_check;

    // Integrate with LAMBS active: a profiled group is left to LAMBS, any other group is guarded
    ALiVE_lambs_on = true;
    _grp setVariable ["lambs_danger_disableGroupAI", nil, true];
    ["guard", [_grp, "PROFILE"]] call ALiVE_fnc_modConflicts;
    ["guard: Integrate leaves a profiled group's LAMBS switch alone", isNil { _grp getVariable "lambs_danger_disableGroupAI" }] call _fnc_check;
    ["guard: Integrate marks the profiled group for LAMBS", _grp getVariable ["ALiVE_lambs_run", false]] call _fnc_check;
    private _other = createGroup [east, true];
    ["guard", [_other]] call ALiVE_fnc_modConflicts;
    ["guard: Integrate still guards a group with no role (CQB, roadblocks, Combat Support)", _other getVariable ["lambs_danger_disableGroupAI", false]] call _fnc_check;
    deleteGroup _other;

    // --- a headless client with no LAMBS -----------------------------------------
    ALiVE_lambs_with = [78];
    ["mayMove: a group LAMBS runs is kept off a machine that has not said it runs LAMBS", (["mayMove", [_grp, 77]] call ALiVE_fnc_lambs) isEqualTo false] call _fnc_check;
    ["mayMove: it may go to a machine that runs LAMBS", (["mayMove", [_grp, 78]] call ALiVE_fnc_lambs) isEqualTo true] call _fnc_check;
    ALiVE_lambs_with = [];
    ["mayMove: with no machine named and none known to run LAMBS, the group stays", (["mayMove", [_grp]] call ALiVE_fnc_lambs) isEqualTo false] call _fnc_check;
    private _garrison = createGroup [east, true];
    _garrison setVariable ["ALiVE_lambs_garrison", true];
    ["mayMove: a garrison, LAMBS' again once it moves on, is kept off such a machine too", (["mayMove", [_garrison, 77]] call ALiVE_fnc_lambs) isEqualTo false] call _fnc_check;
    deleteGroup _garrison;
    private _plain = createGroup [east, true];
    ["mayMove: any other group may go anywhere", (["mayMove", [_plain, 77]] call ALiVE_fnc_lambs) isEqualTo true] call _fnc_check;
    deleteGroup _plain;
    ALiVE_lambs_with = [];

    // --- orders and stamps, on a spawned group -----------------------------------
    private _gO = createGroup [east, true];
    _gO setVariable ["ALiVE_lambs_stamp", 0, true];
    _gO setVariable ["ALiVE_lambs_wpKeep", [[[1, 1, 0], "MOVE"]], true];
    ALiVE_lambs_active set ["test_lambs_p1", _gO];
    ["order", ["test_lambs_p1", "attack", [100, 100, 0], "test_lambs_target", -1]] call ALiVE_fnc_lambs;
    private _o = _gO getVariable ["ALiVE_lambs_order", []];
    ["order: stored on the server", ("test_lambs_p1" in ALiVE_lambs_orders)] call _fnc_check;
    ["order: copied to the group with the kind", (_o param [0, ""]) == "attack"] call _fnc_check;
    ["order: a new order bumps the stamp", (_gO getVariable ["ALiVE_lambs_stamp", 0]) == 1 && {(_o param [3, -1]) == 1}] call _fnc_check;
    ["order: the note of the old waypoints goes", isNil { _gO getVariable "ALiVE_lambs_wpKeep" }] call _fnc_check;
    ["order", ["test_lambs_p1", "ambush", [100, 100, 0], "obj", time + 60]] call ALiVE_fnc_lambs;
    ["order: an ambush keeps the group quiet", _gO getVariable ["ALiVE_lambs_mute", false]] call _fnc_check;
    private _fakeProfile = [] call ALiVE_fnc_hashCreate;
    [_fakeProfile, "profileID", "test_lambs_p1"] call ALiVE_fnc_hashSet;
    _gO setVariable ["ALiVE_lambs_wpKeep", [[[1, 1, 0], "MOVE"]], true];
    ["reordered", [_fakeProfile]] call ALiVE_fnc_lambs;
    ["reordered: the stored order goes", !("test_lambs_p1" in ALiVE_lambs_orders)] call _fnc_check;
    ["reordered: the group's order goes and the stamp moves", (_gO getVariable ["ALiVE_lambs_order", [0]]) isEqualTo [] && {(_gO getVariable ["ALiVE_lambs_stamp", 0]) == 3}] call _fnc_check;
    ["reordered: the note of the old waypoints goes", isNil { _gO getVariable "ALiVE_lambs_wpKeep" }] call _fnc_check;
    ALiVE_lambs_active deleteAt "test_lambs_p1";
    deleteGroup _gO;

    // --- orders on a virtual profile (no group) --------------------------------------
    private _virtual = [] call ALiVE_fnc_hashCreate;
    [_virtual, "profileID", "test_lambs_v1"] call ALiVE_fnc_hashSet;
    ["order", ["test_lambs_v1", "defend", [200, 200, 0], "obj", -1]] call ALiVE_fnc_lambs;
    ["order: stored for a virtual profile", "test_lambs_v1" in ALiVE_lambs_orders] call _fnc_check;
    // a despawn or a route rebuild clears the waypoints to lay the same orders again
    ["sameOrders", [_virtual]] call ALiVE_fnc_lambs;
    // another profile flagged in between (a route rebuild) does not take the first one's flag
    private _virtual2 = [] call ALiVE_fnc_hashCreate;
    [_virtual2, "profileID", "test_lambs_v2"] call ALiVE_fnc_hashSet;
    ["sameOrders", [_virtual2]] call ALiVE_fnc_lambs;
    ["reordered", [_virtual]] call ALiVE_fnc_lambs;
    ["reordered", [_virtual2]] call ALiVE_fnc_lambs;
    ["sameOrders: each flag is used up by its own profile's clear", count ALiVE_lambs_sameOrders == 0] call _fnc_check;
    ["sameOrders: the clear that follows keeps the order", "test_lambs_v1" in ALiVE_lambs_orders] call _fnc_check;
    ["reordered", [_virtual]] call ALiVE_fnc_lambs;
    ["reordered: a virtual profile re-tasked loses its old order", !("test_lambs_v1" in ALiVE_lambs_orders)] call _fnc_check;

    // --- a garrison LAMBS takes back loses Soldier Behaviour --------------------------
    private _gB = createGroup [east, true];
    _gB setVariable ["ALiVE_lambs_run", false];
    _gB setVariable ["ALiVE_AIB_eligible", true];
    ["roleVars", [_gB, "MANEUVER"]] call ALiVE_fnc_lambs;
    ["roleVars: a garrison moved on is LAMBS' and no longer open to Soldier Behaviour", (_gB getVariable ["ALiVE_lambs_run", false]) && {!(_gB getVariable ["ALiVE_AIB_eligible", true])}] call _fnc_check;
    deleteGroup _gB;

    // --- the network door ------------------------------------------------------------
    ["order", ["test_lambs_n1", "attack", [1, 1, 0], "x", -1]] call ALiVE_fnc_lambsRemote;
    ["lambsRemote: an operation not on its list is not run", !("test_lambs_n1" in ALiVE_lambs_orders)] call _fnc_check;
    private _refusedBefore = ALiVE_lambs_stats getOrDefault ["report_refused", 0];
    ["report", ["contact", "test_lambs_none", "EAST", [0, 0, 0], [[], 1], 99]] call ALiVE_fnc_lambs;
    ["report: refused from a machine that does not own the group", (ALiVE_lambs_stats getOrDefault ["report_refused", 0]) == _refusedBefore + 1] call _fnc_check;
    // a report from the machine the group has just left is still heard for a short while
    private _gH = createGroup [east, true];
    ALiVE_lambs_active set ["test_lambs_h1", _gH];
    _gH setVariable ["ALiVE_lambs_owners", [groupOwner _gH, 98, time]];
    _refusedBefore = ALiVE_lambs_stats getOrDefault ["report_refused", 0];
    ["report", ["panic", "test_lambs_h1", "EAST", [], [], 98]] call ALiVE_fnc_lambs;
    ["report: heard from the machine the group has just left", (ALiVE_lambs_stats getOrDefault ["report_refused", 0]) == _refusedBefore] call _fnc_check;
    _gH setVariable ["ALiVE_lambs_owners", [groupOwner _gH, 98, time - 600]];
    ["report", ["panic", "test_lambs_h1", "EAST", [], [], 98]] call ALiVE_fnc_lambs;
    ["report: refused from it once the handover is old", (ALiVE_lambs_stats getOrDefault ["report_refused", 0]) == _refusedBefore + 1] call _fnc_check;
    ALiVE_lambs_active deleteAt "test_lambs_h1";
    deleteGroup _gH;

    // --- a second reinforce call keeps the first note --------------------------------
    ALiVE_lambs_reinforcing set ["test_lambs_r9", [0, [1, 1, 0], [5, 5, 0], true]];
    ["report", ["reinforce", "test_lambs_r9", "EAST", [9, 9, 0], []]] call ALiVE_fnc_lambs;
    private _note = ALiVE_lambs_reinforcing getOrDefault ["test_lambs_r9", []];
    ["reinforce: a second call keeps the garrison note and takes the new place", (_note param [3, false]) isEqualTo true && {(_note param [1, []]) isEqualTo [9, 9, 0]}] call _fnc_check;

    ALiVE_lambs_on = false;
    ["order", ["test_lambs_p2", "attack", [1, 1, 0], "x", -1]] call ALiVE_fnc_lambs;
    ["order: nothing is stored with Integrate off", !("test_lambs_p2" in ALiVE_lambs_orders)] call _fnc_check;

    // --- despawn scrub -------------------------------------------------------------
    private _wpOrder = [[500, 500, 0], 15] call ALIVE_fnc_createProfileWaypoint;
    private _wpHunt = [[700, 700, 0], 15] call ALIVE_fnc_createProfileWaypoint;
    private _wpHold = [[500, 500, 0], 15, "HOLD"] call ALIVE_fnc_createProfileWaypoint;
    [_wpHold, "name", "ALiVE_lambs_defend"] call ALiVE_fnc_hashSet;
    private _p = [] call ALiVE_fnc_hashCreate;
    [_p, "profileID", "test_lambs_p3"] call ALiVE_fnc_hashSet;
    [_p, "waypoints", [_wpOrder, _wpHunt, _wpHold]] call ALiVE_fnc_hashSet;
    [_p, "lambsKeep", [[[500, 500, 0], "MOVE"]]] call ALiVE_fnc_hashSet;
    ["scrub", [_p]] call ALiVE_fnc_lambs;
    private _left = [_p, "waypoints", []] call ALiVE_fnc_hashGet;
    ["scrub: only the commander's waypoint is kept", count _left == 1 && {(_left select 0) isEqualTo _wpOrder}] call _fnc_check;
    ["scrub: the note is cleared", ([_p, "lambsKeep", [0]] call ALiVE_fnc_hashGet) isEqualTo []] call _fnc_check;
    // with no note (new orders came just before the despawn) the commander's waypoints all stay
    [_p, "waypoints", [_wpOrder, _wpHunt, _wpHold]] call ALiVE_fnc_hashSet;
    ["scrub", [_p]] call ALiVE_fnc_lambs;
    ["scrub: without a note only the marked hold goes", count ([_p, "waypoints", []] call ALiVE_fnc_hashGet) == 2] call _fnc_check;

    // --- a vehicle LAMBS took, at despawn ------------------------------------------------
    private _rider = [] call ALiVE_fnc_hashCreate;
    [_rider, "profileID", "test_lambs_u1"] call ALiVE_fnc_hashSet;
    private _links = [] call ALiVE_fnc_hashCreate;
    [_links, "test_lambs_own", [[0], [], [], [], []]] call ALiVE_fnc_hashSet;
    [_links, "test_lambs_taken", [[1], [], [], [], []]] call ALiVE_fnc_hashSet;
    [_rider, "vehicleAssignments", _links] call ALiVE_fnc_hashSet;
    [_rider, "vehiclesInCommandOf", ["test_lambs_own", "test_lambs_taken"]] call ALiVE_fnc_hashSet;
    [_rider, "vehiclesInCargoOf", []] call ALiVE_fnc_hashSet;
    ["unride", [_rider]] call ALiVE_fnc_lambs;
    ["unride: with no note of its own vehicles, every link stays", count ([_rider, "vehiclesInCommandOf", []] call ALiVE_fnc_hashGet) == 2] call _fnc_check;
    [_rider, "lambsOwn", ["test_lambs_own"]] call ALiVE_fnc_hashSet;
    ["unride", [_rider]] call ALiVE_fnc_lambs;
    ["unride: the taken vehicle comes off the lists", ([_rider, "vehiclesInCommandOf", []] call ALiVE_fnc_hashGet) isEqualTo ["test_lambs_own"]] call _fnc_check;
    ["unride: and off the assignments, its own kept", ((_links select 1) isEqualTo ["test_lambs_own"])] call _fnc_check;

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
    ["fixed: an SPE profile is ALiVE's for good", (["fixed", [_rp]] call ALiVE_fnc_lambs) isEqualTo true] call _fnc_check;
    ["fixed: a plain profile is not", (["fixed", [_gp]] call ALiVE_fnc_lambs) isEqualTo false] call _fnc_check;
    // an SPE garrison is STATIC for good: it is not flagged as a garrison, so it may go to any machine
    private _spe = [] call ALiVE_fnc_hashCreate;
    [_spe, "profileID", "test_lambs_s1"] call ALiVE_fnc_hashSet;
    [_spe, "isSPE", true] call ALiVE_fnc_hashSet;
    [_spe, "activeCommands", [["ALIVE_fnc_garrison", "spawn", [10, "false", 50, "SPE"]]]] call ALiVE_fnc_hashSet;
    private _gS = createGroup [east, true];
    ALiVE_lambs_on = true;
    ["attach", [_gS, _spe]] call ALiVE_fnc_lambs;
    ["attach: an SPE garrison is STATIC and not flagged as a garrison", ((_gS getVariable ["ALiVE_lambs", [""]]) select 0) == "STATIC" && {!(_gS getVariable ["ALiVE_lambs_garrison", false])}] call _fnc_check;
    ["mayMove: so it may go to any machine", (["mayMove", [_gS, 77]] call ALiVE_fnc_lambs) isEqualTo true] call _fnc_check;
    ALiVE_lambs_groups deleteAt (_gS getVariable ["ALiVE_lambs_key", ""]);
    ALiVE_lambs_active deleteAt "test_lambs_s1";
    deleteGroup _gS;

    // --- inactive: every op is quiet, and answers false rather than nothing ----------
    ALiVE_lambs_on = false;
    ["active: false, not nil, with Integrate off", (["active"] call ALiVE_fnc_lambs) isEqualTo false] call _fnc_check;
    ["creep: false, not nil, with Integrate off, so the IED squad is guarded", (["creep", [_grp, [0, 0, 0]]] call ALiVE_fnc_lambs) isEqualTo false] call _fnc_check;
    _grp setVariable ["ALiVE_lambs", nil, true];
    ["attach", [_grp, []]] call ALiVE_fnc_lambs;
    ["attach: nothing with Integrate off", (_grp getVariable ["ALiVE_lambs", []]) isEqualTo []] call _fnc_check;

    // --- tidy up -------------------------------------------------------------------
    deleteVehicle _unit;
    deleteGroup _grp;
    { missionNamespace setVariable [_x, _saved select _forEachIndex] } forEach _savedNames;
    { missionNamespace setVariable [_x, _savedMaps select _forEachIndex] } forEach _mapNames;
};

private _fails = [];
{
    _x params ["_name", "_ok"];
    ASSERT_TRUE(_ok,_name);
    if (_ok) then {
        diag_log format ["  pass  %1", _name];
    } else {
        _fails pushBack _name;
        diag_log format ["  FAIL  %1", _name];
    };
} forEach _results;

diag_log format ["=== LAMBS Integrate test: %1 ===", ["all passed", format ["%1 FAILED: %2", count _fails, _fails]] select (_fails isNotEqualTo [])];

nil;
