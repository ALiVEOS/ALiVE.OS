#include "\x\alive\addons\mil_ato\script_component.hpp"
SCRIPT(surface);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_ATOSurface
Description:
Where an airframe may stand, and how it gets on and off the ground.

Two implementations behind one interface, terrain and carrier deck, chosen by
the surface recorded in a home. This is the ONLY place that decides which of the
two a point is: not the module's carrier setting, not a bare distance to a ship,
not whether there is water underneath. A destroyer moored off a coastal airfield
is 700 m from the apron, and the apron is still terrain.

A home is [position, direction, surface]. It is the one authoritative record of
where an airframe lives. Everything else, the airport it belongs to, the pad
object, the taxi point, is worked out from it on read rather than stored beside
it, because six stored copies of one home is what let them drift apart.

A DECK home carries three more entries: [position, direction, "deck", carrier,
offset, relativeDirection]. The position and direction are the world values as
they stood when the home was chosen, so anything reading the first three
entries of any home still gets an answer. The last three are what makes a deck
home survive: the carrier it belongs to, the offset within that carrier in the
ship's own model space, and the heading relative to the ship's. The world
position is derived from those on read, because a stored world position on a
ship is a position that is right until the ship is somewhere else.

Deck positions are ASL. Terrain positions are above terrain level with the
height zeroed. The two cannot be mixed: above water, terrain level is the SEA
BED, so a deck height read as a terrain height is about forty metres wrong.

Parameters:
Nil or Array - If Nil, return a new instance. If a hash, reference an existing one.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function

Examples:
(begin example)
_surface = [nil, "create"] call ALIVE_fnc_ATOSurface;
_home = [_surface, "cascade", ["terrain", "B_Plane_CAS_01_F", _anchorPos, []]] call ALIVE_fnc_ATOSurface;

(end)

See Also:
<ALIVE_fnc_ATOLedger>

Author:
Jman
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClassHash
#define MAINCLASS ALIVE_fnc_ATOSurface

// A ship has to be this close before its parts are even considered. The old
// code used 700 m, which reaches across a coastal airfield.
#define SHIP_SEARCH 400

// Trees, rocks, walls and forest borders are what a spot away from the apron
// actually runs into. The object sweep does not see terrain-placed clutter.
#define CLUTTER ["TREE","SMALL TREE","BUSH","FOREST","FOREST BORDER","ROCK","ROCKS","WALL","FENCE","BUILDING","HOUSE","RUIN","POWER LINES"]

// Deck geometry. Measured on a USS Freedom placed by the editor, 2.5 km off
// Stratis: the flight deck is 23.6 m above the waterline, the hull runs from
// model y -190 to +190 and x -45 to +45, the island stands at model [-30, 105]
// and rises 25 m above the deck, and the landing and taxi lines live on the
// DynamicAirport_01_F the carrier carries at model [0, -1, 24] rather than on
// the hull's own config, which has no ils entries at all.
//
// Nothing here is per-class. The deck is found by tracing, its level is read
// off the ship, and the lines to keep clear of come from the airport object's
// config, so a carrier from a mod is handled the same way as this one.
#define DECK_BAND 4           // above or below the deck's own level and still deck
// Half widths, so the strip kept clear is forty metres across and a taxi lane
// twenty. Both are wider than the real markings, which is the point: an
// aircraft parked a little outside the paint is still in the way of a hook and
// wire recovery. Sixty and twenty-eight were tried first and left room for
// only six airframes on a ship that should hold eight comfortably, because
// between them they took most of a ninety metre deck.
#define DECK_LAND_CLEAR 20    // half width of the landing strip kept clear
#define DECK_TAXI_CLEAR 10    // half width of the taxi lanes kept clear
#define DECK_STEP_X 5
#define DECK_STEP_Y 10
#define DECK_REACH_X 45
#define DECK_REACH_Y 190

private ["_result"];

// Distance from a point to a SEGMENT, in two dimensions. Wanted in three
// places, and the reason it is a segment rather than the nearest listed point
// is that every polyline this file reads is sparse: two consecutive Stratis
// taxi points are 905 m apart, so the middle of that stretch is 450 m from
// either end and a point test would call the runway open country.
private _fnc_segDist = {
    params ["_q", "_a", "_b"];
    private _ax = _a select 0;
    private _ay = _a select 1;
    private _dx = (_b select 0) - _ax;
    private _dy = (_b select 1) - _ay;
    private _len2 = (_dx * _dx) + (_dy * _dy);
    if (_len2 <= 0) exitWith { _q distance2D [_ax, _ay, 0] };
    private _t = ((((_q select 0) - _ax) * _dx) + (((_q select 1) - _ay) * _dy)) / _len2;
    _t = (_t max 0) min 1;
    _q distance2D [_ax + (_t * _dx), _ay + (_t * _dy), 0]
};

TRACE_1("ATO Surface - input",_this);

params [
    ["_logic", objNull, [objNull,[]]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,[],"",0,true,false]]
];

_result = true;

