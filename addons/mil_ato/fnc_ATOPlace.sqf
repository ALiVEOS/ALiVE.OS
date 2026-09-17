#include "\x\alive\addons\mil_ato\script_component.hpp"
SCRIPT(place);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_ATOPlace
Description:
Which aircraft in the world are ours to fly, and how they become ours.

Two halves. The deciding half looks at the profile registry and says what may
be adopted, and refuses with a reason. The taking half consumes a profile and
seizes its object, creates hulls for records that have none, and moves a home
that has been built on. That second half is the one thing in this module that
cannot be undone if it is wrong, which is why every destructive op here is
ordered so that nothing irreversible happens until every check that could
refuse has already passed, and the one irreversible step is the last one.

Two rules give the deciding half its shape, both learnt the hard way by the
module this replaces.

An aircraft is only adopted after being seen twice, at least twenty seconds
apart. A profile that appears once and vanishes was mid-registration, and
adopting it raced the system that created it: the old module took airframes out
from underneath logistics while they were still being delivered, then declared
them lost and ordered replacements, without limit.

And the registry is the only place it looks. Never `vehicles`, because that
answers with everything the engine currently has spawned, including aircraft
belonging to combat support, to a mission maker, or to a player, none of which
are the air commander's to take.

Four rules give the taking half its shape. Each one closes a hole that the
first design of this file had open.

The claim is written before anything destructive. A candidate is named in this
instance's `consuming` list before its home is looked for and long before its
profile is touched, and `admissible` refuses anything on that list. Without
this there is a window, the whole of the consume, in which nothing names the
candidate, and a second pass through the sweep adopts the same profile twice.
That window is the entire point of the claim, not a detail of it.

The hull exists before the profile is destroyed. A virtual profile has nothing
in the world, so its hull is created first, checked to be real, and only then
is the profile unregistered. Done the other way round, a class the game cannot
create leaves the aircraft gone from the registry and absent from the world,
and the module has destroyed an asset rather than adopted one. If the hull
cannot be made the profile is left exactly as it was found.

A remote hull never reaches limbo. A crewed pair whose crew live on a headless
client is a hull owned by that client, and the crew deletion that frees it is
asynchronous, so the hull may still be remote when consume returns. Such a hull
is recorded as attached BEFORE its locality is tested, so `objFor` tells the
truth about it and the Machine's own remote handling can act on it, and the
sweep retries ownership on every pass. Every pass reports only tails whose
attach actually succeeded, the sweep, placeInitial, createReplacement and
restoreAll alike; the deferred ones are exposed through their own accessor,
so the Kernel never builds a row around a hull it cannot yet see.

Every helper below binds what it needs. Code run with `call` inherits the
caller's variables, so a helper that mentions a collaborator without binding it
silently picks up whatever the calling case happened to name that way, and the
fault moves with the caller. Every helper takes `_logic` and reads its
collaborators out of it.

Refusal shapes, fixed per op (there is no shared tuple):
  adoptPair         -> tail STRING, or ["refused", reason]
  consume           -> [hull, crossed]; hull is objNull on a refusal, crossed
                       says whether the point of no return was passed
  attach            -> [true, ""], or [false, reason]; only "remote" is transient
  rehome            -> home, or []
  sweep/placeInitial-> array of tails
  createReplacement -> Boolean
  restoreAll        -> [placed[], consumed[], rehomed[], unplaceable[]]

Parameters:
Nil or Array - If Nil, return a new instance. If a hash, reference an existing one.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function

Examples:
(begin example)
_p = [nil, "create"] call ALIVE_fnc_ATOPlace;
[_p, "configure", [["ledger", _ledger], ["surface", _surface], ["effect", _effect],
    ["faction", "BLU_F"], ["factions", ["BLU_F"]], ["base", _base]]] call ALIVE_fnc_ATOPlace;
_tails = [_p, "sweep", ["AS1", time, _claimedLegacyIds]] call ALIVE_fnc_ATOPlace;

(end)

See Also:
<ALIVE_fnc_ATOSurface>, <ALIVE_fnc_ATOLedger>, <ALIVE_fnc_ATOEffect>, <ALIVE_fnc_ATOTask>

Author:
Jman
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClassHash
#define MAINCLASS ALIVE_fnc_ATOPlace

// A candidate has to still be there this long after it was first seen. Twenty
// seconds is the figure the old module's delivery race needed to settle.
#define SIGHTING_GAP 20

// Set on an object by another system to say "this one is not yours". The first
// belongs to combat support; the second is the general opt-out, and the module
// stamps it on its own aircraft too, which is why a sweep must not treat it as
// an invitation.
#define FOREIGN_MARKS ["ALIVE_CombatSupport", "ALIVE_profileIgnore"]

// How long consume waits for a hull to become server-local once it has asked
// for it. The Effect test's own acceptance for takeOwnership is "local within
// five seconds", so that is the figure here too.
#define LOCALITY_WAIT 5

// How long the live branch waits for deleted crew to actually leave their
// seats. deleteVehicle on a unit owned by another machine takes effect over
// there, and nothing in this codebase establishes that the server's `crew`
// reads empty on the very next statement, so it is waited for rather than
// assumed. Three seconds is well past what a deletion round-trip takes.
#define CREW_CLEAR_WAIT 3

// Nobody this close to a stand sees a wreck vanish. The same figure the state
// table uses for deleteWreckNear, kept identical on purpose.
#define WRECK_PLAYER_RANGE 300

// A hull that stays remote is reported when it is first deferred and then only
// every this many retries, so a client that holds on to one does not write a
// line into the log on every sweep for the rest of the mission.
#define DEFERRED_LOG_EVERY 10

// D3's ceiling on planes created for one field. The raw hangar-node count over
// counts real parking badly, tent hangars being hangars in name only.
#define PLANE_CAP 8

// How old a pass flag or an adoption claim may be before it is taken for
// abandoned. SQF has no finally, so a script error between a claim and its
// release leaves the claim standing, and the first version of this file had
// no way back from that: one throw inside a pass disabled adoption, initial
// placement and restore for the rest of the mission, silently, and one
// throw inside consume made that aircraft unadoptable by every instance. The
// longest legitimate hold is one consume, whose waits sum to nine seconds; a
// pass over several candidates is a few times that. Two minutes is well
// clear of both and still short enough that a wedged instance recovers
// within the mission rather than after it.
#define LATCH_STALE 120

// How high an aircraft bound for a virtual base is created. The engine's flying
// start ignores the height it is handed and an aircraft born in flight at sea
// level has nowhere to go but down, so it is born well clear and brought down
// to its hold point at once. Matches the floor sys_profile uses for the same
// reason.
#define VIRTUAL_BIRTH 300

private ["_result"];

TRACE_1("ATO Place - input",_this);

params [
    ["_logic", objNull, [objNull,[]]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,[],"",0,true,false]]
];

_result = true;

// ---- file-scope helpers ----------------------------------------------------
// Each takes what it needs as a parameter and reads its collaborators out of
// _logic. Nothing below reads a variable it did not declare or receive. That
// is the whole discipline: code run with `call` inherits the caller's scope,
// so a helper that used _surface without binding it would work from the one
// case that happened to bind _surface and throw from the next, and the reader
// would go looking for the fault in the wrong place.

// The one way a profile is looked up in this file. getProfile answers with
// the profile HASH, which is an array, or with nothing at all for an unknown
// id. isNull has no array form and throws on the array, so the answer is held
// as an array and absence is the empty one. The handler itself is a global
// that only exists once sys_profile has started, so that read is guarded too.
// An earlier version of admissible tested the answer with isNull and would
// have thrown on the first lookup that SUCCEEDED; this is the corrected shape
// and every lookup in the file goes through it.
private _fnc_profile = {
    params [["_id", "", [""]]];
    private _profile = [];
    if (!(_id isEqualTo "") && {!isNil "ALIVE_profileHandler"}) then {
        private _got = [ALIVE_profileHandler, "getProfile", _id] call ALIVE_fnc_profileHandler;
        if (!isNil "_got" && {_got isEqualType []}) then { _profile = _got };
    };
    _profile
};

// Have the three collaborators been wired? An instance that has not been
// configured holds [] in each slot, and [] handed to a hashGet is turned away
// with a nil answer, and a nil assigned to a variable DELETES that variable,
// so the failure surfaces two lines later as "undefined variable" with no
// mention of why. For the destructive ops that "two lines later" could be
// after a profile is already gone. So it is asked once, up front, by name,
// and the op refuses before it reads anything.
private _fnc_notReady = {
    params ["_logic"];
    private _missing = [];
    {
        if !([[_logic, _x, []] call ALIVE_fnc_hashGet] call ALIVE_fnc_isHash) then { _missing pushBack _x };
    } forEach ["ledger", "surface", "effect"];
    if (count _missing == 0) then { "" } else { format ["not configured: %1", _missing joinString ", "] }
};

// Ported verbatim from the old module. Some ground drone bases descend from
// Car_F and carry the UAV flag too, so callers test isKindOf "Air" first.
private _fnc_isDroneClass = {
    params [["_v", "", ["", objNull]]];
    if (_v isEqualType objNull) then { _v = typeOf _v };
    if (_v isEqualTo "") exitWith { false };
    (_v isKindOf "UAV") || {getNumber (configFile >> "CfgVehicles" >> _v >> "isUav") == 1}
};

// Whether the air commander should be holding an aircraft of this class at
// all. Answers [ok, why, roles, capabilities] from the class and an optional
// fitted loadout, never from an object, so it can be asked of a virtual
// profile and of a record at load. The loadout matters: getAircraftRoles
// merges the magazines actually fitted, so a refitted aircraft answers with
// more roles than its class alone.
private _fnc_admit = {
    params ["_logic", ["_class", "", [""]], ["_loadout", [], [[]]]];
    if (_class isEqualTo "") exitWith { [false, "it has no vehicle class", [], []] };
    if !(isClass (configFile >> "CfgVehicles" >> _class)) exitWith {
        [false, format ["%1 is not a class this game knows", _class], [], []]
    };
    private _isDrone = _class isKindOf "Air" && {[_class] call _fnc_isDroneClass};
    if (_isDrone && {!([_logic, "useUAVs", true] call ALIVE_fnc_hashGet)}) exitWith {
        [false, "drones are turned off for this commander", [], []]
    };
    private _roles = [_class, _loadout] call ALiVE_fnc_getAircraftRoles;
    if !(_roles isEqualType []) then { _roles = [] };
    if (count _roles == 0) exitWith { [false, "it resolves to no roles, so nothing could ever task it", [], []] };
    if (!([_class] call ALiVE_fnc_isArmed) && {!_isDrone}) exitWith { [false, "it carries no armament", _roles, []] };
    private _caps = [_class, _loadout] call ALiVE_fnc_getAircraftCapabilities;
    if !(_caps isEqualType []) then { _caps = [] };
    [true, "", _roles, _caps]
};

// Half the longest dimension plus courtesy room, with a floor. Identical to
// the figure Surface uses in validate and cascade, deliberately, so a spot
// this reserves is the spot Surface clears and the two never disagree.
private _fnc_span = {
    params [["_class", "", [""]]];
    private _bb = [_class] call ALiVE_fnc_getVehicleBoundingBox;
    if !(_bb isEqualType [] && {count _bb > 1}) then { _bb = [4, 2, 2] };
    ((((_bb select 0) max (_bb select 1)) / 2) + 4) max 12
};

// Helicopters and VTOLs get a stamped pad; planes do not. Read from config
// rather than through ALiVE_fnc_isVTOL, which is assigned inside the OLD
// module's body and only exists once that function has run.
private _fnc_needsPad = {
    params [["_class", "", [""]]];
    !(_class isKindOf "Plane") || {getNumber (configFile >> "CfgVehicles" >> _class >> "vtol") > 0}
};

// Up, or moving without the ground under it. A hull parked on a pad reads a
// metre or so above terrain and touching, so the height alone is not enough
// and the speed test is not enough on its own either.
//
// Over water the height is read against what is UNDER the hull rather than
// against the terrain, because there the terrain is the sea bed: a jet
// standing on a carrier deck is 23.6 m above the waterline and about 64 m
// above the sea bed, and read from the terrain every carrier aircraft was
// "airborne" and could not be attached. There is no home to hand at this
// point, so the water underneath is the test, which is what the deck is over.
private _fnc_airborne = {
    params [["_obj", objNull, [objNull]]];
    if (isNull _obj) exitWith { false };
    private _up = if (surfaceIsWater (getPos _obj)) then { (getPos _obj) select 2 } else { (getPosATL _obj) select 2 };
    (_up > 5) || {!(isTouchingGround _obj) && {(abs (speed _obj)) > 5}}
};

// A player in a seat, or a player flying it from a terminal. A drone under
// UAVControl has no player in its crew at all, and deleting its AI crew out
// from under the operator is exactly the complaint this module exists to stop.
private _fnc_playerAboard = {
    params [["_obj", objNull, [objNull]]];
    if (isNull _obj) exitWith { false };
    ({alive _x && {isPlayer _x}} count (crew _obj)) > 0
        || {isPlayer ((UAVControl _obj) param [0, objNull])}
};

// The crew entity of a vehicle profile, or "". The airframe has always known
// its own crew: it carries exactly one entity id in entitiesInCommandOf. An id
// that does not resolve is treated as no crew rather than as a fault, because
// sys_profile documents that the two sides of an assignment drift apart while
// a profile is being destroyed, and refusing on a dangling id would keep an
// otherwise adoptable airframe out for the rest of the session. The airframe's
// own id is excluded, as the old module's crew resolution did.
private _fnc_pairOf = {
    params [["_veh", [], [[]]]];
    private _own = [_veh, "profileID", ""] call ALIVE_fnc_hashGet;
    private _ents = [_veh, "entitiesInCommandOf", []] call ALIVE_fnc_hashGet;
    if !(_ents isEqualType []) then { _ents = [] };
    private _found = "";
    {
        if (_found isEqualTo "" && {_x isEqualType ""} && {!(_x isEqualTo _own)}) then {
            private _ent = [_x] call _fnc_profile;
            if (!(_ent isEqualTo []) && {([_ent, "type", ""] call ALIVE_fnc_hashGet) isEqualTo "entity"}) then {
                _found = _x;
            };
        };
    } forEach _ents;
    _found
};

