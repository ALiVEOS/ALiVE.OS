#include "\x\alive\addons\mil_ato\script_component.hpp"

SCRIPT(test_ato_surface);

/* ----------------------------------------------------------------------------
Surface test, scene (a): a land airfield with NO ALiVE module placed.

Smallest mission: put a player on Stratis near the airfield, run this from the
debug console. It spawns itself because placing an airframe and letting it
settle takes time, and the console runs unscheduled.

Covers classify and the terrain half. The deck scenes are separate and the deck
half is not built yet; the assertions here prove the deck operations REFUSE
rather than guess, which is the property that lets the two land separately.
---------------------------------------------------------------------------- */

[] spawn {

    private _fails = [];
    private _fnc_check = {
        // _ok taken as Any deliberately: an assertion whose expression threw
        // arrives as nil, and `if (nil)` would throw again and print nothing,
        // so the failure would disappear instead of being reported.
        params ["_name", ["_ok", nil, [true]]];
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

    diag_log "=== ATO Surface test (scene a: land airfield) ===";

    private _surface = [nil, "create"] call ALIVE_fnc_ATOSurface;
    // Anchored on the player when there is one and on the Agia Marina strip
    // when there is not, so this runs on the headless rig as well as in front
    // of somebody. A dedicated server has no player at all.
    private _anchor = if (isNull player) then {[1839.76, 5750.47, 0]} else {getPosATL player};
    private _class = "B_Plane_CAS_01_F";
    private _spawned = [];
    private _pads = [];

    // --- classify -----------------------------------------------------------
    ["an airfield classifies as terrain",
        ([_surface, "classify", _anchor] call ALIVE_fnc_ATOSurface) isEqualTo "terrain"] call _fnc_check;

    // --- cascade ------------------------------------------------------------
    private _bb = [_class] call ALiVE_fnc_getVehicleBoundingBox;
    private _span = ((((_bb select 0) max (_bb select 1)) / 2) + 4) max 12;

    private _homes = [];
    private _reserved = [];
    for "_i" from 1 to 8 do {
        private _home = [_surface, "cascade", ["terrain", _class, _anchor, _reserved]] call ALIVE_fnc_ATOSurface;
        if (count _home == 3) then {
            _homes pushBack _home;
            // Reserve by the airframe's own span, which is what a real caller
            // knows. A flat 30 m is wider than the aircraft and rules out ring
            // neighbours that are genuinely far enough apart.
            _reserved pushBack [_home select 0, _span];
        };
    };
    // Asked EIGHT times from ONE anchor. That is not how the real caller works:
    // it walks the field's hangar buildings and asks once per building, capped at
    // the number of buildings, so breadth comes from different anchors rather
    // than from squeezing one. The shared apron search takes no list of spots
    // already handed out, so a second ask at the same anchor returns the same
    // apron spot, finds it reserved, and drops to the ring search.
    //
    // So the floor here is what ONE anchor should yield on a small field, and
    // getting more than that is a property of the caller, not of this piece.
    diag_log format ["  info  cascade returned %1 home(s) from a single anchor", count _homes];
    ["one anchor yields at least four homes", count _homes >= 4] call _fnc_check;

    // Every home must still pass the acceptance test when it is asked again.
    // A spot that cannot answer for itself a second time was never a spot.
    // Run BEFORE anything is placed, so nothing of ours is standing on a home.
    private _allClear = true;
    {
        if !([_surface, "spotIsClear", [_x select 0, _span]] call ALIVE_fnc_ATOSurface) then { _allClear = false };
    } forEach _homes;
    ["every home passes the predicate re-run as an oracle", _allClear] call _fnc_check;

    // Pairwise separation: a reserved list that is not respected shows up here.
    private _tooClose = false;
    {
        private _a = _x select 0;
        private _i = _forEachIndex;
        {
            if (_forEachIndex > _i && {(_a distance2D (_x select 0)) < _span}) then { _tooClose = true };
        } forEach _homes;
    } forEach _homes;
    ["homes are pairwise separated", !_tooClose] call _fnc_check;

    private _distinct = true;
    {
        private _a = _x select 0;
        if (({(_a distance2D (_x select 0)) < 1} count _homes) > 1) then { _distinct = false };
    } forEach _homes;
    ["homes are distinct", _distinct] call _fnc_check;

    // Never airside: an aircraft parked on the runway blocks every other one.
    private _anyAirside = false;
    if (!isNil "ALiVE_fnc_isAirside") then {
        { if ([_x select 0, _span, [1,2,3]] call ALiVE_fnc_isAirside) then { _anyAirside = true } } forEach _homes;
        ["no home is on a movement surface", !_anyAirside] call _fnc_check;
    };

    // --- place --------------------------------------------------------------
    {
        private _v = createVehicle [_class, [0,0,500], [], 0, "CAN_COLLIDE"];
        _spawned pushBack _v;
        ["place accepted home " + str _forEachIndex,
            [_surface, "place", [_v, _x]] call ALIVE_fnc_ATOSurface] call _fnc_check;
    } forEach _homes;

    // The settle window is 8 s; wait past it before judging.
    sleep 12;

    private _allAlive = ({alive _x} count _spawned) == count _spawned;
    ["every placed airframe is still alive after settling", _allAlive] call _fnc_check;

    private _allHome = true;
    {
        if !([_surface, "atHome", [_x, _homes select _forEachIndex]] call ALIVE_fnc_ATOSurface) then { _allHome = false };
    } forEach _spawned;
    ["every placed airframe is at its home", _allHome] call _fnc_check;

    // Damage must be back ON once settled, or a parked aircraft is invulnerable
    // for the rest of the mission.
    // isDamageAllowed reports the CURRENT LOCALITY and always answers false for
    // an object that is not local, so it is only meaningful behind that guard.
    // The wiki's own example pairs the two for exactly this reason.
    private _rearmed = true;
    { if (local _x && {!isDamageAllowed _x}) then { _rearmed = false } } forEach _spawned;
    ["damage is re-armed after settling", _rearmed] call _fnc_check;

    // --- validate -----------------------------------------------------------
    private _ownHome = _homes select 0;
    private _ownObj = _spawned select 0;
    (([_surface, "validate", [_ownHome, _class, _ownObj]] call ALIVE_fnc_ATOSurface)) params ["_ok1", "_why1"];
    ["a home holding its own airframe validates", _ok1] call _fnc_check;

    // Park something foreign on a home and it must be refused.
    //
    // Clear the home's own airframe FIRST. Spawning a truck on top of a parked
    // aircraft lets the engine shove it an unpredictable distance, so the truck
    // sometimes landed outside the footprint and the test failed while the code
    // was answering correctly. An empty home makes the setup deterministic.
    private _victim = _homes select 1;
    deleteVehicle (_spawned select 1);
    sleep 1;
    private _truck = createVehicle ["B_Truck_01_transport_F", _victim select 0, [], 0, "CAN_COLLIDE"];
    sleep 2;
    private _truckDist = _truck distance2D (_victim select 0);
    diag_log format ["  info  truck settled %1 m from the home centre (span %2)", round _truckDist, round _span];
    ["the truck actually landed on the home", _truckDist < _span] call _fnc_check;

    (([_surface, "validate", [_victim, _class, objNull]] call ALIVE_fnc_ATOSurface)) params ["_ok2", "_why2"];
    ["an occupied home is refused", !_ok2] call _fnc_check;
    ["and the reason says occupied", _why2 isEqualTo "occupied"] call _fnc_check;
    deleteVehicle _truck;

    // --- locks --------------------------------------------------------------
    ["a free lock is taken",
        [_surface, "lock", ["rwy_1", "BLU_F_0", time + 60]] call ALIVE_fnc_ATOSurface] call _fnc_check;
    ["a held lock is refused to someone else",
        !([_surface, "lock", ["rwy_1", "BLU_F_1", time + 60]] call ALIVE_fnc_ATOSurface)] call _fnc_check;
    ["the holder is reported",
        ([_surface, "holder", "rwy_1"] call ALIVE_fnc_ATOSurface) isEqualTo "BLU_F_0"] call _fnc_check;
    ["the holder may re-take its own lock",
        [_surface, "lock", ["rwy_1", "BLU_F_0", time + 60]] call ALIVE_fnc_ATOSurface] call _fnc_check;

    [_surface, "unlock", "BLU_F_0"] call ALIVE_fnc_ATOSurface;
    ["unlock clears it", ([_surface, "holder", "rwy_1"] call ALIVE_fnc_ATOSurface) isEqualTo ""] call _fnc_check;

    // A lock whose holder is gone, and a lock past its time, both have to go:
    // this is what stops a queue wedging behind an airframe that never left.
    [_surface, "lock", ["rwy_2", "BLU_F_2", time + 600]] call ALIVE_fnc_ATOSurface;
    [_surface, "lock", ["rwy_3", "BLU_F_3", time - 1]] call ALIVE_fnc_ATOSurface;
    private _released = [_surface, "reconcileLocks", ["BLU_F_3"]] call ALIVE_fnc_ATOSurface;
    ["reconcile released the absent holder and the expired one", _released == 2] call _fnc_check;
    ["nothing is left locked",
        ([_surface, "holder", "rwy_2"] call ALIVE_fnc_ATOSurface) isEqualTo ""
        && {([_surface, "holder", "rwy_3"] call ALIVE_fnc_ATOSurface) isEqualTo ""}] call _fnc_check;

    // --- pads ---------------------------------------------------------------
    private _padHome = _homes select ((count _homes) - 1);
    private _pad = [_surface, "stampPad", [_padHome, "BLU_F_9"]] call ALIVE_fnc_ATOSurface;
    _pads pushBack _pad;
    ["a pad is created", !isNull _pad] call _fnc_check;
    ["the pad is stamped", _pad getVariable ["ALiVE_atoStamped", false]] call _fnc_check;
    private _again = [_surface, "stampPad", [_padHome, "BLU_F_9"]] call ALIVE_fnc_ATOSurface;
    ["stamping twice reuses the same pad", _again isEqualTo _pad] call _fnc_check;
    [_surface, "unstampPad", "BLU_F_9"] call ALIVE_fnc_ATOSurface;
    // deleteVehicle does not null the reference within the same frame, so give
    // the engine a tick before asking.
    sleep 0.5;
    ["unstamp removes it", isNull _pad] call _fnc_check;

    // --- keepAlive ----------------------------------------------------------
    private _before = if (isNil "ALiVE_airSpawnRegistry") then {0} else {count ALiVE_airSpawnRegistry};
    [_surface, "keepAlive", [_homes select 0, "BLU_F_4"]] call ALIVE_fnc_ATOSurface;
    ["keepAlive registered the home", count ALiVE_airSpawnRegistry == _before + 1] call _fnc_check;
    ["the entry has the four elements the search expects",
        count (ALiVE_airSpawnRegistry select (count ALiVE_airSpawnRegistry - 1)) == 4] call _fnc_check;

    // --- the deck half must refuse, not guess -------------------------------
    ["deck cascade refuses while unbuilt",
        ([_surface, "cascade", ["deck", _class, _anchor, []]] call ALIVE_fnc_ATOSurface) isEqualTo []] call _fnc_check;
    (([_surface, "validate", [[[0,0,0],0,"deck"], _class, objNull]] call ALIVE_fnc_ATOSurface)) params ["_ok3", "_why3"];
    ["deck validate refuses while unbuilt", !_ok3] call _fnc_check;

    // --- tidy ---------------------------------------------------------------
    { deleteVehicle _x } forEach _spawned;
    { if (!isNull _x) then { deleteVehicle _x } } forEach _pads;
    [_surface, "clearReservations"] call ALIVE_fnc_ATOSurface;

    if (count _fails == 0) then {
        diag_log "=== ATO Surface test: ALL PASS ===";
    } else {
        diag_log format ["=== ATO Surface test: %1 FAILURE(S): %2 ===", count _fails, _fails];
    };
};

"ATO Surface test started, results follow in the log"
