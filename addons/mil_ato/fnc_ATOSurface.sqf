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

A VIRTUAL home is three entries like a terrain one, [position, direction,
"virtual"], and needs no more: it is a point in the air at an ingress marker,
where a commander with no airfield holds its aircraft between sorties. Nothing
underneath it is read, so there is nothing to derive on read and nothing to go
stale. Its position is ASL.

Deck and virtual positions are ASL. Terrain positions are above terrain level
with the height zeroed. They cannot be mixed: above water, terrain level is the
SEA BED, so a height read the terrain way is about forty metres wrong, and over
deep water a held aircraft read that way is judged to be flying.

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

// Built things big enough that their walls reach ground their origin does not,
// measured by their real footprint rather than by where their origin is. The
// same list the shared stand search uses for its body pass
// (fnc_findAirSpawnPosition.sqf), and the same distance past the aircraft's own
// reach to go looking for them.
#define BODY_TYPES ["BUILDING","BUNKER","BUSSTOP","CHAPEL","CHURCH","FENCE","FORTRESS","FUELSTATION","HIDE","HOSPITAL","HOUSE","LIGHTHOUSE","POWERSOLAR","POWERWAVE","POWERWIND","QUAY","RAILWAY","RUIN","SHIPWRECK","STACK","TOURISM","TRANSMITTER","VIEW-TOWER","WALL","WATERTOWER","Wreck_Base"]
#define BODY_PAD 25

// How far a helicopter looks for a free pad. The other rungs look 400 m from
// their anchor, and a helicopter's anchor is a pad, so when that pad was taken
// the search could not see the rest of the airfield's pads. Measured on Stratis:
// an Apache anchored on a pad a Combat Support UH-1Y was already standing on
// found nothing within 400 m, while the airfield's free pads stood 597 and 754 m
// away, and it was parked against a hangar instead.
#define PAD_REACH 1000

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

// The catapults. A USS Freedom has four, declared as a Catapults class on the
// PART that carries each one (two hull parts carry one each, a third carries
// two), each with the memory point the shuttle sits at, the launch heading's
// offset from the part's own, and the deflector animations behind it.
//
// Two of the four are never offered. The old module found that a plane shot
// off the outer pair (pos_catapult_01 and pos_catapult_04) tends to crash on
// the way out, and that is not being re-measured here.
#define CATAPULT_EXCLUDED ["pos_catapult_01","pos_catapult_04"]
// A plane's centre within this of the launch point means the catapult is
// taken. The engine's own launch action uses the same figure; the old
// module's three metres missed a jet standing a fuselage off the point.
// How close something has to be to a catapult to be standing on it. Ten,
// matching the clearance deck parking is held to: the catapults sit on the
// taxi centrelines and a parked airframe is kept ten metres clear of those, so
// anything nearer than that is on the catapult rather than beside it. Fifteen
// counted a neighbour on its own stand as occupying the wire.
#define CATAPULT_BUSY 10

// How close to the runway centreline counts as ON the runway. Its half width
// plus a margin: measured, the runway reads 0 m and the nearest stand the
// search chooses reads 39 m, so twenty five separates them with room to spare
// and refuses no stand.
#define RUNWAY_CLEAR 25

// A base with no airfield. The hold points are a ring around the ingress
// marker: as many as any commander could want, since how many aircraft are
// actually created is the commander's own setting and not this file's business.
// The spacing is comfortably more than the widest airframe, because there is no
// ground here to be short of and nothing is gained by crowding.
#define VIRTUAL_SLOTS 12
#define VIRTUAL_SPACING 45
// How far above whatever is underneath an aircraft is held. Half a metre, and
// measured: a hull frozen there over open water does not move at all. Taken
// from sea level rather than terrain level so that a marker over deep water
// does not hold its fleet on the sea bed.
#define VIRTUAL_HOLD 0.5

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

