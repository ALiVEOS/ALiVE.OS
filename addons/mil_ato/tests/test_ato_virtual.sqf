#include "\x\alive\addons\mil_ato\script_component.hpp"

SCRIPT(test_ato_virtual);

/* ----------------------------------------------------------------------------
A base with no airfield: aircraft held at a point in the air.

Runs anywhere with water in reach. It picks the deepest water it can find
within a few kilometres on purpose, because the fault this kind of home is most
likely to have only appears in DEEP water: height measured the land way is
taken from the sea bed, so an aircraft held half a metre above the waves reads
tens of metres up and is judged to be flying with nobody aboard.

What it does NOT cover: the commander end to end. That needs a mission with no
airfield in the airspace, which this terrain is not.

Author:
Jman
---------------------------------------------------------------------------- */

[] spawn {

    private _fails = [];
    private _fnc_check = {
        // _ok is taken as Any on purpose: an assertion whose expression threw
        // arrives as nil, and `if (nil)` throws again and prints nothing, so
        // the failure would disappear rather than be reported.
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

    diag_log "=== ATO Virtual base test ===";

    private _anchor = if (isNull player) then {[1839.76, 5750.47, 0]} else {getPosATL player};

    // The deepest water within reach. Depth is the point: in shallow water the
    // sea-bed fault hides, and the first run of this was written against 5 m of
    // water where everything passed.
    private _best = [];
    private _bestDepth = 0;
    {
        private _q = [_anchor select 0, _x, 0];
        private _d = getTerrainHeightASL _q;
        if (surfaceIsWater _q && {_d < _bestDepth}) then { _bestDepth = _d; _best = _q };
    } forEach [600, 1500, 2400, 3250, 4200];

    if (_best isEqualTo []) exitWith {
        diag_log "=== ATO Virtual base test: SKIPPED, no water within reach ===";
    };
    diag_log format ["  info  holding over %1 m of water at %2", round (abs _bestDepth), _best];

    private _surface = [nil, "create"] call ALIVE_fnc_ATOSurface;
    private _class = "B_Heli_Attack_01_F";

    // --- the ring of hold points ------------------------------------------
    private _homes = [];
    for "_i" from 1 to 4 do {
        private _h = [_surface, "cascade", ["virtual", _class, _best, []]] call ALIVE_fnc_ATOSurface;
        if (count _h > 2) then {
            _homes pushBack _h;
            // Taken, so the next ask cannot be given the same point. This is
            // what placement does after every home it is handed.
            [_surface, "reserve", [_h select 0, 14]] call ALIVE_fnc_ATOSurface;
        };
    };

    ["four asks give four hold points", count _homes == 4] call _fnc_check;
    ["and every one of them is a virtual home",
        (_homes findIf {!((_x select 2) isEqualTo "virtual")}) == -1] call _fnc_check;

    // Compared by INDEX, not by value. Written the obvious way this compared
    // each home's position against the home itself, which can never match, so
    // every point was measured against its own position and the check reported
    // four distances of nothing.
    private _tooClose = [];
    {
        private _a = (_x select 0);
        private _i = _forEachIndex;
        {
            if (_forEachIndex > _i && {(_a distance2D (_x select 0)) < 30}) then {
                _tooClose pushBack round (_a distance2D (_x select 0));
            };
        } forEach _homes;
    } forEach _homes;
    ["and no two of them are on top of each other", count _tooClose == 0] call _fnc_check;
    if (count _tooClose > 0) then {
        diag_log format ["  info  distances that were too close: %1", _tooClose];
    };

    // Above the waves, not on the sea bed. The whole reason the height is kept
    // in the home rather than zeroed like a terrain one.
    private _underWater = _homes select { ((_x select 0) select 2) <= 0 };
    ["and all of them are above the water rather than under it",
        count _underWater == 0] call _fnc_check;

    private _home = _homes select 0;
    ["a free hold point validates",
        ([_surface, "validate", [_home, _class, objNull]] call ALIVE_fnc_ATOSurface) param [0, false]] call _fnc_check;
    ["and it has no pad, because there is nothing to stamp one onto",
        isNull ([_surface, "stampPad", [_home, "TEST_1"]] call ALIVE_fnc_ATOSurface)] call _fnc_check;

    // --- a real aircraft, held there --------------------------------------
    // Born in flight, which is the whole trick: one created the ordinary way
    // can never afterwards be put into the air.
    private _v = createVehicle [_class, [(_home select 0) select 0, (_home select 0) select 1, 300], [], 0, "FLY"];
    _v setVariable ["ALIVE_profileIgnore", true, true];
    createVehicleCrew _v;
    sleep 3;

    ["placing it answers yes",
        [_surface, "place", [_v, _home]] call ALIVE_fnc_ATOSurface] call _fnc_check;
    sleep 4;

    ["it is alive after being held", alive _v] call _fnc_check;
    ["it is out of sight", isObjectHidden _v] call _fnc_check;
    ["it is stopped", !(simulationEnabled _v)] call _fnc_check;
    private _off = abs (((getPosASL _v) select 2) - ((_home select 0) select 2));
    diag_log format ["  info  it sits %1 m from its hold height", (round (_off * 100)) / 100];
    ["and it is at its hold point rather than on the sea bed", _off < 1] call _fnc_check;

    // It stays there. A held aircraft that drifts is one that is somewhere else
    // by the time it is wanted.
    // Both sides read the same way. Measuring an OBJECT against a position
    // taken from getPosASL compares two different frames, and over sixty
    // metres of water that is a sixty metre disagreement about an aircraft
    // that has not moved at all.
    private _was = getPosASL _v;
    sleep 20;
    ["and it has not moved twenty seconds later",
        ((getPosASL _v) distance _was) < 1 && {alive _v}] call _fnc_check;

    // --- what the commander reads about it ---------------------------------
    // The reading that matters. Over deep water the land measure says tens of
    // metres up, which is the reading that has a parked aircraft recrewed in
    // mid air every tick.
    private _o = [nil, "create"] call ALIVE_fnc_ATOObserve;
    private _obs = [_o, "observe", [_v, _home, false, [], time]] call ALIVE_fnc_ATOObserve;
    diag_log format ["  info  it reads %1 m up the right way and %2 m up the land way",
        (round (([_obs, "altAGL", -1] call ALIVE_fnc_hashGet) * 10)) / 10,
        (round (((getPosATL _v) select 2) * 10)) / 10];
    ["it is recognised as living at a virtual home",
        ([_obs, "virtualHome", false] call ALIVE_fnc_hashGet) isEqualTo true] call _fnc_check;
    ["and it is NOT reported as flying, whatever the water is doing underneath",
        ([_obs, "airborne", true] call ALIVE_fnc_hashGet) isEqualTo false] call _fnc_check;
    ["and its crew is not reported lost",
        ([_obs, "crewLoss", true] call ALIVE_fnc_hashGet) isEqualTo false] call _fnc_check;
    ["and it is at home", ([_obs, "atHome", false] call ALIVE_fnc_hashGet) isEqualTo true] call _fnc_check;

    // --- servicing reaches it while it is held -----------------------------
    _v setDamage 0.5;
    _v setFuel 0.3;
    sleep 1;
    _v setDamage 0;
    _v setFuel 1;
    sleep 2;
    ["it can be repaired and refuelled while it is held",
        damage _v < 0.01 && {fuel _v > 0.99}] call _fnc_check;

    // --- letting it go and putting it back ---------------------------------
    ["letting it go answers yes",
        [_surface, "release", _v] call ALIVE_fnc_ATOSurface] call _fnc_check;
    sleep 1;
    ["and it is visible and running again",
        !(isObjectHidden _v) && {simulationEnabled _v}] call _fnc_check;
    ["and letting go of one already let go answers no",
        !([_surface, "release", _v] call ALIVE_fnc_ATOSurface)] call _fnc_check;

    ["it can be held again", [_surface, "place", [_v, _home]] call ALIVE_fnc_ATOSurface] call _fnc_check;
    sleep 3;
    ["and is out of sight and stopped once more",
        isObjectHidden _v && {!(simulationEnabled _v)} && {alive _v}] call _fnc_check;

    // --- an occupied point is refused --------------------------------------
    ["a hold point with somebody else on it does not validate",
        !(([_surface, "validate", [_home, _class, objNull]] call ALIVE_fnc_ATOSurface) param [0, false])] call _fnc_check;
    ["but it validates for the aircraft that is already there",
        ([_surface, "validate", [_home, _class, _v]] call ALIVE_fnc_ATOSurface) param [0, false]] call _fnc_check;

    { deleteVehicle _x } forEach (crew _v);
    deleteVehicle _v;

    if (count _fails == 0) then {
        diag_log "=== ATO Virtual base test: ALL PASS ===";
    } else {
        diag_log format ["=== ATO Virtual base test: %1 FAILURE(S): %2 ===", count _fails, _fails];
    };
};

"ATO Virtual base test started, results follow in the log"
