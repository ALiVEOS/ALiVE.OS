#include "\x\alive\addons\mil_ato\script_component.hpp"

SCRIPT(test_ato_placement);

/* ----------------------------------------------------------------------------
Placement test.

Smallest mission: the profile system running and no air commander at all. This
is the only test in the set that needs another ALiVE module, because the whole
piece is about turning profiles into aircraft this module owns outright, and
there is nothing to turn without a profile system to make them.

What it has to prove is that an adoption is a TRADE and not a copy. Before, one
profile; after, no profile and one aircraft, local to this machine, marked so
nothing else will touch it, standing on a spot the surface agreed to. If any
half of that goes missing the campaign either loses an aircraft or grows one,
and both have happened: the measured defect this piece was rewritten for is an
aircraft declared lost and replaced, over and over, because the adoption never
completed but nothing noticed.

So the assertions are about the world, not about return values. A refusal string
can be made to say anything; a profile that is still registered cannot.
---------------------------------------------------------------------------- */

[] spawn {

    private _fails = [];
    private _skipped = [];
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
    private _fnc_skip = {
        _skipped pushBack _this;
        diag_log format ["  skip  %1", _this];
    };

    diag_log "=== ATO Placement test ===";

    // The profile system is the one dependency. Without it nothing here means
    // anything, so it is waited for rather than assumed.
    private _waited = 0;
    waitUntil {
        sleep 1;
        _waited = _waited + 1;
        (!isNil "ALiVE_profileHandler" && {[ALiVE_ProfileSystem, "startupComplete", false] call ALIVE_fnc_hashGet})
            || _waited > 60
    };
    ["the profile system is running", !isNil "ALiVE_profileHandler"] call _fnc_check;
    if (isNil "ALiVE_profileHandler") exitWith {
        diag_log "=== ATO Placement test: ABANDONED, no profile system ===";
    };

    private _anchor = if (isNull player) then {[1839.76, 5750.47, 0]} else {getPosATL player};
    private _made = [];

    // --- the pieces ----------------------------------------------------------
    private _ledger  = [nil, "create"] call ALIVE_fnc_ATOLedger;
    private _surface = [nil, "create"] call ALIVE_fnc_ATOSurface;
    private _effect  = [nil, "create"] call ALIVE_fnc_ATOEffect;
    private _place   = [nil, "create"] call ALIVE_fnc_ATOPlace;

    [_place, "configure", [
        ["ledger", _ledger], ["surface", _surface], ["effect", _effect],
        ["side", "WEST"], ["faction", "BLU_F"], ["factions", ["BLU_F"]],
        ["airspaces", []],
        ["base", [[["center", _anchor], ["isCarrier", false], ["airspace", ""]]] call ALIVE_fnc_hashCreate]
    ]] call ALIVE_fnc_ATOPlace;

    // --- the fixtures --------------------------------------------------------
    // Two uncrewed aircraft, one crewed pair, and a decoy that belongs to
    // somebody else.
    private _fnc_idOf = { [_this, "profileID", ""] call ALIVE_fnc_hashGet };

    private _p1 = ["B_Heli_Attack_01_F", "WEST", "BLU_F", _anchor getPos [80, 0], 0, false] call ALIVE_fnc_createProfileVehicle;
    private _p2 = ["B_Plane_CAS_01_F",   "WEST", "BLU_F", _anchor getPos [140, 30], 0, false] call ALIVE_fnc_createProfileVehicle;
    // Both of these are classes the admission rule ACCEPTS, deliberately.
    // A transport helicopter resolves to no combat role and an armed
    // Hummingbird reads as carrying no armament, so using either here refuses
    // the fixture for a reason that has nothing to do with what is under test,
    // and the combat-support check below would pass without ever exercising the
    // backstop.
    private _pair = ["B_Heli_Attack_01_F", "WEST", "BLU_F", "CAPTAIN", _anchor getPos [200, 60], 0, false] call ALIVE_fnc_createProfilesCrewedVehicle;
    private _decoy = ["B_Heli_Attack_01_F", "WEST", "BLU_F", _anchor getPos [260, 90], 0, false] call ALIVE_fnc_createProfileVehicle;

    private _id1 = _p1 call _fnc_idOf;
    private _id2 = _p2 call _fnc_idOf;
    private _idDecoy = _decoy call _fnc_idOf;
    private _idPairVeh = "";
    private _idPairEnt = "";
    {
        if (_x isEqualType []) then {
            switch ([_x, "type", ""] call ALIVE_fnc_hashGet) do {
                case "vehicle": { _idPairVeh = _x call _fnc_idOf };
                case "entity":  { _idPairEnt = _x call _fnc_idOf };
            };
        };
    } forEach _pair;

    diag_log format ["  info  fixtures: %1, %2, pair [%3 + %4], decoy %5",
        _id1, _id2, _idPairVeh, _idPairEnt, _idDecoy];
    ["four aircraft profiles and one crew profile exist",
        !(_id1 isEqualTo "") && {!(_id2 isEqualTo "")} && {!(_idPairVeh isEqualTo "")}
        && {!(_idPairEnt isEqualTo "")} && {!(_idDecoy isEqualTo "")}] call _fnc_check;

    // The decoy is marked as somebody else's, and the mark goes on the live
    // OBJECT rather than on the profile, because that is the only place it ever
    // appears: every one of combat support's own sites does setVariable on a
    // spawned vehicle. So the decoy has to be spawned for the mark to exist at
    // all, and a virtual one marked on its profile hash tests nothing, which is
    // how an earlier version of this test passed without exercising the
    // backstop once.
    [_decoy, "spawn"] call ALIVE_fnc_profileVehicle;
    private _decoyWait = 0;
    waitUntil {
        sleep 1;
        _decoyWait = _decoyWait + 1;
        (!isNull ([_decoy, "vehicle", objNull] call ALIVE_fnc_hashGet)) || _decoyWait > 20
    };
    private _decoyObj = [_decoy, "vehicle", objNull] call ALIVE_fnc_hashGet;
    if (!isNull _decoyObj) then {
        _decoyObj setVariable ["ALIVE_CombatSupport", true, true];
    };
    diag_log format ["  info  the decoy spawned as %1 and is marked: %2",
        _decoyObj, !isNull _decoyObj && {_decoyObj getVariable ["ALIVE_CombatSupport", false]}];
    ["the decoy is a live aircraft carrying somebody else's mark",
        !isNull _decoyObj && {_decoyObj getVariable ["ALIVE_CombatSupport", false]}] call _fnc_check;

    // --- the two sightings ---------------------------------------------------
    // A candidate has to be seen twice, at least twenty seconds apart, before
    // it is adopted. An aircraft that is merely passing through an airspace is
    // not the commander's to take.
    private _first = [_place, "sweep", ["", time, []]] call ALIVE_fnc_ATOPlace;
    diag_log format ["  info  first sighting adopted: %1", _first];
    ["nothing is adopted on a single sighting", count _first == 0] call _fnc_check;
    ["and the profiles are all still registered",
        !isNil { [ALiVE_profileHandler, "getProfile", _id1] call ALIVE_fnc_ProfileHandler }] call _fnc_check;

    diag_log "  info  waiting out the two-sighting gap";
    sleep 22;

    private _tails = [_place, "sweep", ["", time, []]] call ALIVE_fnc_ATOPlace;
    diag_log format ["  info  second sighting adopted: %1", _tails];

    // The decoy is the same class as everything else now, so the only thing
    // that can save it is the backstop, and the only evidence is that its
    // profile is still there.
    ["an aircraft marked as combat support is never adopted, and its profile is untouched",
        !isNil { [ALiVE_profileHandler, "getProfile", _idDecoy] call ALIVE_fnc_ProfileHandler }] call _fnc_check;

    ["the two uncrewed aircraft and the crewed pair are adopted, and nothing else",
        count _tails == 3] call _fnc_check;

    // --- what an adoption has to leave behind --------------------------------
    private _profilesGone = 0;
    {
        if (isNil { [ALiVE_profileHandler, "getProfile", _x] call ALIVE_fnc_ProfileHandler }) then {
            _profilesGone = _profilesGone + 1;
        };
    } forEach [_id1, _id2, _idPairVeh, _idPairEnt];
    diag_log format ["  info  %1 of the 4 adopted profile ids are gone", _profilesGone];
    ["an adopted aircraft leaves no profile behind, crew included", _profilesGone == 4] call _fnc_check;

    private _good = 0;
    private _padded = 0;
    private _helis = 0;
    {
        private _tail = _x;
        private _obj = [_place, "objFor", _tail] call ALIVE_fnc_ATOPlace;
        private _rec = [_ledger, "get", _tail] call ALIVE_fnc_ATOLedger;
        private _home = [_rec, "home", []] call ALIVE_fnc_hashGet;
        if (!isNull _obj && {alive _obj} && {count _home > 2}) then {
            _made pushBack _obj;
            private _ok = local _obj
                && {_obj getVariable ["ALIVE_profileIgnore", false]}
                && {!((_obj getVariable ["ALiVE_mil_ato_tail", ""]) isEqualTo "")}
                && {(_obj getVariable ["profileID", ""]) isEqualTo ""}
                && {(_obj distance2D (_home select 0)) < 30};
            if (_ok) then { _good = _good + 1 };
            if (!(typeOf _obj isKindOf "Plane")) then {
                _helis = _helis + 1;
                private _pads = (nearestObjects [_home select 0, ["HeliH"], 5]) select {
                    _x getVariable ["ALiVE_atoStamped", false]
                };
                if (count _pads > 0) then { _padded = _padded + 1 };
            };
            diag_log format ["  info  %1: %2 local %3 ignored %4 tail '%5' profileID '%6' %7 m from home",
                _tail, typeOf _obj, local _obj,
                _obj getVariable ["ALIVE_profileIgnore", false],
                _obj getVariable ["ALiVE_mil_ato_tail", ""],
                _obj getVariable ["profileID", ""],
                round (_obj distance2D (_home select 0))];
        } else {
            diag_log format ["  info  %1: no hull (obj %2, home %3)", _tail, _obj, count _home];
        };
    } forEach _tails;

    ["every adopted aircraft is here, local, marked as ours and on its stand",
        _good == 3 && {_good == count _tails}] call _fnc_check;
    ["and every adopted helicopter has a pad of ours at its stand",
        _helis == 0 || {_padded == _helis}] call _fnc_check;

    // The stands must differ. Two aircraft on one spot is the fault the
    // reservation machinery exists to prevent.
    private _homes = [];
    private _clash = false;
    {
        private _h = [[_ledger, "get", _x] call ALIVE_fnc_ATOLedger, "home", []] call ALIVE_fnc_hashGet;
        if (count _h > 2) then {
            {
                if ((_h select 0) distance2D _x < 10) then { _clash = true };
            } forEach _homes;
            _homes pushBack (_h select 0);
        };
    } forEach _tails;
    ["no two adopted aircraft were given the same stand", !_clash] call _fnc_check;

    // --- an aircraft already taken is not taken again ------------------------
    private _again = [_place, "sweep", ["", time + 60, []]] call ALIVE_fnc_ATOPlace;
    diag_log format ["  info  a third sighting adopted: %1", _again];
    ["a sweep does not adopt the same aircraft twice", count _again == 0] call _fnc_check;

    // --- moving an aircraft off a stand somebody took ------------------------
    if (count _tails > 0) then {
        private _tail = _tails select 0;
        private _rec = [_ledger, "get", _tail] call ALIVE_fnc_ATOLedger;
        private _was = +([_rec, "home", []] call ALIVE_fnc_hashGet);
        private _obj = [_place, "objFor", _tail] call ALIVE_fnc_ATOPlace;
        if (count _was > 2 && {!isNull _obj}) then {
            // The aircraft is away and a stranger is parked on its spot.
            _obj setPosATL [(_anchor select 0) + 500, (_anchor select 1) + 500, 0];
            private _squatter = createVehicle ["B_Truck_01_covered_F", _was select 0, [], 0, "CAN_COLLIDE"];
            _made pushBack _squatter;
            sleep 2;
            private _new = [_place, "rehome", _tail] call ALIVE_fnc_ATOPlace;
            diag_log format ["  info  rehome answered %1", if (count _new > 0) then {str (_new select 0)} else {"[]"}];
            ["an aircraft whose stand was taken is given a different one",
                count _new > 2 && {((_new select 0) distance2D (_was select 0)) > 10}] call _fnc_check;
            private _now = [[_ledger, "get", _tail] call ALIVE_fnc_ATOLedger, "home", []] call ALIVE_fnc_hashGet;
            ["and the record is updated to the new one",
                count _now > 2 && {((_now select 0) distance2D (_was select 0)) > 10}] call _fnc_check;
        } else {
            "an aircraft whose stand was taken is given a different one  (no adopted aircraft to move)" call _fnc_skip;
            "and the record is updated to the new one  (no adopted aircraft to move)" call _fnc_skip;
        };
    };

    // --- a faction with nothing worth flying ---------------------------------
    // Initial placement must answer with nothing and say so, rather than
    // creating something unarmed or throwing.
    private _place2 = [nil, "create"] call ALIVE_fnc_ATOPlace;
    private _ledger2 = [nil, "create"] call ALIVE_fnc_ATOLedger;
    [_place2, "configure", [
        ["ledger", _ledger2], ["surface", _surface], ["effect", _effect],
        ["side", "CIV"], ["faction", "CIV_F"], ["factions", ["CIV_F"]],
        ["placeAir", true],
        ["base", [[["center", _anchor], ["isCarrier", false], ["airspace", ""]]] call ALIVE_fnc_hashCreate]
    ]] call ALIVE_fnc_ATOPlace;
    private _none = [_place2, "placeInitial", []] call ALIVE_fnc_ATOPlace;
    diag_log format ["  info  initial placement for a faction with no aircraft: %1", _none];
    ["a faction with nothing worth flying gets nothing, and no error",
        _none isEqualTo []] call _fnc_check;

    // --- a record whose aircraft is on a spot it cannot use any more ---------
    // restoreAll re-checks every stand and moves the record when its old one
    // will not do, rather than putting an aircraft somewhere impossible.
    private _place3 = [nil, "create"] call ALIVE_fnc_ATOPlace;
    private _ledger3 = [nil, "create"] call ALIVE_fnc_ATOLedger;
    [_place3, "configure", [
        ["ledger", _ledger3], ["surface", _surface], ["effect", _effect],
        ["side", "WEST"], ["faction", "BLU_F"], ["factions", ["BLU_F"]],
        ["base", [[["center", _anchor], ["isCarrier", false], ["airspace", ""]]] call ALIVE_fnc_hashCreate]
    ]] call ALIVE_fnc_ATOPlace;

    private _good1 = [_ledger3, "createRecord", ["B_Heli_Attack_01_F", "BLU_F", [""], [["Attack"], ["CAS"]]]] call ALIVE_fnc_ATOLedger;
    private _goodHome = [_surface, "cascade", ["terrain", "B_Heli_Attack_01_F", _anchor, []]] call ALIVE_fnc_ATOSurface;
    if (count _goodHome > 2) then { [_ledger3, "setHome", [_good1, _goodHome]] call ALIVE_fnc_ATOLedger };

    private _bad1 = [_ledger3, "createRecord", ["B_Heli_Attack_01_F", "BLU_F", [""], [["Attack"], ["CAS"]]]] call ALIVE_fnc_ATOLedger;
    // Out at sea, which no amount of validating will accept.
    [_ledger3, "setHome", [_bad1, [[_anchor select 0, (_anchor select 1) - 3000, 0], 0, "terrain"]]] call ALIVE_fnc_ATOLedger;

    private _restored = [_place3, "restoreAll", []] call ALIVE_fnc_ATOPlace;
    diag_log format ["  info  restore answered %1", _restored];
    ["a restore answers with four lists", count _restored == 4] call _fnc_check;
    if (count _restored == 4) then {
        private _placedTails = (_restored select 0) + (_restored select 2);
        ["the record with a usable stand is placed there",
            _good1 in _placedTails] call _fnc_check;
        private _badHome = [[_ledger3, "get", _bad1] call ALIVE_fnc_ATOLedger, "home", []] call ALIVE_fnc_hashGet;
        private _badStatus = [[_ledger3, "get", _bad1] call ALIVE_fnc_ATOLedger, "status", ""] call ALIVE_fnc_hashGet;
        diag_log format ["  info  the unusable record ended as '%1' at %2", _badStatus,
            if (count _badHome > 0) then {str (_badHome select 0)} else {"[]"}];
        // Either it was moved somewhere it can live, or it was kept and marked
        // as having nowhere to go. Both are correct; silently dropping it is not.
        ["the record with an impossible stand is either moved or marked, never dropped",
            !([[_ledger3, "get", _bad1] call ALIVE_fnc_ATOLedger] isEqualTo [[]])
            && {(_bad1 in (_restored select 2)) || {_badStatus isEqualTo "unplaceable"} || {_bad1 in (_restored select 3)}}] call _fnc_check;
        {
            private _o = [_place3, "objFor", _x] call ALIVE_fnc_ATOPlace;
            if (!isNull _o) then { _made pushBack _o };
        } forEach ((_restored select 0) + (_restored select 1) + (_restored select 2));
    };

    // --- cleanup -------------------------------------------------------------
    {
        if (!isNull _x) then {
            { deleteVehicle _x } forEach (crew _x);
            deleteVehicle _x;
        };
    } forEach _made;
    { if (_x getVariable ["ALiVE_atoStamped", false]) then { deleteVehicle _x } }
        forEach (nearestObjects [_anchor, ["HeliH"], 600]);

    diag_log format ["  info  %1 assertions", _checked];
    if (count _skipped > 0) then {
        diag_log format ["  info  %1 check(s) skipped: %2", count _skipped, _skipped];
    };
    if (count _fails == 0) then {
        if (count _skipped == 0) then {
            diag_log "=== ATO Placement test: ALL PASS ===";
        } else {
            diag_log format ["=== ATO Placement test: ALL PASS, %1 SKIPPED ===", count _skipped];
        };
    } else {
        diag_log format ["=== ATO Placement test: %1 FAILURE(S): %2 ===", count _fails, _fails];
    };
};

"ATO Placement test started, results follow in the log"
