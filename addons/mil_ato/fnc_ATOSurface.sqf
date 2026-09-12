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

This pass carries CLASSIFY and the TERRAIN half. Deck operations refuse and say
so; nothing above this is wired to a carrier until the deck half passes its own
scene test.

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

private ["_result"];

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
        private _parts = _ship getVariable ["multiStructureParts", []];
        if (_parts isEqualTo []) then { _parts = [_ship] };

        // Straight down through the point. A deck is a surface you could stand
        // on, so ask whether one is there rather than inferring it.
        // Both ends built in ASL directly: getTerrainHeightASL already returns
        // ASL, so converting again would put the probe 50 m into the wrong place.
        private _groundASL = getTerrainHeightASL _pos;
        private _from = [_pos select 0, _pos select 1, _groundASL + 50];
        private _to   = [_pos select 0, _pos select 1, _groundASL - 50];
        private _hits = lineIntersectsSurfaces [
            _from, _to, objNull, objNull, true, 1, "GEOM", "NONE"
        ];

        {
            private _obj = _x select 2;
            if (!isNull _obj && {(_parts findIf {_x isEqualTo _obj}) > -1 || {_obj isEqualTo _ship}}) exitWith {
                _result = "deck";
            };
        } forEach _hits;
    };

    // Where an airframe of this class may stand, anchored near a point, without
    // clashing with anything already reserved this pass. An empty return is a
    // refusal and is load bearing: the caller must handle "nowhere" rather than
    // be handed a position that was never checked.
    case "cascade": {
        _args params [
            ["_surface","terrain",[""]],
            ["_class","",[""]],
            ["_anchor",[0,0,0],[[]]],
            ["_reserved",[],[[]]]
        ];

        if (_surface isEqualTo "deck") exitWith {
            ["ALIVE_fnc_ATOSurface - deck cascade is not built yet, refusing rather than guessing"] call ALiVE_fnc_dump;
            _result = [];
        };

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
            if (!_taken) then { _found = [_p, _air select 1, "terrain"] };
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
        if ((_home select 2) isEqualTo "deck") exitWith { _result = [false, "deck validate is not built yet"] };

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
        if ((_home select 2) isEqualTo "deck") exitWith {
            ["ALIVE_fnc_ATOSurface - deck resolve is not built yet"] call ALiVE_fnc_dump;
            _result = [[0,0,0], 0];
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
        private _tolerance = if (_obj isKindOf "Plane") then { 15 } else { 30 };
        _result = (_obj distance2D (_home select 0)) < _tolerance;
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
            ["ALIVE_fnc_ATOSurface - deck place is not built yet"] call ALiVE_fnc_dump;
            _result = false;
        };

        // A COPY. One caller used to hand in the stored home itself, and the
        // grounding write below then landed in the record, so the home crept
        // sideways a little further every time the airframe came back.
        private _target = +(_home select 0);
        // Terrain level. A hangar-parked airframe stores the building's own
        // elevated origin, and placing at that height puts it in the roof.
        _target set [2, 0];

        private _dir = _home select 1;

        _obj allowDamage false;
        if (_dir >= 0) then { _obj setDir _dir };
        _obj setPosATL _target;
        _obj setVectorUp [0,0,1];
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