// A home for this class near an anchor, or []. The anchor itself is tried
// first, so an aircraft standing on a clear spot keeps that spot and a real
// pad is accepted as itself, and only then is the cascade asked.
//
// Deck and terrain both come through here. Which one an anchor is, is Surface's
// answer and nobody else's, and the answer decides the SHAPE of the candidate
// as well as which search runs: a deck candidate is an offset within a ship,
// because a world position on a ship is right only until the ship is somewhere
// else.
//
// The cascade is handed an EMPTY reserved list on purpose. It unions its
// argument with the surface's own reservations, so everything this instance
// has reserved this pass is already honoured without reaching into that piece
// to fetch the list and hand it back.
private _fnc_homeFor = {
    params ["_logic", ["_class", "", [""]], ["_anchor", [0,0,0], [[]]], ["_dir", 0, [0]], ["_ownObj", objNull, [objNull]],
        ["_preferAirfield", false, [false]]];
    private _surface = [_logic, "surface", []] call ALIVE_fnc_hashGet;
    if !([_surface] call ALIVE_fnc_isHash) exitWith { [] };
    if (count _anchor < 2 || {_class isEqualTo ""}) exitWith { [] };
    private _flat = [_anchor select 0, _anchor select 1, 0];

    // A base with no airfield holds its aircraft at a ring of points around its
    // ingress marker, and there is no "the spot you asked for" to try first:
    // every hold point is equal and the search simply takes a free one. The
    // kind is DECLARED by the base rather than read off the ground, because
    // classify derives its answer from what is underneath a point and can only
    // ever say terrain or deck.
    private _baseHere = [_logic, "base", []] call ALIVE_fnc_hashGet;
    if ([_baseHere] call ALIVE_fnc_isHash
        && {[_baseHere, "isVirtual", false] call ALIVE_fnc_hashGet}) exitWith {
        [_surface, "cascade", ["virtual", _class, _flat, []]] call ALIVE_fnc_ATOSurface
    };

    private _kind = [_surface, "classify", _flat] call ALIVE_fnc_ATOSurface;
    private _cand = [_flat, _dir, "terrain"];
    if (_kind isEqualTo "deck") then {
        private _ship = [_surface, "shipAt", _flat] call ALIVE_fnc_ATOSurface;
        if (isNull _ship) then {
            // Surface says deck and there is no ship to hang it on, which
            // should not happen: the same radius decided both. Left as a
            // terrain candidate, which then fails its own validate over water
            // and falls through to the cascade.
            ["ALIVE_fnc_ATOPlace - %1 is on a deck at %2 and no ship was found to attach it to", _class, _flat] call ALiVE_fnc_dump;
        } else {
            private _m = _ship worldToModel _flat;
            _cand = [_flat, _dir, "deck",
                [_surface, "carrierHandle", _ship] call ALIVE_fnc_ATOSurface,
                [_m select 0, _m select 1, 0],
                (_dir - (getDir _ship)) mod 360];
        };
    };
    // A hangar beats a spot that is merely acceptable.
    //
    // Before the rewrite, a profile that was not yet live always got a search,
    // and it asked for "auto", which reaches the hangar tier. So every manned
    // plane was offered a hangar whether or not the ground it was standing on
    // would have done. Validating first and searching only on failure undid
    // that quietly: open flat concrete passes validate perfectly well, so the
    // planes stayed where they were put and the hangars stood empty beside
    // them.
    //
    // Only the hangar rung is asked for, not the whole cascade. Apron and field
    // would move aircraft that are already somewhere sensible, and that is not
    // what was missing.
    //
    // Fresh placements only. A live hull is left where it stands, which is what
    // stopped aircraft visibly teleporting, and the old code gated on the same
    // thing.
    //
    // The answer is deliberately NOT put through validate. That check ends in
    // spotIsClear, and a hangar reports itself as an obstacle, so it could
    // refuse the bay it had just been given. The hangar tier does that work
    // itself: it turns down a bay with a vehicle or a wreck in it, turns down
    // one whose doors will not open, and takes a reservation so two aircraft
    // are never sent to the same bay. Answers from the cascade below are used
    // unvalidated for the same reason.
    private _bayHome = [];
    if (isNull _ownObj
        && {_kind isEqualTo "terrain"}
        && {_class isKindOf "Plane"}
        && {getNumber (configFile >> "CfgVehicles" >> _class >> "isUav") == 0}
    ) then {
        private _bay = [_class, _flat, 400, "hangar"] call ALiVE_fnc_findAirSpawnPosition;
        if (count _bay >= 2) then {
            private _bp = _bay select 0;
            // z dropped, as every other home on terrain is stored flat
            _bayHome = [[_bp select 0, _bp select 1, 0], _bay select 1, "terrain"];
        };
    };
    if (count _bayHome > 0) exitWith { _bayHome };

    // Accepting the anchor because it happens to be clear is only right when
    // something actually chose it: a home hint, or a home the record already
    // carries. When the anchor is the commander's airfield, put there because
    // nothing said where this aircraft belongs, there is no such choice to
    // respect and the bare centre of an airfield is not parking. Straight to
    // the cascade, which knows about pads, bays and aprons.
    private _ok = ([_surface, "validate", [_cand, _class, _ownObj]] call ALIVE_fnc_ATOSurface) param [0, false];
    if (_ok && {!_preferAirfield}) exitWith { _cand };
    [_surface, "cascade", [_kind, _class, _flat, []]] call ALIVE_fnc_ATOSurface
};

// Build a hull at a home. Returns objNull when it could not, and the caller
// has to treat that as a refusal: this is the check that makes "create first,
// destroy second" mean anything. The class is tested against config before
// createVehicle is asked, so a class the game does not have refuses cleanly
// rather than through an engine error and a null.
//
// ALIVE_profileIgnore goes on the object in the same breath as its creation.
// The runtime profiler stamps a profileID on any Air object that lacks the
// flag, and consume unregisters the profile a few statements after this
// returns, so an unflagged hull in that gap would come out of adoption already
// carrying a profile of its own. The pylon loadout is re-applied the way
// sys_profile's spawn does it, so a refitted editor aircraft keeps the
// magazines its admission was judged on. A refusal from Surface.place is
// logged and not fatal: the hull exists and RECOVERING tidies it.
private _fnc_createHull = {
    params ["_logic", ["_class", "", [""]], ["_home", [], [[]]], ["_pylons", [], [[]]]];
    private _surface = [_logic, "surface", []] call ALIVE_fnc_hashGet;
    if (count _home < 3 || {_class isEqualTo ""}) exitWith { objNull };
    if !(isClass (configFile >> "CfgVehicles" >> _class)) exitWith {
        ["ALIVE_fnc_ATOPlace - cannot create %1: not a class this game knows", _class] call ALiVE_fnc_dump;
        objNull
    };
    private _pos = +(_home select 0);
    private _kind = _home select 2;
    // Terrain level for a terrain home: a hangar-parked airframe stores the
    // building's own elevated origin and creating at that height puts it in
    // the roof. A DECK home's height is the deck itself, and zeroing it over
    // water creates the airframe at the waterline under the ship. A VIRTUAL
    // home's height is the hold point, for the same reason.
    if !(_kind in ["deck", "virtual"]) then { _pos set [2, 0] };

    // An aircraft that lives at a virtual base is born FLYING, and then held.
    //
    // This is what makes a base with no airfield possible at all. Measured: a
    // helicopter created the ordinary way can never afterwards be put into the
    // air. Teleported up with its engine running it was dead in fifteen seconds
    // and on the sea bed in thirty, and that held whether it had been frozen
    // first or not, with a forward push or without one, with somewhere to go or
    // nowhere at all. One created with the engine's own flying start survives
    // being held and let go, over and over: a jet and a gunship each flew two
    // sorties out to several kilometres and were holding their point in
    // between.
    //
    // Created high and brought straight down to its hold point by the surface,
    // because the flying start ignores the height it is given and an aircraft
    // born at sea level in flight has nowhere to go but down.
    private _special = "CAN_COLLIDE";
    private _birth = _pos;
    if (_kind isEqualTo "virtual") then {
        _special = "FLY";
        _birth = [_pos select 0, _pos select 1, VIRTUAL_BIRTH];
    };
    private _obj = createVehicle [_class, _birth, [], 0, _special];
    if (isNull _obj) exitWith {
        ["ALIVE_fnc_ATOPlace - createVehicle returned nothing for %1 at %2", _class, _pos] call ALiVE_fnc_dump;
        objNull
    };
    _obj setVariable ["ALIVE_profileIgnore", true, true];
    { _obj setPylonLoadOut [_forEachIndex + 1, _x] } forEach _pylons;
    if ([_surface] call ALIVE_fnc_isHash) then {
        if !([_surface, "place", [_obj, _home]] call ALIVE_fnc_ATOSurface) then {
            ["ALIVE_fnc_ATOPlace - %1 created but the surface refused to place it; recovery will tidy it", _class] call ALiVE_fnc_dump;
        };
    };
    _obj
};

// Delete dead Air on a stand before something is put there again. The sweep
// reaches the same distance Surface's clearance test looks: that test counts
// dead Air out to span plus six with no alive filter, so a wreck nine metres
// off the stand would survive an eight metre sweep and then make validate
// answer "geometry" for a spot whose only problem was the wreck. Skipped
// entirely with a player near enough to watch, matching the state table's own
// wreck rule; a wreck that stays costs one failed validate and a rehome, a
// wreck that vanishes in front of somebody costs more than that.
private _fnc_clearWreck = {
    params [["_home", [], [[]]], ["_class", "", [""]]];
    if (count _home < 1) exitWith { false };
    private _pos = _home select 0;
    if (([_pos, WRECK_PLAYER_RANGE] call ALiVE_fnc_anyPlayersInRange) > 0) exitWith {
        ["ALIVE_fnc_ATOPlace - wreck near %1 left where it is, a player is within %2 m", _pos, WRECK_PLAYER_RANGE] call ALiVE_fnc_dump;
        false
    };
    private _reach = ([_class] call _fnc_span) + 6;
    private _swept = 0;
    { if (!alive _x) then { deleteVehicle _x; _swept = _swept + 1 } } forEach (nearestObjects [_pos, ["Air"], _reach]);
    _swept > 0
};

// What is standing on a home, for the eviction log: the type of the first
// live thing inside the span that is not the airframe or its crew.
private _fnc_intruderName = {
    params [["_home", [], [[]]], ["_class", "", [""]], ["_own", objNull, [objNull]]];
    if (count _home < 1) exitWith { "" };
    private _mine = [_own];
    if (!isNull _own) then { _mine append (crew _own) };
    // Wrecks included, to match what actually refuses a home. Asking for alive
    // here is why every eviction line read "evicted from X by " with nothing
    // after it: the thing in the way was a wrecked hull, this filtered it out,
    // and the message named nothing. That blank sent me looking for a phantom
    // intruder more than once.
    private _found = (nearestObjects [_home select 0, ["Air","LandVehicle","Man"], [_class] call _fnc_span]) select {
        private _cand = _x;
        (_mine findIf {_x isEqualTo _cand}) == -1
            && {alive _cand || {!(_cand isKindOf "Man")}}
    };
    if (count _found == 0) then { "" } else {
        private _who = _found select 0;
        if (alive _who) then { typeOf _who } else { format ["a wrecked %1", typeOf _who] }
    }
};

// Re-announce every recorded home to the surface as reserved. Surface's
// reservations are per-pass scratch and nothing outside a pass re-states an
// existing home, so without this a cascade run for a new arrival could hand
// out the stand of a sibling that is away flying, and the two would then take
// turns evicting each other for the rest of the mission. Every op that runs a
// cascade calls this first. Retired records are the only ones left out: their
// stand is nobody's.
private _fnc_reserveHomes = {
    params ["_logic"];
    private _ledger = [_logic, "ledger", []] call ALIVE_fnc_hashGet;
    private _surface = [_logic, "surface", []] call ALIVE_fnc_hashGet;
    if (!([_ledger] call ALIVE_fnc_isHash) || {!([_surface] call ALIVE_fnc_isHash)}) exitWith { 0 };
    private _view = [_ledger, "view"] call ALIVE_fnc_ATOLedger;
    private _values = _view select 2;
    private _n = 0;
    {
        private _rec = _values select _forEachIndex;
        private _home = [_rec, "home", []] call ALIVE_fnc_hashGet;
        if (count _home >= 3 && {!(([_rec, "status", ""] call ALIVE_fnc_hashGet) isEqualTo "retired")}) then {
            private _span = [[_rec, "vehicleClass", ""] call ALIVE_fnc_hashGet] call _fnc_span;
            [_surface, "reserve", [_home select 0, _span]] call ALIVE_fnc_ATOSurface;
            _n = _n + 1;
        };
    } forEach (_view select 1);
    _n
};

// Take back a reservation this file wrote. Surface has no op for it, and its
// reservations are per-pass scratch that the next adoption pass clears, so a
// stale one used to be tolerated. It is not any more, for two reasons that
// arrived together: adoptPair now reserves a home BEFORE consume rather than
// after it (a home neither recorded nor reserved for the whole of consume's
// wait was one a concurrent pass could hand to a second record), so a
// consume that refuses leaves a reservation behind; and createReplacement no
// longer clears reservations, so that leftover would block a real stand
// until the next sweep rather than until the next pass. Only the exact entry
// reserve wrote is removed, the same position and the same span, which is
// the one reach into Surface's own list this file makes.
private _fnc_unreserve = {
    params ["_logic", ["_home", [], [[]]], ["_class", "", [""]]];
    private _surface = [_logic, "surface", []] call ALIVE_fnc_hashGet;
    if (!([_surface] call ALIVE_fnc_isHash) || {count _home < 1}) exitWith { false };
    private _res = [_surface, "reservations", []] call ALIVE_fnc_hashGet;
    if !(_res isEqualType []) exitWith { false };
    private _span = [_class] call _fnc_span;
    private _at = _res findIf { (_x select 0) isEqualTo (_home select 0) && {(_x select 1) isEqualTo _span} };
    if (_at < 0) exitWith { false };
    _res deleteAt _at;
    true
};

// Every profile id somebody already has a claim on: the legacy ids the ledger
// carries from the old store, whatever this instance is in the middle of
// consuming, and whatever any other instance is in the middle of consuming.
// Computed once per sweep and handed down, not once per candidate: the ledger
// view is a deep copy and asking for it per candidate is candidates times
// records copies for the same answer.
//
// Both claim lists carry the time they were written, and a claim older than
// LATCH_STALE is dropped here rather than honoured. Nothing releases a claim
// on a script error, and a claim that was never released used to make its
// aircraft refused as "already claimed" by every instance for the rest of
// the mission, with nothing in the log to say so after the first refusal.
// The drop is said out loud so the throw that caused it can be found.
private _fnc_claimedIds = {
    params ["_logic"];
    private _ids = [];
    private _ledger = [_logic, "ledger", []] call ALIVE_fnc_hashGet;
    if ([_ledger] call ALIVE_fnc_isHash) then {
        private _view = [_ledger, "view"] call ALIVE_fnc_ATOLedger;
        private _values = _view select 2;
        {
            private _legacy = [_values select _forEachIndex, "legacyProfileID", ""] call ALIVE_fnc_hashGet;
            if (_legacy isEqualType "" && {!(_legacy isEqualTo "")}) then { _ids pushBackUnique _legacy };
        } forEach (_view select 1);
    };
    private _consuming = [_logic, "consuming", []] call ALIVE_fnc_hashGet;
    if ([_consuming] call ALIVE_fnc_isHash) then {
        // Copied before the walk; the removal below is by key.
        private _cKeys = +(_consuming select 1);
        private _cValues = +(_consuming select 2);
        {
            private _since = _cValues select _forEachIndex;
            if (_since isEqualType 0 && {(time - _since) > LATCH_STALE}) then {
                ["ALIVE_fnc_ATOPlace - the claim on %1 is %2 s old and was never released; dropped", _x, round (time - _since)] call ALiVE_fnc_dump;
                [_consuming, _x] call ALIVE_fnc_hashRem;
            } else {
                _ids pushBackUnique _x;
            };
        } forEach _cKeys;
    };
    if (!isNil "ALiVE_ATO_consuming") then {
        {
            private _held = ALiVE_ATO_consuming getOrDefault [_x, []];
            private _since = _held param [1, time];
            if (_since isEqualType 0 && {(time - _since) > LATCH_STALE}) then {
                ["ALIVE_fnc_ATOPlace - the cross-instance claim on %1 by %2 is %3 s old and was never released; dropped",
                    _x, _held param [0, ""], round (time - _since)] call ALiVE_fnc_dump;
                ALiVE_ATO_consuming deleteAt _x;
            } else {
                _ids pushBackUnique _x;
            };
        } forEach (keys ALiVE_ATO_consuming);
    };
    _ids
};

// The cross-instance claim. Two instances of one faction sweeping the same
// airspace can both reach consume for one candidate, and the instance-level
// list above cannot see the other instance. A post-condition that re-reads
// the profile after unregistering cannot tell the two apart either, because
// getProfile hands out the live array and the loser still holds a usable copy
// of it. So the discriminator is a claim taken BEFORE anything is touched, in
// a global keyed by profile id.
//
// The test-and-set has to be one indivisible step. A scheduled script can be
// suspended between any two statements, so "is it claimed, then claim it"
// as two statements is exactly the race it is meant to close. isNil with a
// code argument runs that code in the unscheduled environment, in one go,
// and answers whether the code's result was nil; the winner's branch ends in
// nil and the loser's in false, which is how the answer comes back. The
// atomicity rests on the engine's documented behaviour of that command; no
// sibling in this codebase demonstrates it as a test-and-set.
//
// The value is [instance key, time]. A claim older than LATCH_STALE is one
// nobody released, and it is taken over rather than honoured, loudly, for
// the reason given at _fnc_claimedIds. The age test lives inside the same
// indivisible step as the claim, or it would be the two-statement race
// again with a third statement in front of it.
private _fnc_claimGlobal = {
    params [["_id", "", [""]], ["_key", "", [""]]];
    if (isNil "ALiVE_ATO_consuming") then { ALiVE_ATO_consuming = createHashMap };
    isNil {
        private _held = ALiVE_ATO_consuming getOrDefault [_id, []];
        private _fresh = count _held >= 2 && {(time - (_held param [1, 0])) <= LATCH_STALE};
        if (_fresh) then { false } else {
            if (count _held >= 2) then {
                ["ALIVE_fnc_ATOPlace - the cross-instance claim on %1 by %2 was never released; taken over", _id, _held param [0, ""]] call ALiVE_fnc_dump;
            };
            ALiVE_ATO_consuming set [_id, [_key, time]];
            nil
        }
    }
};

private _fnc_releaseGlobal = {
    params [["_id", "", [""]]];
    if (!isNil "ALiVE_ATO_consuming") then { ALiVE_ATO_consuming deleteAt _id };
    true
};