switch(_operation) do {

    case "create": {
        _result = [[
            ["class", MAINCLASS],
            ["locks", [] call ALIVE_fnc_hashCreate],
            ["pads", [] call ALIVE_fnc_hashCreate],
            // Per carrier, worked out once. A deck does not change shape, and
            // the sweep that finds its parking costs hundreds of traces.
            ["decks", [] call ALIVE_fnc_hashCreate],
            ["reservations", []]
        ]] call ALIVE_fnc_hashCreate;
    };

    // The only derivation of terrain versus deck. A point is deck only when a
    // part of a nearby ship is directly beneath it: being near a ship, or over
    // water, or belonging to a module someone ticked "carrier" on, are all
    // things that are true in places that are not a deck.
    case "classify": {
        private _pos = _args;
        _result = "terrain";

        private _ships = nearestObjects [_pos, ["StaticShip"], SHIP_SEARCH];
        if (count _ships == 0) exitWith { _result = "terrain" };

        private _ship = _ships select 0;

        // What counts as part of this ship, by CLASS.
        //
        // A carrier is a composite: the hull is one object and the deck, the
        // island and the catapults are separate objects beside it. The config
        // lists their classes, which is how the old module found them. This
        // read the list off a VARIABLE on the ship instead, and nothing
        // anywhere sets that variable, so the list was always empty and the
        // test fell back to the hull alone. A trace that hit the deck rather
        // than the hull answered "terrain", which is every trace on a carrier.
        // Each config entry is a PAIR, [class, memory point on the hull], not a
        // bare class name, so the list has to be reduced to its class names
        // before a class can be looked for in it. Measured on a USS Freedom:
        // twenty pairs, entry zero
        // ["Land_Carrier_01_hull_01_F", "pos_hull_1"].
        private _partClasses = (getArray (configFile >> "CfgVehicles" >> typeOf _ship >> "multiStructureParts")) apply {
            if (_x isEqualType []) then { _x param [0, ""] } else { _x }
        };
        // Kept as well, in case something stamps the objects one day.
        private _partObjects = _ship getVariable ["multiStructureParts", []];
        if !(_partObjects isEqualType []) then { _partObjects = [] };

        // Straight down through the point. A deck is a surface you could stand
        // on, so ask whether one is there rather than inferring it.
        //
        // Traced from above the WATER, not from above the sea bed. This started
        // at the terrain height plus fifty, and over water the terrain height
        // IS the sea bed. A carrier deck sits about fifteen metres above the
        // waterline, so anywhere the water is deeper than about thirty-five
        // metres the trace began underneath the deck and went further down, and
        // could never hit it. Measured: a carrier two and a half kilometres off
        // Stratis classified as terrain at every offset, its own deck included.
        //
        // Sea level or the terrain, whichever is higher, works in both places:
        // over land it is the old behaviour, over water it is above the
        // waterline, which is where a deck is.
        private _groundASL = getTerrainHeightASL _pos;
        private _from = [_pos select 0, _pos select 1, (0 max _groundASL) + 80];
        private _to   = [_pos select 0, _pos select 1, (_groundASL min 0) - 5];
        // More than one hit wanted: the first thing a trace meets over a deck
        // may be an aircraft, a crate or a railing, and the deck is under it.
        private _hits = lineIntersectsSurfaces [
            _from, _to, objNull, objNull, true, 8, "GEOM", "NONE"
        ];

        {
            private _obj = _x select 2;
            if (!isNull _obj
                && {(_obj isEqualTo _ship)
                    || {_obj isKindOf "StaticShip"}
                    || {(typeOf _obj) in _partClasses}
                    || {(_partObjects findIf {_x isEqualTo _obj}) > -1}}) exitWith {
                _result = "deck";
            };
        } forEach _hits;
    };

    // Where an airframe of this class may stand, anchored near a point, without
    // clashing with anything already reserved this pass. An empty return is a
    // refusal and is load bearing: the caller must handle "nowhere" rather than
    // be handed a position that was never checked.
    // ---- the deck ---------------------------------------------------------
    // A carrier is referred to by a HANDLE rather than by the object, because
    // an object reference does not survive a save and a net id does not
    // survive a restart. The handle carries all three: the net id for the
    // exact answer now, and the class and position for the answer after a
    // reload. A StaticShip does not move, so where it was recorded is where it
    // still is.
    // The ship a point belongs to. On its own so that nothing outside this
    // file has to know the class or the radius a carrier is found by.
    case "shipAt": {
        _result = (nearestObjects [_args, ["StaticShip"], SHIP_SEARCH]) param [0, objNull];
    };

    case "carrierHandle": {
        private _ship = _args;
        _result = [];
        if (!isNull _ship) then {
            _result = [typeOf _ship, getPosASL _ship, netId _ship];
        };
    };

    case "carrierFor": {
        private _h = _args;
        _result = objNull;
        if (_h isEqualType objNull) then {
            _result = _h;
        } else {
            if (_h isEqualType []) then {
                _h params [["_cls","",[""]], ["_pos",[0,0,0],[[]]], ["_net","",[""]]];
                private _o = objNull;
                if !(_net isEqualTo "") then {
                    private _try = objectFromNetId _net;
                    if (!isNull _try && {_try isKindOf "StaticShip"}) then { _o = _try };
                };
                if (isNull _o && {count _pos > 1}) then {
                    _o = (nearestObjects [_pos, [_cls], SHIP_SEARCH]) param [0, objNull];
                    if (isNull _o) then {
                        _o = (nearestObjects [_pos, ["StaticShip"], SHIP_SEARCH]) param [0, objNull];
                    };
                };
                _result = _o;
            };
        };
    };

    // The first solid thing under a point, looking down from above anything a
    // carrier carries, and what that thing is. Objects in the ignore list are
    // looked through, which is what lets a spot pass its own re-check while the
    // airframe that lives on it is parked there.
    case "deckTop": {
        _args params [["_p",[0,0,0],[[]]], ["_ignore",[],[[]]]];
        private _hits = lineIntersectsSurfaces [
            [_p select 0, _p select 1, 200],
            [_p select 0, _p select 1, -5],
            objNull, objNull, true, 12, "GEOM", "NONE"
        ];
        private _z = -9999;
        private _hit = objNull;
        {
            private _cand = _x select 2;
            if (_z < -9000
                && {!isNull _cand}
                && {(_ignore findIf {_x isEqualTo _cand}) == -1}) then {
                _z = (_x select 0) select 2;
                _hit = _cand;
            };
        } forEach _hits;
        _result = [_z, _hit];
    };

    // Everything about one carrier's deck, worked out once and kept.
    //
    // Returns [deckLevelASL, landFrom, landTo, taxiSegments, spots, partClasses]
    // where the land and taxi geometry and the spots are all in the SHIP's own
    // model space, so every later test happens in one frame.
    //
    // The spots are ordered by how far they are from the landing strip, the
    // farthest first. That is where aircraft are actually parked on a carrier,
    // and it means the order is the same on every run: the ring search on land
    // places spots differently each time, which is what made an intermittent
    // failure there impossible to read.
    case "deckGeometry": {
        private _ship = _args;
        _result = [];
        if (!isNull _ship) then {
            private _decks = [_logic, "decks", []] call ALIVE_fnc_hashGet;
            if !([_decks] call ALIVE_fnc_isHash) then {
                _decks = [] call ALIVE_fnc_hashCreate;
                [_logic, "decks", _decks] call ALIVE_fnc_hashSet;
            };
            private _key = netId _ship;
            private _got = [_decks, _key, []] call ALIVE_fnc_hashGet;
            if (_got isEqualType [] && {count _got > 4}) then {
                _result = _got;
            } else {
                private _began = diag_tickTime;
                // Each config entry is a PAIR, [class, memory point], so the
                // list has to be reduced to class names before a class can be
                // looked for in it.
                private _partClasses = (getArray (configFile >> "CfgVehicles" >> typeOf _ship >> "multiStructureParts")) apply {
                    if (_x isEqualType []) then { _x param [0, ""] } else { _x }
                };

                // Deck level, read off the ship. Five samples down the middle
                // and the middle one taken, so an aircraft or a crate standing
                // on one of them cannot move the answer.
                private _zs = [];
                {
                    private _w = _ship modelToWorld [_x select 0, _x select 1, 0];
                    private _t = ([_logic, "deckTop", [[_w select 0, _w select 1, 0], []]] call MAINCLASS) select 0;
                    if (_t > -9000) then { _zs pushBack _t };
                } forEach [[0,0],[0,-60],[0,60],[18,-20],[-18,20]];
                _zs sort true;
                private _deckZ = -9999;
                if (count _zs > 0) then { _deckZ = _zs select (floor ((count _zs) / 2)) };

                // The lines to keep clear of come from the airport object the
                // carrier carries, because the hull's own config has no ils
                // entries. Measured on a USS Freedom: ilsPosition [3, 125] and
                // ilsDirection [-0.1392, 0.052336, 0.9903], which is the
                // angled deck, eight degrees off the ship's axis, and two taxi
                // polylines of four and six points.
                private _airObj = (nearestObjects [getPosASL _ship, ["AirportBase"], SHIP_SEARCH]) param [0, objNull];
                private _landA = [];
                private _landB = [];
                private _taxi = [];
                if (!isNull _airObj) then {
                    private _ac = configFile >> "CfgVehicles" >> typeOf _airObj;
                    // The airport object has its own model space. Converted
                    // into the ship's through the world, rather than assumed
                    // to be the same frame: it sits a metre off the hull
                    // centre and a mod's could sit anywhere.
                    private _fnc_toShip = {
                        params ["_mx", "_my"];
                        private _w = _airObj modelToWorld [_mx, _my, 0];
                        private _m = _ship worldToModel [_w select 0, _w select 1, _w select 2];
                        [_m select 0, _m select 1, 0]
                    };
                    private _ils = getArray (_ac >> "ilsPosition");
                    private _idir = getArray (_ac >> "ilsDirection");
                    if (count _ils > 1 && {count _idir > 2}) then {
                        // ilsDirection is [x, up, y]. Extended four hundred
                        // metres either way from the threshold so the segment
                        // covers the whole deck whichever end the threshold
                        // sits at.
                        private _dx = _idir select 0;
                        private _dy = _idir select 2;
                        _landA = [(_ils select 0) - (_dx * 400), (_ils select 1) - (_dy * 400)] call _fnc_toShip;
                        _landB = [(_ils select 0) + (_dx * 400), (_ils select 1) + (_dy * 400)] call _fnc_toShip;
                    };
                    {
                        private _flat = getArray (_ac >> _x);
                        private _prev = [];
                        for "_i" from 0 to ((count _flat) - 2) step 2 do {
                            private _q = [_flat select _i, _flat select (_i + 1)] call _fnc_toShip;
                            if (count _prev > 0) then { _taxi pushBack [_prev, _q] };
                            _prev = _q;
                        };
                    } forEach ["ilsTaxiIn", "ilsTaxiOff", "ilsTaxiOn"];
                };

                // The sweep. Every offset on the ship's own footprint is asked
                // whether the deck is under it at the deck's own level, which
                // is what rules out the island, the deck edge and the hangar
                // roof without any of them being named.
                private _ranked = [];
                if (_deckZ > -9000) then {
                    for "_mx" from -DECK_REACH_X to DECK_REACH_X step DECK_STEP_X do {
                        for "_my" from -DECK_REACH_Y to DECK_REACH_Y step DECK_STEP_Y do {
                            private _w = _ship modelToWorld [_mx, _my, 0];
                            private _flat = [_w select 0, _w select 1, 0];
                            ([_logic, "deckTop", [_flat, []]] call MAINCLASS) params ["_tz", "_to"];
                            private _isDeck = _tz > -9000
                                && {(abs (_tz - _deckZ)) <= DECK_BAND}
                                && {!isNull _to}
                                && {(_to isEqualTo _ship)
                                    || {(typeOf _to) in _partClasses}
                                    || {_to isKindOf "StaticShip"}};
                            if (_isDeck) then {
                                private _q = [_mx, _my, 0];
                                private _dLand = 9999;
                                if (count _landA > 1) then {
                                    _dLand = [_q, _landA, _landB] call _fnc_segDist;
                                };
                                private _dTaxi = 9999;
                                {
                                    private _d = [_q, _x select 0, _x select 1] call _fnc_segDist;
                                    if (_d < _dTaxi) then { _dTaxi = _d };
                                } forEach _taxi;
                                if (_dLand >= DECK_LAND_CLEAR && {_dTaxi >= DECK_TAXI_CLEAR}) then {
                                    // Farthest from the strip first, as a
                                    // plain array so the engine's own sort
                                    // does the ordering.
                                    _ranked pushBack [-_dLand, _mx, _my];
                                };
                            };
                        };
                    };
                };
                _ranked sort true;
                private _spots = _ranked apply { [_x select 1, _x select 2] };

                // Timed because this is hundreds of traces in one go and a
                // caller may be unscheduled, in which case they all land in
                // one frame. It happens once per ship and the answer is kept.
                ["ALIVE_fnc_ATOSurface - %1: deck at %2 m, %3 parking offsets, %4 taxi segments, worked out in %5 ms",
                    typeOf _ship, round _deckZ, count _spots, count _taxi,
                    round (((diag_tickTime - _began) * 1000))] call ALiVE_fnc_dump;

                _result = [_deckZ, _landA, _landB, _taxi, _spots, _partClasses];
                [_decks, _key, _result] call ALIVE_fnc_hashSet;
            };
        };
    };

    // The deck's acceptance test, and deliberately NOT the terrain one. Every
    // clause of spotIsClear is wrong over a ship: the deck is over water, the
    // deck edge is a road segment, isFlatEmpty answers about the sea bed forty
    // metres below, and the island and the hangar are Buildings that the test
    // would either refuse the whole ship for or walk straight through.
    //
    // What replaces them is geometry. Nine rays over the footprint all have to
    // find the deck at the deck's own level: over the edge there is nothing, on
    // the island the first thing they meet is twenty-five metres too high, and
    // under a parked aircraft it is a parked aircraft.
    case "deckSpotIsClear": {
        _args params [
            ["_p",[0,0,0],[[]]],
            ["_span",12,[0]],
            ["_ignore",[],[[]]],
            ["_ship",objNull,[objNull]]
        ];
        _result = false;
        if (isNull _ship) then {
            _ship = (nearestObjects [_p, ["StaticShip"], SHIP_SEARCH]) param [0, objNull];
        };
        if (!isNull _ship) then {
            private _geom = [_logic, "deckGeometry", _ship] call MAINCLASS;
            if (_geom isEqualType [] && {count _geom > 5}) then {
                _geom params ["_deckZ", "_landA", "_landB", "_taxi", "_spots", "_partClasses"];
                private _ok = _deckZ > -9000;
                private _diag = (_span * 0.7);
                private _rays = [
                    [0,0],
                    [_span,0], [0,_span], [-_span,0], [0,-_span],
                    [_diag,_diag], [_diag,-_diag], [-_diag,_diag], [-_diag,-_diag]
                ];
                {
                    if (_ok) then {
                        private _q = [(_p select 0) + (_x select 0), (_p select 1) + (_x select 1), 0];
                        ([_logic, "deckTop", [_q, _ignore]] call MAINCLASS) params ["_tz", "_to"];
                        if (_tz < -9000
                            || {(abs (_tz - _deckZ)) > DECK_BAND}
                            || {isNull _to}
                            || {!((_to isEqualTo _ship)
                                  || {(typeOf _to) in _partClasses}
                                  || {_to isKindOf "StaticShip"})}) then {
                            _ok = false;
                        };
                    };
                } forEach _rays;

                // Off the strip and off the taxi lanes, asked in the ship's
                // model space where the geometry lives.
                if (_ok) then {
                    private _m = _ship worldToModel [_p select 0, _p select 1, _p select 2];
                    private _q = [_m select 0, _m select 1, 0];
                    if (count _landA > 1 && {([_q, _landA, _landB] call _fnc_segDist) < DECK_LAND_CLEAR}) then {
                        _ok = false;
                    };
                    if (_ok) then {
                        {
                            if (_ok && {([_q, _x select 0, _x select 1] call _fnc_segDist) < DECK_TAXI_CLEAR}) then {
                                _ok = false;
                            };
                        } forEach _taxi;
                    };
                };

                // And nothing standing there that nine rays slipped between.
                if (_ok) then {
                    private _busy = (nearestObjects [_p, ["Air","LandVehicle","Man"], _span]) select {
                        private _cand = _x;
                        alive _cand && {(_ignore findIf {_x isEqualTo _cand}) == -1}
                    };
                    if (count _busy > 0) then { _ok = false };
                };

                _result = _ok;
            };
        };
    };

    case "cascade": {
        _args params [
            ["_surface","terrain",[""]],
            ["_class","",[""]],
            ["_anchor",[0,0,0],[[]]],
            ["_reserved",[],[[]]]
        ];

        // A deck has no rings and no tiers. The parking offsets are already
        // worked out and ranked for the ship, so the search is a walk down that
        // list taking the first one nothing has claimed.
        if (_surface isEqualTo "deck") exitWith {
            private _ship = (nearestObjects [_anchor, ["StaticShip"], SHIP_SEARCH]) param [0, objNull];
            if (isNull _ship) then {
                ["ALIVE_fnc_ATOSurface - a deck home was asked for at %1 and there is no ship within %2 m",
                    _anchor, SHIP_SEARCH] call ALiVE_fnc_dump;
                _result = [];
            } else {
                // Same union as the terrain half: spots this surface has
                // already promised count as taken whether or not the caller
                // remembered to pass them.
                private _held = [_logic, "reservations", []] call ALIVE_fnc_hashGet;
                {
                    if (!(_x in _reserved)) then { _reserved pushBack _x };
                } forEach _held;

                private _bb = [_class] call ALiVE_fnc_getVehicleBoundingBox;
                private _span = ((((_bb select 0) max (_bb select 1)) / 2) + 4) max 12;

                private _geom = [_logic, "deckGeometry", _ship] call MAINCLASS;
                private _deckZ = _geom param [0, -9999];
                private _spots = _geom param [4, []];
                private _handle = [_logic, "carrierHandle", _ship] call MAINCLASS;

                // No deck level, no home. Every position below is built on
                // that number, and writing a home at minus nine thousand
                // metres would be worse than answering with nothing.
                if (_deckZ < -9000) then {
                    ["ALIVE_fnc_ATOSurface - %1 is a ship whose deck level could not be read; no home given",
                        typeOf _ship] call ALiVE_fnc_dump;
                    _spots = [];
                };

                private _found = [];
                {
                    private _spot = _x;
                    if (count _found == 0) then {
                        private _w = _ship modelToWorld [_spot select 0, _spot select 1, 0];
                        private _p = [_w select 0, _w select 1, _deckZ];
                        private _clashes = (_reserved findIf {
                            (_p distance2D (_x select 0)) < (_span + ((_x select 1) max 0))
                        }) > -1;
                        if (!_clashes && {[_logic, "deckSpotIsClear", [_p, _span, [], _ship]] call MAINCLASS}) then {
                            // The offset is what makes this home survive. The
                            // world position beside it is the value as it
                            // stands now, kept so that anything reading the
                            // first three entries of a home still works.
                            _found = [_p, getDir _ship, "deck", _handle,
                                [_spot select 0, _spot select 1, 0], 0];
                        };
                    };
                } forEach _spots;

                if (count _found == 0) then {
                    ["ALIVE_fnc_ATOSurface - no room on %1 for a %2: %3 offsets tried",
                        typeOf _ship, _class, count _spots] call ALiVE_fnc_dump;
                };
                _result = _found;
            };
        };

        // Spots this surface has already promised to somebody count as taken,
        // whether or not the caller remembered to pass them.
        //
        // Reservations were only ever read from the argument, so a caller that
        // wanted them honoured had to fetch the instance's own list and hand it
        // back in, which means reaching inside another piece to work out what
        // that piece already knows. Unioned here instead.
        private _held = [_logic, "reservations", []] call ALIVE_fnc_hashGet;
        {
            if (!(_x in _reserved)) then { _reserved pushBack _x };
        } forEach _held;

        // Span is HALF the longest dimension plus courtesy room, with a floor,
        // not the full dimension. Using the full length doubles every clearance
        // test and the search then finds almost nowhere on a real airfield.
        // "Wide" is judged on the true dimension, not on the span.
        private _bb = [_class] call ALiVE_fnc_getVehicleBoundingBox;
        private _longest = ((_bb select 0) max (_bb select 1));
        private _span = (((_longest / 2) + 4) max 12);
        private _wide = _longest >= 24;

        // Rings and step kept as they are: this search is stricter than the
        // replacements that were tried for it, and it is the rung that works.
        // A real pad first for anything with rotors, then apron, then field.
        // Never "auto": that tier animates hangar doors on every candidate it
        // looks at and takes an anti-race reservation, neither of which belongs
        // in a parking decision. It also hands back a heading pointing at the
        // runway, which beats facing along a taxiway.
        //
        // The pad rung matters for more than tidiness. The engine puts a
        // helicopter down on a pad whether or not that is where it was sent, so
        // a home chosen anywhere else is a home the aircraft will not land on,
        // and it then reads as away-from-home for the rest of its life. Asking
        // for a pad first makes the module's choice and the engine's choice the
        // same place. Asking for "apron" skipped the pad tier entirely, because
        // these rungs are selected by name (fnc_findAirSpawnPosition.sqf:844):
        // the airfield the aircraft kept landing on was never on offer.
        //
        // No class test needed here. That tier gates itself on rotary and
        // refuses drones by design, so a plane or a UAV gets [] back and falls
        // through to apron at the cost of one call.
        private _air = [];
        if (!isNil "ALiVE_fnc_findAirSpawnPosition") then {
            _air = [_class, _anchor, 400, "helipad"] call ALiVE_fnc_findAirSpawnPosition;
            if (count _air < 2) then {
                _air = [_class, _anchor, 400, "apron"] call ALiVE_fnc_findAirSpawnPosition;
            };
            if (count _air < 2) then {
                _air = [_class, _anchor, 400, "field"] call ALiVE_fnc_findAirSpawnPosition;
            };
            // A wide airframe fails both tiers on a cramped field and used to
            // fall through to a search that parks on a TAXIWAY, blocking every
            // departure. For those only, ask again with no courtesy room, then
            // over a wider area. Ordinary airframes keep the two rungs above
            // because these searches are not cheap.
            if (count _air < 2 && {_wide}) then {
                _air = [_class, _anchor, 400, "field", objNull, "", [], 0] call ALiVE_fnc_findAirSpawnPosition;
                if (count _air < 2) then {
                    _air = [_class, _anchor, 600, "field", objNull, "", [], 0] call ALiVE_fnc_findAirSpawnPosition;
                };
            };
        };

        // Take the airfield answer if there is one. This used to say
        //     if (!_taken) exitWith { _result = [...] };
        // and exitWith leaves the INNERMOST block, which here is the then-block
        // of the test above rather than this case. So the airfield position was
        // computed, assigned, and then thrown away by the ring search below,
        // every single time. Every home this function has ever returned was a
        // ring spot. Written as a plain flag now: no exitWith, nothing to get
        // wrong a second time.
        private _found = [];
        if (count _air >= 2) then {
            private _p = +(_air select 0);
            _p set [2, 0];
            private _taken = (_reserved findIf {
                (_p distance2D (_x select 0)) < (_span + ((_x select 1) max 0))
            }) > -1;
            // Asked the SAME question the ring search below is asked.
            //
            // The shared air-spawn search has its own idea of admissible, built
            // from the engine's airport data, and this piece has another, and
            // where they disagree the cascade was handing back a home that its
            // own predicate refused the moment anything asked again. The
            // surface test asserts exactly that they agree, on the grounds that
            // a spot which cannot answer for itself twice was never a spot, and
            // it was failing INTERMITTENTLY, which is worse than failing: the
            // ring and spiral searches place spots differently each run, so a
            // green run proved nothing.
            //
            // Validating here makes the promise structural instead of hopeful.
            // It is only safe to do now that the predicate waives its road test
            // on an airfield; before that, enforcing it here would have pushed
            // every home back off the field, which is the fault 480ae281 fixed.
            if (!_taken && {[_logic, "spotIsClear", [_p, _span]] call MAINCLASS}) then {
                _found = [_p, _air select 1, "terrain"];
            };
        };

        private _rings = if (_wide) then { [60,100,150,220,300,400,500,600] } else { [60,100,150,220] };
        private _spot = [];

        {
            private _ring = _x;
            // Skipped entirely when the airfield search already answered. Each
            // ring asks spotIsClear twelve times and that is not a cheap call.
            if (count _found == 0 && {count _spot == 0}) then {
                for "_a" from 0 to 330 step 30 do {
                    if (count _spot == 0) then {
                        private _p = _anchor getPos [_ring, _a];
                        _p set [2, 0];

                        // Anything already handed out this pass, plus anything a
                        // caller asked to be kept clear.
                        private _clashes = (_reserved findIf {
                            (_p distance2D (_x select 0)) < (_span + ((_x select 1) max 0))
                        }) > -1;

                        if (!_clashes && {[_logic, "spotIsClear", [_p, _span]] call MAINCLASS}) then {
                            _spot = _p;
                        };
                    };
                };
            };
        } forEach _rings;

        if (count _found > 0) then {
            _result = _found;
        } else {
            if (count _spot == 0) then {
                _result = [];
            } else {
                _result = [_spot, random 360, "terrain"];
            };
        };
    };

    // The acceptance test, on its own so it can be re-run as an oracle against
    // any position this ever returned. A spot that cannot pass this when asked
    // again was never a spot.
    case "spotIsClear": {
        // _ignore is the airframe that already lives here, and its crew. Without
        // it a home fails its own re-check the moment its aircraft is parked on
        // it, because the aircraft is an Air object inside the footprint.
        _args params [["_p",[0,0,0],[[]]], ["_span",12,[0]], ["_ignore",[],[[]]]];

        // Kinds are 1 runway, 2 taxiway, 3 parking (fnc_isAirside.sqf:40-41).
        // This asked for all three, so it refused the airfield's own parking
        // areas: the one surface an aircraft is supposed to sit on. Between that
        // and the discarded airfield result above, a home could only ever come
        // out as open terrain well away from the airfield, which is exactly what
        // it did. Runways and taxiways stay excluded, because parking on those
        // blocks departures.
        private _airside = false;
        if (!isNil "ALiVE_fnc_isAirside") then {
            _airside = [_p, _span, [1,2]] call ALiVE_fnc_isAirside;
        };

        // Test the footprint, not just the centre: a wingtip over the
        // carriageway is still parked on the road.
        private _onRoad = isOnRoad _p
            || {[0,90,180,270] findIf {isOnRoad (_p getPos [_span, _x])} > -1};

        // A taxiway, an apron and a runway are all ROAD segments, and they are
        // also the only surfaces an aircraft belongs on. So being on a road
        // disqualifies a spot only when that spot is not part of an airfield.
        //
        // Without this the predicate refused the airfield and the cascade's own
        // airfield rungs handed back spots it then rejected: measured, eight
        // homes from one anchor on Stratis and three refused for being on a
        // road, all three of them on the apron.
        //
        // The airfield is read from the TERRAIN, not from ALiVE's airfield
        // survey, because the survey only exists once a module is placed and
        // this has to answer the same way without one. ilsTaxiIn and ilsTaxiOff
        // are the taxi polylines and ilsPosition the runway threshold, all of
        // them plain config. Measured on Stratis: every apron home lies within
        // 150 m of that geometry, a village road 3 km off lies 2155 m from it
        // and open ground 2 km east 1974 m, so the two cases are nowhere near
        // each other.
        //
        // Three things this gets right that the obvious alternatives do not.
        // nearestLocations ["Airport"] is EMPTY on Stratis, so locations are no
        // use. Road class and width are no use either: the apron's segments
        // report a blank class and width 0 while a real road 2 km away reports
        // 10. And the distance has to be to the nearest SEGMENT rather than the
        // nearest listed point, because the polyline is sparse: two consecutive
        // Stratis taxi points are 905 m apart, so the middle of that stretch is
        // 450 m from either end and a point test would call the runway open
        // country.
        if (_onRoad) then {
            // Cached per world. This is pure terrain config, identical for
            // every instance and every call, and one cascade asks this dozens
            // of times.
            if (isNil "ALiVE_ATO_airfieldGeometry"
                || {!((ALiVE_ATO_airfieldGeometry param [0,""]) isEqualTo worldName)}) then {
                private _segs = [];
                private _pts = [];
                private _fnc_line = {
                    params ["_flat"];
                    private _prev = [];
                    for "_i" from 0 to ((count _flat) - 2) step 2 do {
                        private _q = [_flat select _i, _flat select (_i + 1), 0];
                        if (count _prev > 0) then { _segs pushBack [_prev, _q] };
                        _prev = _q;
                    };
                };
                private _fnc_field = {
                    params ["_cfg"];
                    [getArray (_cfg >> "ilsTaxiIn")] call _fnc_line;
                    [getArray (_cfg >> "ilsTaxiOff")] call _fnc_line;
                    private _ils = getArray (_cfg >> "ilsPosition");
                    if (count _ils >= 2) then {
                        _pts pushBack [_ils select 0, _ils select 1, 0];
                    };
                };
                private _world = configFile >> "CfgWorlds" >> worldName;
                [_world] call _fnc_field;
                // Every airfield, not just the main one. Stratis has no
                // secondary airports; Altis and most large terrains do, and
                // their taxi geometry lives under their own entries.
                private _secondary = _world >> "SecondaryAirports";
                for "_i" from 0 to ((count _secondary) - 1) do {
                    [_secondary select _i] call _fnc_field;
                };
                ALiVE_ATO_airfieldGeometry = [worldName, _segs, _pts];
            };

            private _segs = ALiVE_ATO_airfieldGeometry select 1;
            private _pts = ALiVE_ATO_airfieldGeometry select 2;
            private _reach = 200;
            private _fnc_toSeg = {
                params ["_q", "_a", "_b"];
                private _ax = _a select 0;
                private _ay = _a select 1;
                private _dx = (_b select 0) - _ax;
                private _dy = (_b select 1) - _ay;
                private _len2 = (_dx * _dx) + (_dy * _dy);
                if (_len2 <= 0) exitWith { _q distance2D _a };
                private _t = ((((_q select 0) - _ax) * _dx) + (((_q select 1) - _ay) * _dy)) / _len2;
                _t = (_t max 0) min 1;
                _q distance2D [_ax + (_t * _dx), _ay + (_t * _dy), 0]
            };

            private _onField = (_pts findIf { (_p distance2D _x) < _reach }) > -1;
            if (!_onField) then {
                _onField = (_segs findIf { ([_p, _x select 0, _x select 1] call _fnc_toSeg) < _reach }) > -1;
            };
            if (_onField) then { _onRoad = false };
        };

        _result = !_airside
            && {!_onRoad}
            && {!surfaceIsWater _p}
            && {(count (_p isFlatEmpty [-1, -1, 0.3, _span, 0, false, objNull])) > 0}
            // A landing pad is a surface to park on, not something to stand
            // clear of, and pads classify as buildings. Anything else built
            // inside the footprint still refuses the spot.
            && {(nearestObjects [_p, ["House","Building"], _span]) findIf {!(_x isKindOf "HeliH")} == -1}
            && {(count (nearestTerrainObjects [_p, CLUTTER, _span, false, true])) == 0}
            && {((nearestObjects [_p, ["Air"], _span + 6]) select {
                    private _cand = _x;
                    (_ignore findIf {_x isEqualTo _cand}) == -1
                }) isEqualTo []};
    };

    // Geometry re-run as an oracle, plus occupancy: the spot may have been fine
    // when it was chosen and have something parked on it now.
    case "validate": {
        _args params [
            ["_home",[],[[]]],
            ["_class","",[""]],
            ["_ownObj",objNull,[objNull]]
        ];

        if (count _home < 3) exitWith { _result = [false, "no home"] };
        // The deck answers the same three ways the terrain half does, so a
        // caller can tell "find another home" from "wait", and adds a fourth
        // that only a ship can give: the ship itself is gone.
        if ((_home select 2) isEqualTo "deck") exitWith {
            private _ship = [_logic, "carrierFor", _home param [3, []]] call MAINCLASS;
            if (isNull _ship) then {
                _result = [false, "carrier gone"];
            } else {
                private _pos = ([_logic, "resolve", _home] call MAINCLASS) select 0;
                private _bbD = [_class] call ALiVE_fnc_getVehicleBoundingBox;
                private _spanD = ((((_bbD select 0) max (_bbD select 1)) / 2) + 4) max 12;
                private _ownD = [_ownObj];
                if (!isNull _ownObj) then { _ownD append (crew _ownObj) };
                private _intrudersD = (nearestObjects [_pos, ["Air","LandVehicle","Man"], _spanD]) select {
                    private _cand = _x;
                    alive _cand && {(_ownD findIf {_x isEqualTo _cand}) == -1}
                };
                if (count _intrudersD > 0) then {
                    _result = [false, "occupied"];
                } else {
                    if ([_logic, "deckSpotIsClear", [_pos, _spanD, _ownD, _ship]] call MAINCLASS) then {
                        _result = [true, ""];
                    } else {
                        _result = [false, "geometry"];
                    };
                };
            };
        };

        private _pos = _home select 0;
        private _bb = [_class] call ALiVE_fnc_getVehicleBoundingBox;
        private _span = ((((_bb select 0) max (_bb select 1)) / 2) + 4) max 12;

        // This airframe and whoever is riding in it are not obstructions to it.
        private _own = [_ownObj];
        if (!isNull _ownObj) then { _own append (crew _ownObj) };

        // Occupancy is asked FIRST. Something parked on a spot also defeats the
        // flat-and-empty geometry test, so asking geometry first reports
        // "geometry" for a home whose real problem is that a truck is sitting on
        // it, and the caller needs the difference: geometry means find another
        // home, occupied means wait, or move whatever is in the way.
        // The candidate is held in its own name: the findIf below rebinds _x,
        // so comparing against _x inside it would compare a thing with itself.
        private _intruders = (nearestObjects [_pos, ["Air","LandVehicle","Man"], _span]) select {
            private _cand = _x;
            alive _cand && {(_own findIf {_x isEqualTo _cand}) == -1}
        };
        if (count _intruders > 0) exitWith { _result = [false, "occupied"] };

        if !([_logic, "spotIsClear", [_pos, _span, _own]] call MAINCLASS) exitWith {
            _result = [false, "geometry"];
        };

        _result = [true, ""];
    };

    case "resolve": {
        private _home = _args;
        if (count _home < 3) exitWith { _result = [[0,0,0], 0] };
        // A deck position is WORKED OUT, never read back. The offset and the
        // relative heading are what the record holds; where that is in the
        // world depends on where the ship is, and the whole reason the old
        // module could not put an aircraft back on a carrier after a reload is
        // that it stored the world position and trusted it.
        //
        // The height is the deck's own level rather than a fresh trace,
        // because a trace at the spot hits whatever is parked there and would
        // answer with the roof of an aircraft.
        if ((_home select 2) isEqualTo "deck") exitWith {
            private _ship = [_logic, "carrierFor", _home param [3, []]] call MAINCLASS;
            if (isNull _ship) then {
                ["ALIVE_fnc_ATOSurface - the carrier a deck home belongs to is not here, so it has no position"] call ALiVE_fnc_dump;
                _result = [[0,0,0], 0];
            } else {
                private _off = _home param [4, [0,0,0]];
                private _rel = _home param [5, 0];
                if !(_off isEqualType []) then { _off = [0,0,0] };
                if !(_rel isEqualType 0) then { _rel = 0 };
                private _w = _ship modelToWorld [_off param [0,0], _off param [1,0], 0];
                private _z = ([_logic, "deckGeometry", _ship] call MAINCLASS) param [0, -9999];
                if (_z < -9000) then {
                    _z = ([_logic, "deckTop", [[_w select 0, _w select 1, 0], []]] call MAINCLASS) select 0;
                };
                if (_z < -9000) then { _z = 0 };
                _result = [[_w select 0, _w select 1, _z], ((getDir _ship) + _rel) mod 360];
            };
        };
        // Terrain homes are above terrain level, and a copy, so a caller cannot
        // edit the home by editing what it was handed.
        _result = [+(_home select 0), _home select 1];
    };

    case "atHome": {
        _args params [["_obj",objNull,[objNull]], ["_home",[],[[]]]];
        if (isNull _obj || {count _home < 3}) exitWith { _result = false };
        // A helicopter is home anywhere on its pad; a plane has to be on its
        // spot. The wider figure is what another module calibrates against.
        // A deck home's world position is derived, not read: the stored one was
        // right when the home was chosen.
        private _at = _home select 0;
        if ((_home select 2) isEqualTo "deck") then {
            _at = ([_logic, "resolve", _home] call MAINCLASS) select 0;
        };
        private _tolerance = if (_obj isKindOf "Plane") then { 15 } else { 30 };
        _result = (_obj distance2D _at) < _tolerance;
    };

    // Put an airframe on its home and make sure it survives arriving there.
    case "place": {
        _args params [["_obj",objNull,[objNull]], ["_home",[],[[]]]];
        if (isNull _obj || {count _home < 3}) exitWith { _result = false };

        // Never onto a player, and never on a machine that does not own the
        // object: a position set from the wrong place simply does not apply.
        if ({isPlayer _x} count (crew _obj) > 0) exitWith {
            ["ALIVE_fnc_ATOSurface - place refused for %1: a player is aboard", typeOf _obj] call ALiVE_fnc_dump;
            _result = false;
        };
        if (!local _obj) exitWith {
            ["ALIVE_fnc_ATOSurface - place refused for %1: object is not local", typeOf _obj] call ALiVE_fnc_dump;
            _result = false;
        };
        if ((_home select 2) isEqualTo "deck") exitWith {
            private _ship = [_logic, "carrierFor", _home param [3, []]] call MAINCLASS;
            if (isNull _ship) then {
                ["ALIVE_fnc_ATOSurface - %1 cannot be put on a deck: its carrier is not here", typeOf _obj] call ALiVE_fnc_dump;
                _result = false;
            } else {
                ([_logic, "resolve", _home] call MAINCLASS) params ["_targetD", "_dirD"];
                private _mineD = [_obj] + (crew _obj);
                private _reachD = 12;
                private _bbD = [typeOf _obj] call ALiVE_fnc_getVehicleBoundingBox;
                if (count _bbD > 1) then {
                    _reachD = (((((_bbD select 0) max (_bbD select 1)) / 2) + 4) max 12);
                };
                private _blockedD = (nearestObjects [_targetD, ["Air"], _reachD]) select {
                    private _cand = _x;
                    (_mineD findIf {_x isEqualTo _cand}) == -1 && {alive _cand}
                };
                if (count _blockedD > 0) then {
                    ["ALIVE_fnc_ATOSurface - place refused for %1: %2 is already on that deck spot",
                        typeOf _obj, typeOf (_blockedD select 0)] call ALiVE_fnc_dump;
                    _result = false;
                } else {
                    _obj allowDamage false;
                    if (_dirD >= 0) then { _obj setDir _dirD };
                    // ASL, and a hand's breadth clear of the plating.
                    // setPosATL over water measures from the SEA BED, which on
                    // the scene this was measured against is forty metres
                    // down, so the terrain half's write would drop an airframe
                    // through the ship and into the sea.
                    _obj setPosASL [_targetD select 0, _targetD select 1, (_targetD select 2) + 0.4];
                    // Level, and here that is right: plating is level, and the
                    // surface normal over water answers about the sea rather
                    // than about the ship standing on it.
                    _obj setVectorUp [0,0,1];
                    _obj setVelocity [0,0,0];

                    // Damage stays off until it has settled, and on a deck
                    // "settled" is measured against the deck rather than
                    // against terrain level: over water terrain level is the
                    // sea bed and every airframe would read as forty metres up.
                    [_obj, _targetD] spawn {
                        params ["_v", "_tgt"];
                        sleep 8;
                        if (isNull _v || {!alive _v}) exitWith {};
                        private _off = ((getPosASL _v) select 2) - (_tgt select 2);
                        if (_off < -3 || {_off > 3.5}) then {
                            _v allowDamage false;
                            ["ALIVE_fnc_ATOSurface - %1 settled %2 m off its deck spot, damage left off",
                                typeOf _v, round _off] call ALiVE_fnc_dump;
                        } else {
                            _v allowDamage true;
                            _v setDamage 0;
                        };
                    };

                    _result = true;
                };
            };
        };

        // A COPY. One caller used to hand in the stored home itself, and the
        // grounding write below then landed in the record, so the home crept
        // sideways a little further every time the airframe came back.
        private _target = +(_home select 0);
        // Terrain level. A hangar-parked airframe stores the building's own
        // elevated origin, and placing at that height puts it in the roof.
        _target set [2, 0];

        // Is the stand already occupied?
        //
        // Nothing asked, and nothing needed to while one aircraft was being
        // tested. With several sharing an airfield this puts one hull inside
        // another and destroys both, which is a recorded fault of the module
        // being replaced. Asked here rather than at the caller because every
        // path that moves an airframe onto its home comes through this one.
        //
        // Only occupancy, not the full clearance test: the home was already
        // judged for geometry when it was chosen, and re-running that here
        // would refuse a perfectly good stand for a reason that has not
        // changed since. The aircraft being placed and its own crew are not
        // obstacles to themselves.
        private _mine = [_obj] + (crew _obj);
        private _reach = 12;
        private _bb = [typeOf _obj] call ALiVE_fnc_getVehicleBoundingBox;
        if (count _bb > 1) then {
            _reach = (((((_bb select 0) max (_bb select 1)) / 2) + 4) max 12);
        };
        private _blocked = (nearestObjects [_target, ["Air"], _reach]) select {
            private _cand = _x;
            (_mine findIf {_x isEqualTo _cand}) == -1 && {alive _cand}
        };
        if (count _blocked > 0) exitWith {
            ["ALIVE_fnc_ATOSurface - place refused for %1: %2 is already on that stand",
                typeOf _obj, typeOf (_blocked select 0)] call ALiVE_fnc_dump;
            _result = false;
        };

        private _dir = _home select 1;

        _obj allowDamage false;
        if (_dir >= 0) then { _obj setDir _dir };
        _obj setPosATL _target;
        // Seated on the ground it is standing on, not forced level.
        //
        // A level hull on sloping ground is an attitude the ground disagrees
        // with: one side of the undercarriage ends up buried and the other in
        // the air, and the engine settles the argument by pushing the aircraft
        // out of the ground. It then slides until it reaches somewhere the
        // wrong attitude happens to fit.
        //
        // Measured at [1893, 6146] on Stratis, a shoulder with about ten
        // degrees of tilt and nothing at all in the way: forced level it was
        // doing 11 km/h within one second and came to rest 11.5 m away, twice
        // out of two tries, its attitude visibly drifting onto the real slope
        // as it went. Seated on the surface it stayed at 0.6 m and never moved,
        // twice out of two. On the airfield itself the same spot could throw an
        // aircraft 16 m.
        //
        // Past 15 m a plane reads as away from its home, and a home an
        // aircraft is never at is a home it spends the rest of the mission
        // trying to return to. That is the fault this whole piece exists to
        // prevent, and it was the last failing check in the set: it looked
        // intermittent only because the search reaches ground like this for
        // the eighth aircraft and rarely for the first.
        //
        // The steepness is not the measure, by the way. A spot with 5.8 m of
        // fall across the same footprint did not move an aircraft at all.
        // What matters is whether the attitude being forced disagrees with
        // the ground, not how steep the ground is.
        _obj setVectorUp (surfaceNormal [_target select 0, _target select 1, 0]);
        _obj setVelocity [0,0,0];

        // Damage stays off until the airframe has actually settled. Re-arming
        // on a frame still clipping something is what destroyed them eight
        // seconds later, and the old check read damage, which allowDamage false
        // had already forced to zero, so it always re-armed.
        [_obj, _target] spawn {
            params ["_v", "_tgt"];
            sleep 8;
            if (isNull _v || {!alive _v}) exitWith {};
            private _z = (getPosATL _v) select 2;
            if (_z > 3.5) then {
                _v allowDamage false;
                ["ALIVE_fnc_ATOSurface - %1 still %2 m up after settling, damage left off", typeOf _v, round _z] call ALiVE_fnc_dump;
            } else {
                _v allowDamage true;
                _v setDamage 0;
            };
        };

        _result = true;
    };

    // ---- the runway lock ------------------------------------------------
    // Every lock has an owner and an expiry. A lock with neither is how a queue
    // wedges behind an airframe that never left.

    case "lock": {
        _args params [["_key","",[""]], ["_tail","",[""]], ["_expiresAt",0,[0]]];
        private _locks = [_logic,"locks"] call ALIVE_fnc_hashGet;
        private _held = [_locks,_key,[]] call ALIVE_fnc_hashGet;

        if (!(_held isEqualTo []) && {(_held select 0) != _tail} && {(_held select 1) > time}) exitWith {
            _result = false;
        };
        [_locks,_key,[_tail,_expiresAt]] call ALIVE_fnc_hashSet;
        _result = true;
    };

    case "unlock": {
        private _tail = _args;
        private _locks = [_logic,"locks"] call ALIVE_fnc_hashGet;
        // Both copied before the loop. Removing a key shortens the live values
        // array, so indexing it by position mid-loop reads the wrong entry.
        private _keys = + (_locks select 1);
        private _values = + (_locks select 2);
        private _drop = [];
        {
            if (((_values select _forEachIndex) select 0) isEqualTo _tail) then { _drop pushBack _x };
        } forEach _keys;
        { [_locks,_x] call ALIVE_fnc_hashRem } forEach _drop;
        _result = true;
    };

    // Every runway booking, moved by the same amount.
    //
    // A lock expires by comparing its own time against the mission clock, and
    // that clock keeps running while the module is paused. Without this, the
    // first tick after un-pausing finds every lock long expired and hands the
    // runway to whoever asks next, while the aircraft that actually holds it is
    // still sitting on it.
    case "shiftLocks": {
        private _delta = _args;
        if !(_delta isEqualType 0) exitWith { _result = 0 };
        private _locks = [_logic,"locks"] call ALIVE_fnc_hashGet;
        private _moved = 0;
        {
            private _lock = [_locks, _x, []] call ALIVE_fnc_hashGet;
            if (count _lock > 1) then {
                [_locks, _x, [_lock select 0, (_lock select 1) + _delta]] call ALIVE_fnc_hashSet;
                _moved = _moved + 1;
            };
        } forEach (_locks select 1);
        _result = _moved;
    };

    case "holder": {
        private _locks = [_logic,"locks"] call ALIVE_fnc_hashGet;
        private _held = [_locks,_args,[]] call ALIVE_fnc_hashGet;
        _result = if (_held isEqualTo []) then { "" } else { _held select 0 };
    };

    // Releases every lock whose holder is gone or whose time is up. Called on a
    // tick, so a lock can never outlive the thing that took it.
    case "reconcileLocks": {
        private _live = _args;
        private _locks = [_logic,"locks"] call ALIVE_fnc_hashGet;
        private _keys = + (_locks select 1);
        private _values = + (_locks select 2);
        private _released = 0;
        {
            private _key = _x;
            private _held = _values select _forEachIndex;
            private _tail = _held select 0;
            private _expiry = _held select 1;
            if ((_live findIf {_x isEqualTo _tail}) == -1 || {_expiry <= time}) then {
                [_locks,_key] call ALIVE_fnc_hashRem;
                _released = _released + 1;
                ["ALIVE_fnc_ATOSurface - released %1 held by %2: %3", _key, _tail,
                    if ((_live findIf {_x isEqualTo _tail}) == -1) then {"holder gone"} else {"expired"}] call ALiVE_fnc_dump;
            };
        } forEach _keys;
        _result = _released;
    };

    // ---- pads and reservations ------------------------------------------

    case "stampPad": {
        _args params [["_home",[],[[]]], ["_tail","",[""]]];
        if (count _home < 3) exitWith { _result = objNull };
        private _pads = [_logic,"pads"] call ALIVE_fnc_hashGet;

        private _existing = [_pads,_tail,objNull] call ALIVE_fnc_hashGet;
        if (!isNull _existing) exitWith { _result = _existing };

        private _pad = createVehicle ["Land_HelipadEmpty_F", _home select 0, [], 0, "CAN_COLLIDE"];
        _pad setPosATL [(_home select 0) select 0, (_home select 0) select 1, 0];
        // Stamped so the shared air-spawn search knows the spot is spoken for.
        _pad setVariable ["ALiVE_atoStamped", true, true];
        [_pads,_tail,_pad] call ALIVE_fnc_hashSet;
        _result = _pad;
    };

    // The object an aircraft is told to land on.
    //
    // A helicopter cannot be sent to a coordinate to land. There is no landing
    // waypoint type in this engine, which cost a week of runs to establish:
    // setWaypointType "LAND" is accepted and silently does nothing, leaving a
    // waypoint with no type, which is no order at all, and the aircraft hovers
    // until something else puts it down. The only working idiom is landAt, and
    // landAt takes an OBJECT. Logistics lands every one of its helicopters this
    // way, at forty-two call sites, and never once with a waypoint.
    //
    // Preferring the terrain's own pad was tried first, to avoid creating
    // objects at all, and it is the paragraph below that replaced it. The
    // reasoning is kept because the conclusion is not obvious: the tidier
    // idiom is the one that does not work.
    case "padFor": {
        _args params [["_home",[],[[]]], ["_tail","",[""]]];
        if (count _home < 3) exitWith { _result = objNull };

        // ALWAYS our own pad, never the map's.
        //
        // This used to prefer a real HeliH within three metres of the home, to
        // avoid creating objects. It does avoid that, and it does not work:
        // handed one of the terrain's own pads, landAt issues no command at all
        // (measured, currentCommand empty for the whole descent) and the
        // aircraft simply sinks wherever its last order left it, 26 to 38 m
        // from the pad it was aimed at. Every landing that looked like it was
        // working was the height floor letting it down, not the landing order
        // placing it.
        //
        // Logistics lands helicopters at forty-two sites and creates a fresh
        // Land_HelipadEmpty_F at every one of them, never passing a map object.
        // That is the only idiom in this codebase demonstrated to work, so do
        // that. The pad is deleted by releaseApproach when the approach ends,
        // whatever ended it, so it cannot outlive the state that needed it.
        _result = [_logic, "stampPad", [_home, _tail]] call MAINCLASS;
    };

    case "unstampPad": {
        private _pads = [_logic,"pads"] call ALIVE_fnc_hashGet;
        private _pad = [_pads,_args,objNull] call ALIVE_fnc_hashGet;
        if (!isNull _pad) then { deleteVehicle _pad };
        [_pads,_args] call ALIVE_fnc_hashRem;
        _result = true;
    };

    case "reserve": {
        _args params [["_pos",[0,0,0],[[]]], ["_radius",0,[0]]];
        private _res = [_logic,"reservations"] call ALIVE_fnc_hashGet;
        _res pushBack [+_pos, _radius];
        _result = count _res;
    };

    case "clearReservations": {
        [_logic,"reservations",[]] call ALIVE_fnc_hashSet;
        _result = true;
    };

    // Re-announce a home to the shared air spawn search so nothing else is
    // given the spot while the airframe is away flying.
    case "keepAlive": {
        _args params [["_home",[],[[]]], ["_tail","",[""]]];
        if (count _home < 3) exitWith { _result = false };
        if (isNil "ALiVE_airSpawnRegistry") then { ALiVE_airSpawnRegistry = [] };
        // Four elements, matching what the search itself writes and prunes.
        ALiVE_airSpawnRegistry pushBack [+(_home select 0), _tail, time, _tail];
        _result = true;
    };

    default {
        _result = [_logic, _operation, _args] call SUPERCLASS;
    };
};

TRACE_1("ATO Surface - output",_result);

_result;
