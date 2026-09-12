#include "\x\alive\addons\mil_ato\script_component.hpp"

SCRIPT(test_ato_deck);

/* ----------------------------------------------------------------------------
Surface test, scene (b): a carrier deck.

Smallest mission: place a USS Freedom (Land_Carrier_01_base_F) in deep water,
put a player anywhere, and run this from the debug console. The carrier has to
be placed by the EDITOR: the twenty parts a carrier is made of are spawned by
the hull's own init handler, and a hull created from a script and then moved
leaves them behind.

Covers the deck half, which the terrain scene deliberately does not: what counts
as a deck, how a carrier is referred to across a reload, where an airframe may
park on one, and that a deck position is worked out from the ship rather than
read back from a record.

The property this is really here to hold is the last one. A world position on a
ship is right until the ship is somewhere else, and storing one is why an
imported carrier aircraft used to come back in the sea.

Author:
Jman
---------------------------------------------------------------------------- */

[] spawn {

    private _fails = [];
    private _skips = [];
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
    private _fnc_skip = {
        _skips pushBack _this;
        diag_log format ["  skip  %1", _this];
    };

    diag_log "=== ATO Deck test (scene b: a carrier) ===";

    private _surface = [nil, "create"] call ALIVE_fnc_ATOSurface;
    private _land = if (isNull player) then {[1839.76, 5750.47, 0]} else {getPosATL player};

    // The carrier, by name when the scene gives it one and by search when it
    // does not, so this runs in a hand-built mission as well as on the rig.
    private _ship = objNull;
    if (!isNil "ATO_TEST_CARRIER") then { _ship = ATO_TEST_CARRIER };
    if (isNull _ship) then {
        _ship = (nearestObjects [_land, ["StaticShip"], 6000]) param [0, objNull];
    };

    if (isNull _ship) exitWith {
        diag_log "  FAIL  no carrier in this mission, so nothing here can run";
        diag_log "=== ATO Deck test: NO CARRIER ===";
    };

    private _centre = _ship modelToWorld [0, 0, 0];
    private _flatCentre = [_centre select 0, _centre select 1, 0];
    diag_log format ["  info  %1 at %2, heading %3", typeOf _ship, getPosASL _ship, round (getDir _ship)];

    private _spawned = [];

    // --- classify -----------------------------------------------------------
    ["the middle of a carrier classifies as deck",
        ([_surface, "classify", _flatCentre] call ALIVE_fnc_ATOSurface) isEqualTo "deck"] call _fnc_check;
    ["open water beside it does not",
        ([_surface, "classify", (_ship modelToWorld [140, 0, 0])] call ALIVE_fnc_ATOSurface) isEqualTo "terrain"] call _fnc_check;
    ["and an airfield on land still does not",
        ([_surface, "classify", _land] call ALIVE_fnc_ATOSurface) isEqualTo "terrain"] call _fnc_check;

    // --- how a carrier is referred to --------------------------------------
    ["the ship a deck point belongs to is found from the point",
        ([_surface, "shipAt", _flatCentre] call ALIVE_fnc_ATOSurface) isEqualTo _ship] call _fnc_check;
    ["and a point on land belongs to no ship",
        isNull ([_surface, "shipAt", _land] call ALIVE_fnc_ATOSurface)] call _fnc_check;

    private _handle = [_surface, "carrierHandle", _ship] call ALIVE_fnc_ATOSurface;
    ["a carrier handle carries its class, its position and its net id",
        count _handle == 3 && {(_handle select 0) isEqualTo (typeOf _ship)}] call _fnc_check;
    ["a handle resolves back to the same ship",
        ([_surface, "carrierFor", _handle] call ALIVE_fnc_ATOSurface) isEqualTo _ship] call _fnc_check;

    // The reload path. A net id does not survive a restart, so the class and
    // the position beside it have to be enough on their own.
    private _stale = [_handle select 0, _handle select 1, "0:0"];
    ["and resolves without its net id, which is what a reload leaves",
        ([_surface, "carrierFor", _stale] call ALIVE_fnc_ATOSurface) isEqualTo _ship] call _fnc_check;
    ["a handle to a ship that is not here resolves to nothing",
        isNull ([_surface, "carrierFor", [typeOf _ship, [10, 10, 0], "0:0"]] call ALIVE_fnc_ATOSurface)] call _fnc_check;

    // --- the deck's own geometry -------------------------------------------
    private _geom = [_surface, "deckGeometry", _ship] call ALIVE_fnc_ATOSurface;
    _geom params [["_deckZ", -9999], ["_landA", []], ["_landB", []], ["_taxi", []], ["_spots", []], ["_parts", []]];
    diag_log format ["  info  deck at %1 m, %2 parking offsets, %3 taxi segments, %4 part classes",
        _deckZ, count _spots, count _taxi, count _parts];

    ["the deck's level is read off the ship and is above the water",
        _deckZ > 5 && {_deckZ < 60}] call _fnc_check;
    ["the twenty part classes are read as classes, not as config pairs",
        count _parts > 0 && {(_parts select 0) isEqualType ""} && {isClass (configFile >> "CfgVehicles" >> (_parts select 0))}] call _fnc_check;
    ["the landing strip is known",
        count _landA > 1 && {count _landB > 1}] call _fnc_check;
    ["the taxi lanes are known",
        count _taxi > 0] call _fnc_check;
    ["there is somewhere to park",
        count _spots > 3] call _fnc_check;

    // Asked of itself: every offset the sweep kept has to be a deck when
    // something asks again. A spot that cannot answer twice was never a spot.
    private _badSpot = [];
    {
        if (count _badSpot == 0) then {
            private _w = _ship modelToWorld [_x select 0, _x select 1, 0];
            if !(([_surface, "classify", [_w select 0, _w select 1, 0]] call ALIVE_fnc_ATOSurface) isEqualTo "deck") then {
                _badSpot = _x;
            };
        };
    } forEach _spots;
    ["every parking offset is on the deck when asked again",
        count _badSpot == 0] call _fnc_check;
    if (count _badSpot > 0) then {
        diag_log format ["  info  the offset that is not deck: %1", _badSpot];
    };

    // The order is the point of the ranking: farthest from the strip first, so
    // the first aircraft to ask gets the spot furthest out of the way.
    private _dFirst = 0;
    private _dLast = 0;
    if (count _spots > 1 && {count _landA > 1}) then {
        private _fnc_toLine = {
            params ["_s"];
            private _q = [_s select 0, _s select 1, 0];
            private _ax = _landA select 0;
            private _ay = _landA select 1;
            private _dx = (_landB select 0) - _ax;
            private _dy = (_landB select 1) - _ay;
            private _len2 = (_dx * _dx) + (_dy * _dy);
            private _t = ((((_q select 0) - _ax) * _dx) + (((_q select 1) - _ay) * _dy)) / _len2;
            _t = (_t max 0) min 1;
            _q distance2D [_ax + (_t * _dx), _ay + (_t * _dy), 0]
        };
        _dFirst = [_spots select 0] call _fnc_toLine;
        _dLast = [_spots select ((count _spots) - 1)] call _fnc_toLine;
    };
    diag_log format ["  info  first offset is %1 m from the strip, last is %2 m", round _dFirst, round _dLast];
    ["parking is offered farthest from the landing strip first",
        _dFirst >= _dLast] call _fnc_check;

    // --- what the deck must refuse -----------------------------------------
    // The island. It is a part of the ship, so a trace hits it and the naive
    // answer is "deck"; what rules it out is that its top is twenty-five
    // metres above the deck's own level.
    private _island = _ship modelToWorld [-30, 105, 0];
    ["the island is not somewhere to park",
        !([_surface, "deckSpotIsClear", [[_island select 0, _island select 1, _deckZ], 14, [], _ship]] call ALIVE_fnc_ATOSurface)] call _fnc_check;

    // The landing strip, taken from the middle of the strip the geometry found
    // rather than from a number written here.
    if (count _landA > 1) then {
        private _mid = [((_landA select 0) + (_landB select 0)) / 2, ((_landA select 1) + (_landB select 1)) / 2, 0];
        private _w = _ship modelToWorld _mid;
        ["the landing strip is not somewhere to park",
            !([_surface, "deckSpotIsClear", [[_w select 0, _w select 1, _deckZ], 14, [], _ship]] call ALIVE_fnc_ATOSurface)] call _fnc_check;
    } else {
        "the landing strip is not somewhere to park" call _fnc_skip;
    };

    private _water = _ship modelToWorld [140, 0, 0];
    ["the water beside the ship is not somewhere to park",
        !([_surface, "deckSpotIsClear", [[_water select 0, _water select 1, _deckZ], 14, [], _ship]] call ALIVE_fnc_ATOSurface)] call _fnc_check;

    // --- a home on the deck -------------------------------------------------
    private _class = "B_Heli_Transport_01_F";
    private _home = [_surface, "cascade", ["deck", _class, _flatCentre, []]] call ALIVE_fnc_ATOSurface;
    diag_log format ["  info  the home that came back: %1", _home];

    ["a deck home comes back and says it is a deck",
        count _home >= 6 && {(_home select 2) isEqualTo "deck"}] call _fnc_check;
    ["it names the carrier it belongs to",
        count _home >= 4 && {([_surface, "carrierFor", _home select 3] call ALIVE_fnc_ATOSurface) isEqualTo _ship}] call _fnc_check;
    ["and where it is within that carrier",
        count _home >= 5 && {(_home select 4) isEqualType []} && {count (_home select 4) == 3}] call _fnc_check;
    ["its first three entries still read as any other home does",
        count _home >= 3 && {(_home select 0) isEqualType []} && {(_home select 1) isEqualType 0}] call _fnc_check;

    // Worked out, not read back. The stored world position is deliberately
    // wrecked in a copy: a resolve that still answers correctly is a resolve
    // that derived the answer from the ship.
    if (count _home >= 6) then {
        ([_surface, "resolve", _home] call ALIVE_fnc_ATOSurface) params ["_rPos", "_rDir"];
        ["resolving a deck home gives back the place it was chosen",
            (_rPos distance2D (_home select 0)) < 1] call _fnc_check;
        ["and a heading relative to the ship's own",
            (abs (_rDir - (getDir _ship))) < 1 || {(abs (_rDir - (getDir _ship))) > 359}] call _fnc_check;
        ["and the height is the deck, not the sea bed",
            (abs ((_rPos select 2) - _deckZ)) < 2] call _fnc_check;

        private _lying = +_home;
        _lying set [0, [0, 0, 0]];
        private _rLying = ([_surface, "resolve", _lying] call ALIVE_fnc_ATOSurface) select 0;
        ["a deck home with a wrecked stored position still resolves correctly",
            (_rLying distance2D _rPos) < 1] call _fnc_check;
    } else {
        "resolving a deck home gives back the place it was chosen" call _fnc_skip;
    };

    // --- eight of them, which is what a carrier air group looks like --------
    private _homes = [];
    private _reserved = [];
    private _bb = [_class] call ALiVE_fnc_getVehicleBoundingBox;
    private _span = ((((_bb select 0) max (_bb select 1)) / 2) + 4) max 12;
    for "_i" from 1 to 8 do {
        private _h = [_surface, "cascade", ["deck", _class, _flatCentre, _reserved]] call ALIVE_fnc_ATOSurface;
        if (count _h >= 6) then {
            _homes pushBack _h;
            _reserved pushBack [_h select 0, _span];
        };
    };
    diag_log format ["  info  %1 of 8 airframes found a place on the deck", count _homes];
    ["a carrier has room for eight airframes", count _homes == 8] call _fnc_check;

    private _tooClose = [];
    {
        private _a = _x;
        private _i = _forEachIndex;
        {
            if (_forEachIndex > _i && {count _tooClose == 0}) then {
                private _d = (_a select 0) distance2D (_x select 0);
                if (_d < _span) then { _tooClose = [_i, _forEachIndex, round _d] };
            };
        } forEach _homes;
    } forEach _homes;
    ["and none of the eight is parked inside another",
        count _tooClose == 0] call _fnc_check;
    if (count _tooClose > 0) then {
        diag_log format ["  info  %1 and %2 are only %3 m apart, span is %4",
            _tooClose select 0, _tooClose select 1, _tooClose select 2, round _span];
    };

    // --- putting one there --------------------------------------------------
    if (count _home >= 6) then {
        private _veh = createVehicle [_class, [0,0,0], [], 0, "CAN_COLLIDE"];
        _veh setVariable ["ALIVE_profileIgnore", true, true];
        _spawned pushBack _veh;
        private _placed = [_surface, "place", [_veh, _home]] call ALIVE_fnc_ATOSurface;
        ["an airframe can be put on a deck home", _placed] call _fnc_check;

        sleep 2;
        private _target = ([_surface, "resolve", _home] call ALIVE_fnc_ATOSurface) select 0;
        private _dTo = _veh distance2D _target;
        private _zNow = (getPosASL _veh) select 2;
        diag_log format ["  info  it is %1 m from its spot and %2 m up", round _dTo, round _zNow];
        ["and it lands on the spot rather than beside it", _dTo < 3] call _fnc_check;
        ["and on the deck rather than in the sea",
            _zNow > (_deckZ - 3)] call _fnc_check;
        ["and the surface agrees it is home",
            [_surface, "atHome", [_veh, _home]] call ALIVE_fnc_ATOSurface] call _fnc_check;

        // Its own home has to validate while it is standing on it. Without the
        // ignore list an airframe fails its own re-check the moment it parks.
        ([_surface, "validate", [_home, _class, _veh]] call ALIVE_fnc_ATOSurface) params ["_vOk", "_vWhy"];
        diag_log format ["  info  validate with the airframe as its own: %1 %2", _vOk, _vWhy];
        ["a deck home validates with its own airframe parked on it", _vOk] call _fnc_check;

        // And refuses when somebody else is on it.
        ([_surface, "validate", [_home, _class, objNull]] call ALIVE_fnc_ATOSurface) params ["_oOk", "_oWhy"];
        ["and reports it occupied when the airframe is not ours",
            !_oOk && {_oWhy isEqualTo "occupied"}] call _fnc_check;

        // Still there after it has settled. Damage is re-armed eight seconds
        // in, and an airframe clipping the plating is destroyed a moment later.
        sleep 12;
        ["and it is still in one piece twelve seconds later",
            !isNull _veh && {alive _veh} && {((getPosASL _veh) select 2) > (_deckZ - 3)}] call _fnc_check;

        // A home whose carrier has gone is refused rather than guessed at.
        private _orphan = +_home;
        _orphan set [3, [typeOf _ship, [10, 10, 0], "0:0"]];
        ([_surface, "validate", [_orphan, _class, objNull]] call ALIVE_fnc_ATOSurface) params ["_gOk", "_gWhy"];
        ["a deck home whose carrier is gone says so",
            !_gOk && {_gWhy isEqualTo "carrier gone"}] call _fnc_check;
        ["and nothing is placed on it",
            !([_surface, "place", [_veh, _orphan]] call ALIVE_fnc_ATOSurface)] call _fnc_check;
    } else {
        "an airframe can be put on a deck home" call _fnc_skip;
    };

    // --- what the old module's records become -------------------------------
    // An imported carrier aircraft has to come out of the import with its ship
    // and its offset, not with a bare world position and a flag.
    private _ledger = [nil, "create"] call ALIVE_fnc_ATOLedger;
    private _asset = [[
        ["profileID", "legacy_deck_1"],
        ["vehicleClass", _class],
        ["startPos", _flatCentre],
        ["startDir", getDir _ship],
        ["isOnCarrier", true],
        ["roles", ["CAS"]],
        ["capabilities", []],
        ["airspace", []]
    ]] call ALIVE_fnc_hashCreate;
    private _assets = [] call ALIVE_fnc_hashCreate;
    [_assets, "legacy_deck_1", _asset] call ALIVE_fnc_hashSet;
    private _byFaction = [] call ALIVE_fnc_hashCreate;
    [_byFaction, "BLU_F", _assets] call ALIVE_fnc_hashSet;

    private _imported = [_ledger, "importLegacy", _byFaction] call ALIVE_fnc_ATOLedger;
    diag_log format ["  info  the import took %1", _imported];
    private _view = [_ledger, "view"] call ALIVE_fnc_ATOLedger;
    private _tails = if ([_view] call ALIVE_fnc_isHash) then { _view select 1 } else { [] };
    if (_tails isEqualType [] && {count _tails > 0}) then {
        private _rec = [_ledger, "get", _tails select 0] call ALIVE_fnc_ATOLedger;
        private _iHome = [_rec, "home", []] call ALIVE_fnc_hashGet;
        diag_log format ["  info  the imported home: %1", _iHome];
        ["an imported carrier aircraft comes in as a deck home",
            count _iHome >= 6 && {(_iHome select 2) isEqualTo "deck"}] call _fnc_check;
        ["and it knows which ship it was on",
            count _iHome >= 4 && {([_surface, "carrierFor", _iHome select 3] call ALIVE_fnc_ATOSurface) isEqualTo _ship}] call _fnc_check;
        ["and resolves to where the old module last saw it",
            (([_surface, "resolve", _iHome] call ALIVE_fnc_ATOSurface) select 0) distance2D _flatCentre < 2] call _fnc_check;
    } else {
        "an imported carrier aircraft comes in as a deck home" call _fnc_skip;
    };

    // --- a commander placed ON the carrier ---------------------------------
    // Base has had a carrier branch since it was written and nothing had ever
    // run it, because no scene had a ship in it. What is asserted here is that
    // the branch is reached at all, that it reaches it through Surface's
    // answer rather than through a setting, and that it leaves the deck
    // already worked out so the first aircraft to ask does not pay for it.
    private _madeDeck = [];
    private _zoneD = "ato_deck_test_zone";
    private _mkD = createMarker [_zoneD, _flatCentre];
    _mkD setMarkerShape "ELLIPSE";
    _mkD setMarkerSize [1200, 1200];
    _mkD setMarkerAlpha 0;

    private _gD = createGroup sideLogic;
    private _modD = _gD createUnit ["Logic", _flatCentre, [], 0, "CAN_COLLIDE"];
    _madeDeck pushBack _modD;
    // Read as STRINGS by the module's own accessors, which compare against
    // "true". A boolean there is a type error rather than a false, and it
    // kills the whole init.
    _modD setVariable ["airspace", [_zoneD]];
    {
        _modD setVariable [_x select 0, _x select 1];
    } forEach [["faction", "BLU_F"], ["placeAir", "false"], ["debug", "false"],
        ["createHQ", "true"], ["resupply", "false"], ["persistent", "false"],
        ["broadcastOnRadio", "false"], ["generateTasks", "false"]];

    private _surfD = [nil, "create"] call ALIVE_fnc_ATOSurface;
    private _depsD = [[
        ["ledger",  [nil, "create"] call ALIVE_fnc_ATOLedger],
        ["surface", _surfD],
        ["place",   [nil, "create"] call ALIVE_fnc_ATOPlace],
        ["task",    [nil, "create"] call ALIVE_fnc_ATOTask],
        ["effect",  [nil, "create"] call ALIVE_fnc_ATOEffect]
    ]] call ALIVE_fnc_hashCreate;

    private _baseD = [nil, "create"] call ALIVE_fnc_ATOBase;
    [_baseD, "establish", [_modD, _depsD]] call ALIVE_fnc_ATOBase;
    ["a commander on a deck reports itself started",
        _modD getVariable ["startupComplete", false]] call _fnc_check;

    private _settleD = 0;
    waitUntil {
        sleep 2;
        _settleD = _settleD + 2;
        (([_baseD, "phase"] call ALIVE_fnc_ATOBase) in ["established", "failed"]) || {_settleD > 100}
    };
    private _phaseD = [_baseD, "phase"] call ALIVE_fnc_ATOBase;
    // Read through the view, which is the copy Base offers of itself; there is
    // no accessor for either of these and inventing one for a test would be
    // adding to the interface to make the test easier.
    private _viewD = [_baseD, "view"] call ALIVE_fnc_ATOBase;
    private _isCarrierD = [_viewD, "isCarrier", false] call ALIVE_fnc_hashGet;
    private _carrierD = [_viewD, "carrier", objNull] call ALIVE_fnc_hashGet;
    diag_log format ["  info  the deck commander finished as '%1', carrier %2 (%3), failed '%4'",
        _phaseD, _isCarrierD, typeOf _carrierD, [_baseD, "failed"] call ALIVE_fnc_ATOBase];
    ["and finishes building rather than failing",
        _phaseD isEqualTo "established"] call _fnc_check;
    ["and knows it is on a carrier", _isCarrierD] call _fnc_check;
    ["and names the ship it is standing on",
        _carrierD isEqualTo _ship] call _fnc_check;

    // Warm, meaning the sweep already happened. Asked of a brand new instance
    // the same question costs 700 ms of tracing; asked of this one it is a
    // read, so the deck it hands back has to be there without any further
    // work. The cache is the instance's own, so this is the instance Base was
    // given rather than the one this test has been using.
    private _warm = [_surfD, "decks", []] call ALIVE_fnc_hashGet;
    ["and leaves the deck already worked out",
        ([_warm] call ALIVE_fnc_isHash) && {count (_warm select 1) > 0}] call _fnc_check;

    deleteMarker _zoneD;
    { if (!isNull _x) then { deleteVehicle _x } } forEach _madeDeck;

    // --- tidy up ------------------------------------------------------------
    {
        if (!isNull _x) then {
            { deleteVehicle _x } forEach (crew _x);
            deleteVehicle _x;
        };
    } forEach _spawned;

    if (count _fails == 0) then {
        diag_log format ["=== ATO Deck test: ALL PASS (%1 skipped) ===", count _skips];
    } else {
        diag_log format ["=== ATO Deck test: %1 FAILED ===", count _fails];
        { diag_log format ["   failed: %1", _x] } forEach _fails;
    };
};