// Is a pass that can sleep already in progress? Answers "" when none is, or
// the name of the one that is. The flag is [name, startedAt] rather than a
// bare Boolean because nothing clears a Boolean on a script error: a throw
// anywhere inside a pass used to leave it set for the rest of the mission,
// after which the sweep adopted nothing, the deferred retry never ran, and
// placeInitial and restoreAll refused, all of it silent past the first log
// line. A flag older than LATCH_STALE is taken for that case, said out
// loud, and cleared, so a wedged instance costs one stale pass instead of
// the mission. Set with [name, time] and cleared with [] at the three sites
// that hold it; this is the only reader.
private _fnc_passRunning = {
    params ["_logic"];
    private _flag = [_logic, "passRunning", []] call ALIVE_fnc_hashGet;
    if !(_flag isEqualType [] && {count _flag >= 2}) exitWith { "" };
    private _owner = _flag param [0, ""];
    private _since = _flag param [1, 0];
    if (!(_owner isEqualType "") || {!(_since isEqualType 0)}) exitWith { "" };
    if ((time - _since) <= LATCH_STALE) exitWith { _owner };
    ["ALIVE_fnc_ATOPlace - a %1 pass started %2 s ago and never finished; its flag is cleared so passes can run again",
        _owner, round (time - _since)] call ALiVE_fnc_dump;
    [_logic, "passRunning", []] call ALIVE_fnc_hashSet;
    ""
};

// Create a hull for a tail and attach it. Answers "placed", "deferred", or
// the attach refusal. A hull this helper created and could not attach for a
// reason that will not change is deleted again, because a record with a hull
// standing beside it that nothing owns is worse than a record with no hull:
// the next restore would build a second one next to it. Only "remote" is left
// standing, and a hull just created on the server is local, so in practice
// that branch is the shape of the answer rather than a path anything takes.
private _fnc_placeHull = {
    params ["_logic", ["_tail", "", [""]], ["_class", "", [""]], ["_home", [], [[]]], ["_pylons", [], [[]]]];
    private _hull = [_logic, _class, _home, _pylons] call _fnc_createHull;
    if (isNull _hull) exitWith { "no hull" };
    ([_logic, "attach", [_tail, _hull]] call MAINCLASS) params [["_ok", false, [false]], ["_why", "", [""]]];
    if (_ok) exitWith { "placed" };
    if (_why isEqualTo "remote") exitWith { "deferred" };
    ["ALIVE_fnc_ATOPlace - %1 created for %2 and then refused by attach (%3), deleted again", _class, _tail, _why] call ALiVE_fnc_dump;
    deleteVehicle _hull;
    _why
};

// One new record and one new hull for initial placement. Everything it needs
// is bound here; the anchor is where to look, not where it will stand.
private _fnc_placeNew = {
    params ["_logic", ["_class", "", [""]], ["_anchor", [0,0,0], [[]]], ["_dir", 0, [0]], ["_airspaceName", "", [""]]];
    private _ledger = [_logic, "ledger", []] call ALIVE_fnc_hashGet;
    private _surface = [_logic, "surface", []] call ALIVE_fnc_hashGet;
    private _home = [_logic, _class, _anchor, _dir, objNull] call _fnc_homeFor;
    if (count _home < 3) exitWith { "" };
    ([_logic, _class, []] call _fnc_admit) params ["_ok", "_why", "_roles", "_caps"];
    if (!_ok) exitWith {
        ["ALIVE_fnc_ATOPlace - not placing %1: %2", _class, _why] call ALiVE_fnc_dump;
        ""
    };
    private _faction = [_logic, "faction", ""] call ALIVE_fnc_hashGet;
    private _tail = [_ledger, "createRecord", [_class, _faction, [_airspaceName], [_roles, _caps]]] call ALIVE_fnc_ATOLedger;
    [_ledger, "setHome", [_tail, _home]] call ALIVE_fnc_ATOLedger;
    // Reserved at once, so the next cascade this pass cannot be handed the
    // same stand while this hull is still settling onto it.
    [_surface, "reserve", [_home select 0, [_class] call _fnc_span]] call ALIVE_fnc_ATOSurface;
    private _r = [_logic, _tail, _class, _home, []] call _fnc_placeHull;
    // Only a hull attach actually took is reported as placed, the same rule
    // the sweep applies to its own return. A deferred hull is on the books
    // and reachable through deferredTails, and the sweep keeps asking for
    // it; reporting its tail here would hand the Kernel a row around a hull
    // it cannot see, which goes LOST on its first tick. A hull just created
    // on the server is local, so this is the shape of the answer rather than
    // a path anything takes.
    if (_r isEqualTo "deferred") exitWith { "" };
    if !(_r isEqualTo "placed") exitWith {
        // A record minted a moment ago for a hull that never came. Kept, as
        // every record is, and marked so a later restore tries again.
        [_ledger, "markUnplaceable", [_tail, _r]] call ALIVE_fnc_ATOLedger;
        ""
    };
    _tail
};

