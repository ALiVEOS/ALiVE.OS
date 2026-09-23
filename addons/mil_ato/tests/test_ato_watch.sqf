#include "\x\alive\addons\mil_ato\script_component.hpp"

SCRIPT(test_ato_watch);

/* ----------------------------------------------------------------------------
Watch test.

Smallest mission: nothing placed. The test makes its own airspace marker, its
own intruders and its own air defence, and removes them afterwards.

The Tasker it asks is a REAL one rather than a stub. A stub would have to be
told what activeInZone should answer, and that answer is exactly the thing worth
testing: a scramble is refused while one is already up over the same airspace,
and it is the Tasker's record of its own sorties that decides. With a real one
the refusal is produced rather than arranged.

What this piece must never do is order an airframe anywhere. There is no
assertion that can prove a negative outright, so the nearest thing is checked:
after a full pass over a live aircraft, the aircraft has the same position, the
same orders and the same waypoint count it started with.
---------------------------------------------------------------------------- */

[] spawn {

    private _fails = [];
    private _checked = 0;
    private _fnc_check = {
        params ["_name", ["_ok", nil, [true]]];
        _checked = _checked + 1;
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

    diag_log "=== ATO Watch test ===";

    private _anchor = if (isNull player) then {[1839.76, 5750.47, 0]} else {getPosATL player};

    // --- the airspace --------------------------------------------------------
    private _zone = "ato_watch_test_zone";
    private _marker = createMarker [_zone, _anchor];
    _marker setMarkerShape "ELLIPSE";
    _marker setMarkerSize [1200, 1200];
    _marker setMarkerAlpha 0;

    private _made = [];

    private _w = [nil, "create"] call ALIVE_fnc_ATOWatch;
    private _t = [nil, "create"] call ALIVE_fnc_ATOTask;
    [_t, "configure", [["side", "WEST"], ["faction", "BLU_F"]]] call ALIVE_fnc_ATOTask;
    [_t, "firstPassDone"] call ALIVE_fnc_ATOTask;

    [_w, "configure", [
        ["airspaces", [_zone]],
        ["enemyFactions", ["OPF_F"]],
        ["enemySides", ["EAST"]],
        ["types", ["DCA", "CAP", "SEAD"]],
        ["generateTasks", false],
        ["generateSEADTasks", false],
        ["task", _t],
        ["key", "watchtest"]
    ]] call ALIVE_fnc_ATOWatch;

    // --- two intruders, one of them too low to count -------------------------
    private _high1 = createVehicle ["O_Heli_Attack_02_F", [(_anchor select 0) + 100, (_anchor select 1) + 100, 500], [], 0, "FLY"];
    private _high2 = createVehicle ["O_Plane_CAS_02_F", [(_anchor select 0) - 200, (_anchor select 1) + 200, 600], [], 0, "FLY"];
    private _low   = createVehicle ["O_Heli_Light_02_F", [(_anchor select 0) + 300, (_anchor select 1), 40], [], 0, "FLY"];
    private _friend = createVehicle ["B_Plane_CAS_01_F", [(_anchor select 0), (_anchor select 1) + 400, 700], [], 0, "FLY"];
    _made append [_high1, _high2, _low, _friend];
    sleep 3;
    // The engine settles a created aircraft, so the heights are set again.
    _high1 setPosATL [(_anchor select 0) + 100, (_anchor select 1) + 100, 500];
    _high2 setPosATL [(_anchor select 0) - 200, (_anchor select 1) + 200, 600];
    _low   setPosATL [(_anchor select 0) + 300, (_anchor select 1), 40];
    _friend setPosATL [(_anchor select 0), (_anchor select 1) + 400, 700];
    sleep 1;

    private _bogeys = [_w, "scanBogeys"] call ALIVE_fnc_ATOWatch;
    private _seen = [_bogeys, _zone, []] call ALIVE_fnc_hashGet;
    diag_log format ["  info  bogeys in %1: %2", _zone, _seen apply {typeOf _x}];
    ["both high intruders are seen", (_high1 in _seen) && {_high2 in _seen}] call _fnc_check;
    ["one flying below radar height is not an intrusion", !(_low in _seen)] call _fnc_check;
    ["and an aircraft of our own side is not an intrusion", !(_friend in _seen)] call _fnc_check;

    // --- an air defence ------------------------------------------------------
    private _sam = createVehicle ["O_SAM_System_04_F", [(_anchor select 0) + 500, (_anchor select 1) - 500, 0], [], 0, "CAN_COLLIDE"];
    _made pushBack _sam;
    sleep 2;
    private _threats = [_w, "scanThreats"] call ALIVE_fnc_ATOWatch;
    private _aa = [_threats, _zone, []] call ALIVE_fnc_hashGet;
    diag_log format ["  info  air defences in %1: %2", _zone, _aa apply {typeOf _x}];
    ["an enemy air defence is seen", _sam in _aa] call _fnc_check;

    // --- a threat reported from outside --------------------------------------
    [_w, "registerThreat", [_sam, _zone]] call ALIVE_fnc_ATOWatch;
    [_w, "registerThreat", [_sam, _zone]] call ALIVE_fnc_ATOWatch;
    private _reported = [[_w, "threats", []] call ALIVE_fnc_hashGet, _zone, []] call ALIVE_fnc_hashGet;
    ["the same threat reported twice is one entry", count _reported == 1] call _fnc_check;
    ["and it is published under this instance's own name",
        !isNil "ALiVE_mil_ato_threats"
        && {!(([ALiVE_mil_ato_threats, "watchtest", []] call ALIVE_fnc_hashGet) isEqualTo [])}] call _fnc_check;

    // --- nothing runs until it is started ------------------------------------
    ["a watch that was never started raises nothing",
        ([_w, "tick", [1000]] call ALIVE_fnc_ATOWatch) isEqualTo []] call _fnc_check;
    [_w, "start"] call ALIVE_fnc_ATOWatch;
    [_w, "pause", true] call ALIVE_fnc_ATOWatch;
    ["a paused watch raises nothing",
        ([_w, "tick", [1000]] call ALIVE_fnc_ATOWatch) isEqualTo []] call _fnc_check;
    [_w, "pause", false] call ALIVE_fnc_ATOWatch;

    // --- the pass, and what it asks for --------------------------------------
    private _before = [getPosATL _high1, count (waypoints (group (driver _high1)))];
    private _first = [_w, "tick", [1000]] call ALIVE_fnc_ATOWatch;
    diag_log format ["  info  first pass raised: %1", _first];
    private _kinds = _first apply {_x select 0};
    ["intruders bring an interception", "DCA" in _kinds] call _fnc_check;
    ["and an empty airspace brings a standing patrol", "CAP" in _kinds] call _fnc_check;

    // The one thing it must never do.
    ["the watch did not move the aircraft it was looking at",
        ((getPosATL _high1) distance (_before select 0)) < 50
        && {count (waypoints (group (driver _high1))) == (_before select 1)}] call _fnc_check;

    // --- it does not scramble on top of itself -------------------------------
    // The first pass put a DCA up over this airspace, and the Tasker remembers
    // that, so the second pass must leave it alone.
    private _second = [_w, "tick", [1010]] call ALIVE_fnc_ATOWatch;
    diag_log format ["  info  second pass raised: %1", _second];
    ["a second pass does not scramble a second interception",
        !("DCA" in (_second apply {_x select 0}))] call _fnc_check;
    ["and does not raise a second patrol either",
        !("CAP" in (_second apply {_x select 0}))] call _fnc_check;

    // --- air defences are only attacked with something that can do it --------
    // No records at all, so nothing is ready and nothing is ordered. With task
    // generation off there is nobody to hand it to either, so the answer is to
    // do nothing rather than send an unsuitable aircraft at a launcher.
    ["no suitable aircraft means no suppression sortie",
        !("SEAD" in (_first apply {_x select 0}))] call _fnc_check;

    private _w2 = [nil, "create"] call ALIVE_fnc_ATOWatch;
    private _t2 = [nil, "create"] call ALIVE_fnc_ATOTask;
    [_t2, "configure", [["side", "WEST"], ["faction", "BLU_F"]]] call ALIVE_fnc_ATOTask;
    [_t2, "firstPassDone"] call ALIVE_fnc_ATOTask;
    [_w2, "configure", [
        ["airspaces", [_zone]], ["enemyFactions", ["OPF_F"]], ["enemySides", ["EAST"]],
        ["types", ["SEAD"]], ["task", _t2], ["key", "watchtest2"]
    ]] call ALIVE_fnc_ATOWatch;
    [_w2, "start"] call ALIVE_fnc_ATOWatch;

    private _records = [] call ALIVE_fnc_hashCreate;
    private _rows = [] call ALIVE_fnc_hashCreate;
    [_records, "s1", [[
        ["class", "B_Plane_CAS_01_F"], ["faction", "BLU_F"],
        ["home", [_anchor, 0, "terrain"]], ["roles", ["Attack"]],
        ["capabilities", ["armed", "agGuided", "antiRadiation", "sensors"]]
    ]] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet;
    [_rows, "s1", [[["state", "PARKED"]]] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet;

    private _seadPass = [_w2, "tick", [2000, _records, _rows]] call ALIVE_fnc_ATOWatch;
    diag_log format ["  info  suppression pass raised: %1", _seadPass];
    ["a suppression sortie is raised once there is an aircraft that can fly it",
        "SEAD" in (_seadPass apply {_x select 0})] call _fnc_check;

    // #1029: the records above used to carry a "SEAD" role and capability that nothing
    // real produces, which is how this passed while the air commander never raised one.
    // An attack helicopter carries no anti-radar missiles, so ready or not it is not a
    // reason to send anything at a launcher.
    private _w5 = [nil, "create"] call ALIVE_fnc_ATOWatch;
    private _t5 = [nil, "create"] call ALIVE_fnc_ATOTask;
    [_t5, "configure", [["side", "WEST"], ["faction", "BLU_F"]]] call ALIVE_fnc_ATOTask;
    [_t5, "firstPassDone"] call ALIVE_fnc_ATOTask;
    [_w5, "configure", [
        ["airspaces", [_zone]], ["enemyFactions", ["OPF_F"]], ["enemySides", ["EAST"]],
        ["types", ["SEAD"]], ["task", _t5], ["key", "watchtest5"]
    ]] call ALIVE_fnc_ATOWatch;
    [_w5, "start"] call ALIVE_fnc_ATOWatch;
    private _noHarm = [] call ALIVE_fnc_hashCreate;
    [_noHarm, "h1", [[
        ["class", "B_Heli_Attack_01_F"], ["faction", "BLU_F"],
        ["home", [_anchor, 0, "terrain"]], ["roles", ["Attack", "CAS"]],
        ["capabilities", ["armed", "gun", "agGuided", "sensors"]]
    ]] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet;
    private _noHarmRows = [] call ALIVE_fnc_hashCreate;
    [_noHarmRows, "h1", [[["state", "PARKED"]]] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet;
    private _noHarmPass = [_w5, "tick", [2000, _noHarm, _noHarmRows]] call ALIVE_fnc_ATOWatch;
    diag_log format ["  info  pass with only an attack helicopter ready raised: %1", _noHarmPass];
    ["an attack aircraft without anti-radar missiles does not raise one",
        !("SEAD" in (_noHarmPass apply {_x select 0}))] call _fnc_check;

    private _parked = [[["state", "PARKED"]]] call ALIVE_fnc_hashCreate;
    [_rows, "s1", [[["state", "ENROUTE"]]] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet;
    private _w3 = [nil, "create"] call ALIVE_fnc_ATOWatch;
    [_w3, "configure", [
        ["airspaces", [_zone]], ["enemySides", ["EAST"]],
        ["types", ["SEAD"]], ["task", [nil, "create"] call ALIVE_fnc_ATOTask], ["key", "watchtest3"]
    ]] call ALIVE_fnc_ATOWatch;
    [_w3, "start"] call ALIVE_fnc_ATOWatch;
    ["an aircraft that is already flying is not a reason to raise another",
        !("SEAD" in (([_w3, "tick", [2000, _records, _rows]] call ALIVE_fnc_ATOWatch) apply {_x select 0}))] call _fnc_check;

    // --- a type this commander does not hold is never asked for --------------
    private _w4 = [nil, "create"] call ALIVE_fnc_ATOWatch;
    [_w4, "configure", [
        ["airspaces", [_zone]], ["enemyFactions", ["OPF_F"]], ["enemySides", ["EAST"]],
        ["types", []], ["task", [nil, "create"] call ALIVE_fnc_ATOTask], ["key", "watchtest4"]
    ]] call ALIVE_fnc_ATOWatch;
    [_w4, "start"] call ALIVE_fnc_ATOWatch;
    ["a commander allowed no sortie types raises none",
        ([_w4, "tick", [3000]] call ALIVE_fnc_ATOWatch) isEqualTo []] call _fnc_check;

    // --- a threat that cannot be placed does not hide the ones that can ------
    // One unresolvable entry used to abandon the whole remaining list.
    private _w5 = [nil, "create"] call ALIVE_fnc_ATOWatch;
    [_w5, "configure", [["airspaces", [_zone]], ["enemySides", ["EAST"]], ["key", "watchtest5"]]] call ALIVE_fnc_ATOWatch;
    [_w5, "registerThreat", ["anIdNothingKnows", _zone]] call ALIVE_fnc_ATOWatch;
    [_w5, "registerThreat", [_sam, _zone]] call ALIVE_fnc_ATOWatch;
    private _mixed = [[_w5, "scanThreats"] call ALIVE_fnc_ATOWatch, _zone, []] call ALIVE_fnc_hashGet;
    diag_log format ["  info  a mixed threat list resolved to %1 entry(s)", count _mixed];
    ["one threat that cannot be placed does not lose the ones that can",
        _sam in _mixed] call _fnc_check;

    // --- cleanup -------------------------------------------------------------
    {
        if (!isNull _x) then { { deleteVehicle _x } forEach (crew _x); deleteVehicle _x };
    } forEach _made;
    deleteMarker _zone;

    diag_log format ["  info  %1 assertions", _checked];
    if (count _fails == 0) then {
        diag_log "=== ATO Watch test: ALL PASS ===";
    } else {
        diag_log format ["=== ATO Watch test: %1 FAILURE(S): %2 ===", count _fails, _fails];
    };
};

"ATO Watch test started, results follow in the log"
