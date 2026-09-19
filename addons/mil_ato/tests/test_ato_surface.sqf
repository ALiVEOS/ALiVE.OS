#include "\x\alive\addons\mil_ato\script_component.hpp"

SCRIPT(test_ato_surface);

/* ----------------------------------------------------------------------------
Surface test, scene (a): a land airfield with NO ALiVE module placed.

Smallest mission: put a player on Stratis near the airfield, run this from the
debug console. It spawns itself because placing an airframe and letting it
settle takes time, and the console runs unscheduled.

Covers classify and the terrain half. The deck is its own scene, in
test_ato_deck, because it needs a carrier in the mission; what the deck
assertions here hold is that asking for a deck where there is no ship is
refused rather than guessed at.
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
    // Asked with the class, as the cascade and every later validation ask it:
    // without it no hangar is shelter, and a jet in a hangar bay is refused by
    // the hangar's own walls.
    private _allClear = true;
    {
        if !([_surface, "spotIsClear", [_x select 0, _span, [], _class]] call ALIVE_fnc_ATOSurface) then { _allClear = false };
    } forEach _homes;
    ["every home passes the predicate re-run as an oracle", _allClear] call _fnc_check;

    // A stand between two tent hangars. Measured on Stratis: an Apache was
    // given this spot by the ring search, with the hangars' origins 17 and 20 m
    // away and their walls 4.5 and 7.2 m away, and it lost its rotors to one of
    // them as it started up. Their origins are what the old test measured.
    if (worldName == "Stratis") then {
        private _heli = "B_Heli_Attack_01_dynamicLoadout_F";
        private _hbb = [_heli] call ALiVE_fnc_getVehicleBoundingBox;
        private _hspan = ((((_hbb select 0) max (_hbb select 1)) / 2) + 4) max 12;
        ["a stand with a hangar wall inside the rotor's reach is refused",
            !([_surface, "spotIsClear", [[1727.89, 5213.25, 0], _hspan, [], _heli, false]] call ALIVE_fnc_ATOSurface)] call _fnc_check;
        ["and so is the same stand asked without the class",
            !([_surface, "spotIsClear", [[1727.89, 5213.25, 0], _hspan]] call ALIVE_fnc_ATOSurface)] call _fnc_check;
        // The anchor it was placed from: the pad a Combat Support transport
        // started on, 597 m from the nearest of the field's own pads. The
        // search for a pad now reaches the rest of the field.
        private _hhome = [_surface, "cascade", ["terrain", _heli, [1727.89, 5153.25, 0], []]] call ALIVE_fnc_ATOSurface;
        diag_log format ["  info  a helicopter anchored at the south pad was given %1", _hhome];
        ["a helicopter anchored 600 m from the nearest free pad is still given a pad",
            count _hhome == 3 && {!((nearestObjects [_hhome select 0, ["HeliH"], 5]) isEqualTo [])}] call _fnc_check;
        ALiVE_airSpawnRegistry = [];
    };

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

    // Never on a runway or a taxiway, because an aircraft parked on either
    // blocks every other one. PARKING is deliberately allowed, and that is the
    // difference between this and what it used to ask.
    //
    // The kinds are 1 runway, 2 taxiway, 3 parking, and this asked about all
    // three. It passed for years because it was passing for the wrong reason:
    // the airfield rungs of the search were handing back a spot and it was
    // being discarded further down, so every home came out on open ground well
    // away from the airfield and could not be airside of any kind. With the
    // airfield working, a home on the apron IS kind 3, so this began failing
    // on the runs where the airfield answered and passing on the runs where it
    // did not, which read as an intermittent fault in the code and was an
    // assertion describing behaviour that had been deliberately replaced.
    private _airside = [];
    if (!isNil "ALiVE_fnc_isAirside") then {
        {
            if ([_x select 0, _span, [1,2]] call ALiVE_fnc_isAirside) then {
                _airside pushBack [_forEachIndex, _x select 0];
            };
        } forEach _homes;
        ["no home is on a runway or a taxiway", count _airside == 0] call _fnc_check;

    // And asked of the terrain's own geometry as well, because the test above
    // rests on the shared airside test and that answers false everywhere on
    // this map. Measured before this check existed: the parking predicate
    // returned TRUE in the middle of the runway and at a threshold.
    private _onRunway = [];
    {
        if ([_surface, "onRunway", _x select 0] call ALIVE_fnc_ATOSurface) then {
            _onRunway pushBack [_forEachIndex, [round ((_x select 0) select 0), round ((_x select 0) select 1)]];
        };
    } forEach _homes;
    ["and none of them is on the runway itself", count _onRunway == 0] call _fnc_check;
    if (count _onRunway > 0) then {
        diag_log format ["  info  on the runway: %1", _onRunway];
    };
    // The check that the check works: the middle of the runway has to be
    // refused, or the two above pass for want of an answer.
    private _rwLine = [_surface, "runwayDistance", _anchor] call ALIVE_fnc_ATOSurface;
    diag_log format ["  info  the commander's anchor is %1 m from the runway", round _rwLine];
    if (!isNil "ALiVE_fnc_getRunwayCentreline") then {
        private _l = [_anchor] call ALiVE_fnc_getRunwayCentreline;
        if (_l isEqualType [] && {count _l > 1}) then {
            private _ra = _l select 0;
            private _rb = _l select 1;
            private _rmid = [((_ra select 0) + (_rb select 0)) / 2, ((_ra select 1) + (_rb select 1)) / 2, 0];
            ["the middle of the runway is recognised as the runway",
                [_surface, "onRunway", _rmid] call ALIVE_fnc_ATOSurface] call _fnc_check;
            ["and is refused as a place to park",
                !([_surface, "spotIsClear", [_rmid, 13]] call ALIVE_fnc_ATOSurface)] call _fnc_check;
        };
    };
        if (count _airside > 0) then {
            diag_log format ["  info  on a movement surface: %1", _airside];
        };
        // Reported rather than asserted: how many of the homes are on real
        // parking is worth watching, because a run where none of them are is a
        // run where the airfield search answered for none of them.
        private _onStands = 0;
        {
            if ([_x select 0, _span, [3]] call ALiVE_fnc_isAirside) then { _onStands = _onStands + 1 };
        } forEach _homes;
        diag_log format ["  info  %1 of %2 homes are on the airfield's own parking", _onStands, count _homes];

        // Getting to your own parking must not mean crossing the active
        // runway. The search has no idea which side of the field the commander
        // is on, so it could hand back a stand across the runway from the
        // hangars, and an aircraft then crossed it to park and crossed it again
        // on every departure.
        private _crossers = [];
        {
            private _to = _x select 0;
            private _len = _anchor distance2D _to;
            private _crosses = false;
            if (_len > 20) then {
                private _steps = (round (_len / 20)) min 40;
                for "_i" from 1 to (_steps - 1) do {
                    if (!_crosses) then {
                        private _f = _i / _steps;
                        private _q = [
                            (_anchor select 0) + (((_to select 0) - (_anchor select 0)) * _f),
                            (_anchor select 1) + (((_to select 1) - (_anchor select 1)) * _f),
                            0
                        ];
                        // Asked of the surface, which measures against the
                        // terrain's own centreline. Asking the shared airside
                        // test here made this check vacuous: it answers false
                        // everywhere on this map, so it could never find a
                        // crossing and the check passed for want of an answer
                        // rather than because nothing crossed.
                        if ([_surface, "onRunway", _q] call ALIVE_fnc_ATOSurface) then { _crosses = true };
                    };
                };
            };
            if (_crosses) then { _crossers pushBack [_forEachIndex, [round (_to select 0), round (_to select 1)]] };
        } forEach _homes;
        // REPORTED, not asserted, and the reason is this airfield.
        //
        // The commander's anchor sits about a hundred metres off one side of
        // the runway and every stand the search can reach is on the other, so
        // on Stratis there is no non-crossing choice to prefer and the search
        // correctly takes one across the runway rather than putting aircraft
        // in a field. Asserting that none crosses would be asserting something
        // about the terrain rather than about the module. What IS asserted is
        // that none of them is ON the runway, below.
        //
        // Which side each one is on is reported too, because that is what
        // makes the count meaningful rather than mysterious.
        private _fnc_sideOf = {
            params ["_q"];
            private _l = [_anchor] call ALiVE_fnc_getRunwayCentreline;
            if (!(_l isEqualType []) || {count _l < 2}) exitWith { 0 };
            private _ra = _l select 0;
            private _rb = _l select 1;
            private _cross = (((_rb select 0) - (_ra select 0)) * ((_q select 1) - (_ra select 1)))
                - (((_rb select 1) - (_ra select 1)) * ((_q select 0) - (_ra select 0)));
            if (_cross > 0) then { 1 } else { -1 }
        };
        diag_log format ["  info  %1 of %2 homes are reached across the runway; the commander is on side %3",
            count _crossers, count _homes, [_anchor] call _fnc_sideOf];
        if (count _crossers > 0) then {
            diag_log format ["  info  across the runway: %1", _crossers];
        };
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

    // Named and measured when it fails, not just counted.
    //
    // This fails about one run in three, and a count alone cannot say why. The
    // suspicion is crowding: eight airframes are placed from ONE anchor, which
    // the note above says is not how the real caller works, and two homes only
    // have to be a span apart while atHome allows thirty metres, so neighbours
    // can shove each other past their own radius. The distances below are what
    // settles it.
    private _allHome = true;
    private _strays = [];
    {
        private _mine = _x;
        private _home = _homes select _forEachIndex;
        if !([_surface, "atHome", [_mine, _home]] call ALIVE_fnc_ATOSurface) then {
            _allHome = false;
            private _nearest = 99999;
            {
                if (!(_x isEqualTo _mine) && {(_x distance2D _mine) < _nearest}) then {
                    _nearest = _x distance2D _mine;
                };
            } forEach _spawned;
            _strays pushBack format ["%1 (%2) is %3 m from its home, kind %4, nearest neighbour %5 m",
                _forEachIndex, typeOf _mine, round (_mine distance2D (_home select 0)),
                _home select 2, round _nearest];
        };
    } forEach _spawned;
    if (count _strays > 0) then {
        { diag_log format ["  info  stray: %1", _x] } forEach _strays;
    };
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

    // A man on a stand does not occupy it. Measured: an aircraft put down on
    // four soldiers did not move and every one of them was alive, pushed a few
    // metres. Counting them took a Blackfish off its stand the moment it landed
    // for a soldier walking over it.
    private _walker = (createGroup west) createUnit ["B_Soldier_F", _victim select 0, [], 0, "CAN_COLLIDE"];
    sleep 1;
    diag_log format ["  info  a soldier stands %1 m from the home centre", round (_walker distance2D (_victim select 0))];
    (([_surface, "validate", [_victim, _class, objNull]] call ALIVE_fnc_ATOSurface)) params ["_ok3", "_why3"];
    ["a soldier standing on a home does not occupy it", _ok3 && {_why3 isEqualTo ""}] call _fnc_check;
    private _walkerGroup = group _walker;
    deleteVehicle _walker;
    deleteGroup _walkerGroup;

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

    // --- a deck where there is no ship must refuse, not guess ---------------
    ["asking for a deck home on an airfield finds nothing",
        ([_surface, "cascade", ["deck", _class, _anchor, []]] call ALIVE_fnc_ATOSurface) isEqualTo []] call _fnc_check;
    (([_surface, "validate", [[[0,0,0],0,"deck"], _class, objNull]] call ALIVE_fnc_ATOSurface)) params ["_ok3", "_why3"];
    ["and a deck home with no carrier behind it is refused, with a reason",
        !_ok3 && {_why3 isEqualTo "carrier gone"}] call _fnc_check;
    ["nothing on land is mistaken for a ship",
        isNull ([_surface, "shipAt", _anchor] call ALIVE_fnc_ATOSurface)] call _fnc_check;

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