switch(_operation) do {

    case "create": {
        _result = [[
            ["class", MAINCLASS],
            // profile id -> when it was first seen by a sweep
            ["sightings", [] call ALIVE_fnc_hashCreate],
            // profile id -> why it was refused, most recently
            ["refusals", [] call ALIVE_fnc_hashCreate],
            ["factions", []],
            ["firstPassDone", false],
            // the module's own identity
            ["side", ""],
            ["faction", ""],
            // marker names; a sweep with no airspace given looks in all of them
            ["airspaces", []],
            ["useUAVs", true],
            ["placeAir", false],
            ["placeDrones", false],
            ["droneTypes", ""],
            // the collaborators, [] until configure hands them over
            ["ledger", []],
            ["surface", []],
            ["effect", []],
            // center, nodes, hq, isCarrier, airspace
            ["base", [] call ALIVE_fnc_hashCreate],
            // tail -> hull, for every hull this instance has taken on, whether
            // or not it is server-local yet. Session only.
            ["attached", [] call ALIVE_fnc_hashCreate],
            // tail -> [hull, retries] for hulls taken on but still remote
            ["deferred", [] call ALIVE_fnc_hashCreate],
            // profile id -> when this instance claimed it for adoption
            ["consuming", [] call ALIVE_fnc_hashCreate],
            // tail -> when its one logged rehome failure was written
            ["rehomeFailed", [] call ALIVE_fnc_hashCreate],
            // tails whose legacy profile came back but could not be adopted
            ["pendingLegacy", []],
            // [name, startedAt] while a pass that can sleep (sweep adoption,
            // placeInitial, restoreAll) is in progress, [] otherwise. Those
            // passes wait inside consume, and the Kernel's next tick can
            // start another before the first has finished; two passes
            // clearing and rebuilding the same reservations under each other
            // is how one stand gets two hulls. Read only through
            // _fnc_passRunning, which ages it.
            ["passRunning", []]
        ]] call ALIVE_fnc_hashCreate;
    };

    // Settings arrive as pairs, as the Tasker takes them, so the Kernel can
    // push whatever the module's attributes gave it. The four hash-valued
    // slots are only overwritten by a real hash: a [] handed in for one of
    // them would replace the seeded value with something every later read
    // trips over, and the fault would surface as an undefined variable a
    // long way from here. Airspace names that are not markers are reported
    // once, here, because a filter built on a name that resolves to nothing
    // removes every candidate silently.
    case "configure": {
        private _pairs = _args;
        if !(_pairs isEqualType []) then { _pairs = [] };
        {
            if (_x isEqualType [] && {count _x > 1}) then {
                private _key = _x select 0;
                private _value = _x select 1;
                if (_key in ["ledger", "surface", "effect", "base"]) then {
                    if ([_value] call ALIVE_fnc_isHash) then {
                        [_logic, _key, _value] call ALIVE_fnc_hashSet;
                    } else {
                        ["ALIVE_fnc_ATOPlace - configure ignored %1: not a hash", _key] call ALiVE_fnc_dump;
                    };
                } else {
                    [_logic, _key, _value] call ALIVE_fnc_hashSet;
                };
            };
        } forEach _pairs;

        {
            // markerShape, not markerType. markerType is the ICON a marker
            // draws and an area marker has none, so asking that reported every
            // correctly drawn airspace as missing: the warning fired on a
            // mission whose marker the commander had just used to find its
            // base. An airspace is always an area, so ELLIPSE or RECTANGLE is
            // what proves it is there.
            if (_x isEqualType "" && {(markerShape _x) isEqualTo ""}) then {
                ["ALIVE_fnc_ATOPlace - airspace %1 is not a marker; candidates inside it will never be found", _x] call ALiVE_fnc_dump;
            };
        } forEach ([_logic, "airspaces", []] call ALIVE_fnc_hashGet);

        _result = true;
    };

    // ---- accessors ---------------------------------------------------------

    // The hull for a tail, or objNull. Truthful for a deferred hull too: it is
    // written into `attached` before its locality is tested, so a caller that
    // asks about a tail the sweep has not reported yet still gets the object.
    case "objFor": {
        private _tail = _args;
        if !(_tail isEqualType "") then { _tail = "" };
        private _attached = [_logic, "attached", []] call ALIVE_fnc_hashGet;
        _result = [_attached, _tail, objNull] call ALIVE_fnc_hashGet;
        if !(_result isEqualType objNull) then { _result = objNull };
    };

    // Tails whose attach SUCCEEDED: the hull is local and shielded. This, and
    // never a sweep's return on its own, is what a row may be built from.
    case "attachedTails": {
        private _attached = [_logic, "attached", []] call ALIVE_fnc_hashGet;
        private _deferred = [_logic, "deferred", []] call ALIVE_fnc_hashGet;
        _result = (+(_attached select 1)) select { !(_x in (_deferred select 1)) };
    };

    // Tails taken on but not yet attachable, because the hull is still owned
    // by another machine. Retried on every sweep.
    case "deferredTails": {
        private _deferred = [_logic, "deferred", []] call ALIVE_fnc_hashGet;
        _result = +(_deferred select 1);
    };

    // Forget a hull. The Kernel calls this when a row goes LOST, so a dead
    // object does not sit in `attached` answering for a tail that has none.
    case "detach": {
        private _tail = _args;
        if !(_tail isEqualType "") then { _tail = "" };
        [[_logic, "attached", []] call ALIVE_fnc_hashGet, _tail] call ALIVE_fnc_hashRem;
        [[_logic, "deferred", []] call ALIVE_fnc_hashGet, _tail] call ALIVE_fnc_hashRem;
        _result = true;
    };

    case "claimed": { _result = [_logic] call _fnc_claimedIds };

    case "pendingLegacy": { _result = +([_logic, "pendingLegacy", []] call ALIVE_fnc_hashGet) };

    // ---- may we have this one? --------------------------------------------
    // Answers [true] or [false, reason] or [false, reason, true] where the
    // third element says the reason is transient, so the sweep keeps the
    // candidate's sighting and offers it again when the reason clears rather
    // than making it serve the gap afresh. Reads the world but changes
    // nothing, so it can be asked as often as a caller likes.
    case "admissible": {
        _args params [["_vehId", "", [""]], ["_claimed", [], [[]]], ["_claimedComplete", false, [false]]];

        if (_vehId isEqualTo "") exitWith { _result = [false, "no profile id"] };

        // A record already names this profile as the one it came from, or an
        // adoption of it is in flight somewhere. Adopting it again is how one
        // airframe becomes two. The caller's list is unioned with everything
        // this instance can see for itself, so the rule holds whether or not
        // the caller remembered to pass one.
        //
        // A caller that vouches its list is complete is taken at its word and
        // the union is skipped. Two callers need that: the sweep, which has
        // already computed the list once and would otherwise pay for a deep
        // copy of the ledger per candidate; and restore, whose legacy path
        // is asking about the very id its own record claims, and would be
        // refused "already claimed" by its own record if the union ran.
        private _allClaimed = +_claimed;
        if (!_claimedComplete) then {
            { _allClaimed pushBackUnique _x } forEach ([_logic] call _fnc_claimedIds);
        };
        if (_vehId in _allClaimed) exitWith { _result = [false, "already claimed by a record"] };

        private _profile = [_vehId] call _fnc_profile;
        if (_profile isEqualTo []) exitWith { _result = [false, "no such profile"] };

        private _type = [_profile, "type", ""] call ALIVE_fnc_hashGet;
        if !(_type isEqualTo "vehicle") exitWith { _result = [false, "not a vehicle profile"] };

        private _objectType = [_profile, "objectType", ""] call ALIVE_fnc_hashGet;
        if !((toLower _objectType) in ["helicopter", "plane"]) exitWith {
            _result = [false, format ["not an aircraft (%1)", _objectType]];
        };

        // Everything below writes a reason into a plain flag and the case
        // tests it once, afterwards. Setting the answer from inside a nested
        // block and then working out whether it was set is the shape that has
        // already produced a refusal reported as success and a position
        // computed and discarded, both in this module.
        private _why = "";
        private _transient = false;

        // Somebody else's job in progress. Logistics marks every delivery
        // vehicle and its crew busy for the length of the delivery, and the
        // old module adopted them mid-flight anyway, which is the race the
        // two-sighting rule was written against. Busy clears when the job
        // ends, so the sighting is kept.
        if ([_profile, "busy", false] call ALIVE_fnc_hashGet) then {
            _why = "busy with another module"; _transient = true;
        };

        // A cargo entity is somebody being carried somewhere. Not ours.
        private _cargo = [_profile, "entitiesInCargoOf", []] call ALIVE_fnc_hashGet;
        if (_why isEqualTo "" && {_cargo isEqualType []} && {count _cargo > 0}) then {
            _why = "carries a profiled cargo";
        };

        // The crew. Uncrewed is fine. One crew is fine when that crew's only
        // commanded vehicle is this airframe, is not a player's, and is not
        // busy. More than one crew is not a pair. An id that does not resolve
        // counts as no crew, for the reason given at _fnc_pairOf.
        private _ents = [_profile, "entitiesInCommandOf", []] call ALIVE_fnc_hashGet;
        if !(_ents isEqualType []) then { _ents = [] };
        private _live = [];
        {
            if (_x isEqualType "" && {!(_x isEqualTo _vehId)}) then {
                private _e = [_x] call _fnc_profile;
                if !(_e isEqualTo []) then { _live pushBack _e };
            };
        } forEach _ents;
        if (_why isEqualTo "" && {count _live > 1}) then { _why = "more than one crew" };
        if (_why isEqualTo "" && {count _live == 1}) then {
            private _ent = _live select 0;
            if ([_ent, "isPlayer", false] call ALIVE_fnc_hashGet) then { _why = "crewed by a player profile" };
            if (_why isEqualTo "" && {[_ent, "busy", false] call ALIVE_fnc_hashGet}) then {
                _why = "crew busy with another module"; _transient = true;
            };
            private _commands = [_ent, "vehiclesInCommandOf", []] call ALIVE_fnc_hashGet;
            if (_why isEqualTo "" && {!(_commands isEqualTo [_vehId])}) then { _why = "crew commands other vehicles" };
            // Combat support marks its crew group as well as its vehicle. The
            // mark is written without the public flag, so it may not be
            // visible here; it is read because it is cheap, and the mark on
            // the OBJECT below is the one relied on.
            if (_why isEqualTo "" && {[_ent, "active", false] call ALIVE_fnc_hashGet}) then {
                private _grp = [_ent, "group", grpNull] call ALIVE_fnc_hashGet;
                if (_grp isEqualType grpNull && {!isNull _grp} && {_grp getVariable ["ALIVE_profileIgnore", false]}) then {
                    _why = "crew group is marked ALIVE_profileIgnore";
                };
            };
        };

        // The backstop. If the profile is spawned, the object itself may carry
        // a mark from another system saying it is not available. Checked on
        // the object rather than the profile because that is where the other
        // systems write it. And a live hull with a player in it, or in the
        // air, is not taken: adopting one mid-flight deletes its crew in the
        // air, and the row that could recover from that does not exist until
        // after attach. Airborne clears by itself, so the sighting is kept.
        private _obj = [_profile, "vehicle", objNull] call ALIVE_fnc_hashGet;
        if (_why isEqualTo "" && {_obj isEqualType objNull} && {!isNull _obj}) then {
            private _mark = "";
            { if (_mark isEqualTo "" && {_obj getVariable [_x, false]}) then { _mark = _x } } forEach FOREIGN_MARKS;
            if !(_mark isEqualTo "") then { _why = format ["object is marked %1", _mark] };
            if (_why isEqualTo "" && {[_obj] call _fnc_playerAboard}) then { _why = "a player is aboard" };
            if (_why isEqualTo "" && {[_obj] call _fnc_airborne}) then {
                _why = "airborne, re-offered when it lands"; _transient = true;
            };
        };

        if !(_why isEqualTo "") exitWith {
            _result = if (_transient) then { [false, _why, true] } else { [false, _why] };
        };

        _result = [true];
    };

    // ---- the sweep ---------------------------------------------------------
    // sweep(airspace, now, claimedLegacyIds) -> the tails adopted on this pass
    // whose attach succeeded.
    //
    // Called twice or more; adopts nothing the first time it sees a candidate
    // and only takes it once it has survived the gap. Also the heartbeat for
    // deferred hulls: each pass asks for ownership of them again.
    case "sweep": {
        _args params [["_airspace", "", [""]], ["_now", 0, [0]], ["_claimed", [], [[]]]];

        private _factions = [_logic, "factions", []] call ALIVE_fnc_hashGet;
        private _sightings = [_logic, "sightings", []] call ALIVE_fnc_hashGet;
        private _refusals = [_logic, "refusals", []] call ALIVE_fnc_hashGet;
        private _airspaces = [_logic, "airspaces", []] call ALIVE_fnc_hashGet;

        // Once per pass, not once per candidate.
        private _allClaimed = +_claimed;
        { _allClaimed pushBackUnique _x } forEach ([_logic] call _fnc_claimedIds);

        // Gather from the registry, per faction.
        //
        // getProfilesByFaction is used rather than the type-filtered sibling on
        // purpose. That one reads its inner key with a two-argument hashGet,
        // which answers nil for a key that is absent, and a nil assignment
        // deletes the variable rather than emptying it, so asking about a
        // vehicle type a faction has never registered takes the getter down on
        // its own trailing read. This one passes a default and cannot.
        private _ids = [];
        if (!isNil "ALIVE_profileHandler") then {
            {
                private _got = [ALIVE_profileHandler, "getProfilesByFaction", _x] call ALIVE_fnc_profileHandler;
                if (!isNil "_got" && {_got isEqualType []}) then {
                    { _ids pushBackUnique _x } forEach _got;
                };
            } forEach _factions;
        };

        // Only candidates inside the airspace asked for, else inside any of
        // the instance's airspaces, else everywhere. The fallback is for an
        // instance with NO airspaces; an instance whose configured names do
        // not resolve gets nothing, and that is said out loud below rather
        // than found six sweeps later.
        private _before = count _ids;
        if (!(_airspace isEqualTo "") || {count _airspaces > 0}) then {
            private _zones = if (_airspace isEqualTo "") then { _airspaces } else { [_airspace] };
            _ids = _ids select {
                private _p = [_x] call _fnc_profile;
                private _pos = if (_p isEqualTo []) then { [] } else { [_p, "position", []] call ALIVE_fnc_hashGet };
                if !(_pos isEqualType []) then { _pos = [] };
                // Inside the findIf, _x is the zone; the profile id is not
                // needed again, so nothing is lost by the rebinding.
                count _pos >= 2 && {(_zones findIf { _pos inArea _x }) > -1}
            };
            if (_before > 0 && {count _ids == 0}) then {
                ["ALIVE_fnc_ATOPlace - sweep: %1 candidates and none inside %2", _before, _zones] call ALiVE_fnc_dump;
            };
        };

        // Judge each one, and remember when we first saw the ones we would take.
        private _ready = [];
        private _seen = [];
        {
            private _id = _x;
            // The list was computed once above and is complete; admissible
            // is told so and does not rebuild it per candidate.
            private _verdict = [_logic, "admissible", [_id, _allClaimed, true]] call MAINCLASS;

            if (_verdict param [0, false]) then {
                _seen pushBack _id;
                private _first = [_sightings, _id, -1] call ALIVE_fnc_hashGet;
                if (_first < 0) then {
                    [_sightings, _id, _now] call ALIVE_fnc_hashSet;
                } else {
                    if (_now - _first >= SIGHTING_GAP) then { _ready pushBack _id };
                };
            } else {
                // A transient refusal keeps its sighting: an aircraft that is
                // busy or in the air right now is the same aircraft when that
                // clears, and should not serve the gap again.
                if (_verdict param [2, false]) then { _seen pushBack _id };
                // Remember the reason, but only say it once per profile. A
                // refusal that repeats every sweep buries everything else.
                private _reason = _verdict param [1, ""];
                private _last = [_refusals, _id, ""] call ALIVE_fnc_hashGet;
                if !(_last isEqualTo _reason) then {
                    [_refusals, _id, _reason] call ALIVE_fnc_hashSet;
                    ["ALIVE_fnc_ATOPlace - %1 not adopted: %2", _id, _reason] call ALiVE_fnc_dump;
                };
            };
        } forEach _ids;

        // A candidate that has gone away loses its sighting, so an aircraft
        // that appears, vanishes and appears again has to serve the gap afresh
        // rather than inheriting credit for a profile that no longer exists.
        {
            if !(_x in _seen) then { [_sightings, _x, nil] call ALIVE_fnc_hashSet };
        } forEach (+(_sightings select 1));

        // ---- adoption -------------------------------------------------------
        // Everything from here changes the world and needs to be able to wait,
        // so it is refused as a whole, once, when the caller forgot to spawn
        // it, rather than as one refusal line per candidate per pass. The
        // sightings above are intact either way.
        private _tails = [];
        private _notReady = [_logic] call _fnc_notReady;
        private _busy = [_logic] call _fnc_passRunning;
        private _mayAdopt = isServer && {canSuspend} && {_notReady isEqualTo ""} && {_busy isEqualTo ""};
        if (!_mayAdopt && {count _ready > 0}) then {
            ["ALIVE_fnc_ATOPlace - sweep cannot adopt %1 candidate(s): %2", count _ready,
                if (!isServer) then {"not the server"} else {
                    if (!canSuspend) then {"sweep must be called scheduled"} else {
                        if !(_busy isEqualTo "") then {format ["a %1 pass is still running", _busy]} else {_notReady}
                    }
                }] call ALiVE_fnc_dump;
        };

        // The flag is set here and cleared at the end of the block, and the
        // block has no early exit, so this code cannot leave it set; a throw
        // inside the block is what the flag's age is for.
        if (_mayAdopt) then {
            [_logic, "passRunning", ["sweep", time]] call ALIVE_fnc_hashSet;
            private _surface = [_logic, "surface", []] call ALIVE_fnc_hashGet;
            private _attached = [_logic, "attached", []] call ALIVE_fnc_hashGet;
            private _deferred = [_logic, "deferred", []] call ALIVE_fnc_hashGet;
            private _effect = [_logic, "effect", []] call ALIVE_fnc_hashGet;

            // Reservations are per-pass scratch. Start the pass with exactly
            // the homes the ledger knows, so nothing adopted below can be
            // handed the stand of a sibling that is away.
            [_surface, "clearReservations"] call ALIVE_fnc_ATOSurface;
            [_logic] call _fnc_reserveHomes;

            {
                private _id = _x;
                private _got = [_logic, "adoptPair", [_id, "", []]] call MAINCLASS;
                if (_got isEqualType "") then {
                    // Reported only when the hull is really in hand. A tail
                    // whose hull is still remote is not one the Kernel can
                    // build a row around, and a row around a null object goes
                    // LOST on its first tick and orders a replacement for an
                    // aircraft that is standing right there.
                    private _hull = [_attached, _got, objNull] call ALIVE_fnc_hashGet;
                    if (!isNull _hull && {alive _hull} && {([_deferred, _got, []] call ALIVE_fnc_hashGet) isEqualTo []}) then {
                        _tails pushBack _got;
                    };
                } else {
                    private _reason = _got param [1, ""];
                    private _last = [_refusals, _id, ""] call ALIVE_fnc_hashGet;
                    if !(_last isEqualTo _reason) then {
                        [_refusals, _id, _reason] call ALIVE_fnc_hashSet;
                        ["ALIVE_fnc_ATOPlace - %1 not adopted: %2", _id, _reason] call ALiVE_fnc_dump;
                    };
                };
            } forEach _ready;

            // ---- deferred hulls ---------------------------------------------
            // Ask for ownership again and re-test. Attaching alone would never
            // get one back: attach refuses a remote hull and nothing else ever
            // re-issues the transfer, so without this a pair whose crew lived
            // on a headless client stayed remote for the rest of the mission.
            //
            // Retried without limit. Giving up would mean either leaving the
            // hull in `deferred` untried, which is the limbo this exists to
            // prevent, or handing a hull the session never attached to over to
            // the roster, where a loss could not even be marked. The log is
            // quietened instead.
            //
            // The keys and values are copied before the walk, and every change
            // to the live hash is by KEY. Walking a copy and deleting by index
            // in the original is off by one after the first removal, so a hull
            // that did attach could stay queued and one that did not could be
            // dropped.
            private _keys = +(_deferred select 1);
            private _values = +(_deferred select 2);
            {
                private _tail = _x;
                (_values select _forEachIndex) params [["_o", objNull, [objNull]], ["_tries", 0, [0]]];
                if (isNull _o || {!alive _o}) then {
                    ["ALIVE_fnc_ATOPlace - deferred hull for %1 is gone, dropped", _tail] call ALiVE_fnc_dump;
                    [_deferred, _tail] call ALIVE_fnc_hashRem;
                    [_attached, _tail] call ALIVE_fnc_hashRem;
                } else {
                    private _r = [_effect, "apply", ["takeOwnership", _o, [], []]] call ALIVE_fnc_ATOEffect;
                    // setOwner takes effect a little after it is asked for, so
                    // a test in the same breath would see the old owner.
                    if (!((_r param [0, ""]) isEqualTo "refused") && {!(_r param [1, false])}) then {
                        private _until = time + LOCALITY_WAIT;
                        waitUntil { sleep 0.5; isNull _o || {local _o} || {time > _until} };
                    };
                    private _a = [_logic, "attach", [_tail, _o]] call MAINCLASS;
                    if !(_a param [0, false]) then {
                        [_deferred, _tail, [_o, _tries + 1]] call ALIVE_fnc_hashSet;
                        if (((_tries + 1) mod DEFERRED_LOG_EVERY) == 0) then {
                            ["ALIVE_fnc_ATOPlace - %1 still not attachable after %2 sweeps: %3 (%4)",
                                _tail, _tries + 1, _a param [1, ""], _r param [2, ""]] call ALiVE_fnc_dump;
                        };
                    };
                };
            } forEach _keys;

            [_logic, "passRunning", []] call ALIVE_fnc_hashSet;
        };

        [_logic, "firstPassDone", true] call ALIVE_fnc_hashSet;
        _result = _tails;
    };

    case "firstPassDone": { _result = [_logic, "firstPassDone", false] call ALIVE_fnc_hashGet };

    // How many candidates a sweep is currently holding, whether or not they
    // have served their gap. The Tasker gates "not enough aircraft for an
    // operation" on a count like this, and needs to be told rather than to
    // reach in here for it.
    case "candidateCount": {
        // Parenthesised deliberately: call and select are both binary, so
        // leaving it to precedence is a coin toss about which one binds first.
        private _s = [_logic, "sightings", []] call ALIVE_fnc_hashGet;
        _result = count (_s select 1);
    };

    // ---- taking a pair over -----------------------------------------------
    // adoptPair(vehId, entId | "", homeHint, intoTail | "") -> tail, or
    // ["refused", reason].
    //
    // Every refusal before the consume leaves the profile exactly as found.
    // The claim on the id is written before the home is looked for, so from
    // that moment no other pass of this instance can start on the same
    // profile, and it is released on every exit, refusals included.
    //
    // intoTail is for Resupply. A delivered replacement is consumed into the
    // record it replaces, so the tail, callsign and roles are inherited and
    // the home is re-validated rather than a second record minted for an
    // aircraft the campaign already has.
    case "adoptPair": {
        _args params [["_vehId", "", [""]], ["_entId", "", [""]], ["_homeHint", [], [[]]], ["_intoTail", "", [""]]];
        _result = ["refused", ""];

        if (!isServer) exitWith { _result = ["refused", "not server"] };
        if (!canSuspend) exitWith {
            ["ALIVE_fnc_ATOPlace - adoptPair must be called scheduled"] call ALiVE_fnc_dump;
            _result = ["refused", "must run scheduled"];
        };
        private _notReady = [_logic] call _fnc_notReady;
        if !(_notReady isEqualTo "") exitWith {
            ["ALIVE_fnc_ATOPlace - adoptPair refused: %1", _notReady] call ALiVE_fnc_dump;
            _result = ["refused", _notReady];
        };
        if (_vehId isEqualTo "") exitWith { _result = ["refused", "no profile id"] };

        private _ledger = [_logic, "ledger", []] call ALIVE_fnc_hashGet;
        private _surface = [_logic, "surface", []] call ALIVE_fnc_hashGet;
        private _base = [_logic, "base", []] call ALIVE_fnc_hashGet;
        private _consuming = [_logic, "consuming", []] call ALIVE_fnc_hashGet;

        // An aircraft that already exists cannot join a base with no airfield,
        // and this is measured rather than cautious. A helicopter created the
        // ordinary way can NEVER afterwards be put into the air: teleported up
        // with its engine running it was dead in fifteen seconds, frozen first
        // or not, pushed or not, with somewhere to go or nowhere at all. The
        // fleet at an ingress point is created in flight for that reason, so an
        // aircraft taken over off the ground would hold its point perfectly
        // well and then drown the first time it was asked to fly.
        //
        // Left exactly as it was found, which is what refusing here means. That
        // includes a replacement flown in by logistics, and the resupply half
        // knows it: a commander like this builds its own replacements instead
        // of asking for one to be delivered.
        if ([_base] call ALIVE_fnc_isHash
            && {[_base, "isVirtual", false] call ALIVE_fnc_hashGet}) exitWith {
            _result = ["refused", "this commander flies from an ingress point and can only use aircraft created there"];
        };

        // The record a delivery is going into, if there is one.
        private _target = [];
        private _why = "";
        if !(_intoTail isEqualTo "") then {
            _target = [_ledger, "get", _intoTail] call ALIVE_fnc_ATOLedger;
            if (_target isEqualTo []) then { _why = "no such record" } else {
                if !(([_target, "status", ""] call ALIVE_fnc_hashGet) isEqualTo "lost") then { _why = "record is not lost" };
                private _held = [_logic, "objFor", _intoTail] call MAINCLASS;
                if (_why isEqualTo "" && {!isNull _held} && {alive _held}) then { _why = "record already has a hull" };
            };
        };
        if !(_why isEqualTo "") exitWith { _result = ["refused", _why] };

        private _verdict = [_logic, "admissible", [_vehId, []]] call MAINCLASS;
        if !(_verdict param [0, false]) exitWith { _result = ["refused", _verdict param [1, ""]] };

        // Positive confirmation: the profile is in the handler's hands now.
        private _veh = [_vehId] call _fnc_profile;
        if (_veh isEqualTo []) exitWith { _result = ["refused", "no such profile"] };

        private _class = [_veh, "vehicleClass", ""] call ALIVE_fnc_hashGet;
        private _pylons = [_veh, "pylonLoadout", []] call ALIVE_fnc_hashGet;
        if !(_pylons isEqualType []) then { _pylons = [] };
        private _active = [_veh, "active", false] call ALIVE_fnc_hashGet;
        private _obj = [_veh, "vehicle", objNull] call ALIVE_fnc_hashGet;
        if !(_obj isEqualType objNull) then { _obj = objNull };

        ([_logic, _class, _pylons] call _fnc_admit) params ["_ok", "_admitWhy", "_roles", "_caps"];
        if (!_ok) exitWith {
            ["ALIVE_fnc_ATOPlace - not adopting %1 (%2): %3", _vehId, _class, _admitWhy] call ALiVE_fnc_dump;
            _result = ["refused", _admitWhy];
        };

        // A crewed pair reached through the vehicle id.
        if (_entId isEqualTo "") then { _entId = [_veh] call _fnc_pairOf };

        // ---- the claim ------------------------------------------------------
        // Written here, before the home search and before consume, and
        // released on every path out. Between this line and the record being
        // created, nothing else names this profile: not the ledger, which has
        // no record yet, and not the profile system, which does not know it is
        // spoken for. That window is the whole reason the claim exists; a
        // claim written after consume would name the profile only once it was
        // already gone.
        [_consuming, _vehId, time] call ALIVE_fnc_hashSet;

        // Home. The hint first, then the record's own home for a delivery
        // (the hull stands at the delivery point, which is not where it
        // lives), then wherever the live hull stands, then the profile's
        // position. The live hull is its own object for the validate, so it
        // never blocks itself.
        //
        // The hint's canonical shape is a bare POSITION, and that is what
        // Resupply passes. A full home [pos, dir, surface] is accepted as
        // well and its position taken, because the record's home is the
        // natural thing for a caller to have in its hand, and the first
        // version of this read one as a position: the whole triple became
        // the anchor, _fnc_homeFor built [[x,y,z], dir, 0] out of it, and
        // Surface's nearestObjects threw on the nested array, after the claim
        // above was written and before any release, so every delivered
        // replacement was refused as already claimed for the rest of the
        // session. The two shapes are told apart by their first element: a
        // home's is an array, a position's is a number.
        private _live = _active && {!isNull _obj};
        private _anchor = [];
        // Whether anybody actually said where this aircraft belongs. A hint and
        // a stored home are instructions and are obeyed; the aircraft's own
        // position is not, it is just where it happens to be standing.
        private _chosen = false;
        if (count _homeHint >= 3 && {(_homeHint select 0) isEqualType []}) then {
            _anchor = +(_homeHint select 0);
            _chosen = true;
        } else {
            if (count _homeHint >= 2 && {(_homeHint select 0) isEqualType 0}) then {
                _anchor = +_homeHint;
                _chosen = true;
            };
        };
        if (count _anchor < 2 && {!(_target isEqualTo [])}) then {
            private _recHome = [_target, "home", []] call ALIVE_fnc_hashGet;
            if (count _recHome >= 3) then { _anchor = _recHome select 0; _chosen = true };
        };

        // Nothing said where it belongs, so it belongs at its commander's
        // airfield. Parking used to be searched for around the aircraft itself,
        // which is why an Apache that spawned 590 m from the field was parked on
        // the shoreline: the search reaches 400 m, so every pad on the airfield
        // was 190 m outside it and an empty one was never even a candidate.
        //
        // The airfield only. A commander with no airfield holds its aircraft at a
        // ring of points around its ingress marker and the cascade handles that
        // already, so a virtual base is left alone.
        private _preferAirfield = false;
        if (!_chosen) then {
            private _baseHash = [_logic, "base", []] call ALIVE_fnc_hashGet;
            if ([_baseHash] call ALIVE_fnc_isHash
                && {!([_baseHash, "isVirtual", false] call ALIVE_fnc_hashGet)}
            ) then {
                private _bp = [_baseHash, "basePos", [0,0,0]] call ALIVE_fnc_hashGet;
                if (_bp isEqualType [] && {count _bp >= 2} && {!(_bp isEqualTo [0,0,0])}) then {
                    _anchor = [_bp select 0, _bp select 1, 0];
                    _preferAirfield = true;
                };
            };
        };

        if (count _anchor < 2 && {_live}) then { _anchor = getPosATL _obj };
        if (count _anchor < 2) then { _anchor = [_veh, "position", [0,0,0]] call ALIVE_fnc_hashGet };
        private _dir = 0;
        if (_live) then { _dir = getDir _obj } else {
            private _stored = [_veh, "direction", 0] call ALIVE_fnc_hashGet;
            if (_stored isEqualType 0) then { _dir = _stored };
        };
        private _own = if (_live) then { _obj } else { objNull };
        private _home = [_logic, _class, _anchor, _dir, _own, _preferAirfield] call _fnc_homeFor;
        if (count _home < 3) exitWith {
            [_consuming, _vehId] call ALIVE_fnc_hashRem;
            _result = ["refused", "no home"];
        };

        // Reserved NOW, the moment the home is known, not after consume.
        // consume's live branch waits up to nine seconds, and for the whole
        // of that wait the stand was neither recorded on a record nor
        // reserved on the surface, so a concurrent pass's cascade could hand
        // the same spot to a second record and the two would then take turns
        // evicting each other. Taken back on every refusal below; a refusal
        // that kept it would block a real stand until the next sweep.
        [_surface, "reserve", [_home select 0, [_class] call _fnc_span]] call ALIVE_fnc_ATOSurface;

        // ---- the one irreversible step --------------------------------------
        ([_logic, "consume", [_vehId, _entId, _home]] call MAINCLASS) params [["_hull", objNull, [objNull]], ["_crossed", false, [false]]];

        // consume says which side of its point of no return it stopped on,
        // and that answer, not the registry, is what decides here. Re-reading
        // the registry cannot tell "consumed" from "refused, and somebody
        // else removed the profile meanwhile": the profile is absent in both.
        // Its own clean refusal "vehicle profile not found" is the second
        // case, and so is losing the cross-instance claim to an instance that
        // then finished, and so is the aircraft being shot down during the
        // home search above. The first version of this minted a record for
        // every one of those, present with no hull, which markLost then
        // refused for ever, placeInitial counted toward its gate, and the
        // next load built into a free aircraft. Not crossed means the profile
        // was not touched, and nothing is created.
        if (!_crossed) exitWith {
            [_logic, _home, _class] call _fnc_unreserve;
            [_consuming, _vehId] call ALIVE_fnc_hashRem;
            _result = ["refused", "consume refused"];
        };

        // Crossed, and the hull was lost on the way back (deleted, or killed
        // during the ownership wait). For a delivery the record stays lost
        // and this REFUSES, so Resupply falls back to building one at the
        // stand. Reporting the tail would have it book the delivery as done
        // and clear the order, and with the record lost and nothing left to
        // order for it the airframe would drop out of the campaign.
        if (isNull _hull && {!(_intoTail isEqualTo "")}) exitWith {
            [_logic, _home, _class] call _fnc_unreserve;
            [_consuming, _vehId] call ALIVE_fnc_hashRem;
            ["ALIVE_fnc_ATOPlace - %1 consumed for %2 but the hull was lost on the way; the record stays lost so a replacement is built instead",
                _vehId, _intoTail] call ALiVE_fnc_dump;
            _result = ["refused", "consumed but the hull was lost"];
        };

        private _tail = _intoTail;
        if (_tail isEqualTo "") then {
            // The airspace the home falls in, else the base's. A flag and a
            // plain if, not an exitWith inside the loop: the answer is set in
            // one place and read after the loop.
            private _airspaceName = "";
            {
                if (_airspaceName isEqualTo "" && {_x isEqualType ""} && {(_home select 0) inArea _x}) then { _airspaceName = _x };
            } forEach ([_logic, "airspaces", []] call ALIVE_fnc_hashGet);
            if (_airspaceName isEqualTo "") then { _airspaceName = [_base, "airspace", ""] call ALIVE_fnc_hashGet };
            _tail = [_ledger, "createRecord", [_class, [_logic, "faction", ""] call ALIVE_fnc_hashGet,
                [_airspaceName], [_roles, _caps]]] call ALIVE_fnc_ATOLedger;
            [_ledger, "setHome", [_tail, _home]] call ALIVE_fnc_ATOLedger;
        } else {
            // Inherited record: roles and callsign stay. The home is written
            // only when the re-validation moved it.
            if !(([_target, "home", []] call ALIVE_fnc_hashGet) isEqualTo _home) then {
                [_ledger, "setHome", [_tail, _home]] call ALIVE_fnc_ATOLedger;
            };
        };
        // The reservation for this stand was taken above, before consume, and
        // stays: the hull is still settling onto it.

        [_consuming, _vehId] call ALIVE_fnc_hashRem;

        if (isNull _hull) exitWith {
            // A new record for an aircraft that really was taken and then
            // lost. Marked unplaceable with the reason rather than left
            // present with nothing behind it: present with no hull counts
            // toward placeInitial's gate and cannot be marked lost this
            // session, while unplaceable is retried by every restore with
            // the reason on the books.
            [_ledger, "markUnplaceable", [_tail, "consumed but the hull was lost"]] call ALIVE_fnc_ATOLedger;
            ["ALIVE_fnc_ATOPlace - %1 consumed from %2 but no hull came back; the record stands unplaceable and the next restore builds it",
                _tail, _vehId] call ALiVE_fnc_dump;
            _result = _tail;
        };

        ([_logic, "attach", [_tail, _hull]] call MAINCLASS) params [["_attached", false, [false]], ["_attachWhy", "", [""]]];
        if (!_attached && {!(_attachWhy isEqualTo "remote")}) then {
            ["ALIVE_fnc_ATOPlace - %1 consumed from %2 but attach refused it: %3", _tail, _vehId, _attachWhy] call ALiVE_fnc_dump;
        };
        _result = _tail;
    };

    // ---- consuming a profile ------------------------------------------------
    // consume(vehId, entId | "", home) -> [hull, crossed]. hull is objNull on
    // a refusal, and objNull after a crossing whose hull was lost on the way
    // back; crossed says which of those it is, and is the ONLY thing a
    // caller may decide that from. The registry cannot tell them apart: a
    // clean refusal for a profile that is not there and a completed consume
    // both leave the profile absent.
    //
    // One linear pass with a reason string. Nothing destructive happens while
    // the reason is non-empty, and every check that could refuse comes before
    // the first thing that cannot be undone. Scheduled, because it waits: for
    // the crew to leave the seats, and for the hull to become ours.
    //
    // The vehicle profile's own `destroy` is never used. On an active profile
    // that deletes the hull, which is the one thing this must not do. The
    // ENTITY's destroy is used deliberately over a bare unregister, because it
    // is the only path that also detaches the command router, which a bare
    // unregister leaves pointing at a dead profile.
    case "consume": {
        _args params [["_vehId", "", [""]], ["_entId", "", [""]], ["_home", [], [[]]]];
        _result = [objNull, false];

        if (!isServer) exitWith {
            ["ALIVE_fnc_ATOPlace - consume refused for %1: not the server", _vehId] call ALiVE_fnc_dump;
        };
        if (!canSuspend) exitWith {
            ["ALIVE_fnc_ATOPlace - consume refused for %1: must be called scheduled", _vehId] call ALiVE_fnc_dump;
        };
        private _notReady = [_logic] call _fnc_notReady;
        if !(_notReady isEqualTo "") exitWith {
            ["ALIVE_fnc_ATOPlace - consume refused for %1: %2", _vehId, _notReady] call ALiVE_fnc_dump;
        };

        private _ledger = [_logic, "ledger", []] call ALIVE_fnc_hashGet;
        private _effect = [_logic, "effect", []] call ALIVE_fnc_hashGet;
        private _key = [_ledger, "instanceKey", ""] call ALIVE_fnc_hashGet;
        if (_key isEqualTo "") then { _key = [_logic, "faction", ""] call ALIVE_fnc_hashGet };

        private _veh = [_vehId] call _fnc_profile;
        if (_veh isEqualTo []) exitWith {
            ["ALIVE_fnc_ATOPlace - consume refused for %1: vehicle profile not found", _vehId] call ALiVE_fnc_dump;
        };
        if !(([_veh, "type", ""] call ALIVE_fnc_hashGet) isEqualTo "vehicle") exitWith {
            ["ALIVE_fnc_ATOPlace - consume refused for %1: not a vehicle profile", _vehId] call ALiVE_fnc_dump;
        };

        // The cross-instance claim. The loser logs and walks away with the
        // profile untouched; that is the contract's "loser logs" case, and it
        // has to be decided here, before anything is read for a decision.
        if !([_vehId, _key] call _fnc_claimGlobal) exitWith {
            ["ALIVE_fnc_ATOPlace - consume refused for %1: being consumed by another instance", _vehId] call ALiVE_fnc_dump;
        };

        // ---- pre-checks, no writes ----------------------------------------
        private _why = "";
        private _ent = [];
        private _class = [_veh, "vehicleClass", ""] call ALIVE_fnc_hashGet;
        private _pylons = [_veh, "pylonLoadout", []] call ALIVE_fnc_hashGet;
        if !(_pylons isEqualType []) then { _pylons = [] };

        private _cargo = [_veh, "entitiesInCargoOf", []] call ALIVE_fnc_hashGet;
        if (_cargo isEqualType [] && {count _cargo > 0}) then { _why = "carries a profiled cargo" };
        if (_why isEqualTo "" && {[_veh, "busy", false] call ALIVE_fnc_hashGet}) then { _why = "busy with another module" };

        // Only crew ids that resolve count; a dangling one is no crew.
        private _ents = [_veh, "entitiesInCommandOf", []] call ALIVE_fnc_hashGet;
        if !(_ents isEqualType []) then { _ents = [] };
        private _resolved = _ents select { _x isEqualType "" && {!(_x isEqualTo _vehId)} && {!(([_x] call _fnc_profile) isEqualTo [])} };
        if (_why isEqualTo "" && {_entId isEqualTo ""} && {count _resolved > 0}) then { _why = "crewed but no entity given" };

        // Decision 6: an entity is unregistered only when this airframe is
        // its only commanded vehicle. A crew that also commands a truck is a
        // crew somebody else is still using.
        if (_why isEqualTo "" && {!(_entId isEqualTo "")}) then {
            _ent = [_entId] call _fnc_profile;
            if (_ent isEqualTo []) then { _why = "entity profile not found" } else {
                if !(([_ent, "type", ""] call ALIVE_fnc_hashGet) isEqualTo "entity") then { _why = "not an entity profile" };
                if (_why isEqualTo "" && {!(([_ent, "vehiclesInCommandOf", []] call ALIVE_fnc_hashGet) isEqualTo [_vehId])}) then {
                    _why = "entity commands other vehicles";
                };
                if (_why isEqualTo "" && {[_ent, "isPlayer", false] call ALIVE_fnc_hashGet}) then { _why = "player profile" };
                if (_why isEqualTo "" && {[_ent, "busy", false] call ALIVE_fnc_hashGet}) then { _why = "crew busy with another module" };
            };
        };

        // Live or virtual, and the states in between. `active` and `vehicle`
        // are written in two separate statements by both spawn and despawn,
        // and this runs scheduled alongside them, so the two can be read
        // mid-flip. Any disagreement is a profile in transition and is refused
        // for this pass rather than guessed at: taking the virtual branch on a
        // profile whose hull is about to appear would create a second hull.
        //
        // The fence. sys_profile's spawn op refuses a profile whose `locked`
        // is set, and the spawn queue drops one too, so setting it here keeps
        // the spawner off a virtual profile for as long as this takes.
        //
        // Read, decide and fence in ONE unscheduled step, through isNil the
        // way the global claim is taken. Spawn runs as its own scheduled
        // thread: it sets `locked` early and writes `vehicle` and `active`
        // only at its very end, after createVehicle and the crew. As three
        // scheduled statements this could read "not locked", be pre-empted
        // by a spawn that then locks and starts building, resume, fence, and
        // re-read `active` still false, since the spawn has not reached the
        // line that sets it: the virtual branch would build a second hull and
        // unregister the profile the spawn's own hull is about to be stamped
        // with. A re-read after the fence, which is what stood here before,
        // catches only a spawn that has COMPLETED. Done indivisibly, a spawn
        // that has set its lock is seen and refused, and one that has not yet
        // reached its lock check finds the fence. What this cannot close is
        // sys_profile's own read-then-set: a spawn suspended between reading
        // `locked` and writing it is invisible from here, and only a change
        // in sys_profile would close that.
        private _active = false;
        private _obj = objNull;
        private _locked = false;
        private _fenced = false;
        isNil {
            _active = [_veh, "active", false] call ALIVE_fnc_hashGet;
            _obj = [_veh, "vehicle", objNull] call ALIVE_fnc_hashGet;
            if !(_obj isEqualType objNull) then { _obj = objNull };
            _locked = [_veh, "locked", false] call ALIVE_fnc_hashGet;
            if (_why isEqualTo "") then {
                if (_active && {isNull _obj}) then { _why = "profile in transition (despawning)" };
                if (!_active && {!isNull _obj}) then { _why = "profile in transition (spawning)" };
                // A virtual profile that is locked is one the spawner has
                // already started on: spawn sets the lock as its first act
                // and only despawn clears it.
                if (!_active && {isNull _obj} && {_locked}) then { _why = "profile in transition (spawn queued)" };
            };
            if (_why isEqualTo "" && {!_active}) then {
                [_veh, "locked", true] call ALIVE_fnc_hashSet;
                _fenced = true;
            };
        };
        private _live = _why isEqualTo "" && {_active} && {!isNull _obj};

        if (_live) then {
            if (!alive _obj) then { _why = "hull is dead" };
            if (_why isEqualTo "" && {[_obj] call _fnc_playerAboard}) then { _why = "a player is aboard" };
            // A live hull in the air is not taken. Deleting its crew up
            // there is a crash, and the row that could recover from it does
            // not exist until after attach.
            if (_why isEqualTo "" && {[_obj] call _fnc_airborne}) then { _why = "airborne" };
            // The C1 backstop, repeated here rather than trusted to the
            // caller: a hull combat support has since taken is not ours to
            // consume whatever the sweep thought of it earlier.
            private _mark = "";
            { if (_mark isEqualTo "" && {_obj getVariable [_x, false]}) then { _mark = _x } } forEach FOREIGN_MARKS;
            if (_why isEqualTo "" && {!(_mark isEqualTo "")}) then { _why = format ["object is marked %1", _mark] };
            if (_why isEqualTo "" && {!((toLower ([_veh, "objectType", ""] call ALIVE_fnc_hashGet)) in ["helicopter", "plane"])}) then {
                _why = "not an aircraft";
            };
        } else {
            if (_why isEqualTo "" && {count _home < 3}) then { _why = "no home" };
            if (_why isEqualTo "" && {_class isEqualTo ""}) then { _why = "no vehicle class" };
        };

        // ---- the hull, before anything is destroyed -------------------------
        // For a virtual profile the hull is created NOW, while the profile is
        // still whole. If it cannot be created the profile is left as found:
        // creating after unregistering, with nothing checking the hull
        // appeared, is how a class the game cannot build would have taken an
        // aircraft out of the registry and put nothing in the world.
        private _hull = objNull;
        if (_why isEqualTo "" && {!_live}) then {
            _hull = [_logic, _class, _home, _pylons] call _fnc_createHull;
            if (isNull _hull) then { _why = "hull could not be created" };
        };

        if !(_why isEqualTo "") exitWith {
            // A fence taken for nothing is given back, but only when nothing
            // spawned under it: if a spawn slipped past, the lock is the
            // spawn's own now and clearing it would let the queue take the
            // profile a second time.
            if (_fenced && {!_active} && {isNull _obj}) then { [_veh, "locked", _locked] call ALIVE_fnc_hashSet };
            [_vehId] call _fnc_releaseGlobal;
            ["ALIVE_fnc_ATOPlace - consume refused for %1: %2", _vehId, _why] call ALiVE_fnc_dump;
            _result = [objNull, false];
        };

        // ---- the point of no return -----------------------------------------
        // From the entity destroy onwards this op never answers a refusal for
        // a reason of its own. Whatever is found below is put right and
        // logged; a refusal here would be a refusal for a crew already
        // deleted and a profile already gone, and the caller would then
        // record the aircraft as declined when it had in fact been taken.
        // The flag is the caller's only way to tell that case from a
        // refusal, and it goes back with the hull.
        private _crossed = true;
        if (_live) then {
            // The opt-out first, before anything that can suspend and before
            // the profile is touched. The runtime profiler stamps a profileID
            // on any Air object that has neither an id nor this flag, and
            // between the unregister below and a flag written after the
            // crew-clear wait, which is where it used to be written, the hull
            // was exactly that for up to three seconds. The flag is read by
            // the profiler and by admissible, and admissible refusing this
            // hull from here on is right: it is spoken for.
            _obj setVariable ["ALIVE_profileIgnore", true, true];

            // The crew. destroy on an active entity dismounts its units and
            // deletes them and their group; the group deletion travels to the
            // machine that owns it and completes there. Units still in their
            // seats are deleted from them, which is the contract's "resident
            // units deleted".
            if !(_ent isEqualTo []) then { [_ent, "destroy"] call ALIVE_fnc_profileEntity };

            // Residue: anything left aboard that is not a player. No player
            // can be here, that was refused above.
            {
                if (!isPlayer _x) then {
                    if !((_x getVariable ["profileID", ""]) isEqualTo "") then {
                        ["ALIVE_fnc_ATOPlace - deleting a profiled unit (%1) found aboard %2", typeOf _x, _vehId] call ALiVE_fnc_dump;
                    };
                    deleteVehicle _x;
                };
            } forEach (crew _obj);

            // Off the registry BEFORE the crew-clear wait, not after it. The
            // entity destroy above strips the vehicle's assignments, and an
            // active, grounded vehicle profile with no assignments is exactly
            // what the spawn coordinator despawns on its own; parked for
            // three seconds in that state, the hull could be deleted from the
            // world and the profile from the registry by a system that was
            // only doing its job, and this op would then return no hull for
            // an aircraft it had taken. Nothing in the wait needs the
            // registration.
            [_veh, "clearVehicleAssignments"] call ALIVE_fnc_profileVehicle;
            [ALIVE_profileHandler, "unregisterProfile", _veh] call ALIVE_fnc_profileHandler;

            // unregisterProfile clears ProfileID on an active hull and never
            // profileIndex or runtimeProfiled, and it clears it locally. All
            // three, and broadcast.
            _obj setVariable ["profileID", nil, true];
            _obj setVariable ["profileIndex", nil, true];
            _obj setVariable ["runtimeProfiled", nil, true];

            // The handlers sys_profile put on the hull at spawn stay behind
            // after unregister. With the profile id gone, the GetIn and
            // Killed handlers read it with no default, assign the nil, and
            // then index into a variable that no longer exists; a hull shot
            // during the wait below, or the first player to climb in, would
            // produce a script error from a system that no longer owns the
            // aircraft. So they go before the wait rather than after it. The
            // ids of those handlers were never stored, so the whole set goes,
            // and any third party's GetIn, GetOut or MPKilled handler on the
            // airframe goes with it. Nothing of this module's is on the hull
            // yet to lose.
            _obj removeAllEventHandlers "GetIn";
            _obj removeAllEventHandlers "GetOut";
            _obj removeAllMPEventHandlers "MPKilled";

            // Wait for the seats to actually empty. takeOwnership refuses a
            // hull with anyone still in it, and a unit deleted on another
            // machine leaves its seat when that machine says so, not when
            // this statement finishes.
            private _clearBy = time + CREW_CLEAR_WAIT;
            waitUntil { sleep 0.25; isNull _obj || {(count (crew _obj)) == 0} || {time > _clearBy} };

            if (!isNull _obj) then {
                // Ours now, and asked for again if the first ask is refused
                // because a seat was still emptying.
                private _r = [_effect, "apply", ["takeOwnership", _obj, [], []]] call ALIVE_fnc_ATOEffect;
                if ((_r param [0, ""]) isEqualTo "refused") then {
                    sleep 1;
                    _r = [_effect, "apply", ["takeOwnership", _obj, [], []]] call ALIVE_fnc_ATOEffect;
                };
                if ((_r param [0, ""]) isEqualTo "refused") then {
                    ["ALIVE_fnc_ATOPlace - takeOwnership refused for %1 (%2); the hull stays remote and attach will defer it",
                        _vehId, _r param [2, ""]] call ALiVE_fnc_dump;
                };
                // The transfer is asynchronous. Bounded, because a machine
                // that never answers must not hold this op forever; a hull
                // still remote at the end is returned anyway, recorded, and
                // recovered by the sweep's retry.
                private _localBy = time + LOCALITY_WAIT;
                waitUntil { sleep 0.5; isNull _obj || {local _obj} || {time > _localBy} };
            };
            _hull = _obj;
        } else {
            if !(_ent isEqualTo []) then { [_ent, "destroy"] call ALIVE_fnc_profileEntity };
            [_veh, "clearVehicleAssignments"] call ALIVE_fnc_profileVehicle;
            [ALIVE_profileHandler, "unregisterProfile", _veh] call ALIVE_fnc_profileHandler;
            // Unset on a fresh createVehicle already; set explicitly so the
            // invariant is stated in code rather than assumed of the engine.
            _hull setVariable ["profileID", nil, true];
            _hull setVariable ["profileIndex", nil, true];
            _hull setVariable ["runtimeProfiled", nil, true];
        };

        // ---- post-conditions --------------------------------------------------
        // Both ids must answer nothing. A profile still behind either one is
        // put right here rather than reported as a refusal, because the crew
        // and the registration are already gone and there is no state to hand
        // back to.
        private _again = [_vehId] call _fnc_profile;
        if !(_again isEqualTo []) then {
            ["ALIVE_fnc_ATOPlace - %1 still registered after consume, unregistering again", _vehId] call ALiVE_fnc_dump;
            [ALIVE_profileHandler, "unregisterProfile", _again] call ALIVE_fnc_profileHandler;
        };
        if !(_entId isEqualTo "") then {
            private _entAgain = [_entId] call _fnc_profile;
            if !(_entAgain isEqualTo []) then {
                ["ALIVE_fnc_ATOPlace - crew %1 still registered after consume of %2, unregistering again", _entId, _vehId] call ALiVE_fnc_dump;
                [ALIVE_profileHandler, "unregisterProfile", _entAgain] call ALIVE_fnc_profileHandler;
            };
        };

        [_vehId] call _fnc_releaseGlobal;

        if (isNull _hull || {!alive _hull}) then {
            ["ALIVE_fnc_ATOPlace - %1 consumed but its hull was lost on the way (null %2)", _vehId, isNull _hull] call ALiVE_fnc_dump;
            _result = [objNull, _crossed];
        } else {
            if (!local _hull) then {
                ["ALIVE_fnc_ATOPlace - %1 consumed but its hull is still owned elsewhere; attach will defer it", _vehId] call ALiVE_fnc_dump;
            };
            _result = [_hull, _crossed];
        };
    };

    // ---- attaching a hull to a tail ----------------------------------------
    // attach(tail, obj) -> [true, ""] or [false, reason]. Only "remote" is a
    // reason that will change on its own; a caller that created the hull
    // deletes it on any other refusal, and a caller that consumed it logs.
    //
    // The order below is the point. Every refusal that will not change comes
    // first and leaves no trace. Then the hull is protected and recorded as
    // ours, and only THEN is its locality tested, so a remote hull is one
    // this instance knows about, answers for through objFor, and keeps asking
    // for on every sweep, rather than one that fell between the cracks.
    case "attach": {
        _args params [["_tail", "", [""]], ["_obj", objNull, [objNull]]];
        _result = [false, ""];

        private _why = "";
        if (!isServer) then { _why = "not server" };
        private _notReady = [_logic] call _fnc_notReady;
        if (_why isEqualTo "" && {!(_notReady isEqualTo "")}) then { _why = _notReady };
        if (_why isEqualTo "" && {_tail isEqualTo ""}) then { _why = "no tail" };
        if (_why isEqualTo "" && {isNull _obj}) then { _why = "no object" };
        if (_why isEqualTo "" && {!alive _obj}) then { _why = "dead" };

        private _ledger = [_logic, "ledger", []] call ALIVE_fnc_hashGet;
        private _surface = [_logic, "surface", []] call ALIVE_fnc_hashGet;
        private _effect = [_logic, "effect", []] call ALIVE_fnc_hashGet;
        private _attached = [_logic, "attached", []] call ALIVE_fnc_hashGet;
        private _deferred = [_logic, "deferred", []] call ALIVE_fnc_hashGet;

        private _record = [];
        private _home = [];
        if (_why isEqualTo "") then {
            _record = [_ledger, "get", _tail] call ALIVE_fnc_ATOLedger;
            if (_record isEqualTo []) then { _why = "no record" } else {
                // markPresent below flips status as well as the session flag.
                // Lost to present is right: that is a replacement or a
                // restore arriving. Unplaceable to present is right: a
                // restore succeeded. Retired is somebody's deliberate act and
                // is never undone from here.
                if (([_record, "status", ""] call ALIVE_fnc_hashGet) isEqualTo "retired") then { _why = "retired" };
                _home = [_record, "home", []] call ALIVE_fnc_hashGet;
                if (_why isEqualTo "" && {count _home < 3}) then { _why = "no home" };
            };
        };

        // One tail, one hull. A second live hull for a tail is how a restore
        // run twice doubled a fleet.
        if (_why isEqualTo "") then {
            private _held = [_attached, _tail, objNull] call ALIVE_fnc_hashGet;
            if (_held isEqualType objNull && {!isNull _held} && {alive _held} && {!(_held isEqualTo _obj)}) then {
                _why = "tail already has a hull";
            };
        };

        // A profile still references it. The runtime profiler can stamp a
        // hull in the moments before it is shielded, and a stamp with a live
        // profile behind it means the aircraft would be despawned out from
        // under this module. So the profile is consumed, here, and the
        // violation said out loud; only a stamp that cannot be consumed
        // refuses. A stale stamp with nothing behind it is a leftover, which
        // shield clears.
        if (_why isEqualTo "") then {
            private _pid = _obj getVariable ["profileID", ""];
            if (_pid isEqualType "" && {!(_pid isEqualTo "")}) then {
                private _p = [_pid] call _fnc_profile;
                if !(_p isEqualTo []) then {
                    ["ALIVE_fnc_ATOPlace - %1 reached attach with profile %2 still on it; consuming that profile", _tail, _pid] call ALiVE_fnc_dump;
                    private _pObj = [_p, "vehicle", objNull] call ALIVE_fnc_hashGet;
                    private _pActive = [_p, "active", false] call ALIVE_fnc_hashGet;
                    private _again = objNull;
                    // Only when that profile is the live one for THIS object.
                    // Anything else is a profile in transition, and consume's
                    // virtual branch would build a second hull for it.
                    if (_pActive && {_pObj isEqualType objNull} && {_pObj isEqualTo _obj}) then {
                        // Parenthesised: call and param are both binary.
                        _again = ([_logic, "consume", [_pid, [_p] call _fnc_pairOf, _home]] call MAINCLASS) param [0, objNull];
                    };
                    if (isNull _again) then { _why = "profiled" };
                };
            };
        };

        if !(_why isEqualTo "") exitWith {
            ["ALIVE_fnc_ATOPlace - attach refused for %1: %2", _tail, _why] call ALiVE_fnc_dump;
            _result = [false, _why];
        };

        // Protected first, whatever machine it is on: setVariable with the
        // public flag reaches a remote object, and an unshielded hull is one
        // the runtime profiler can take between this line and the next sweep.
        [_effect, "apply", ["shield", _obj, _home, [_tail]]] call ALIVE_fnc_ATOEffect;

        // Ours, on the books, BEFORE the locality test. objFor answers with
        // it from here on, remote or not.
        [_attached, _tail, _obj] call ALIVE_fnc_hashSet;

        if (!local _obj) exitWith {
            private _prior = [_deferred, _tail, [objNull, 0]] call ALIVE_fnc_hashGet;
            private _tries = _prior param [1, 0];
            if !(_tries isEqualType 0) then { _tries = 0 };
            [_deferred, _tail, [_obj, _tries]] call ALIVE_fnc_hashSet;
            if (_tries == 0) then {
                ["ALIVE_fnc_ATOPlace - attach deferred for %1: the hull is owned elsewhere", _tail] call ALiVE_fnc_dump;
            };
            _result = [false, "remote"];
        };

        // Planes get no pad. Note that Effect's releaseApproach deletes this
        // pad at the end of every landing and Surface's padFor creates it
        // again on the next approach, at this same home, so the stamp is
        // re-established with every arrival; while the aircraft is parked the
        // hull itself is what keeps the spot from being handed out.
        if ([typeOf _obj] call _fnc_needsPad) then {
            [_surface, "stampPad", [_home, _tail]] call ALIVE_fnc_ATOSurface;
        };

        // "I have this airframe in front of me." Without it markLost refuses
        // the tail for the rest of the session, by design.
        [_ledger, "markPresent", _tail] call ALIVE_fnc_ATOLedger;
        [_deferred, _tail] call ALIVE_fnc_hashRem;

        ["ALIVE_fnc_ATOPlace - attached %1 (%2) at %3", _tail, typeOf _obj, _home select 0] call ALiVE_fnc_dump;
        _result = [true, ""];
    };

    // ---- moving a home that is in use ---------------------------------------
    // rehome(tail) -> the new home, or []. The one path to setHome after
    // attach. Runs the cascade around the current home and logs the eviction
    // with what caused it.
    //
    // Every known home is reserved first, this tail's own included, so the
    // cascade cannot hand the old stand straight back: its airfield rung
    // would otherwise return the same spot it returned last time.
    //
    // Reservations are left in place afterwards. A pass-level op (sweep,
    // placeInitial, restoreAll) clears them at its start and this may be
    // running inside one; clearing here would wipe that pass's own
    // bookkeeping halfway through it. createReplacement does not clear
    // either: it runs from Resupply's thread outside the pass interlock, so
    // a clear there could land inside a sweep parked in consume's wait and
    // discard what that pass had reserved. It only adds.
    case "rehome": {
        private _tail = _args;
        if !(_tail isEqualType "") then { _tail = "" };
        _result = [];

        if (!isServer) exitWith {};
        private _notReady = [_logic] call _fnc_notReady;
        if !(_notReady isEqualTo "") exitWith {
            ["ALIVE_fnc_ATOPlace - rehome refused for %1: %2", _tail, _notReady] call ALiVE_fnc_dump;
        };

        private _ledger = [_logic, "ledger", []] call ALIVE_fnc_hashGet;
        private _surface = [_logic, "surface", []] call ALIVE_fnc_hashGet;
        private _failed = [_logic, "rehomeFailed", []] call ALIVE_fnc_hashGet;

        private _record = [_ledger, "get", _tail] call ALIVE_fnc_ATOLedger;
        if (_record isEqualTo []) exitWith { _result = [] };
        private _home = [_record, "home", []] call ALIVE_fnc_hashGet;
        if (count _home < 3) exitWith { _result = [] };
        private _class = [_record, "vehicleClass", ""] call ALIVE_fnc_hashGet;
        // May be null or away; passed as the own object so it never blocks
        // itself, and named in the log for what stood on the stand.
        private _obj = [_logic, "objFor", _tail] call MAINCLASS;
        ["ALIVE_fnc_ATOPlace - %1 evicted from %2 by %3", _tail, _home select 0,
            [_home, _class, _obj] call _fnc_intruderName] call ALiVE_fnc_dump;

        [_logic] call _fnc_reserveHomes;
        // Asked on the home's OWN surface, and from where that home actually
        // is rather than from what it stored: a deck home's world position is
        // the value it had when it was chosen.
        private _kind = _home select 2;
        private _from = _home select 0;
        if (_kind isEqualTo "deck") then {
            _from = ([_surface, "resolve", _home] call ALIVE_fnc_ATOSurface) select 0;
        };
        private _new = [_surface, "cascade", [_kind, _class, _from, []]] call ALIVE_fnc_ATOSurface;
        if !(_new isEqualType []) then { _new = [] };

        // Logged once per tail. The row stays RECOVERING and the Kernel asks
        // again on its own schedule, and a line per ask would bury the log.
        if (count _new < 3) exitWith {
            if (([_failed, _tail, -1] call ALIVE_fnc_hashGet) < 0) then {
                [_failed, _tail, time] call ALIVE_fnc_hashSet;
                ["ALIVE_fnc_ATOPlace - no new home for %1 near %2; it stays where it is", _tail, _home select 0] call ALiVE_fnc_dump;
            };
            _result = [];
        };
        [_failed, _tail] call ALIVE_fnc_hashRem;

        [_ledger, "setHome", [_tail, _new]] call ALIVE_fnc_ATOLedger;
        [_surface, "reserve", [_new select 0, [_class] call _fnc_span]] call ALIVE_fnc_ATOSurface;
        if ([_class] call _fnc_needsPad) then {
            [_surface, "unstampPad", _tail] call ALIVE_fnc_ATOSurface;
            [_surface, "stampPad", [_new, _tail]] call ALIVE_fnc_ATOSurface;
        };
        ["ALIVE_fnc_ATOPlace - %1 rehomed to %2", _tail, _new select 0] call ALiVE_fnc_dump;
        _result = _new;
    };

    // ---- initial placement --------------------------------------------------
    // placeInitial() -> tails. Runs when the sweep yielded fewer than two ARMED
    // present records, and when either placing aircraft is on or the base has
    // no airfield. D2 helicopters on the field's pads, D3 planes one per hangar
    // building up to the cap, D12 one drone, each hull created directly at a
    // cascade home.
    //
    // The hangar-fit rung (bounding box against the building, doors, the
    // heading flip) is NOT ported here: a home inside a hangar cannot pass
    // Surface's clearance test, which refuses any building within the span,
    // so it could never pass validate at PARKED entry either and would
    // oscillate to RECOVERING. It needs a Surface change first. Planes are
    // anchored on their hangars and the cascade finds the apron beside them.
    case "placeInitial": {
        _result = [];

        if (!isServer) exitWith {};
        if (!canSuspend) exitWith {
            ["ALIVE_fnc_ATOPlace - placeInitial must be called scheduled"] call ALiVE_fnc_dump;
        };
        private _notReady = [_logic] call _fnc_notReady;
        if !(_notReady isEqualTo "") exitWith {
            ["ALIVE_fnc_ATOPlace - placeInitial refused: %1", _notReady] call ALiVE_fnc_dump;
        };

        private _ledger = [_logic, "ledger", []] call ALIVE_fnc_hashGet;
        private _surface = [_logic, "surface", []] call ALIVE_fnc_hashGet;
        private _base = [_logic, "base", []] call ALIVE_fnc_hashGet;
        private _faction = [_logic, "faction", ""] call ALIVE_fnc_hashGet;

        if !([_base] call ALIVE_fnc_isHash) exitWith {
            ["ALIVE_fnc_ATOPlace - placeInitial refused: no base"] call ALiVE_fnc_dump;
        };
        // Place Air Assets decides whether a commander is given aircraft of
        // its own, and a base with no airfield is the one case where the answer
        // cannot be no. Such a base refuses every aircraft that already exists,
        // deliberately and for a measured reason (see adoptPair), so the
        // setting left at its default does not mean "fly what is already here",
        // it means this commander flies nothing at all for the whole mission
        // and reports on the radio that it was never established. There is no
        // way to ask for the other reading either: Ingress Aircraft is clamped
        // to one or more, so nobody can ask for a marker with no aircraft. The
        // marker being named is taken as the answer, and the override is said
        // out loud below rather than done quietly.
        private _virtual = [_base, "isVirtual", false] call ALIVE_fnc_hashGet;
        private _placeAir = [_logic, "placeAir", false] call ALIVE_fnc_hashGet;
        if (!_placeAir && {!_virtual}) exitWith { _result = [] };

        // The gate counts armed, crewed aircraft on the books. A drone or an
        // unarmed airframe is not what the gate is asking about.
        private _view = [_ledger, "view"] call ALIVE_fnc_ATOLedger;
        private _values = _view select 2;
        private _armed = 0;
        {
            private _rec = _values select _forEachIndex;
            private _cls = [_rec, "vehicleClass", ""] call ALIVE_fnc_hashGet;
            if (([_rec, "status", ""] call ALIVE_fnc_hashGet) isEqualTo "present"
                && {!(_cls isEqualTo "")}
                && {[_cls] call ALiVE_fnc_isArmed}
                && {!([_cls] call _fnc_isDroneClass)}) then { _armed = _armed + 1 };
        } forEach (_view select 1);
        if (_armed >= 2) exitWith { _result = [] };

        // Said only where it changed the outcome: after the count above, so a
        // base that already has its fleet does not announce an override that
        // did nothing.
        if (_virtual && {!_placeAir}) then {
            ["ALIVE_fnc_ATOPlace - %1 has no airfield and cannot take over an aircraft that already exists, so it is given its own at its ingress point even though Place Air Assets is off. Nothing else can give this commander aircraft.",
                _faction] call ALiVE_fnc_dumpR;
        };

        private _busy = [_logic] call _fnc_passRunning;
        if !(_busy isEqualTo "") exitWith {
            ["ALIVE_fnc_ATOPlace - placeInitial refused: a %1 pass is still running", _busy] call ALiVE_fnc_dump;
        };
        // No early exit from here to the clear at the end.
        [_logic, "passRunning", ["placeInitial", time]] call ALIVE_fnc_hashSet;

        private _nodes = [_base, "nodes", []] call ALIVE_fnc_hashGet;
        if !(_nodes isEqualType []) then { _nodes = [] };
        private _center = [_base, "center", [0,0,0]] call ALIVE_fnc_hashGet;
        private _hq = [_base, "hq", objNull] call ALIVE_fnc_hashGet;
        if !(_hq isEqualType objNull) then { _hq = objNull };
        private _airspaceName = [_base, "airspace", ""] call ALIVE_fnc_hashGet;
        private _blacklist = if (isNil "ALiVE_PLACEMENT_VEHICLEBLACKLIST") then { [] } else { ALiVE_PLACEMENT_VEHICLEBLACKLIST };

        // Start the pass with exactly the homes the ledger knows, so a
        // sibling whose hull is away is not parked on.
        [_surface, "clearReservations"] call ALIVE_fnc_ATOSurface;
        [_logic] call _fnc_reserveHomes;

        private _tails = [];
        private _fnc_flyable = {
            count ([_x] call ALiVE_fnc_getAircraftRoles) > 0
                && {[_x] call ALiVE_fnc_isArmed}
                && {!([_x] call _fnc_isDroneClass)}
        };

        // ---- a base with no airfield ---------------------------------------
        // Every aircraft is asked for at the marker itself. The cascade hands
        // back a different hold point each time, because each home is reserved
        // as it is taken, so nothing here has to know about the ring or how big
        // it is.
        //
        // Split between planes and helicopters rather than all of one kind: a
        // commander with nowhere to fly from still has to cover the sorties
        // that want speed and the ones that want to loiter. Whichever of the
        // two the faction actually has is what it gets.
        // Declared out here rather than inside the airfield branch: the tail
        // below reads all three whichever branch ran, and scoped to the branch
        // they are undefined the moment a base with no airfield takes the other
        // one.
        private _helis = [];
        private _planes = [];
        private _heliPlaced = 0;

        private _slots = [_base, "virtualSlots", 6] call ALIVE_fnc_hashGet;
        if !(_slots isEqualType 0) then { _slots = 6 };
        _slots = (round _slots) max 1;

        if (_virtual) then {
            // Ingress Aircraft is how many aircraft fly from the point, not how
            // many to add to whatever is there. A fleet that came back from a
            // save is counted by the gate above and has to be counted here too,
            // or a base restored with one aircraft ends up holding one more
            // than the figure the mission maker typed.
            private _want = (_slots - _armed) max 0;
            _helis = (([0, _faction, "Helicopter"] call ALiVE_fnc_findVehicleType) - _blacklist) select _fnc_flyable;
            _planes = (([0, _faction, "Plane"] call ALiVE_fnc_findVehicleType) - _blacklist) select _fnc_flyable;
            private _heliList = _helis;
            private _planeList = _planes;
            private _mix = [];
            if (count _planeList > 0 && {count _heliList > 0}) then {
                for "_i" from 1 to _want do {
                    _mix pushBack (if (_i % 2 == 1) then { selectRandom _planeList } else { selectRandom _heliList });
                };
            } else {
                private _only = if (count _planeList > 0) then { _planeList } else { _heliList };
                if (count _only > 0) then {
                    for "_i" from 1 to _want do { _mix pushBack (selectRandom _only) };
                };
            };
            if (_want > 0 && {count _mix == 0}) then {
                ["ALIVE_fnc_ATOPlace - %1 has no armed aircraft this commander can fly, so its ingress point stays empty", _faction] call ALiVE_fnc_dumpR;
            };
            {
                private _tail = [_logic, _x, _center, 0, _airspaceName] call _fnc_placeNew;
                if !(_tail isEqualTo "") then {
                    _tails pushBack _tail;
                    // Counted here as well as on the airfield rungs, or the
                    // summary line below reports none: it placed a plane and a
                    // helicopter and said nought helicopters.
                    if (_x in _helis) then { _heliPlaced = _heliPlaced + 1 };
                };
            } forEach _mix;
            ["ALIVE_fnc_ATOPlace - %1 of the %2 aircraft asked for are held at the ingress point",
                count _tails, _want] call ALiVE_fnc_dump;
        } else {

        // ---- D2 helicopters ------------------------------------------------
        _helis = (([0, _faction, "Helicopter"] call ALiVE_fnc_findVehicleType) - _blacklist) select _fnc_flyable;
        if (count _helis > 0) then {
            // Every pad in the cluster: the nodes that are pads, plus the
            // nearest pad to each node that is not. The nearest-pad lookup
            // answers nil for an empty result and pushBackUnique of nil is
            // an engine error, hence the param with a null default.
            private _pads = [];
            {
                if (_x isKindOf "HeliH") then {
                    _pads pushBackUnique _x;
                } else {
                    private _near = (nearestObjects [position _x, ["HeliH"], 250]) param [0, objNull];
                    if (!isNull _near) then { _pads pushBackUnique _near };
                };
            } forEach _nodes;
            // Nearest the centre first. The centre goes in as an input rather
            // than being read off this scope from inside the closure.
            _pads = [_pads, [_center], { _input0 distance2D _x }, "ASCEND"] call ALiVE_fnc_SortBy;

            {
                private _tail = [_logic, selectRandom _helis, getPosATL _x, getDir _x, _airspaceName] call _fnc_placeNew;
                if !(_tail isEqualTo "") then { _tails pushBack _tail; _heliPlaced = _heliPlaced + 1 };
            } forEach _pads;

            // No pad, or none that yielded a home: one at the centre, so at
            // least one helicopter exists. This replaces the old heliport
            // composition fallback, which built a pad out of a composition.
            if (_heliPlaced == 0) then {
                private _tail = [_logic, selectRandom _helis, _center, 0, _airspaceName] call _fnc_placeNew;
                if !(_tail isEqualTo "") then { _tails pushBack _tail; _heliPlaced = _heliPlaced + 1 };
            };
        };

        // ---- D3 planes -----------------------------------------------------
        // One cascade per hangar building, never the same anchor twice: the
        // shared apron search accepts no list of spots already handed out, so
        // asked repeatedly at one anchor it returns the same spot, finds it
        // reserved, and falls to a ring search that exhausts.
        _planes = (([0, _faction, "Plane"] call ALiVE_fnc_findVehicleType) - _blacklist) select _fnc_flyable;
        if (count _planes > 0) then {
            private _anchors = [];
            if (!isNil "ALIVE_airBuildingTypes" && {!isNil "ALIVE_militaryAirBuildingTypes"} && {count _nodes > 0}) then {
                _anchors = [_nodes, ALIVE_airBuildingTypes + ALIVE_militaryAirBuildingTypes] call ALIVE_fnc_findBuildingsInClusterNodes;
                if !(_anchors isEqualType []) then { _anchors = [] };
            };
            if (count _anchors == 0 && {!isNull _hq}) then { _anchors = [_hq] };

            private _cap = (count _anchors) min PLANE_CAP;
            private _planesPlaced = 0;
            private _first = true;
            {
                // The first building always, the rest with D3's chance, and
                // never past the cap. The in-place candidate at a hangar
                // fails validate (the hangar is a building inside the span),
                // so the cascade runs anchored on the hangar and finds the
                // apron beside it.
                if (_planesPlaced < _cap && {_first || {random 1 > 0.30}}) then {
                    private _tail = [_logic, selectRandom _planes, position _x, getDir _x, _airspaceName] call _fnc_placeNew;
                    if !(_tail isEqualTo "") then { _tails pushBack _tail; _planesPlaced = _planesPlaced + 1 };
                };
                _first = false;
            } forEach _anchors;
        };

        // The end of the airfield rungs, which a base with no airfield takes
        // the branch above instead of.
        };

        // ---- D12 one drone -------------------------------------------------
        private _droneOn = ([_logic, "placeDrones", false] call ALIVE_fnc_hashGet)
            && {[_logic, "useUAVs", true] call ALIVE_fnc_hashGet};
        private _drones = [];
        if (_droneOn) then {
            private _custom = [_logic, "droneTypes", ""] call ALIVE_fnc_hashGet;
            if !(_custom isEqualType "") then { _custom = "" };
            if !(_custom isEqualTo "") then {
                {
                    if !(_x isEqualTo "") then {
                        if (isClass (configFile >> "CfgVehicles" >> _x) && {_x isKindOf "Air"}) then {
                            _drones pushBackUnique _x;
                        } else {
                            ["ALIVE_fnc_ATOPlace - drone type %1 is not an aircraft class and was ignored", _x] call ALiVE_fnc_dump;
                        };
                    };
                } forEach (_custom splitString "[]""', ");
            } else {
                // Both families, then only the drones. Asking for "UAV"
                // directly misses the small rotary reconnaissance drones,
                // whose base inherits from the helicopter chain. Deliberately
                // NOT filtered for armament: a reconnaissance drone carries
                // nothing, and that filter would throw away exactly what was
                // asked for.
                _drones = ((([0, _faction, "Helicopter"] call ALiVE_fnc_findVehicleType)
                          + ([0, _faction, "Plane"] call ALiVE_fnc_findVehicleType)) - _blacklist)
                          select { [_x] call _fnc_isDroneClass };
            };

            if (count _drones == 0) then {
                ["ALIVE_fnc_ATOPlace - drone placement is on but faction %1 has no drones to place", _faction] call ALiVE_fnc_dump;
            } else {
                private _padNode = (_nodes select { _x isKindOf "HeliH" }) param [0, objNull];
                private _anchor = if (isNull _padNode) then { _center } else { getPosATL _padNode };
                private _tail = [_logic, selectRandom _drones, _anchor, random 360, _airspaceName] call _fnc_placeNew;
                if !(_tail isEqualTo "") then { _tails pushBack _tail };
            };
        };

        if (count _tails == 0 && {count _helis == 0} && {count _planes == 0} && {count _drones == 0}) then {
            ["ALIVE_fnc_ATOPlace - no admissible aircraft class for faction %1; nothing placed", _faction] call ALiVE_fnc_dump;
        };

        [_logic, "passRunning", []] call ALIVE_fnc_hashSet;
        [_logic, "firstPassDone", true] call ALIVE_fnc_hashSet;
        ["ALIVE_fnc_ATOPlace - initial placement for %1: %2 aircraft (%3 helicopters)", _faction, count _tails, _heliPlaced] call ALiVE_fnc_dump;
        _result = _tails;
    };

    // ---- a replacement for a lost record -----------------------------------
    // createReplacement(tail) -> Boolean. Only for a record that is LOST with
    // no live hull: anything else is either a record somebody closed on
    // purpose, which a hull must not reopen, or a record that already has its
    // aircraft. The stand is swept of the old wreck and re-validated; a bad
    // slot is fixed once here, through rehome, and never bequeathed. Roles,
    // callsign and tail are inherited by construction, and the status flip
    // happens in attach.
    case "createReplacement": {
        private _tail = _args;
        if !(_tail isEqualType "") then { _tail = "" };
        _result = false;

        if (!isServer) exitWith {};
        if (!canSuspend) exitWith {
            ["ALIVE_fnc_ATOPlace - createReplacement must be called scheduled"] call ALiVE_fnc_dump;
        };
        private _notReady = [_logic] call _fnc_notReady;
        if !(_notReady isEqualTo "") exitWith {
            ["ALIVE_fnc_ATOPlace - createReplacement refused for %1: %2", _tail, _notReady] call ALiVE_fnc_dump;
        };

        private _ledger = [_logic, "ledger", []] call ALIVE_fnc_hashGet;
        private _surface = [_logic, "surface", []] call ALIVE_fnc_hashGet;

        private _record = [_ledger, "get", _tail] call ALIVE_fnc_ATOLedger;
        if (_record isEqualTo []) exitWith {
            ["ALIVE_fnc_ATOPlace - createReplacement refused for %1: no record", _tail] call ALiVE_fnc_dump;
        };
        private _status = [_record, "status", ""] call ALIVE_fnc_hashGet;
        if !(_status isEqualTo "lost") exitWith {
            ["ALIVE_fnc_ATOPlace - createReplacement refused for %1: status is %2, not lost", _tail, _status] call ALiVE_fnc_dump;
        };
        private _held = [_logic, "objFor", _tail] call MAINCLASS;
        if (!isNull _held && {alive _held}) exitWith {
            ["ALIVE_fnc_ATOPlace - createReplacement refused for %1: it already has a live hull", _tail] call ALiVE_fnc_dump;
        };
        private _class = [_record, "vehicleClass", ""] call ALIVE_fnc_hashGet;
        if (_class isEqualTo "") exitWith {
            ["ALIVE_fnc_ATOPlace - createReplacement refused for %1: no vehicle class", _tail] call ALiVE_fnc_dump;
        };
        private _home = [_record, "home", []] call ALIVE_fnc_hashGet;
        if (count _home < 3) exitWith {
            ["ALIVE_fnc_ATOPlace - createReplacement refused for %1: no home", _tail] call ALiVE_fnc_dump;
        };
        // Reservations are ADDED here and never cleared, which is the one
        // way this op differs from the three passes. It runs from Resupply's
        // own thread with no pass interlock, and it suspends inside attach
        // and consume, so a clear here could land inside a sweep parked in
        // consume's wait and discard everything that pass had reserved, the
        // candidate mid-consume included: two records, one stand. Gating it
        // on the pass flag instead would refuse Resupply while a sweep runs,
        // and Resupply counts a refusal as a failed try. Re-announcing every
        // recorded home is enough for the rehome below to keep clear of
        // them, and the next sweep clears the lot.
        [_logic] call _fnc_reserveHomes;
        [_home, _class] call _fnc_clearWreck;

        // Occupied means wait: something alive is on the stand, and it may
        // move. Resupply retries on its own ladder rather than this re-homing
        // around a truck. Geometry means find another home, once, here.
        ([_surface, "validate", [_home, _class, objNull]] call ALIVE_fnc_ATOSurface) params [["_ok", false, [false]], ["_vWhy", "", [""]]];
        if (!_ok && {_vWhy isEqualTo "occupied"}) exitWith {
            ["ALIVE_fnc_ATOPlace - createReplacement for %1 waits: the stand is occupied", _tail] call ALiVE_fnc_dump;
        };
        if (!_ok) then {
            private _new = [_logic, "rehome", _tail] call MAINCLASS;
            if (count _new >= 3) then { _home = _new } else { _home = [] };
        };
        if (count _home < 3) exitWith {
            ["ALIVE_fnc_ATOPlace - createReplacement for %1 found no home", _tail] call ALiVE_fnc_dump;
        };

        private _r = [_logic, _tail, _class, _home, []] call _fnc_placeHull;
        // Only a hull attach actually took is reported as built, the rule
        // the sweep applies. A deferred hull is on the books through
        // deferredTails and the sweep keeps asking for it; answering true
        // for one would have Resupply book a replacement whose row the
        // Kernel cannot build. A fresh hull on the server is local, so this
        // is the shape of the answer rather than a path anything takes.
        if (_r isEqualTo "deferred") exitWith {
            ["ALIVE_fnc_ATOPlace - replacement %1 (%2) created but its hull is owned elsewhere; the sweep will attach it", _tail, _class] call ALiVE_fnc_dump;
        };
        if !(_r isEqualTo "placed") exitWith {
            ["ALIVE_fnc_ATOPlace - createReplacement for %1 failed: %2", _tail, _r] call ALiVE_fnc_dump;
        };
        ["ALIVE_fnc_ATOPlace - replacement %1 (%2) %3 at %4", _tail, _class, _r, _home select 0] call ALiVE_fnc_dump;
        _result = true;
    };

    // ---- restore ----------------------------------------------------------
    // restoreAll() -> [placed, consumed, rehomed, unplaceable], tails.
    //
    // Walks every present and unplaceable record. Lost is Resupply's. An
    // unplaceable record is tried again on every load, because a stand that
    // was unusable last mission may be usable this one and the record was
    // kept for exactly that reason.
    //
    // Admission at load marks, never removes. A class the game no longer has,
    // or that no longer resolves to a role, makes the record unplaceable with
    // the reason; the record stays. A class that fails class-only admission
    // but whose record carries roles from its adoption keeps them: the record
    // does not store the loadout it was admitted with, and an aircraft whose
    // roles came from a refit would otherwise be marked unplaceable for
    // missing magazines it will be given back when created.
    //
    // Legacy: a record carrying a profile id from the old store, whose
    // profile is back in the registry, is consumed into that record so the
    // campaign has one aircraft and not two. When the profile is there and
    // cannot be adopted this pass, NOTHING is created beside it: the record is
    // left present and unattached, the tail is noted in pendingLegacy, and
    // the profile keeps flying as a faction asset until it can be taken.
    // Creating in that case would double the aircraft, and the sweep would
    // then refuse the profile forever as claimed by a record.
    case "restoreAll": {
        _result = [[], [], [], []];

        if (!isServer) exitWith {};
        if (!canSuspend) exitWith {
            ["ALIVE_fnc_ATOPlace - restoreAll must be called scheduled"] call ALiVE_fnc_dump;
        };
        private _notReady = [_logic] call _fnc_notReady;
        if !(_notReady isEqualTo "") exitWith {
            ["ALIVE_fnc_ATOPlace - restoreAll refused: %1", _notReady] call ALiVE_fnc_dump;
        };

        private _busy = [_logic] call _fnc_passRunning;
        if !(_busy isEqualTo "") exitWith {
            ["ALIVE_fnc_ATOPlace - restoreAll refused: a %1 pass is still running", _busy] call ALiVE_fnc_dump;
        };
        // No early exit from here to the clear at the end.
        [_logic, "passRunning", ["restoreAll", time]] call ALIVE_fnc_hashSet;

        private _ledger = [_logic, "ledger", []] call ALIVE_fnc_hashGet;
        private _surface = [_logic, "surface", []] call ALIVE_fnc_hashGet;
        private _pending = [];

        private _placed = [];
        private _consumed = [];
        private _rehomed = [];
        private _unplaceable = [];

        [_surface, "clearReservations"] call ALIVE_fnc_ATOSurface;
        [_logic] call _fnc_reserveHomes;

        private _view = [_ledger, "view"] call ALIVE_fnc_ATOLedger;
        private _keys = +(_view select 1);
        private _values = +(_view select 2);

        {
            private _tail = _x;
            private _rec = _values select _forEachIndex;
            private _status = [_rec, "status", ""] call ALIVE_fnc_hashGet;

            if (_status in ["present", "unplaceable"]) then {
                private _why = "";
                private _skip = false;
                private _done = "";
                private _class = [_rec, "vehicleClass", ""] call ALIVE_fnc_hashGet;
                private _home = [_rec, "home", []] call ALIVE_fnc_hashGet;
                if !(_home isEqualType []) then { _home = [] };
                private _legacy = [_rec, "legacyProfileID", ""] call ALIVE_fnc_hashGet;
                if !(_legacy isEqualType "") then { _legacy = "" };

                // Already placed this session: a second restoreAll must not
                // build a second hull per record.
                private _held = [_logic, "objFor", _tail] call MAINCLASS;
                if (!isNull _held && {alive _held}) then { _skip = true };

                if (!_skip && {_class isEqualTo ""}) then { _why = "no vehicle class" };

                // Admission at load.
                if (!_skip && {_why isEqualTo ""}) then {
                    ([_logic, _class, []] call _fnc_admit) params ["_ok", "_admitWhy", "_roles", "_caps"];
                    if (_ok) then {
                        [_ledger, "setAdmission", [_tail, _roles, _caps]] call ALIVE_fnc_ATOLedger;
                    } else {
                        private _saved = [_rec, "roles", []] call ALIVE_fnc_hashGet;
                        if (_saved isEqualType [] && {count _saved > 0}) then {
                            ["ALIVE_fnc_ATOPlace - %1 (%2) fails class-only admission (%3) but carries roles %4 from its adoption; kept",
                                _tail, _class, _admitWhy, _saved] call ALiVE_fnc_dump;
                        } else {
                            _why = format ["no longer admissible: %1", _admitWhy];
                        };
                    };
                };

                // Legacy profile, back in the registry.
                if (!_skip && {_why isEqualTo ""} && {!(_legacy isEqualTo "")}) then {
                    private _veh = [_legacy] call _fnc_profile;
                    if !(_veh isEqualTo []) then {
                        // Its own legacy id is the one claim that does not
                        // count against it, so the list is built here with
                        // that id taken out and admissible is told it is
                        // complete; left to its own union it would refuse the
                        // id as claimed by this very record.
                        private _others = ([_logic] call _fnc_claimedIds) - [_legacy];
                        private _verdict = [_logic, "admissible", [_legacy, _others, true]] call MAINCLASS;
                        private _hull = objNull;
                        private _crossed = false;
                        private _h = [];
                        if (_verdict param [0, false]) then {
                            // The record's home if it still validates, else a
                            // cascade around it, else around the profile.
                            private _vObj = [_veh, "vehicle", objNull] call ALIVE_fnc_hashGet;
                            if !(_vObj isEqualType objNull) then { _vObj = objNull };
                            private _vDir = 0;
                            if (!isNull _vObj) then { _vDir = getDir _vObj };
                            // A deck home is offered back the same way a
                            // terrain one is. The home finder classifies the
                            // anchor it is handed, so a deck position comes
                            // back as a deck candidate with its ship and its
                            // offset, which is what it could not do before the
                            // deck half existed.
                            if (count _home >= 3) then {
                                _h = [_logic, _class, _home select 0, _home select 1, _vObj] call _fnc_homeFor;
                            };
                            if (count _h < 3) then {
                                _h = [_logic, _class, [_veh, "position", [0,0,0]] call ALIVE_fnc_hashGet, _vDir, _vObj] call _fnc_homeFor;
                            };
                            if (count _h >= 3) then {
                                private _answer = [_logic, "consume", [_legacy, [_veh] call _fnc_pairOf, _h]] call MAINCLASS;
                                _hull = _answer param [0, objNull];
                                _crossed = _answer param [1, false];
                            };
                        } else {
                            ["ALIVE_fnc_ATOPlace - legacy profile %1 for %2 is present but not admissible: %3",
                                _legacy, _tail, _verdict param [1, ""]] call ALiVE_fnc_dump;
                        };

                        // consume's own word on whether it crossed its point
                        // of no return, never the registry: a refused profile
                        // that somebody else removed meanwhile is absent too.
                        if (isNull _hull) then {
                            if (_crossed) then {
                                // Crossed, and the hull did not come back:
                                // the profile is gone from the registry and
                                // nothing stands in the world. Said loudly,
                                // and NOT skipped. With nothing left behind
                                // the profile, the create branch below may
                                // build at the home, which is the restore the
                                // record is owed; left pending it would sit
                                // hull-less all session for a profile that no
                                // longer exists.
                                ["ALIVE_fnc_ATOPlace - legacy profile %1 consumed for %2 but no hull came back; building one at the home", _legacy, _tail] call ALiVE_fnc_dump;
                            } else {
                                _pending pushBackUnique _tail;
                                _skip = true;
                                ["ALIVE_fnc_ATOPlace - %1 left unattached: its legacy profile %2 is present and could not be adopted this pass", _tail, _legacy] call ALiVE_fnc_dump;
                            };
                        } else {
                            if !(_h isEqualTo _home) then { [_ledger, "setHome", [_tail, _h]] call ALIVE_fnc_ATOLedger };
                            [_surface, "reserve", [_h select 0, [_class] call _fnc_span]] call ALIVE_fnc_ATOSurface;
                            ([_logic, "attach", [_tail, _hull]] call MAINCLASS) params [["_aOk", false, [false]], ["_aWhy", "", [""]]];
                            // Reported as consumed only when attach took the
                            // hull, the rule the sweep applies. A remote hull
                            // is on the books through deferredTails and the
                            // sweep keeps asking for it, so it is neither
                            // reported nor built beside. Anything else is a
                            // hull this session cannot use, and the record
                            // is marked with the reason so the next restore
                            // tries again rather than reported as restored.
                            if (_aOk) then { _done = "consumed" } else {
                                if (_aWhy isEqualTo "remote") then { _done = "deferred" } else {
                                    ["ALIVE_fnc_ATOPlace - %1 consumed from legacy %2 but attach refused it: %3", _tail, _legacy, _aWhy] call ALiVE_fnc_dump;
                                    _why = format ["consumed from legacy but attach refused: %1", _aWhy];
                                };
                            };
                        };
                    };
                };

                // Create at the home.
                if (!_skip && {_why isEqualTo ""} && {_done isEqualTo ""}) then {
                    if (count _home < 3) then { _why = "no home" };
                    if (_why isEqualTo "") then {
                        [_home, _class] call _fnc_clearWreck;
                        private _v = [_surface, "validate", [_home, _class, objNull]] call ALIVE_fnc_ATOSurface;
                        private _target = _home;
                        if (_v param [0, false]) then {
                            _done = "placed";
                        } else {
                            private _new = [_logic, "rehome", _tail] call MAINCLASS;
                            if (count _new >= 3) then { _target = _new; _done = "rehomed" } else {
                                _why = format ["no home could be found (%1)", _v param [1, ""]];
                            };
                        };
                        if (_why isEqualTo "") then {
                            private _r = [_logic, _tail, _class, _target, []] call _fnc_placeHull;
                            // A deferred hull is not reported, the rule the
                            // sweep applies; it is reachable through
                            // deferredTails and the sweep keeps asking for it.
                            if (_r isEqualTo "deferred") then { _done = "deferred" };
                            if !(_r in ["placed", "deferred"]) then { _why = format ["hull not placed: %1", _r]; _done = "" };
                        };
                    };
                };

                // Bookkeeping, once, after every branch.
                if (!_skip) then {
                    if !(_why isEqualTo "") then {
                        [_ledger, "markUnplaceable", [_tail, _why]] call ALIVE_fnc_ATOLedger;
                        _unplaceable pushBack _tail;
                        ["ALIVE_fnc_ATOPlace - %1 (%2) is unplaceable: %3", _tail, _class, _why] call ALiVE_fnc_dump;
                    } else {
                        if (_done isEqualTo "consumed") then { _consumed pushBack _tail };
                        if (_done isEqualTo "placed") then { _placed pushBack _tail };
                        if (_done isEqualTo "rehomed") then { _rehomed pushBack _tail };
                    };
                };
            };
        } forEach _keys;

        [_logic, "pendingLegacy", _pending] call ALIVE_fnc_hashSet;
        [_logic, "passRunning", []] call ALIVE_fnc_hashSet;
        // A restore is a placement pass; the Tasker holds requests until one
        // has happened.
        [_logic, "firstPassDone", true] call ALIVE_fnc_hashSet;
        ["ALIVE_fnc_ATOPlace - restore: %1 placed, %2 consumed, %3 rehomed, %4 unplaceable, %5 pending legacy",
            count _placed, count _consumed, count _rehomed, count _unplaceable, count _pending] call ALiVE_fnc_dump;
        _result = [_placed, _consumed, _rehomed, _unplaceable];
    };

    default {
        _result = [_logic, _operation, _args] call SUPERCLASS;
    };
};

TRACE_1("ATO Place - output",_result);

_result;