// The runway, and how far a point is from it.
//
// Cached per world, because it is pure terrain config and identical for every
// instance and every call. Answers a large number when the terrain has no
// runway at all, so a caller that cannot find one simply never refuses
// anything for being on it.
//
// This exists because the shared airside test does not answer on every map.
// Measured on Stratis with its cache built: false at the middle of the runway,
// at radius thirty, for every kind. The terrain's own centreline is 0 m from
// the middle of the runway and from both thresholds, and 39 m or more from
// every stand the search chooses, so it discriminates where the other does
// not.
//
// Asked afresh each time rather than remembered here. The answer depends on
// where it is asked from, so one answer kept for the whole terrain was wrong:
// the first position this was asked about decided it for the rest of the
// mission, and one far from the field made every refusal below refuse nothing.
// The derivation keeps its own answer per area, so asking is cheap.
private _fnc_offRunway = {
    params ["_q"];
    private _line = [];
    if (!isNil "ALiVE_fnc_getRunwayCentreline") then {
        _line = [_q] call ALiVE_fnc_getRunwayCentreline;
    };
    if (!(_line isEqualType []) || {count _line < 2}) exitWith { 1e8 };
    private _a = _line select 0;
    private _b = _line select 1;
    if (!(_a isEqualType []) || {!(_b isEqualType [])}) exitWith { 1e8 };
    if (count _a < 2 || {count _b < 2}) exitWith { 1e8 };
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
            // Per carrier as well: which parts carry a catapult and where on
            // them it is. The parts do not move relative to the ship.
            ["catapults", [] call ALIVE_fnc_hashCreate],
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
    // How far a point is from the runway, and whether that is close enough to
    // count as standing on it. On its own so that nothing outside this file
    // has to know that the shared airside test cannot be relied on.
    case "runwayDistance": {
        _result = [_args] call _fnc_offRunway;
    };

    case "onRunway": {
        _result = ([_args] call _fnc_offRunway) < RUNWAY_CLEAR;
    };

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

    // ---- the catapults ----------------------------------------------------
    // Every catapult on one carrier, as [part, memoryPoint, dirOffset,
    // animations] entries, worked out once per ship and kept beside the deck.
    //
    // Walks the part CLASSES the deck geometry already reduced from the
    // config pairs, and for each class that declares a Catapults class finds
    // the live part object near the ship and reads each catapult off it by
    // index. The old module read the same config through a text property
    // walk and saw an empty dirOffset; getNumber is the read that fits a
    // number. Expected on a USS Freedom: two entries once the outer pair is
    // dropped, Catapult1 on Land_Carrier_01_hull_04_1_F (pos_catapult_02) and
    // Catapult3 on Land_Carrier_01_hull_07_1_F (pos_catapult_03).
    //
    // An empty answer is NOT cached. The parts are spawned by the hull's own
    // init and a question asked before they exist would otherwise be the
    // answer for the rest of the mission.
    case "catapults": {
        private _ship = _args;
        _result = [];
        if (!isNull _ship) then {
            private _cats = [_logic, "catapults", []] call ALIVE_fnc_hashGet;
            if !([_cats] call ALIVE_fnc_isHash) then {
                _cats = [] call ALIVE_fnc_hashCreate;
                [_logic, "catapults", _cats] call ALIVE_fnc_hashSet;
            };
            private _key = netId _ship;
            private _got = [_cats, _key, []] call ALIVE_fnc_hashGet;
            if (_got isEqualType [] && {count _got > 0}) then {
                _result = _got;
            } else {
                private _geom = [_logic, "deckGeometry", _ship] call MAINCLASS;
                private _partClasses = _geom param [5, []];
                if !(_partClasses isEqualType []) then { _partClasses = [] };
                // Each class once. A part class listed twice would otherwise
                // hand back its catapults twice.
                private _classes = [];
                { if (_x isEqualType "") then { _classes pushBackUnique _x } } forEach _partClasses;

                private _found = [];
                {
                    private _cls = _x;
                    private _catCfg = configFile >> "CfgVehicles" >> _cls >> "Catapults";
                    if (isClass _catCfg) then {
                        private _part = (nearestObjects [getPosASL _ship, [_cls], SHIP_SEARCH]) param [0, objNull];
                        if (!isNull _part) then {
                            for "_i" from 0 to ((count _catCfg) - 1) do {
                                private _c = _catCfg select _i;
                                if (isClass _c) then {
                                    private _mem = getText (_c >> "memoryPoint");
                                    if (!(_mem isEqualTo "") && {!(_mem in CATAPULT_EXCLUDED)}) then {
                                        _found pushBack [
                                            _part,
                                            _mem,
                                            getNumber (_c >> "dirOffset"),
                                            getArray (_c >> "animations")
                                        ];
                                    };
                                };
                            };
                        };
                    };
                } forEach _classes;

                if (count _found > 0) then {
                    [_cats, _key, _found] call ALIVE_fnc_hashSet;
                    ["ALIVE_fnc_ATOSurface - %1: %2 catapult(s) offered: %3",
                        typeOf _ship, count _found, _found apply { _x select 1 }] call ALiVE_fnc_dump;
                };
                _result = _found;
            };
        };
    };

    // Where a catapult's shuttle is in the world, ASL. Worked out fresh from
    // the part every time and never cached, for the same reason a deck home
    // resolves rather than reads: a ship that has moved between a save and a
    // reload must not hand back where its catapult used to be. The read is
    // the engine's own (fn_carrier01catapultid.sqf).
    case "catapultPos": {
        private _entry = _args;
        _result = [0,0,0];
        if (_entry isEqualType [] && {count _entry > 1}) then {
            private _part = _entry select 0;
            private _mem = _entry select 1;
            if (!isNull _part && {_mem isEqualType ""}) then {
                _result = _part modelToWorldWorld (_part selectionPosition _mem);
            };
        };
    };

    // The nearest catapult to a point that nothing is standing on, as the
    // entry with its world position appended: [part, memoryPoint, dirOffset,
    // animations, positionASL]. Empty when every catapult is taken.
    //
    // Occupancy is physical and current rather than a claim table. The
    // runway lock already makes launches one at a time per commander, and the
    // effect puts the aircraft on the catapult in the same call that chose
    // it, so the next question sees it there. What this catches is the other
    // thing: a player's aircraft sitting on a catapult. The aircraft asking
    // is passed in the ignore list so its own catapult counts as free.
    case "freeCatapult": {
        _args params [
            ["_ship",objNull,[objNull]],
            ["_from",[0,0,0],[[]]],
            ["_ignore",[],[[]]]
        ];
        _result = [];
        if (!isNull _ship) then {
            private _entries = [_logic, "catapults", _ship] call MAINCLASS;
            // Ranked by distance and read back by index, as plain numbers,
            // so the engine's own sort does the ordering and never has to
            // compare two entries that carry objects.
            private _ranked = [];
            {
                private _pos = [_logic, "catapultPos", _x] call MAINCLASS;
                _ranked pushBack [_from distance2D _pos, _forEachIndex];
            } forEach _entries;
            _ranked sort true;
            {
                if (count _result == 0) then {
                    private _entry = _entries select (_x select 1);
                    private _mem = _entry param [1, ""];
                    private _pos = [_logic, "catapultPos", _entry] call MAINCLASS;
                    private _busy = (nearestObjects [_pos, ["Plane"], CATAPULT_BUSY]) select {
                        private _cand = _x;
                        alive _cand && {(_ignore findIf {_x isEqualTo _cand}) == -1}
                    };

                    // And anything that has CLAIMED this catapult but has not
                    // reached it yet.
                    //
                    // Standing on it is not the only way to be using it. An
                    // aircraft is towed to the wire over as much as thirty
                    // seconds, and for all of that time it is still back on its
                    // stand with nothing near the catapult, so asking only what
                    // is standing there told a second aircraft the same wire was
                    // free. The claim lives on the aircraft, stamped the moment
                    // the wire is chosen and cleared when the launch ends or
                    // stands down, so there is no separate list to keep in step
                    // with reality.
                    if (count _busy == 0) then {
                        private _claimed = (nearestObjects [getPosASL _ship, ["Plane"], SHIP_SEARCH]) select {
                            private _cand = _x;
                            alive _cand
                            && {(_ignore findIf {_x isEqualTo _cand}) == -1}
                            && {(_cand getVariable ["ALiVE_mil_ato_catapult", ""]) isEqualTo _mem}
                            && {time < (_cand getVariable ["ALiVE_mil_ato_catapultUntil", -99999])}
                        };
                        if (count _claimed > 0) then { _busy = _claimed };
                    };

                    if (count _busy == 0) then { _result = _entry + [_pos] };
                };
            } forEach _ranked;
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

        // A virtual base has no ground to search, so there are no rings, no
        // tiers and no terrain tests: the only question a hold point can fail
        // is whether this commander has already promised it to somebody.
        if (_surface isEqualTo "virtual") exitWith {
            // The same union as the other two halves: points this surface has
            // already promised count as taken whether or not the caller
            // remembered to pass them.
            private _heldV = [_logic, "reservations", []] call ALIVE_fnc_hashGet;
            {
                if (!(_x in _reserved)) then { _reserved pushBack _x };
            } forEach _heldV;

            private _bbV = [_class] call ALiVE_fnc_getVehicleBoundingBox;
            private _spanV = 12;
            if (count _bbV > 1) then {
                _spanV = ((((_bbV select 0) max (_bbV select 1)) / 2) + 4) max 12;
            };

            // Spaced around a circle rather than along a line, so no aircraft
            // is ever behind another and the ring grows with the slot count
            // instead of the spacing shrinking.
            private _radiusV = VIRTUAL_SPACING max ((VIRTUAL_SPACING * VIRTUAL_SLOTS) / 6.2832);
            private _foundV = [];
            for "_i" from 0 to (VIRTUAL_SLOTS - 1) do {
                if (_foundV isEqualTo []) then {
                    private _bearing = (360 / VIRTUAL_SLOTS) * _i;
                    private _pV = [
                        (_anchor select 0) + ((sin _bearing) * _radiusV),
                        (_anchor select 1) + ((cos _bearing) * _radiusV),
                        0
                    ];
                    private _clashV = (_reserved findIf {
                        (_pV distance2D (_x select 0)) < (_spanV + ((_x select 1) max 0))
                    }) > -1;
                    if (!_clashV) then {
                        // Above the sea, or above the ground when the marker is
                        // on dry land, whichever is higher. Terrain level is
                        // NEGATIVE over water and holding at it would be
                        // holding on the sea bed.
                        private _floorV = ((getTerrainHeightASL _pV) max 0) + VIRTUAL_HOLD;
                        // Facing out from the marker, so a fleet released
                        // together does not fly through itself.
                        _foundV = [[_pV select 0, _pV select 1, _floorV], _bearing, "virtual"];
                    };
                };
            };

            if (_foundV isEqualTo []) then {
                ["ALIVE_fnc_ATOSurface - all %1 hold points at %2 are taken; no home given",
                    VIRTUAL_SLOTS, _anchor] call ALiVE_fnc_dump;
            };
            _result = _foundV;
        };

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
        // A real pad first for anything with rotors, then a hangar, then apron,
        // then field.
        //
        // The hangar rung was missing from the day this function took parking
        // over, and the search has no other way to reach it: the hangar tier is
        // offered only to "auto" or "hangar" and the old code got there by
        // asking for "auto". So every plane came down the rungs below it,
        // failed the pad tier for having no rotors, found no apron, and was
        // parked on grass by the field fallback with the hangars standing empty
        // beside it.
        //
        // Still not "auto", which would reach the hangar tier but bring the
        // whole cascade with it and hand back its own choice of rung. Named
        // instead, so the order here stays the order that runs.
        //
        // It does animate the doors of hangars it inspects and then rejects, so
        // a hangar can be left open with nothing in it. Cosmetic, and the
        // alternative is aircraft on the grass. The anti-race reservation the
        // old comment here also objected to is not the hangar tier's doing: it
        // is taken on any successful find (fnc_findAirSpawnPosition.sqf:1198),
        // so the apron and field rungs have always taken one too.
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
        // No class test needed on either of the first two rungs. The pad tier
        // gates itself on rotary and refuses drones, and the hangar tier takes
        // manned planes only, so each hands back [] for anything it does not
        // want and the next rung gets it, at the cost of one call.
        // Does getting there mean crossing the runway.
        //
        // The search has no idea which side of the field the commander is on,
        // so it could hand back a stand across the active runway from the
        // hangars. An aircraft then crossed the runway to reach its own
        // parking, and crossed it again on every departure, which is the one
        // thing parking is supposed to keep clear of.
        //
        // Asked by walking the straight line from the commander to the
        // candidate and asking the shared airside test whether any point on it
        // is runway. Kind 1 only: a taxiway is meant to be crossed.
        private _fnc_crossesRunway = {
            params ["_to"];
            private _crosses = false;
            private _len = _anchor distance2D _to;
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
                        // The terrain's own centreline, not the shared airside
                        // test. That test answers false everywhere on this map,
                        // so asking it made this whole preference inert: it
                        // could never find a crossing and so never preferred
                        // anything.
                        if (([_q] call _fnc_offRunway) < RUNWAY_CLEAR) then { _crosses = true };
                    };
                };
            };
            _crosses
        };

        private _air = [];
        if (!isNil "ALiVE_fnc_findAirSpawnPosition") then {
            // The rungs in their own order, and the first answer that does not
            // cross the runway wins. The first answer of all is kept as the
            // fallback, so nothing is lost when every rung is on the far side.
            private _fallback = [];
            {
                if (count _air < 2) then {
                    private _try = [_class, _anchor, if (_x isEqualTo "helipad") then { PAD_REACH } else { 400 }, _x] call ALiVE_fnc_findAirSpawnPosition;
                    if (count _try >= 2) then {
                        if (count _fallback < 2) then { _fallback = _try };
                        if !([_try select 0] call _fnc_crossesRunway) then {
                            _air = _try;
                        } else {
                            ["ALIVE_fnc_ATOSurface - the %1 stand for %2 is across the runway from the commander; trying further out",
                                _x, _class] call ALiVE_fnc_dump;
                        };
                    };
                };
            } forEach ["helipad", "hangar", "apron", "field"];
            if (count _air < 2 && {count _fallback >= 2}) then {
                ["ALIVE_fnc_ATOSurface - every stand found for %1 is across the runway; taking the nearest one anyway",
                    _class] call ALiVE_fnc_dump;
                _air = _fallback;
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
            // With the class, so a hangar bay the shared search chose is
            // judged as shelter, the way the home is judged every time it is
            // validated afterwards.
            if (!_taken && {[_logic, "spotIsClear", [_p, _span, [], _class]] call MAINCLASS}) then {
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

                        // With the class, for the aircraft's real reach, but
                        // no hangar counts as shelter here: a ring spot is
                        // parked at a random heading, and a jet turned across
                        // a tent hangar has its wings through the walls.
                        if (!_clashes && {[_logic, "spotIsClear", [_p, _span, [], _class, false]] call MAINCLASS}) then {
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
        // The class is optional. The shelter test uses it, and so does the
        // measure of how far the aircraft reaches. Without it a hangar is an
        // obstruction as it always was, which is what the deck callers want:
        // there are no hangars on a ship. _shelterOk false keeps a hangar an
        // obstruction even with the class, for a caller that does not line the
        // aircraft up with the hangar.
        _args params [["_p",[0,0,0],[[]]], ["_span",12,[0]], ["_ignore",[],[[]]], ["_class","",[""]], ["_shelterOk",true,[true]]];

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

        // A hangar the point is INSIDE is shelter, for the same reason a pad is:
        // it is somewhere to park, not something to stand clear of.
        //
        // Three separate conditions below refused a bay, and the aircraft was
        // evicted to the next ring because the caller reads any of them as
        // "geometry" rather than "occupied". Measured at a Stratis tent hangar:
        // the paving under it answers isOnRoad, the hangar answers the building
        // sweep, and it answers the clutter sweep as a terrain object too. Every
        // plane that won a bay was thrown out of it within seconds, and all five
        // ended up in a state where no order could be given to them.
        //
        // Only a hangar the point is actually within. One standing beside the
        // spot is a real obstruction and still refuses it, which is why this
        // measures the bounding box in the building's own axes rather than
        // taking whatever happens to be nearest.
        // AND the aircraft has to fit in it. The first version of this asked only
        // whether the point was inside a hangar, which told a V-44 at 38 m across
        // that a spot in a 21 m tent hangar was fine. The fit below is the same
        // one the hangar search applies before it ever awards a bay: longest
        // against longest, shortest against shortest, and the roof against the
        // tail. Without it this excuses hangars the aircraft could never use.
        private _shelter = [];
        if (!isNil "ALIVE_airBuildingTypes" && {!(_class isEqualTo "")} && {_shelterOk}) then {
            ([_class] call ALiVE_fnc_getVehicleBoundingBox) params [["_vLen", 0], ["_vWid", 0], ["_vHt", 0]];
            private _vLong  = _vLen max _vWid;
            private _vShort = _vLen min _vWid;
            // Hangars are looked for as far out as the walls test below looks,
            // because a tent hangar's origin is at its edge: one with a jet in
            // the middle of its bay can have its origin further off than the
            // span, and then its own walls would refuse the bay it was chosen
            // for. Being inside is decided by the box, so looking wider finds
            // more hangars to ask and excuses nothing new.
            {
                private _hh = _x;
                (boundingBoxReal _hh) params ["_bmin", "_bmax"];
                private _m = _hh worldToModel _p;
                if ((_m select 0) > (_bmin select 0) && {(_m select 0) < (_bmax select 0)}
                    && {(_m select 1) > (_bmin select 1)} && {(_m select 1) < (_bmax select 1)}
                ) then {
                    private _hd = _hh call BIS_fnc_boundingBoxDimensions;
                    private _hLong  = (_hd select 0) max (_hd select 1);
                    private _hShort = (_hd select 0) min (_hd select 1);
                    private _tooLow = (count _hd >= 3)
                        && {(_hd select 2) > 0 && {(_hd select 2) < _vHt}};
                    if (_hLong >= _vLong && {_hShort >= _vShort} && {!_tooLow}) then {
                        _shelter pushBack _hh;
                    };
                };
            } forEach ((nearestObjects [_p, ["House","Building"], _span + BODY_PAD]) select {
                private _t = toLower (typeOf _x);
                ALIVE_airBuildingTypes findIf { [_t, _x] call CBA_fnc_find != -1 } >= 0
            });
        };
        private _sheltered = count _shelter > 0;

        // Anything built whose WALLS come within the aircraft's reach,
        // wherever its origin is.
        //
        // The building tests below ask for objects whose origin lies within the
        // span, and a tent hangar's origin sits at one edge of it, not in the
        // middle. Measured at the stand an Apache was given on Stratis: two tent
        // hangars with their origins 17 and 20 m away, both outside the span,
        // and their walls 4.5 and 7.2 m from the spot. The rotor reaches about
        // seven, so it was parked with its blades over one of them, and they
        // came off when it started up. The shared stand search found the same
        // blind spot first and measures a building's real rotated footprint;
        // this does the same, at the aircraft's own reach and with no courtesy
        // margin, so no stand that search chose is refused here.
        //
        // The reach is that search's too: a rotor disc is a little wider than
        // the longest side, a wing is the longest side. Without a class it is
        // the span without its courtesy room.
        //
        // Not for the hangar it is sheltered in, not for anything flat (paving,
        // painted pads, lights), and not on a pad at all: a pad is there to be
        // landed on, and the stand search has already judged what stands round
        // it. Asked last, because it is the dearest test here.
        // Inside a hangar the shared search chose, it is not asked at all. A
        // disc round the aircraft reaches straight through the hangar's own
        // walls to whatever stands outside them, and the bay was vetted when it
        // was given. On a LAN run an RHS F-22 was evicted from a Stratis tent
        // hangar bay the moment it parked, a bay that passed before this test
        // existed. Not where the caller will not line the aircraft up with the
        // hangar (_shelterOk false): there the hangar is a wall like any other.
        private _inHangar = false;
        if (_shelterOk) then {
            private _hangarTypes = (if (isNil "ALIVE_airBuildingTypes") then {[]} else {ALIVE_airBuildingTypes})
                + (if (isNil "ALIVE_militaryAirBuildingTypes") then {[]} else {ALIVE_militaryAirBuildingTypes});
            _inHangar = ((nearestObjects [_p, ["House","Building"], _span + BODY_PAD]) findIf {
                private _hh = _x;
                private _t = toLower (typeOf _hh);
                ((_hangarTypes findIf { [_t, _x] call CBA_fnc_find != -1 }) >= 0) && {
                    (boundingBoxReal _hh) params ["_hmin", "_hmax"];
                    private _m = _hh worldToModel _p;
                    (_m select 0) > (_hmin select 0) && {(_m select 0) < (_hmax select 0)}
                        && {(_m select 1) > (_hmin select 1)} && {(_m select 1) < (_hmax select 1)}
                }
            }) > -1;
        };
        private _reach = (_span - 4) max 1;
        if !(_class isEqualTo "") then {
            ([_class] call ALiVE_fnc_getVehicleBoundingBox) params [["_rLen", 0], ["_rWid", 0]];
            _reach = if (_class isKindOf "Helicopter") then {
                (_rLen max _rWid) * 0.55
            } else {
                ((_rLen max _rWid) * 0.5) + 0.5
            };
        };
        private _fnc_walled = {
            if (_inHangar) exitWith { false };
            if !((nearestObjects [_p, ["HeliH"], 5]) isEqualTo []) exitWith { false };
            private _near = ((nearestObjects [_p, ["House","Building","Wall"], _reach + BODY_PAD])
                + (nearestTerrainObjects [_p, BODY_TYPES, _reach + BODY_PAD, false, true]))
                select { !(_x isKindOf "HeliH") && {!(_x in _shelter)} };
            (_near findIf {
                private _o = _x;
                (boundingBoxReal _o) params ["_bMin", "_bMax"];
                // Flat is ground, not an obstacle.
                if (((_bMax select 2) - (_bMin select 2)) < 1) then {
                    false
                } else {
                    // The spot in the object's own frame, clamped to its box:
                    // the distance to its true rotated rectangle.
                    private _l = _o worldToModel [_p select 0, _p select 1, (position _o) select 2];
                    private _dx = (_l select 0) - (((_l select 0) max (_bMin select 0)) min (_bMax select 0));
                    private _dy = (_l select 1) - (((_l select 1) max (_bMin select 1)) min (_bMax select 1));
                    ((_dx * _dx) + (_dy * _dy)) < (_reach * _reach)
                };
            }) > -1
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

        // Never ON the runway, whatever else is true.
        //
        // This is the one the airside test was supposed to do and does not on
        // every map. Measured before this line existed: the predicate answered
        // TRUE in the middle of the runway and at a threshold, so a stand could
        // be chosen there and nothing would have stopped it.
        private _onRunway = ([_p] call _fnc_offRunway) < RUNWAY_CLEAR;

        // The airfield test above works off the runway and taxi lines, and a
        // hangar apron sits off to the side of those, so it does not reach a
        // bay. Being under a hangar says the same thing about the paving.
        if (_sheltered) then { _onRoad = false };

        _result = !_airside
            && {!_onRunway}
            && {!_onRoad}
            && {!surfaceIsWater _p}
            && {(count (_p isFlatEmpty [-1, -1, 0.3, _span, 0, false, objNull])) > 0}
            // A landing pad is a surface to park on, not something to stand
            // clear of, and pads classify as buildings. Anything else built
            // inside the footprint still refuses the spot.
            && {(nearestObjects [_p, ["House","Building"], _span]) findIf {
                    !(_x isKindOf "HeliH") && {!(_x in _shelter)}
                } == -1}
            && {((nearestTerrainObjects [_p, CLUTTER, _span, false, true]) - _shelter) isEqualTo []}
            && {((nearestObjects [_p, ["Air"], _span + 6]) select {
                    private _cand = _x;
                    (_ignore findIf {_x isEqualTo _cand}) == -1
                }) isEqualTo []}
            && {!(call _fnc_walled)};
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

        // A hold point can only be occupied. There is no ground to be unsuitable
        // and no geometry to be wrong, and it must NOT fall through to the
        // terrain test below, which refuses every point over water outright and
        // would therefore refuse every hold point a sea marker has.
        if ((_home select 2) isEqualTo "virtual") exitWith {
            private _posV = _home select 0;
            private _bbV = [_class] call ALiVE_fnc_getVehicleBoundingBox;
            private _spanV = 12;
            if (count _bbV > 1) then {
                _spanV = ((((_bbV select 0) max (_bbV select 1)) / 2) + 4) max 12;
            };
            private _ownV = [_ownObj];
            if (!isNull _ownObj) then { _ownV append (crew _ownObj) };
            private _intrudersV = (nearestObjects [_posV, ["Air","LandVehicle","Man"], _spanV]) select {
                private _cand = _x;
                alive _cand && {(_ownV findIf {_x isEqualTo _cand}) == -1}
            };
            if (count _intrudersV > 0) then {
                _result = [false, "occupied"];
            } else {
                _result = [true, ""];
            };
        };

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
        // A WRECK counts, which it used to not. This filter asked for alive, so a
        // wrecked hull was invisible here and the spot fell through to the
        // geometry test below, whose Air sweep does not ask about alive and so
        // refused it. The caller then read "geometry" and evicted the aircraft
        // from its own home, when the comment above says exactly what should
        // have happened: something is in the way, so wait for it to be moved.
        // fnc_ATOPlace's clearWreck is the thing that moves it, once no player
        // is within 300 m of it.
        //
        // Still alive-only for a Man. A body is not something the wreck clearer
        // will take away, and nothing in this file has ever refused a spot for
        // one, so counting them here would strand aircraft over corpses.
        private _intruders = (nearestObjects [_pos, ["Air","LandVehicle","Man"], _span]) select {
            private _cand = _x;
            (_own findIf {_x isEqualTo _cand}) == -1
                && {alive _cand || {!(_cand isKindOf "Man")}}
        };
        if (count _intruders > 0) exitWith { _result = [false, "occupied"] };

        // The class goes with it, so the shelter test can ask whether this
        // airframe actually fits the hangar it is standing in.
        if !([_logic, "spotIsClear", [_pos, _span, _own, _class]] call MAINCLASS) exitWith {
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
        // Held: put exactly where it belongs, stopped, hidden, and with its
        // simulation off so it stays there. Measured: a hull frozen this way
        // over open water reads the same position thirty seconds later, still
        // takes a crew, and still accepts the servicing writes.
        //
        // No settle thread and no damage handed back. There is nothing to settle
        // onto, and an aircraft held above the sea that is allowed to be damaged
        // is an aircraft that drowns the moment anything goes wrong.
        //
        // And no wreck clearing, which a stand on an airfield does need. A
        // wreck ends up where the aircraft died rather than where it lived, so
        // there is never one at a hold point. Confirmed by watching one: an
        // aircraft shot down on station left its wreck out over the airspace
        // and its replacement took the hold point cleanly.
        if ((_home select 2) isEqualTo "virtual") exitWith {
            ([_logic, "resolve", _home] call MAINCLASS) params ["_targetV", "_dirV"];
            _obj allowDamage false;
            if (_dirV >= 0) then { _obj setDir _dirV };
            _obj setPosASL [_targetV select 0, _targetV select 1, _targetV select 2];
            _obj setVectorUp [0,0,1];
            _obj setVelocity [0,0,0];
            _obj hideObjectGlobal true;
            _obj enableSimulationGlobal false;
            _result = true;
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

    // Let a held aircraft go. The exact inverse of what place does to one at a
    // virtual home, kept here because this file owns what "held" means.
    //
    // Answers false for anything that is not actually held, so a caller may ask
    // without knowing.
    case "release": {
        private _obj = _args;
        _result = false;
        if (!(_obj isEqualType objNull) || {isNull _obj}) exitWith {};
        if (simulationEnabled _obj && {!(isObjectHidden _obj)}) exitWith {};
        _obj enableSimulationGlobal true;
        _obj hideObjectGlobal false;
        _obj allowDamage true;
        _result = true;
    };

    case "stampPad": {
        _args params [["_home",[],[[]]], ["_tail","",[""]]];
        if (count _home < 3) exitWith { _result = objNull };
        private _pads = [_logic,"pads"] call ALIVE_fnc_hashGet;

        private _existing = [_pads,_tail,objNull] call ALIVE_fnc_hashGet;
        if (!isNull _existing) exitWith { _result = _existing };

        // Nothing to stamp a pad onto. A pad written the terrain way at a point
        // over water lands on the sea bed, and a virtual home never lands an
        // aircraft on a pad anyway: it is put back where it belongs instead.
        if ((_home select 2) isEqualTo "virtual") exitWith { _result = objNull };

        // Where the pad goes. A deck home's world position is worked out from
        // its ship rather than read back, the same as everywhere else that
        // uses one.
        private _at = _home select 0;
        private _onDeck = (_home select 2) isEqualTo "deck";
        if (_onDeck) then {
            _at = ([_logic, "resolve", _home] call MAINCLASS) select 0;
        };

        private _pad = createVehicle ["Land_HelipadEmpty_F", _at, [], 0, "CAN_COLLIDE"];
        if (_onDeck) then {
            // ON THE PLATING, above sea level.
            //
            // setPosATL measures from the terrain and over water the terrain is
            // the SEA BED, so a pad stamped the land way sat about forty metres
            // underneath the ship. A helicopter told to land on its pad was
            // being aimed at the sea floor, and the whole point of stamping a
            // pad is that the engine puts a helicopter down on one whether or
            // not that is where it was sent.
            //
            // A deck home already carries its position above sea level, which
            // is the frame the deck half works in throughout.
            _pad setPosASL [_at select 0, _at select 1, _at select 2];
        } else {
            // Terrain level. A hangar-parked airframe stores the building's own
            // elevated origin, and a pad at that height is a pad in the roof.
            _pad setPosATL [_at select 0, _at select 1, 0];
        };
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
        // Four elements, matching what the search itself writes and prunes,
        // and stamped on the same clock it prunes by. This wrote mission time,
        // and the search prunes by diag_tickTime, which counts from when the
        // game started: on any server that had run for a minute before its
        // mission, every entry was already expired when it was written, so the
        // spot of an aircraft away flying read as free to every search.
        ALiVE_airSpawnRegistry pushBack [+(_home select 0), _tail, diag_tickTime, _tail];
        _result = true;
    };

    default {
        _result = [_logic, _operation, _args] call SUPERCLASS;
    };
};

TRACE_1("ATO Surface - output",_result);

_result;
