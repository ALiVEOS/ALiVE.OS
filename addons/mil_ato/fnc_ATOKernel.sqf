#include "\x\alive\addons\mil_ato\script_component.hpp"
SCRIPT(kernel);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_ATOKernel
Description:
The Kernel and the bus. The one piece that owns the module logic, holds the ten
pieces together, drives them on a clock, and answers the public operations the
rest of the mod calls on an air commander.

It decides nothing about an aircraft itself. The state table decides, the
observer measures, the effector acts, the tasker chooses, the base establishes,
placement adopts, the surface parks, the ledger remembers, the watch looks and
resupply replaces. This file is the wiring between them and the three loops
that turn the handle: a ROSTER tick that steps every aircraft's row through the
state table and applies what it asks for, a QUEUE tick that plans sorties,
mirrors the base and keeps the ground tidy, and a WATCH tick that looks at the
airspace. Everything the old module did in one eight thousand line file is now
one of those pieces, and the Kernel is the only place two of them meet.

Three rules give the file its shape.

The Kernel is the only writer of the roster. A row is changed by handing it to
the state table and storing what comes back, never by editing it in place from
some other loop, so there is exactly one place a row can be mid-change and that
place runs in one indivisible step per row. That is why a pause cannot catch a
half-stepped aircraft.

Everything the state table asks for is applied out loud. Every effect answer is
read, and a refusal is written down once per aircraft, effect and reason, so a
guard that refuses correctly and silently cannot cost four days again.

Every public operation keeps the name, the call shape and the DEFAULT it had in
the old module, because other modules read this logic raw and a mission built
against the old defaults must behave the same. Where a behaviour had to change
the reason is written at the operation.

CUTOVER. This file is written so that a later, reversible commit can point the
module at it without touching anything else first. What that commit will do:

  1. fnc_ATOInit.sqf calls [_logic, "init"] call ALIVE_fnc_ATOKernel instead
     of ALIVE_fnc_ATO. The Kernel writes class = ALIVE_fnc_ATOKernel onto the
     logic, and the event log's listener worker and main's pause and un-pause
     both resolve the class off the logic, so those follow on their own.
     Steps 1 and 2 have to land TOGETHER, though: the global registry does not
     resolve anything, it spells out ALIVE_fnc_ATO in three places (its
     registryID, persistent and assets reads), so with step 1 alone the
     registry would still be asking the OLD file, whose assets accessor
     answers an empty list, and it would publish nothing under every faction.
  2. fnc_ATO.sqf is replaced by a thin file that defines the seven helpers it
     carries today at file scope (ALiVE_fnc_catapultLaunch,
     ALiVE_fnc_getAirportTaxiPos, ALiVE_fnc_getNearestCatapult,
     ALiVE_fnc_isVTOL, ALiVE_fnc_isAntiAir, ALiVE_fnc_DrawRunwayBlacklistMarkers,
     ALiVE_fnc_CheckSpawnInMarkerArea) and forwards every operation to this
     function. The observer's air defence scan asks for ALiVE_fnc_isAntiAir
     behind an isNil guard, so dropping the helpers would silently blind it.
  3. fnc_ATOSaveData.sqf becomes a walk over every persistent air commander
     calling [_logic, "save"] here and collecting [bool, messages];
     fnc_ATOLoadData.sqf becomes a thin read taking an instance key. Until
     then the Kernel does its own loading and saving through the ledger.
  4. fnc_ATOGlobalRegistry.sqf loses its legacy store path. Until then the
     Kernel registers with it AFTER the kernel state exists and asks it to
     init without persistence, so its legacy load never runs.
  5. The four legacy test scripts under tests/ keep raising five slot
     ATO_REQUEST events; the bus here accepts exactly that shape.

Until that commit the old module keeps running exactly as it does, and this
function is inert: nothing calls it.

Parameters:
Object - The module logic
String - The selected function
Any - The selected parameters

Returns:
Any - The result of the selected function

Examples:
(begin example)
[_logic, "init"] call ALIVE_fnc_ATOKernel;
_state = [_logic, "state", "BLU_F_0"] call ALIVE_fnc_ATOKernel;
(end)

See Also:
<ALIVE_fnc_ATOBase>, <ALIVE_fnc_ATOMachine>, <ALIVE_fnc_ATOTask>, <ALIVE_fnc_ATOPlace>

Author:
Jman
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClass
#define MAINCLASS ALIVE_fnc_ATOKernel

// The defaults every public operation answers with. They are the old module's
// figures and the Eden defaults, and they must not move: other modules and
// existing missions were built against them.
#define DEFAULT_FACTION "OPF_F"
#define DEFAULT_AIRSPACE []
#define DEFAULT_SIDE "EAST"
#define DEFAULT_ATO_TYPES ["CAP","DCA","SEAD","CAS","Strike","Recce","OCA"]
#define DEFAULT_OP_HEIGHT 750
// Minutes. Every raiser sends minutes; the pieces compare seconds.
#define DEFAULT_OP_DURATION 25
#define DEFAULT_SPEED "NORMAL"
#define DEFAULT_MIN_WEAP_STATE 0.5
#define DEFAULT_MIN_FUEL_STATE 0.5
#define DEFAULT_RANGE 2000
#define DEFAULT_ROE "RED"
// The old module always offered a rescue. The tasker's own default is a coin
// toss, so the old figure is pushed in explicitly.
#define CHANCE_OF_RESCUE 1

// How long a runway may be held by an aircraft that has not yet left it. The
// public global ALiVE_ATO_runwayLockTimeout overrides it, as it always has.
#define RUNWAY_LOCK_TIMEOUT 180
// How long an approach may hold the runway. Longer, because an aircraft on
// finals is not the one that can be told to hurry.
#define LANDING_LOCK_SPAN 700

// The roster loop runs fast while anything is flying and slow when the whole
// fleet is parked, because a parked aircraft has nothing to be measured.
#define ROSTER_FAST 2
#define ROSTER_SLOW 10
#define QUEUE_INTERVAL 10
// A placement sweep every this many queue ticks, once the base stands.
#define SWEEP_EVERY 6
// The air picture is looked at every minute or two, staggered.
#define WATCH_MIN 60
#define WATCH_SPREAD 90
#define KEEPALIVE_EVERY 30
#define PUBLISH_EVERY 30
// A stand that could not be rehomed is asked about again after this long.
#define REHOME_RETRY 600
// If the base has not reported ready by then, the Kernel reports it itself.
#define READY_WATCHDOG 25
// Turnaround after a landing: three minutes plus up to ten. The old module's
// figures, and the state table reads readyAt but never sets it.
#define TURNAROUND_MIN 180
#define TURNAROUND_SPREAD 600
// The states in which an aircraft is up or about to be, which is when the
// roster has to look often.
#define FLYING_STATES ["LAUNCHING","ENROUTE","ON_STATION","RTB","LANDING"]
// The states that may hold the runway. RTB is in the list on purpose: the
// table asks for the lock FROM RTB and only moves to LANDING on the next tick
// once it reads the lock as held, so reconciling against the three states the
// contract names would release the lock in the same tick it was taken.
#define LOCK_STATES ["ASSIGNED","LAUNCHING","RTB","LANDING"]
// Effects that are announcements rather than things done to a hull.
#define BROADCAST_EFFECTS ["broadcastStart","broadcastOnStation","broadcastReturn","broadcastLost"]
// Effects that are bookkeeping for the tasker rather than for the effector.
#define BOOKKEEPING_EFFECTS ["onLost","assignFailed","sortiePlayerControl","sortieArrived","sortieReturning"]
// Base phases before the merged faction list exists.
#define EARLY_PHASES ["establishing","ready","building","ownSweep","opcomWait"]

private ["_result"];

TRACE_1("ATO Kernel - input",_this);

params [
    ["_logic", objNull, [objNull]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,[],"",0,true,false]]
];

_result = true;

// ---- file-scope helpers ----------------------------------------------------
// Each one binds what it needs. Code run with `call` inherits the caller's
// variables, so a helper that used a name it did not bind would work from the
// one case that happened to declare it and throw from the next.

// The kernel state for a logic, or [] when the module has not started. Every
// public operation that needs the state asks this and answers something sane
// on [], because the registry, the pause bus and the event log can all reach
// an operation before start has run.
private _fnc_kernel = {
    params [["_logic", objNull, [objNull]]];
    private _k = [];
    if (!isNull _logic) then {
        private _held = _logic getVariable [QGVAR(kernel), []];
        if ([_held] call ALIVE_fnc_isHash) then { _k = _held };
    };
    _k
};

// One of the ten pieces out of the kernel state, or [] when it is not there.
// Read with a default and type tested: a two-argument hashGet answers nil for
// a missing key and a nil assigned to a variable deletes it.
private _fnc_piece = {
    params [["_logic", objNull, [objNull]], ["_name", "", [""]]];
    private _out = [];
    private _k = [_logic] call _fnc_kernel;
    if !(_k isEqualTo []) then {
        private _got = [_k, _name, []] call ALIVE_fnc_hashGet;
        if ([_got] call ALIVE_fnc_isHash) then { _out = _got };
    };
    _out
};

// The debug attribute as a bool, however Eden stored it.
private _fnc_debugOn = {
    params [["_logic", objNull, [objNull]]];
    private _d = _logic getVariable ["debug", false];
    if (_d isEqualType "") then { _d = (toLower _d) isEqualTo "true" };
    if !(_d isEqualType true) then { _d = false };
    _d
};

// The legacy boolean accessor, kept as one helper so all ten of them behave
// identically: a bool argument SETS, anything else READS, and a string
// "true"/"false" left behind by Eden is coerced and written back so the next
// read is a bool. The old file repeated this block ten times by hand and two
// of the copies had drifted apart on their default.
private _fnc_boolAttr = {
    params [["_logic", objNull, [objNull]], ["_name", "", [""]], "_args", ["_default", false, [false]]];
    if (isNil "_args") then { _args = objNull };
    if (_args isEqualType true) then {
        _logic setVariable [_name, _args];
    } else {
        _args = _logic getVariable [_name, _default];
    };
    if (_args isEqualType "") then {
        _args = (toLower _args) isEqualTo "true";
        _logic setVariable [_name, _args];
    };
    if !(_args isEqualType true) then {
        _args = _default;
        _logic setVariable [_name, _args];
    };
    _args
};

// A list of names out of what Eden stored: the comma separated text the
// mission maker typed, possibly with the brackets and quotes of an array
// typed by hand, or the array a previous read already produced. Blank entries
// are dropped, because the Eden default is the empty string and the old
// parser turned that into a list holding one empty name.
private _fnc_parseList = {
    params [["_raw", "", ["", []]]];
    private _names = [];
    if (_raw isEqualType []) then {
        _names = _raw select { _x isEqualType "" };
    } else {
        _names = _raw splitString "[]""', ;";
    };
    (_names apply { trim _x }) select { !(_x isEqualTo "") }
};

// Push settings to a piece, when the module has started and the piece exists.
// Before start there is nothing to push to and the attribute on the logic is
// what start will read.
private _fnc_configure = {
    params [["_logic", objNull, [objNull]], ["_name", "", [""]], ["_pairs", [], [[]]]];
    private _dep = [_logic, _name] call _fnc_piece;
    private _ok = !(_dep isEqualTo []);
    if (_ok) then {
        switch (_name) do {
            case "task":     { [_dep, "configure", _pairs] call ALIVE_fnc_ATOTask };
            case "place":    { [_dep, "configure", _pairs] call ALIVE_fnc_ATOPlace };
            case "watch":    { [_dep, "configure", _pairs] call ALIVE_fnc_ATOWatch };
            case "resupply": { [_dep, "configure", _pairs] call ALIVE_fnc_ATOResupply };
            default { _ok = false };
        };
    };
    _ok
};

// The CfgHQIdentities class the radio speaks under, by side text. The same
// table the base uses, so the two voices are one voice.
private _fnc_hqClass = {
    params [["_side", "", [""]]];
    switch (toUpper _side) do {
        case "WEST": { "BLU" };
        case "EAST": { "OPF" };
        case "GUER": { "IND" };
        default { "HQ" };
    }
};

// Say something to the side as its HQ, through the effector's raw broadcast.
// Raw and with a null object on purpose: every named effect refuses a null
// hull, and two of the announcements this module makes are about a hull that
// is no longer there.
private _fnc_radio = {
    params [["_logic", objNull, [objNull]], ["_key", "", [""]], ["_say", [], [[]]]];
    private _effect = [_logic, "effect"] call _fnc_piece;
    private _out = false;
    if !(_effect isEqualTo []) then {
        private _side = [_logic, "side"] call MAINCLASS;
        private _hqClass = [_side] call _fnc_hqClass;
        private _onRadio = [_logic, "broadcastOnRadio", objNull, true] call _fnc_boolAttr;
        private _r = [_effect, "apply", ["broadcast", objNull, [], [_key, _say, _side, _hqClass, _onRadio]]] call ALIVE_fnc_ATOEffect;
        _out = (_r param [0, ""]) isEqualTo "ok";
        if ((_r param [0, ""]) isEqualTo "refused") then {
            ["ALIVE_fnc_ATOKernel - radio %1 not sent: %2", _key, _r param [2, ""]] call ALiVE_fnc_dump;
        };
    };
    _out
};

// The name the HQ speaks under.
private _fnc_hqName = {
    params [["_logic", objNull, [objNull]]];
    private _name = "HQ";
    private _effect = [_logic, "effect"] call _fnc_piece;
    if !(_effect isEqualTo []) then {
        private _got = [_effect, "hqName", [[_logic, "side"] call MAINCLASS] call _fnc_hqClass] call ALIVE_fnc_ATOEffect;
        if (!isNil "_got" && {_got isEqualType ""} && {!(_got isEqualTo "")}) then { _name = _got };
    };
    _name
};

// A grid somebody could act on, or a placeholder rather than the map origin.
private _fnc_grid = {
    params [["_p", [], [[]]]];
    if (count _p < 2) then { "000000" } else { mapGridPosition _p }
};

// Where something is, whatever it is: a position, an object, or a profile id.
// Answers [] when it cannot be placed, never [0,0,0], because that is a real
// corner of every map.
private _fnc_positionOf = {
    params ["_what"];
    private _out = [];
    if (isNil "_what") exitWith { [] };
    if (_what isEqualType []) then {
        if (count _what >= 2 && {(_what select 0) isEqualType 0}) then { _out = +_what };
    };
    if (_what isEqualType objNull) then {
        if (!isNull _what) then { _out = getPosATL _what };
    };
    if (_what isEqualType "" && {!(_what isEqualTo "")} && {!isNil "ALIVE_profileHandler"}) then {
        private _got = [ALIVE_profileHandler, "getProfile", _what] call ALIVE_fnc_profileHandler;
        if (!isNil "_got" && {[_got] call ALIVE_fnc_isHash}) then {
            private _p = [_got, "position", []] call ALIVE_fnc_hashGet;
            if (_p isEqualType [] && {count _p >= 2}) then { _out = +_p };
        };
    };
    _out
};

// The live objects behind a target list, for the effector to reveal. An
// object is itself; a profile id is the profile's hull or its units when they
// are spawned; anything else is skipped.
private _fnc_objectsOf = {
    params [["_targets", [], [[]]]];
    private _out = [];
    {
        if (_x isEqualType objNull) then {
            if (!isNull _x && {alive _x}) then { _out pushBackUnique _x };
        };
        if (_x isEqualType "" && {!(_x isEqualTo "")} && {!isNil "ALIVE_profileHandler"}) then {
            private _got = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
            if (!isNil "_got" && {[_got] call ALIVE_fnc_isHash}) then {
                private _v = [_got, "vehicle", objNull] call ALIVE_fnc_hashGet;
                if (_v isEqualType objNull && {!isNull _v} && {alive _v}) then { _out pushBackUnique _v };
                private _u = [_got, "units", []] call ALIVE_fnc_hashGet;
                if (_u isEqualType []) then {
                    { if (_x isEqualType objNull && {!isNull _x} && {alive _x}) then { _out pushBackUnique _x } } forEach _u;
                };
            };
        };
    } forEach _targets;
    _out
};

// Is this class a drone. The same test placement uses, kept in step with it:
// some ground drone bases carry the flag too, so callers test Air first.
private _fnc_isDrone = {
    params [["_class", "", [""]]];
    if (_class isEqualTo "") exitWith { false };
    (_class isKindOf "UAV") || {getNumber (configFile >> "CfgVehicles" >> _class >> "isUav") == 1}
};

// A campaign record as a COPY, or []. The ledger's get already copies; this
// only adds the type test so a missing record is [] rather than something a
// hashGet would refuse.
// One field of a record, with a default, safe on a missing record.
//
// Asked of the ledger as a field rather than fetched as a record and then
// indexed. Fetching the record copies all of it, and this is called several
// times per aircraft per tick: the class and the callsign for every effect
// routed, and the home in three separate places. At the fast roster rate with
// twenty aircraft that was around thirty whole record copies a second to read
// a few strings.
private _fnc_recField = {
    params [["_logic", objNull, [objNull]], ["_tail", "", [""]], ["_key", "", [""]], "_default"];
    private _ledger = [_logic, "ledger"] call _fnc_piece;
    private _out = _default;
    if (!(_ledger isEqualTo []) && {!(_tail isEqualTo "")}) then {
        private _got = [_ledger, "field", [_tail, _key, _default]] call ALIVE_fnc_ATOLedger;
        if (!isNil "_got") then { _out = _got };
    };
    _out
};

// The home of a tail, read FRESH from the ledger every time it is needed. The
// row carries a home too, but the state table never reads it and placement's
// rehome writes only the ledger, so the ledger is the one that is right.
private _fnc_homeOf = {
    params [["_logic", objNull, [objNull]], ["_tail", "", [""]]];
    private _home = [_logic, _tail, "home", []] call _fnc_recField;
    if !(_home isEqualType []) then { _home = [] };
    // A DECK home's place in the world is worked out from its ship rather
    // than read back from the record, so the copy handed out here carries
    // where that ship is NOW.
    //
    // Everything downstream reads entry zero and nothing else: the observer
    // measures the distance to it to decide whether an aircraft is home, the
    // effects fly to it, placement builds hulls on it. Handing over the
    // position that was recorded when the home was chosen means all of them
    // measure against where the ship used to be, which is the whole reason
    // the offset exists.
    if (count _home >= 6 && {(_home select 2) isEqualTo "deck"}) then {
        private _surface = [_logic, "surface"] call _fnc_piece;
        if ([_surface] call ALIVE_fnc_isHash) then {
            ([_surface, "resolve", _home] call ALIVE_fnc_ATOSurface) params [["_rp", []], ["_rd", 0]];
            // A resolve that could not find the ship answers with the origin,
            // and the origin is not a home. The record's own value is kept in
            // that case: it is stale, but validate then refuses it for the
            // right reason rather than sending anything to the map corner.
            if (_rp isEqualType [] && {count _rp > 1}
                && {!(((_rp select 0) == 0) && {(_rp select 1) == 0})}) then {
                _home = +_home;
                _home set [0, _rp];
                _home set [1, _rd];
            };
        };
    };
    _home
};

// The sortie tuple a row carries: [type, targetPos, durationSeconds, range,
// sortieId, targets]. Indices 1 to 3 are what the pieces read (the observer
// reads the target and the range, the table reads the duration); index 0 is
// the type for the kernel's own projections, 4 and 5 are kernel-private.
private _fnc_tupleOf = {
    params [["_row", [], [[]]]];
    private _t = [];
    if ([_row] call ALIVE_fnc_isHash) then { _t = [_row, "sortie", []] call ALIVE_fnc_hashGet };
    if !(_t isEqualType []) then { _t = [] };
    _t
};

// How the request wants its sortie flown, as an order chain the effector can
// take: [[type, position], ...]. Order NAMES come from the tasker or the state
// table; turning a name into a place needs the sortie and the home, and this
// is the one place that knows both.
private _fnc_resolveOrders = {
    params [["_orders", [], [[]]], ["_obj", objNull, [objNull]], ["_home", [], [[]]], ["_tuple", [], [[]]], ["_state", "", [""]]];
    private _out = [];
    if (isNull _obj) exitWith { [] };

    private _here = getPosATL _obj;
    private _homePos = if (count _home > 0 && {(_home select 0) isEqualType []}) then { +(_home select 0) } else { +_here };
    private _homeDir = if (count _home > 1 && {(_home select 1) isEqualType 0}) then { _home select 1 } else { getDir _obj };
    private _hasTarget = count _tuple > 1 && {(_tuple select 1) isEqualType []} && {count (_tuple select 1) >= 2};
    private _targetPos = if (_hasTarget) then { +(_tuple select 1) } else { _homePos getPos [1200, _homeDir] };

    // Height above the DECK when the home is a deck, above the terrain
    // otherwise. This is the one remaining thing here that reads a height, and
    // it is the thing that decides whether an order is a hold on the ground or
    // an orbit in the air, so reading it in the wrong frame is not a detail.
    //
    // Above water, terrain level is the SEA BED. Measured on the test carrier:
    // an aircraft parked on the plating reads 27.9 m above terrain level and
    // minus a tenth of a metre above the deck, and in deeper water the terrain
    // figure is nearer sixty. So every parked deck aircraft read as airborne
    // here, and a jet that had just landed on the carrier was handed an orbit
    // over its own position at sea level with its engine ordered off. It then
    // started rolling for a takeoff it could not make on a ninety metre deck,
    // and kept at it for the whole recovery deadline.
    private _airborne = if (count _home > 2 && {(_home select 2) isEqualTo "deck"}) then {
        ((getPos _obj) select 2) > 50
    } else {
        (_here select 2) > 50
    };

    {
        switch (_x) do {
            // Being told to go somewhere is what makes an aircraft lift; a
            // bare "take off" is not an order the engine understands. Aimed
            // at the target when there is one, else down the stored heading.
            case "TAKEOFF": {
                private _dir = if (_hasTarget) then { _homePos getDir _targetPos } else { _homeDir };
                _out pushBack ["MOVE", _homePos getPos [1200, _dir]];
            };
            case "MOVE_STATION": { _out pushBack ["MOVE", _targetPos] };
            case "EXECUTE":      { _out pushBack ["SAD", _targetPos] };
            // An approach fix between the target and home, so the aircraft
            // arrives near home rather than overflying it and coming back.
            case "MOVE_APPROACH": {
                _out pushBack ["MOVE", _homePos getPos [800, _homePos getDir _targetPos]];
            };
            case "LOITER": {
                if (_state in ["ENROUTE","ON_STATION"]) then {
                    _out pushBack ["LOITER", _targetPos];
                } else {
                    _out pushBack ["LOITER", _homePos getPos [600, 90]];
                };
            };
            // Stay where you are. WHERE YOU ARE, which on the ground is the
            // aircraft's own position and not its stand.
            //
            // The effector follows every new chain with a move order to the
            // chain's first position, so a hold on the stand is a hold for an
            // aircraft standing on it and an order to drive across the
            // airfield for one that is not. The aircraft this order exists
            // for is the one sitting somewhere it should not be with people
            // watching, which is exactly the case that was being told to
            // move. Rounded to the metre either way so the chain reads the
            // same tick to tick and the effector treats it as unchanged.
            //
            // In the air a hold is not something the effector will accept, an
            // airborne chain has to end in a loiter, so it becomes an orbit
            // over the spot.
            case "HOLD": {
                private _spot = [round (_here select 0), round (_here select 1), 0];
                if (_airborne) then {
                    _out pushBack ["LOITER", _spot];
                } else {
                    _out pushBack ["HOLD", _spot];
                };
            };
            // There is no landing waypoint type in this engine. The landAtPad
            // effect owns the approach; a waypoint would only fight it.
            case "LAND": { };
            default { };
        };
    } forEach _orders;
    _out
};

// The projections the tasker and the watch read: records keyed by tail with
// the class, home, readiness, roles and capabilities; rows keyed by tail with
// the state, sortie type and sortie id; and the last observation per tail.
// Built from the ledger's flat projection rather than its deep-copied view,
// because this runs on every planning drain.
private _fnc_projections = {
    params [["_logic", objNull, [objNull]]];
    private _records = [] call ALIVE_fnc_hashCreate;
    private _rowsOut = [] call ALIVE_fnc_hashCreate;
    private _obsOut = [] call ALIVE_fnc_hashCreate;
    private _k = [_logic] call _fnc_kernel;
    if (_k isEqualTo []) exitWith { [_records, _rowsOut, _obsOut] };

    private _ledger = [_logic, "ledger"] call _fnc_piece;
    private _rows = [_k, "rows", []] call ALIVE_fnc_hashGet;
    private _sortieOf = [_k, "sortieOf", []] call ALIVE_fnc_hashGet;
    private _lastObs = [_k, "lastObs", []] call ALIVE_fnc_hashGet;
    if (_ledger isEqualTo [] || {!([_rows] call ALIVE_fnc_isHash)}) exitWith { [_records, _rowsOut, _obsOut] };

    private _faction = [_ledger, "faction", ""] call ALIVE_fnc_hashGet;
    private _proj = [_ledger, "projection"] call ALIVE_fnc_ATOLedger;
    if !(_proj isEqualType []) then { _proj = [] };
    {
        _x params [["_tail", "", [""]], ["_class", "", [""]], ["_airspace", [], [[]]], ["_homePos", [0,0,0], [[]]],
                   ["_homeDir", 0, [0]], ["_roles", [], [[]]], ["_caps", [], [[]]], ["_status", "", [""]]];
        private _row = [_rows, _tail, []] call ALIVE_fnc_hashGet;
        if ([_row] call ALIVE_fnc_isHash) then {
            private _tuple = [_row] call _fnc_tupleOf;
            private _rec = [[
                ["class", _class],
                ["home", [+_homePos, _homeDir, "terrain"]],
                ["faction", _faction],
                // Readiness lives on the row; the tasker reads it off the
                // record projection, so it is carried across here.
                ["readyAt", [_row, "readyAt", 0] call ALIVE_fnc_hashGet],
                ["roles", +_roles],
                ["capabilities", +_caps],
                ["status", _status]
            ]] call ALIVE_fnc_hashCreate;
            [_records, _tail, _rec] call ALIVE_fnc_hashSet;
            private _r = [[
                ["state", [_row, "state", ""] call ALIVE_fnc_hashGet],
                ["sortieType", if (count _tuple > 0 && {(_tuple select 0) isEqualType ""}) then { _tuple select 0 } else { "" }],
                ["sortieId", [_sortieOf, _tail, ""] call ALIVE_fnc_hashGet]
            ]] call ALIVE_fnc_hashCreate;
            [_rowsOut, _tail, _r] call ALIVE_fnc_hashSet;
            private _o = [_lastObs, _tail, []] call ALIVE_fnc_hashGet;
            if ([_o] call ALIVE_fnc_isHash) then { [_obsOut, _tail, _o] call ALIVE_fnc_hashSet };
        };
    } forEach _proj;
    [_records, _rowsOut, _obsOut]
};

// The airspaces this commander holds, as marker names: the base's validated
// list once it exists, else whatever the attribute parsed to.
private _fnc_airspaces = {
    params [["_logic", objNull, [objNull]]];
    private _out = [];
    private _base = [_logic, "base"] call _fnc_piece;
    if !(_base isEqualTo []) then {
        private _got = [_base, "airspaces", []] call ALIVE_fnc_hashGet;
        if (_got isEqualType []) then { _out = _got select { _x isEqualType "" } };
    };
    if (count _out == 0) then {
        private _attr = _logic getVariable ["airspace", DEFAULT_AIRSPACE];
        if (_attr isEqualType [] || {_attr isEqualType ""}) then { _out = [_attr] call _fnc_parseList };
    };
    _out
};

// The instance key the campaign store files this commander under. The
// mission maker's own variable name when there is one; otherwise the faction
// plus this module's ordinal among the same faction modules, ordered by map
// position so the ordinal is the same every time the mission loads as long
// as the modules are where they were.
private _fnc_instanceKey = {
    params [["_logic", objNull, [objNull]], ["_faction", "", [""]]];
    private _key = vehicleVarName _logic;
    private _peers = 1;
    if (_key isEqualTo "") then {
        private _raw = _logic getVariable ["faction", DEFAULT_FACTION];
        private _same = (entities "Module_F") select {
            (typeOf _x) isEqualTo "ALiVE_mil_ato" && {(_x getVariable ["faction", DEFAULT_FACTION]) isEqualTo _raw}
        };
        _same = [_same, [], { ((getPosATL _x) select 0) * 100000 + ((getPosATL _x) select 1) }, "ASCEND"] call ALiVE_fnc_SortBy;
        if !(_same isEqualType []) then { _same = [_logic] };
        private _ordinal = _same find _logic;
        if (_ordinal < 0) then {
            // Not one of the placed commanders this rule can put in order,
            // which is what a commander created from a script looks like.
            // Ordinal zero was handed to EVERY such commander, so two of one
            // faction shared a key and would have written over each other's
            // campaign store without the unstable-key guard even noticing,
            // because that guard counts peers and the list is empty.
            //
            // Keyed by where it stands instead. No two commanders occupy the
            // same point, and one that was placed stands in the same place
            // next session, so the key is both unique and stable.
            private _p = getPosATL _logic;
            _key = format ["%1_at_%2_%3", _faction, round (_p select 0), round (_p select 1)];
            _peers = 1;
        } else {
            _key = format ["%1_%2", _faction, _ordinal];
            _peers = count _same;
        };
    };
    [_key, _peers]
};

// The two keys a campaign store may hold for this commander: its own, and
// the one shared key the old module wrote for every commander together.
private _fnc_storeKeys = {
    params [["_logic", objNull, [objNull]]];
    private _mission = [missionName, "%20", "-"] call CBA_fnc_replace;
    private _group = missionNamespace getVariable ["ALIVE_sys_data_GROUP_ID", ""];
    private _instance = "";
    private _k = [_logic] call _fnc_kernel;
    if !(_k isEqualTo []) then { _instance = [_k, "instanceKey", ""] call ALIVE_fnc_hashGet };
    [format ["%1_%2_ATO_%3", _group, _mission, _instance], format ["%1_%2_ATO", _group, _mission]]
};

// Is the persistence backend there to talk to. The same guard the old save
// and load files used.
private _fnc_dataUp = {
    isServer && {!isNil "ALIVE_sys_data"} && {!(missionNamespace getVariable ["ALIVE_sys_data_DISABLED", true])}
};

// The data handler, created once and shared, as the old files did it.
private _fnc_dataHandler = {
    if (isNil QGVAR(DATAHANDLER)) then {
        GVAR(DATAHANDLER) = [nil, "create"] call ALIVE_fnc_Data;
        [GVAR(DATAHANDLER), "storeType", true] call ALIVE_fnc_Data;
    };
    GVAR(DATAHANDLER)
};

// A refusal from the effector, written down once per aircraft, effect and
// reason. The next different reason is written down too; the same one again
// is not, because a refusal that repeats every tick buries everything else.
private _fnc_noteRefusal = {
    params [["_logic", objNull, [objNull]], ["_tail", "", [""]], ["_name", "", [""]], ["_r", [], [[]]], ["_state", "", [""]]];
    if !((_r param [0, ""]) isEqualTo "refused") exitWith { false };
    private _k = [_logic] call _fnc_kernel;
    if (_k isEqualTo []) exitWith { false };
    private _seen = [_k, "refusalsSeen", []] call ALIVE_fnc_hashGet;
    private _key = format ["%1|%2", _tail, _name];
    private _detail = _r param [2, ""];
    if !(_detail isEqualType "") then { _detail = str _detail };
    if (([_seen, _key, ""] call ALIVE_fnc_hashGet) isEqualTo _detail) exitWith { false };
    [_seen, _key, _detail] call ALIVE_fnc_hashSet;
    ["ALIVE_fnc_ATOKernel - %1 refused on %2 (%3): %4", _name, _tail, _state, _detail] call ALiVE_fnc_dump;
    true
};

// Answer a player's request event. Both shapes are the old module's, kept
// by name and by shape because a third party may listen for them.
private _fnc_playerResponse = {
    params [["_requester", [], [[]]], ["_message", "", [""]], ["_payload", [], [[]]]];
    if !([_requester] call ALIVE_fnc_isHash) exitWith { false };
    if !(([_requester, "kind", ""] call ALIVE_fnc_hashGet) isEqualTo "player") exitWith { false };
    if (isNil "ALIVE_eventLog") exitWith { false };
    private _data = [[_requester, "requestId", ""] call ALIVE_fnc_hashGet, [_requester, "playerId", ""] call ALIVE_fnc_hashGet];
    if (count _payload > 0) then { _data pushBack _payload };
    private _e = ["ATO_RESPONSE", _data, "Military Air Component Commander", _message] call ALIVE_fnc_event;
    [ALIVE_eventLog, "addEvent", _e] call ALIVE_fnc_eventLog;
    true
};

// Tell the side, and the player if it was theirs, that a request is refused.
// The unavailable key when the fleet is the reason, the denied key otherwise:
// they are different messages and the old module chose between them.
private _fnc_denyOnRadio = {
    params [["_logic", objNull, [objNull]], ["_type", "", [""]], ["_targetPos", [], [[]]], ["_requester", [], [[]]], ["_reason", "", [""]]];
    private _hqName = [_logic] call _fnc_hqName;
    if (_reason isEqualTo "not enough aircraft for an operation") then {
        [_logic, "STR_ALIVE_ATO_UNAVAILABLE", [_hqName]] call _fnc_radio;
    } else {
        [_logic, "STR_ALIVE_ATO_REQUEST_DENIED", [_hqName, _type, [_targetPos] call _fnc_grid]] call _fnc_radio;
    };
    [_requester, "DENIED_ATO_UNAVAILABLE", []] call _fnc_playerResponse;
    true
};

// Publish this commander's roster to the shared registry, as a fresh copy.
private _fnc_publish = {
    params [["_logic", objNull, [objNull]]];
    private _k = [_logic] call _fnc_kernel;
    if (_k isEqualTo []) exitWith { false };
    private _id = _logic getVariable ["registryID", ""];
    if (!(_id isEqualType "") || {_id isEqualTo ""} || {isNil "ALIVE_ATOGlobalRegistry"}) exitWith { false };
    [ALIVE_ATOGlobalRegistry, "updateGlobalATO", [_id, [_logic, "assets"] call MAINCLASS]] call ALIVE_fnc_ATOGlobalRegistry;
    [_k, "lastPublish", time] call ALIVE_fnc_hashSet;
    true
};

// ---- the transition hook ---------------------------------------------------
// Kernel-only bookkeeping when a row changes state. The state table has
// already decided the new state; this writes down what that means for the
// sortie, the stand and the radio.
private _fnc_transition = {
    params [["_logic", objNull, [objNull]], ["_tail", "", [""]], ["_from", "", [""]], ["_to", "", [""]],
            ["_row2", [], [[]]], ["_obs", [], [[]]], ["_effects", [], [[]]], ["_obj", objNull, [objNull]],
            ["_home", [], [[]]], ["_now", 0, [0]]];
    private _k = [_logic] call _fnc_kernel;
    if (_k isEqualTo []) exitWith { false };
    private _sortieOf = [_k, "sortieOf", []] call ALIVE_fnc_hashGet;
    private _tuples = [_k, "tuples", []] call ALIVE_fnc_hashGet;
    private _task = [_logic, "task"] call _fnc_piece;
    private _place = [_logic, "place"] call _fnc_piece;
    private _surface = [_logic, "surface"] call _fnc_piece;
    private _tuple = [_row2] call _fnc_tupleOf;
    private _type = if (count _tuple > 0 && {(_tuple select 0) isEqualType ""}) then { _tuple select 0 } else { "" };

    // One line per change: coarse instrumentation, nothing per tick.
    private _alt = 0;
    private _fuel = 0;
    if ([_obs] call ALIVE_fnc_isHash) then {
        _alt = [_obs, "altAGL", 0] call ALIVE_fnc_hashGet;
        _fuel = [_obs, "fuel", 0] call ALIVE_fnc_hashGet;
    };
    ["ALIVE_fnc_ATOKernel - %1: %2 -> %3 (%4, alt %5 m, fuel %6)", _tail, _from, _to,
        [_row2, "reason", ""] call ALIVE_fnc_hashGet, round _alt, _fuel toFixed 2] call ALiVE_fnc_dump;

    switch (_to) do {
        case "PARKED": {
            // ---- the stand ----------------------------------------------
            // Is the home still a home. Geometry means find another; occupied
            // means something else is sitting on it and this aircraft has to
            // move. Both go through placement's rehome, which is the one path
            // to a new home after attach. A failure is retried on the queue
            // tick's own schedule rather than every roster tick.
            if (!(_surface isEqualTo []) && {!(_place isEqualTo [])} && {count _home >= 3}) then {
                private _class = [_logic, _tail, "vehicleClass", ""] call _fnc_recField;
                private _v = [_surface, "validate", [_home, _class, _obj]] call ALIVE_fnc_ATOSurface;
                if (!(_v param [0, false]) && {(_v param [1, ""]) in ["occupied","geometry"]}) then {
                    private _retry = [_k, "rehomeFailedAt", []] call ALIVE_fnc_hashGet;
                    private _h = [_place, "rehome", _tail] call ALIVE_fnc_ATOPlace;
                    if (_h isEqualType [] && {count _h >= 3}) then {
                        [_retry, _tail] call ALIVE_fnc_hashRem;
                    } else {
                        [_retry, _tail, _now] call ALIVE_fnc_hashSet;
                    };
                };
            };

            // ---- the sortie ---------------------------------------------
            // Closed here, and ONLY when the aircraft actually went somewhere.
            // The table also moves ASSIGNED to PARKED when the crew never
            // seated, and emits assignFailed for it; that sortie is being
            // handed back to be re-let, not completed, and completing it here
            // as well would leave the tasker with a sortie that is both
            // complete and planning, plus a mission-complete call on the
            // radio for an aircraft that never moved.
            private _sid = [_sortieOf, _tail, ""] call ALIVE_fnc_hashGet;
            if (!(_sid isEqualTo "") && {!("assignFailed" in _effects)}) then {
                private _landed = _from in ["LANDING","RTB"];
                if !(_task isEqualTo []) then {
                    [_task, "complete", [_sid, if (_landed) then { "landed" } else { "recovered" }]] call ALIVE_fnc_ATOTask;
                };
                if (_landed) then {
                    [_logic, "STR_ALIVE_ATO_MISSION_COMPLETE",
                        [[_logic] call _fnc_hqName, [_logic, _tail, "callsign", _tail] call _fnc_recField, _type]] call _fnc_radio;
                };
                // The turnaround. The table reads readyAt when it is asked to
                // assign and never sets it, so the kernel sets it here.
                [_row2, "readyAt", _now + TURNAROUND_MIN + (random TURNAROUND_SPREAD)] call ALIVE_fnc_hashSet;
                [_row2, "sortie", []] call ALIVE_fnc_hashSet;
                [_sortieOf, _tail, ""] call ALIVE_fnc_hashSet;
                [_tuples, _sid] call ALIVE_fnc_hashRem;
            };
        };

        case "ON_STATION": {
            // A suppression sortie arriving is something the rest of the mod
            // may want to know about: the old module raised this event.
            if (_from isEqualTo "ENROUTE" && {_type isEqualTo "SEAD"} && {!isNil "ALIVE_eventLog"}) then {
                private _sid = [_sortieOf, _tail, ""] call ALIVE_fnc_hashGet;
                private _zone = "";
                if (count _tuple > 6 && {(_tuple select 6) isEqualType ""}) then { _zone = _tuple select 6 };
                private _at = [];
                if (count _tuple > 5 && {(_tuple select 5) isEqualType []}) then {
                    { private _p = [_x] call _fnc_positionOf; if (count _p >= 2) then { _at pushBack _p } } forEach (_tuple select 5);
                };
                private _e = ["ATO_SEAD_ON_STATION", [_sid, _zone, _at], "ATO"] call ALIVE_fnc_event;
                [ALIVE_eventLog, "addEvent", _e] call ALIVE_fnc_eventLog;
            };
        };

        default { };
    };
    true
};

// ---- effect routing --------------------------------------------------------
// Every name the state table can emit, turned into a call. Answers true when
// the row has to be dropped from the roster afterwards (the hull is lost).
private _fnc_routeEffects = {
    params [["_logic", objNull, [objNull]], ["_tail", "", [""]], ["_row2", [], [[]]], ["_effects", [], [[]]],
            ["_obj", objNull, [objNull]], ["_home", [], [[]]], ["_obs", [], [[]]], ["_now", 0, [0]]];
    private _k = [_logic] call _fnc_kernel;
    if (_k isEqualTo []) exitWith { false };

    private _ledger = [_logic, "ledger"] call _fnc_piece;
    private _surface = [_logic, "surface"] call _fnc_piece;
    private _effect = [_logic, "effect"] call _fnc_piece;
    private _place = [_logic, "place"] call _fnc_piece;
    private _task = [_logic, "task"] call _fnc_piece;
    private _resupply = [_logic, "resupply"] call _fnc_piece;
    private _sortieOf = [_k, "sortieOf", []] call ALIVE_fnc_hashGet;
    private _tuples = [_k, "tuples", []] call ALIVE_fnc_hashGet;
    private _lastLivePos = [_k, "lastLivePos", []] call ALIVE_fnc_hashGet;
    private _lockKey = [_k, "lockKey", ""] call ALIVE_fnc_hashGet;
    private _debug = [_logic] call _fnc_debugOn;

    private _state = [_row2, "state", ""] call ALIVE_fnc_hashGet;
    private _tuple = [_row2] call _fnc_tupleOf;
    private _type = if (count _tuple > 0 && {(_tuple select 0) isEqualType ""}) then { _tuple select 0 } else { "" };
    private _targetPos = if (count _tuple > 1 && {(_tuple select 1) isEqualType []}) then { _tuple select 1 } else { [] };
    private _class = [_logic, _tail, "vehicleClass", ""] call _fnc_recField;
    private _callsign = [_logic, _tail, "callsign", _tail] call _fnc_recField;
    private _drop = false;

    {
        private _name = _x;
        switch (true) do {

            // ---- the runway ---------------------------------------------
            case (_name isEqualTo "lock"): {
                if !(_surface isEqualTo []) then {
                    private _span = if (_state in ["ASSIGNED","LAUNCHING"]) then {
                        if (isNil "ALiVE_ATO_runwayLockTimeout") then { RUNWAY_LOCK_TIMEOUT } else { ALiVE_ATO_runwayLockTimeout }
                    } else { LANDING_LOCK_SPAN };
                    [_surface, "lock", [_lockKey, _tail, _now + _span]] call ALIVE_fnc_ATOSurface;
                };
            };
            case (_name isEqualTo "unlock"): {
                if !(_surface isEqualTo []) then { [_surface, "unlock", _tail] call ALIVE_fnc_ATOSurface };
            };

            // ---- the loss -----------------------------------------------
            // The rescue is offered from the last place the aircraft was seen
            // ALIVE, or from the wreck while it still exists. The observation
            // that reports the death carries no position at all (a dead hull
            // answers only the flags), so reading the position off it handed
            // the tasker nothing and every rescue was refused for want of a
            // position. The live position is kept per tail on every tick that
            // sees the hull alive, for exactly this moment.
            case (_name isEqualTo "markLost"): {
                private _pos = [_lastLivePos, _tail, []] call ALIVE_fnc_hashGet;
                if (!isNull _obj) then { _pos = getPosATL _obj };
                if (!(_ledger isEqualTo []) && {!([_ledger, "markLost", _tail] call ALIVE_fnc_ATOLedger)}) then {
                    ["ALIVE_fnc_ATOKernel - %1 lost but the ledger refused to record it (never attached this session)", _tail] call ALiVE_fnc_dump;
                };
                if !(_place isEqualTo []) then { [_place, "detach", _tail] call ALIVE_fnc_ATOPlace };
                // The rescue before the replacement: resupply deletes the
                // wreck on the stand, and the rescue wants to point at it.
                if !(_task isEqualTo []) then {
                    private _r = [_task, "csar", [_tail, _class, _pos]] call ALIVE_fnc_ATOTask;
                    if (_debug) then { ["ALIVE_fnc_ATOKernel - rescue for %1: %2", _tail, _r] call ALiVE_fnc_dump };
                };
                if !(_resupply isEqualTo []) then { [_resupply, "onLost", _tail] call ALIVE_fnc_ATOResupply };
                _drop = true;
            };

            // ---- the tasker's bookkeeping -------------------------------
            case (_name in BOOKKEEPING_EFFECTS): {
                private _sid = [_sortieOf, _tail, ""] call ALIVE_fnc_hashGet;
                // A CANCELLED sortie is already closed, and telling the
                // tasker the aircraft is on its way back re-opens it.
                //
                // A cancel marks the sortie finished and then sends the
                // aircraft home, and going home is what raises "returning",
                // which the tasker reads as the sortie being live again. For
                // a patrol that means its airspace counts as covered until
                // the aircraft is on the ground, so no replacement is raised
                // in the meantime, and the sortie is then finished a second
                // time when it parks.
                if ((([_row2, "reason", ""] call ALIVE_fnc_hashGet) isEqualTo "CANCELLED")
                    && {_name in ["sortieReturning","sortieArrived"]}) then {
                    _sid = "";
                };
                if (!(_sid isEqualTo "") && {!(_task isEqualTo [])}) then {
                    private _answer = [_task, "onRowEvent", [_sid, _tail, _name, _now]] call ALIVE_fnc_ATOTask;
                    if (_name in ["assignFailed","onLost","sortiePlayerControl"]) then {
                        ["ALIVE_fnc_ATOKernel - %1 %2 on sortie %3, the tasker says %4", _tail, _name, _sid, _answer] call ALiVE_fnc_dump;
                        [_row2, "sortie", []] call ALIVE_fnc_hashSet;
                        [_sortieOf, _tail, ""] call ALIVE_fnc_hashSet;
                        [_tuples, _sid] call ALIVE_fnc_hashRem;
                    };
                };
            };

            // ---- the radio ----------------------------------------------
            // Through the raw broadcast with a NULL object and the key spelt
            // out, never through the named broadcast effects. Those refuse a
            // null hull like every other effect, and an aircraft is LOST
            // precisely when its hull is null or dead: a hull that was
            // deleted rather than merely wrecked never had its loss announced.
            // The base announces its establishment the same way.
            case (_name in BROADCAST_EFFECTS): {
                private _hqName = [_logic] call _fnc_hqName;
                private _said = if (_type isEqualTo "") then { "an air tasking order" } else { _type };
                private _key = "";
                private _say = [];
                switch (_name) do {
                    case "broadcastStart": {
                        _key = "STR_ALIVE_ATO_START";
                        _say = [_hqName, _callsign, _said, [_targetPos] call _fnc_grid];
                    };
                    case "broadcastOnStation": {
                        _key = "STR_ALIVE_ATO_ON_STATION";
                        _say = [_hqName, _callsign, [_targetPos] call _fnc_grid, _said];
                    };
                    case "broadcastReturn": {
                        // Keyed by why it is coming back. The three short keys
                        // want no arguments at all.
                        private _why = [_row2, "reason", ""] call ALIVE_fnc_hashGet;
                        if (_why in ["RETURN_FUEL","RETURN_AMMO","RETURN_DAMAGE"]) then {
                            _key = format ["STR_ALIVE_ATO_%1", _why];
                            _say = [];
                        } else {
                            _key = "STR_ALIVE_ATO_RETURN";
                            _say = [_said];
                        };
                    };
                    default {
                        _key = "STR_ALIVE_ATO_AIRCRAFT_LOST";
                        private _display = getText (configFile >> "CfgVehicles" >> _class >> "displayName");
                        if (_display isEqualTo "") then { _display = _class };
                        _say = [_hqName, _display, _said];
                    };
                };
                [_logic, _key, _say] call _fnc_radio;
            };

            case (_name isEqualTo "refusedTeleportPlayerAboard"): {
                if (_debug) then { ["ALIVE_fnc_ATOKernel - %1 not moved: a player is aboard", _tail] call ALiVE_fnc_dump };
            };

            // ---- things done to the hull --------------------------------
            default {
                // Nothing is asked of a hull that is not there.
                //
                // Losing an aircraft raises a handful of effects at once, and
                // the ones that act on the hull are refused by the effector
                // for the good reason that there is no hull, which then puts a
                // line in the log for every aircraft ever lost. The loss
                // itself, the rescue and the replacement are not hull effects
                // and are routed above, so skipping these costs nothing and
                // keeps a real refusal worth reading.
                if (isNull _obj && {!(_name in ["shield"])}) then {
                    if (_debug) then {
                        ["ALIVE_fnc_ATOKernel - %1: %2 skipped, there is no hull to act on", _tail, _name] call ALiVE_fnc_dump;
                    };
                } else {
                if !(_effect isEqualTo []) then {
                    // The table only knows one crew effect. A drone gets the
                    // drone one, whose crew is not treated as pilots.
                    if (_name isEqualTo "mintCrew" && {[_class] call _fnc_isDrone}) then { _name = "mintDroneCrew" };
                    private _extra = switch (true) do {
                        case (_name in ["placeOnSlot","forceLanded"]): { [_surface] };
                        case (_name in ["landAtPad","releaseApproach"]): { [_surface, _tail] };
                        // The carrier pieces need the surface for the same
                        // reason the pad ones do: it holds the deck cache and
                        // resolves a carrier handle, and an effect reaches it
                        // through this switch and nowhere else.
                        case (_name in ["catapult","deckRecover","landOnRunway","virtualLaunch"]): { [_surface, _tail] };
                        // The tail is the aircraft's name on the radio, and the
                        // supply truck's dispatch carries a callsign.
                        case (_name isEqualTo "turnaround"): { [_tail] };
                        case (_name isEqualTo "revealTargets"): {
                            private _targets = if (count _tuple > 5 && {(_tuple select 5) isEqualType []}) then { _tuple select 5 } else { [] };
                            [[_targets] call _fnc_objectsOf]
                        };
                        case (_name isEqualTo "shield"): { [_tail] };
                        default { [] };
                    };
                    private _r = [_effect, "apply", [_name, _obj, _home, _extra]] call ALIVE_fnc_ATOEffect;
                    if !(_r isEqualType []) then { _r = ["refused", false, "no answer"] };
                    [_logic, _tail, _name, _r, _state] call _fnc_noteRefusal;
                };
                };
            };
        };
    } forEach _effects;
    _drop
};

// ---- orders ----------------------------------------------------------------
// The standing orders for a row, resolved and handed to the effector. The
// tasker's table is type-aware (a patrol holds, a strike attacks) and is used
// whenever the row is on a sortie; the state table's list otherwise.
private _fnc_issueOrders = {
    params [["_logic", objNull, [objNull]], ["_tail", "", [""]], ["_row2", [], [[]]], ["_orders", [], [[]]],
            ["_obj", objNull, [objNull]], ["_home", [], [[]]]];
    private _k = [_logic] call _fnc_kernel;
    if (_k isEqualTo []) exitWith { false };
    private _state = [_row2, "state", ""] call ALIVE_fnc_hashGet;
    if (_state in ["PARKED","PLAYER_FLOWN","LOST"]) exitWith { false };
    if (isNull _obj) exitWith { false };
    private _effect = [_logic, "effect"] call _fnc_piece;
    private _task = [_logic, "task"] call _fnc_piece;
    if (_effect isEqualTo []) exitWith { false };

    private _tuple = [_row2] call _fnc_tupleOf;
    private _sid = [[_k, "sortieOf", []] call ALIVE_fnc_hashGet, _tail, ""] call ALIVE_fnc_hashGet;
    if (!(_sid isEqualTo "") && {!(_task isEqualTo [])} && {count _tuple > 0}) then {
        private _typed = [_task, "ordersFor", [_tuple select 0, _state]] call ALIVE_fnc_ATOTask;
        if (_typed isEqualType []) then { _orders = _typed };
    };
    private _chain = [_orders, _obj, _home, _tuple, _state] call _fnc_resolveOrders;
    if (count _chain == 0) exitWith { false };
    private _r = [_effect, "apply", ["issueOrders", _obj, _home, [_chain]]] call ALIVE_fnc_ATOEffect;
    if !(_r isEqualType []) then { _r = ["refused", false, "no answer"] };
    [_logic, _tail, "issueOrders", _r, _state] call _fnc_noteRefusal;
    true
};

// ---- the planning drain ----------------------------------------------------
// Every sortie the tasker is waiting to fly is given a plan, and the plan is
// handed to the roster as a pending command per aircraft. The roster commits
// or refuses it on its next tick; nothing about a row changes here.
private _fnc_drain = {
    params [["_logic", objNull, [objNull]], ["_now", 0, [0]]];
    private _k = [_logic] call _fnc_kernel;
    if (_k isEqualTo []) exitWith { 0 };
    private _task = [_logic, "task"] call _fnc_piece;
    if (_task isEqualTo []) exitWith { 0 };
    private _rows = [_k, "rows", []] call ALIVE_fnc_hashGet;
    private _sortieOf = [_k, "sortieOf", []] call ALIVE_fnc_hashGet;
    private _pendingCmd = [_k, "pendingCmd", []] call ALIVE_fnc_hashGet;
    private _pendingSortie = [_k, "pendingSortie", []] call ALIVE_fnc_hashGet;
    private _override = parseNumber ([_logic, "sortieDuration"] call MAINCLASS);

    private _pending = [_task, "pending", _now] call ALIVE_fnc_ATOTask;
    if !(_pending isEqualType []) then { _pending = [] };
    if (count _pending == 0) exitWith { 0 };

    ([_logic] call _fnc_projections) params ["_records", "_rowsProj", "_obs"];

    // Aircraft whose last command has not been picked up yet are already
    // spoken for, from an EARLIER pass.
    //
    // This pass and the roster run on their own clocks and, while the fleet
    // is parked, at the same interval, so two of these with no roster between
    // them is ordinary scheduling rather than a corner case. The picture this
    // reads is rebuilt from the rows, and a row does not change until the
    // roster picks the command up, so the second pass saw the same parked
    // aircraft and planned a second sortie onto it. The pending entry is
    // keyed by aircraft, so the second wrote over the first, and the first
    // sortie then sat assigned for the rest of the mission: never stepped, so
    // never told its assignment had failed, and for a patrol its airspace
    // counted as covered, so no replacement was ever raised.
    {
        private _pr = [_rowsProj, _x, []] call ALIVE_fnc_hashGet;
        if ([_pr] call ALIVE_fnc_isHash) then {
            private _held = [_pendingCmd, _x, ""] call ALIVE_fnc_hashGet;
            if !(_held isEqualType "") then { _held = "" };
            [_pr, "state", if (_held isEqualTo "REROUTE") then { "ENROUTE" } else { "ASSIGNED" }] call ALIVE_fnc_hashSet;
        };
    } forEach ((_pendingCmd select 1) + (_pendingSortie select 1));

    private _planned = 0;

    {
        private _sid = _x;
        private _s = [_task, "sortie", _sid] call ALIVE_fnc_ATOTask;
        private _req = [];
        if ([_s] call ALIVE_fnc_isHash) then {
            _req = [_task, "request", [_s, "requestId", ""] call ALIVE_fnc_hashGet] call ALIVE_fnc_ATOTask;
        };
        if (!([_s] call ALIVE_fnc_isHash) || {!([_req] call ALIVE_fnc_isHash)}) then {
            if ([_s] call ALIVE_fnc_isHash) then {
                [_task, "deny", [_sid, "request record missing", _now]] call ALIVE_fnc_ATOTask;
            };
        } else {
            private _type = [_req, "type", ""] call ALIVE_fnc_hashGet;
            private _requester = [_req, "requester", []] call ALIVE_fnc_hashGet;
            private _kind = "";
            if ([_requester] call ALIVE_fnc_isHash) then { _kind = [_requester, "kind", ""] call ALIVE_fnc_hashGet };
            private _targetPos = [_req, "targetPos", []] call ALIVE_fnc_hashGet;
            if (!(_targetPos isEqualType []) || {count _targetPos < 2}) then {
                private _zone = [_req, "airspace", ""] call ALIVE_fnc_hashGet;
                _targetPos = if (_zone isEqualType "" && {!(_zone isEqualTo "")}) then { getMarkerPos _zone } else { [0,0,0] };
            };

            // The planner measures readiness against the request's own
            // clock, so it is handed a copy stamped NOW: an aircraft whose
            // turnaround ended after the request arrived is a candidate for
            // it, rather than never.
            //
            // And the faction is blanked OUTRIGHT.
            //
            // Whose request this is was settled when it was taken in: the bus
            // refuses one from a faction this commander does not answer for.
            // What the planner is being asked is which of OUR aircraft can
            // fly it, and every record carries the module's own faction, so
            // leaving the requester's faction on the question makes the
            // planner look for aircraft of a faction that owns none.
            //
            // The test that used to be here compared against the logic's own
            // faction list, and that list is the module's own faction alone
            // until the base has merged its synced commanders in. Anything
            // from a merged faction that arrived before the merge had already
            // waited out the whole commander wait, so the first pass to see
            // it turned it down, out loud on the radio, for good.
            private _ask = [_req] call ALIVE_fnc_hashCopy;
            [_ask, "receivedAt", _now] call ALIVE_fnc_hashSet;
            [_ask, "faction", ""] call ALIVE_fnc_hashSet;

            private _plan = [_task, "plan", [_ask, _records, _rowsProj, _obs, [_s, "excluded", []] call ALIVE_fnc_hashGet]] call ALIVE_fnc_ATOTask;
            if !(_plan isEqualType []) then { _plan = ["denied", "no plan"] };

            if ((_plan param [0, ""]) isEqualTo "denied") then {
                // Not refused on the first empty look. The request waits as
                // long as its type allows for an airframe to come free, and
                // only then is it turned down. Refusing at once denied every
                // request that arrived while the fleet was in turnaround.
                private _wait = [_task, "waitFor", _type] call ALIVE_fnc_ATOTask;
                if !(_wait isEqualType 0) then { _wait = 60 };
                if ((_now - ([_s, "receivedAt", _now] call ALIVE_fnc_hashGet)) > _wait) then {
                    private _reason = _plan param [1, "no candidate airframe"];
                    [_task, "deny", [_sid, _reason, _now]] call ALIVE_fnc_ATOTask;
                    // The module's own requests are not read out on the
                    // radio; a patrol that could not go up is not news.
                    if !(_kind isEqualTo "ATO") then {
                        [_logic, _type, _targetPos, _requester, _reason] call _fnc_denyOnRadio;
                    };
                };
            } else {
                private _tails = _plan param [0, []];
                if !(_tails isEqualType []) then { _tails = [] };
                private _planType = _plan param [1, _type];
                if (count _tails > 0 && {[_task, "dispatch", [_sid, _tails]] call ALIVE_fnc_ATOTask}) then {
                    // How long the sortie is. A commander's request carries
                    // its own length in seconds by the time it is stored. The
                    // module's own requests (patrol, intercept, suppression)
                    // carry the WAIT time in that field, which is how long to
                    // wait for a better airframe and not how long to fly, so
                    // for those the module's sortie length is used instead.
                    private _duration = [_req, "duration", 0] call ALIVE_fnc_hashGet;
                    if (!(_duration isEqualType 0) || {_kind isEqualTo "ATO"}) then {
                        _duration = if (_override > 0) then { _override * 60 } else { DEFAULT_OP_DURATION * 60 };
                    };
                    private _range = [_req, "range", DEFAULT_RANGE] call ALIVE_fnc_hashGet;
                    if !(_range isEqualType 0) then { _range = DEFAULT_RANGE };
                    private _targets = [_req, "targets", []] call ALIVE_fnc_hashGet;
                    if !(_targets isEqualType []) then { _targets = [] };
                    private _tuple = [_planType, +_targetPos, _duration, _range, _sid, +_targets, [_req, "airspace", ""] call ALIVE_fnc_hashGet];

                    {
                        private _tail = _x;
                        private _row = [_rows, _tail, []] call ALIVE_fnc_hashGet;
                        if ([_row] call ALIVE_fnc_isHash) then {
                            private _state = [_row, "state", ""] call ALIVE_fnc_hashGet;
                            // A patrol already up is turned onto the new job
                            // rather than told to start again from the stand.
                            private _cmd = if (_state isEqualTo "ON_STATION") then { "REROUTE" } else { "ASSIGN" };
                            [_pendingCmd, _tail, _cmd] call ALIVE_fnc_hashSet;
                            // The row keeps its current sortie until the
                            // roster confirms the command took. See the
                            // roster tick for why.
                            [_pendingSortie, _tail, [_sid, +_tuple, [_sortieOf, _tail, ""] call ALIVE_fnc_hashGet, [_row] call _fnc_tupleOf]] call ALIVE_fnc_hashSet;
                            // Spoken for within this drain. The projection
                            // the planner reads was built once at the top,
                            // and the row itself does not change until the
                            // roster ticks, so without this the next sortie
                            // in the same pass could choose the same aircraft
                            // and the first would keep a tail it never gets.
                            private _pr = [_rowsProj, _tail, []] call ALIVE_fnc_hashGet;
                            if ([_pr] call ALIVE_fnc_isHash) then {
                                [_pr, "state", if (_cmd isEqualTo "REROUTE") then { "ENROUTE" } else { "ASSIGNED" }] call ALIVE_fnc_hashSet;
                            };
                        };
                    } forEach _tails;
                    _planned = _planned + 1;
                    ["ALIVE_fnc_ATOKernel - sortie %1 (%2) planned for %3 at %4", _sid, _planType, _tails, [_targetPos] call _fnc_grid] call ALiVE_fnc_dump;
                };
            };
        };
    } forEach _pending;

    // Requests held for want of aircraft that have waited longer than the
    // sortie would have taken. The tasker denies them; the player is told.
    private _stale = [_task, "expireQueued", _now] call ALIVE_fnc_ATOTask;
    if (_stale isEqualType []) then {
        {
            private _s = [_task, "sortie", _x] call ALIVE_fnc_ATOTask;
            if ([_s] call ALIVE_fnc_isHash) then {
                private _req = [_task, "request", [_s, "requestId", ""] call ALIVE_fnc_hashGet] call ALIVE_fnc_ATOTask;
                if ([_req] call ALIVE_fnc_isHash) then {
                    [[_req, "requester", []] call ALIVE_fnc_hashGet, "DENIED_ATO_UNAVAILABLE", []] call _fnc_playerResponse;
                };
            };
        } forEach _stale;
    };
    _planned
};

switch(_operation) do {

    // ======================================================================
    // Boolean attributes. Same names, same defaults as the Eden attributes.
    // A SET after start is pushed to the piece that reads it.
    // ======================================================================

    case "debug": {
        _result = [_logic, "debug", _args, false] call _fnc_boolAttr;
        // The global the hangar diagnostics read. This accessor is also the
        // read path, so the global exists whether or not anything sets debug.
        if (_result) then { ALiVE_ATO_debug = true };
    };

    case "broadcastOnRadio": {
        _result = [_logic, "broadcastOnRadio", _args, true] call _fnc_boolAttr;
    };

    case "createHQ": {
        _result = [_logic, "createHQ", _args, true] call _fnc_boolAttr;
    };

    case "placeAir": {
        private _set = _args isEqualType true;
        _result = [_logic, "placeAir", _args, false] call _fnc_boolAttr;
        if (_set) then { [_logic, "place", [["placeAir", _result]]] call _fnc_configure };
    };

    case "generateTasks": {
        private _set = _args isEqualType true;
        _result = [_logic, "generateTasks", _args, false] call _fnc_boolAttr;
        if (_set) then {
            [_logic, "task", [["generateTasks", _result]]] call _fnc_configure;
            [_logic, "watch", [["generateTasks", _result]]] call _fnc_configure;
        };
    };

    case "generateSEADTasks": {
        private _set = _args isEqualType true;
        _result = [_logic, "generateSEADTasks", _args, false] call _fnc_boolAttr;
        if (_set) then { [_logic, "watch", [["generateSEADTasks", _result]]] call _fnc_configure };
    };

    // Stored under the operation name, as the old file did, and default TRUE
    // to match Eden. Keeping the two defaults apart is what made offensive
    // counter-air unreachable for years.
    case "resupply": {
        private _set = _args isEqualType true;
        _result = [_logic, _operation, _args, true] call _fnc_boolAttr;
        if (_set) then { [_logic, "resupply", [["enabled", _result]]] call _fnc_configure };
    };

    case "persistent": {
        _result = [_logic, "persistent", _args, false] call _fnc_boolAttr;
    };

    case "placeDrones": {
        private _set = _args isEqualType true;
        _result = [_logic, _operation, _args, false] call _fnc_boolAttr;
        if (_set) then { [_logic, "place", [["placeDrones", _result]]] call _fnc_configure };
    };

    case "useUAVs": {
        private _set = _args isEqualType true;
        _result = [_logic, _operation, _args, true] call _fnc_boolAttr;
        if (_set) then { [_logic, "place", [["useUAVs", _result]]] call _fnc_configure };
    };

    // Whether the base stands on a deck. The base decides this, and once it
    // has looked its answer wins; a SET is accepted for compatibility and the
    // queue tick mirrors the base's answer over it.
    case "isCarrier": {
        _result = [_logic, "isCarrier", _args, false] call _fnc_boolAttr;
        if !(_args isEqualType true) then {
            private _base = [_logic, "base"] call _fnc_piece;
            if !(_base isEqualTo []) then {
                if !(([_base, "phase", "idle"] call ALIVE_fnc_ATOBase) in ["idle","establishing","ready","building"]) then {
                    private _got = [_base, "isCarrier", false] call ALIVE_fnc_hashGet;
                    if (_got isEqualType true) then { _result = _got };
                };
            };
        };
    };

    // ======================================================================
    // Plain attributes, exactly as the old file stored them.
    // ======================================================================

    case "side": {
        _result = [_logic, _operation, _args, DEFAULT_SIDE] call ALIVE_fnc_OOsimpleOperation;
    };

    // A faction built by the faction compiler is stored under the name the
    // compiler gave it and resolves, on READ only, to the faction it stands
    // for. Guarded, because the compiler is its own module.
    case "faction": {
        _result = [_logic, _operation, _args, DEFAULT_FACTION] call ALIVE_fnc_OOsimpleOperation;
        if (!(_args isEqualType "") && {!isNil "ALiVE_fnc_factionCompilerResolveForModule"}) then {
            private _compiled = [_logic] call ALiVE_fnc_factionCompilerResolveForModule;
            if (!isNil "_compiled" && {_compiled isEqualType ""} && {!(_compiled isEqualTo "")}) then {
                _result = _compiled;
            };
        };
    };

    case "factions": {
        _result = [_logic, _operation, _args, []] call ALIVE_fnc_OOsimpleOperation;
    };
    case "enemyFactions": {
        _result = [_logic, _operation, _args, []] call ALIVE_fnc_OOsimpleOperation;
    };
    case "enemySides": {
        _result = [_logic, _operation, _args, []] call ALIVE_fnc_OOsimpleOperation;
    };
    case "registryID": {
        _result = [_logic, _operation, _args, ""] call ALIVE_fnc_OOsimpleOperation;
    };
    case "objectiveObjects": {
        _result = [_logic, _operation, _args, ""] call ALIVE_fnc_OOsimpleOperation;
    };
    case "objectiveObjectsCount": {
        _result = [_logic, _operation, _args, "0"] call ALIVE_fnc_OOsimpleOperation;
    };
    case "objectiveObjectsChance": {
        _result = [_logic, _operation, _args, "100"] call ALIVE_fnc_OOsimpleOperation;
    };
    case "objectiveObjectsBehaviour": {
        _result = [_logic, _operation, _args, "dispersed"] call ALIVE_fnc_OOsimpleOperation;
    };

    case "droneTypes": {
        private _set = _args isEqualType "";
        _result = [_logic, _operation, _args, ""] call ALIVE_fnc_OOsimpleOperation;
        if (_set) then { [_logic, "place", [["droneTypes", _result]]] call _fnc_configure };
    };

    // Minutes allowed for a sortie, as text. Blank or 0 keeps whatever the
    // requesting commander asked for. Pushed to the tasker in SECONDS.
    case "sortieDuration": {
        private _set = _args isEqualType "";
        _result = [_logic, _operation, _args, ""] call ALIVE_fnc_OOsimpleOperation;
        if (_set) then { [_logic, "task", [["sortieDuration", (parseNumber _result) * 60]]] call _fnc_configure };
    };

    case "minAssetsForOffensive": {
        private _set = _args isEqualType "";
        _result = [_logic, _operation, _args, ""] call ALIVE_fnc_OOsimpleOperation;
        if (_set) then { [_logic, "task", [["minAssetsForOffensive", parseNumber _result]]] call _fnc_configure };
    };

    case "maxConcurrentSorties": {
        private _set = _args isEqualType "";
        _result = [_logic, _operation, _args, ""] call ALIVE_fnc_OOsimpleOperation;
        if (_set) then { [_logic, "task", [["maxConcurrentSorties", parseNumber _result]]] call _fnc_configure };
    };

    case "HQBuilding": {
        _result = [_logic, _operation, _args, objNull] call ALIVE_fnc_OOsimpleOperation;
    };
    case "currentBase": {
        _result = [_logic, _operation, _args, []] call ALIVE_fnc_OOsimpleOperation;
    };
    case "pilotbuilding": {
        _result = [_logic, _operation, _args, ""] call ALIVE_fnc_OOsimpleOperation;
    };
    case "runwaystartpos": {
        _result = [_logic, _operation, _args, ""] call ALIVE_fnc_OOsimpleOperation;
    };
    case "runwayendpos": {
        _result = [_logic, _operation, _args, ""] call ALIVE_fnc_OOsimpleOperation;
    };
    case "runwaywidth": {
        _result = [_logic, _operation, _args, ""] call ALIVE_fnc_OOsimpleOperation;
    };

    // Kept only so a legacy read answers its old default. Nothing writes them.
    case "eventQueue": {
        _result = [_logic, _operation, _args, []] call ALIVE_fnc_OOsimpleOperation;
    };
    case "airspaceAssets": {
        _result = [_logic, _operation, _args, []] call ALIVE_fnc_OOsimpleOperation;
    };
    case "requestAnalysis": {
        _result = [_logic, _operation, _args, []] call ALIVE_fnc_OOsimpleOperation;
    };
    case "runways": {
        _result = [_logic, _operation, _args, []] call ALIVE_fnc_OOsimpleOperation;
    };

    // ======================================================================
    // The two parsed attributes.
    // ======================================================================

    // The airspace markers, as a list of names. Text or array in, list out;
    // the base validates the names and writes the validated list back.
    case "airspace": {
        if (_args isEqualType "" || {_args isEqualType []}) then {
            private _list = [_args] call _fnc_parseList;
            _logic setVariable [_operation, _list];
            [_logic, "place", [["airspaces", +_list]]] call _fnc_configure;
            [_logic, "watch", [["airspaces", +_list]]] call _fnc_configure;
        };
        _result = _logic getVariable [_operation, DEFAULT_AIRSPACE];
        if !(_result isEqualType []) then { _result = +DEFAULT_AIRSPACE };
    };

    // The sortie types this commander may fly. Accepts the Eden picker's CSV
    // and the legacy hand-typed array literal alike, parsed rather than
    // compiled, matched case-insensitively and stored in canonical case.
    // An empty list is indistinguishable from a broken module, so it is
    // treated as impossible and replaced by the full set, loudly.
    case "types": {
        private _set = _args isEqualType "" || {_args isEqualType []};
        if (_args isEqualType "") then {
            private _parsed = [];
            {
                private _token = toLower _x;
                if !(_token isEqualTo "") then {
                    {
                        if ((toLower _x) isEqualTo _token && {!(_x in _parsed)}) then { _parsed pushBack _x };
                    } forEach DEFAULT_ATO_TYPES;
                };
            } forEach (_args splitString "[]""', ");
            if (count _parsed == 0 && {!(_args isEqualTo "")}) then {
                ["ATO %1 - Warning, no recognisable mission types in %2. Using the full set instead.", _logic, str _args] call ALiVE_fnc_dumpR;
                _parsed = +DEFAULT_ATO_TYPES;
            };
            _logic setVariable [_operation, _parsed];
        };
        if (_args isEqualType []) then {
            _logic setVariable [_operation, _args select { _x isEqualType "" }];
        };
        _result = _logic getVariable [_operation, DEFAULT_ATO_TYPES];
        if (!(_result isEqualType []) || {count _result == 0}) then {
            ["ATO %1 - Warning, no air mission types are set for this commander, so nothing could be flown. Falling back to the full set - check the Available ATOs setting on the module.", _logic] call ALiVE_fnc_dumpR;
            _result = +DEFAULT_ATO_TYPES;
            _logic setVariable [_operation, _result];
        };
        if (_set) then {
            [_logic, "watch", [["types", +_result]]] call _fnc_configure;
            [_logic, "task", [["types", +_result]]] call _fnc_configure;
        };
    };

    // ======================================================================
    // Derived reads.
    // ======================================================================

    // The roster as the registry wants it: a FRESH hash, tail to asset. Empty
    // before start rather than an error, because the registry asks for this
    // the moment a module registers and registration may come before the
    // kernel state exists.
    case "assets": {
        private _out = [] call ALIVE_fnc_hashCreate;
        private _k = [_logic] call _fnc_kernel;
        if (!(_k isEqualTo []) && {!(_args isEqualType [])}) then {
            private _ledger = [_logic, "ledger"] call _fnc_piece;
            private _rows = [_k, "rows", []] call ALIVE_fnc_hashGet;
            if (!(_ledger isEqualTo []) && {[_rows] call ALIVE_fnc_isHash}) then {
                private _proj = [_ledger, "projection"] call ALIVE_fnc_ATOLedger;
                if !(_proj isEqualType []) then { _proj = [] };
                private _now = time;
                {
                    _x params [["_tail", "", [""]], ["_class", "", [""]], ["_airspace", [], [[]]], ["_homePos", [0,0,0], [[]]],
                               ["_homeDir", 0, [0]], ["_roles", [], [[]]], ["_caps", [], [[]]], ["_status", "", [""]]];
                    private _row = [_rows, _tail, []] call ALIVE_fnc_hashGet;
                    private _state = "";
                    private _ready = false;
                    if ([_row] call ALIVE_fnc_isHash) then {
                        _state = [_row, "state", ""] call ALIVE_fnc_hashGet;
                        _ready = _state isEqualTo "PARKED" && {_now >= ([_row, "readyAt", 0] call ALIVE_fnc_hashGet)};
                    };
                    private _asset = [[
                        ["profileID", _tail],
                        ["vehicleClass", _class],
                        ["airspace", +_airspace],
                        ["startPos", +_homePos],
                        ["startDir", _homeDir],
                        ["roles", +_roles],
                        ["capabilities", +_caps],
                        ["status", _status],
                        ["currentOp", _state],
                        ["ready", _ready]
                    ]] call ALIVE_fnc_hashCreate;
                    [_out, _tail, _asset] call ALIVE_fnc_hashSet;
                } forEach _proj;
            };
        };
        if (_args isEqualType [] && {count _args > 0}) then {
            ["ALIVE_fnc_ATOKernel - assets is read-only under the kernel; the ledger is the store"] call ALiVE_fnc_dump;
        };
        _result = _out;
    };

    // What one aircraft is doing: [state, seconds in it, seconds to its
    // deadline or -1, sortie id, protected, home, seconds until ready].
    // The air picture, for anything outside this module that wants to report
    // it to a player.
    //
    // Read only, and it draws nothing. The design for the reporting splits it
    // on purpose: losses and ground attacks belong in the situation report's
    // diary, the periodic state belongs on a common operational picture layer,
    // and the settings that turn any of it on belong to the tasking module.
    // This module's share is to be able to answer the question.
    //
    // Ours is counted off the state table's own flying states. The design brief
    // flagged that the obvious signal for this is wrong because it is a
    // launch-preparation latch rather than a statement about being in the air;
    // that cannot happen here, because a state says where an aircraft is.
    //
    // Theirs is counted fresh rather than remembered, so a contact that has
    // left is not still on the books.
    case "airPicture": {
        private _k = [_logic] call _fnc_kernel;
        private _out = [[
            ["side", [_logic, "side"] call MAINCLASS],
            ["faction", [_logic, "faction"] call MAINCLASS],
            ["ours", 0],
            ["oursAirborne", 0],
            ["theirs", 0],
            ["zones", []],
            ["state", "unknown"],
            ["at", time]
        ]] call ALIVE_fnc_hashCreate;

        if !(_k isEqualTo []) then {
            private _rows = [_k, "rows", []] call ALIVE_fnc_hashGet;
            private _ours = 0;
            private _up = 0;
            if ([_rows] call ALIVE_fnc_isHash) then {
                {
                    private _row = [_rows, _x, []] call ALIVE_fnc_hashGet;
                    if ([_row] call ALIVE_fnc_isHash) then {
                        _ours = _ours + 1;
                        if (([_row, "state", ""] call ALIVE_fnc_hashGet) in FLYING_STATES) then {
                            _up = _up + 1;
                        };
                    };
                } forEach (_rows select 1);
            };
            [_out, "ours", _ours] call ALIVE_fnc_hashSet;
            [_out, "oursAirborne", _up] call ALIVE_fnc_hashSet;

            private _theirs = 0;
            private _zones = [];
            private _watch = [_logic, "watch"] call _fnc_piece;
            if !(_watch isEqualTo []) then {
                private _found = [_watch, "scanBogeys"] call ALIVE_fnc_ATOWatch;
                if ([_found] call ALIVE_fnc_isHash) then {
                    {
                        private _inZone = [_found, _x, []] call ALIVE_fnc_hashGet;
                        if (_inZone isEqualType [] && {count _inZone > 0}) then {
                            _theirs = _theirs + (count _inZone);
                            _zones pushBack [_x, count _inZone];
                        };
                    } forEach (_found select 1);
                };
            };
            [_out, "theirs", _theirs] call ALIVE_fnc_hashSet;
            [_out, "zones", _zones] call ALIVE_fnc_hashSet;

            // Contested means both sides have something in the air over our
            // own airspaces. Inferiority means they do and we do not, which is
            // the one worth telling a player about. And with nothing of theirs
            // up, having something of ours up is superiority while having
            // nothing up is simply quiet: an empty sky is not a victory.
            private _state = switch (true) do {
                case (_theirs > 0 && {_up > 0}): { "contested" };
                case (_theirs > 0):              { "inferiority" };
                case (_up > 0):                  { "superiority" };
                default                          { "quiet" };
            };
            [_out, "state", _state] call ALIVE_fnc_hashSet;
        };

        _result = _out;
    };

    case "state": {
        _result = [];
        private _k = [_logic] call _fnc_kernel;
        if (_k isEqualTo [] || {!(_args isEqualType "")}) exitWith {};
        private _row = [[_k, "rows", []] call ALIVE_fnc_hashGet, _args, []] call ALIVE_fnc_hashGet;
        if !([_row] call ALIVE_fnc_isHash) exitWith {};
        private _now = time;
        private _deadline = [_row, "deadlineAt", 0] call ALIVE_fnc_hashGet;
        private _readyAt = [_row, "readyAt", 0] call ALIVE_fnc_hashGet;
        private _protected = [_logic, "isProtected", _args] call MAINCLASS;
        _result = [
            [_row, "state", ""] call ALIVE_fnc_hashGet,
            _now - ([_row, "enteredAt", 0] call ALIVE_fnc_hashGet),
            if (_deadline > 0) then { _deadline - _now } else { -1 },
            [[_k, "sortieOf", []] call ALIVE_fnc_hashGet, _args, ""] call ALIVE_fnc_hashGet,
            _protected param [0, false],
            [_logic, _args] call _fnc_homeOf,
            (_readyAt - _now) max 0
        ];
    };

    // Can this hull be taken away from us. An object or a tail.
    case "isProtected": {
        _result = [false, ["no object"]];
        private _obj = objNull;
        if (_args isEqualType objNull) then { _obj = _args };
        if (_args isEqualType "") then {
            private _place = [_logic, "place"] call _fnc_piece;
            if !(_place isEqualTo []) then { _obj = [_place, "objFor", _args] call ALIVE_fnc_ATOPlace };
        };
        private _observe = [_logic, "observe"] call _fnc_piece;
        if (!isNull _obj && {!(_observe isEqualTo [])}) then {
            _result = [_observe, "isProtected", _obj] call ALIVE_fnc_ATOObserve;
        };
    };

    // The kernel state itself, for a test or a diagnostic to read. Never
    // written to from outside.
    case "kernel": {
        _result = [_logic] call _fnc_kernel;
    };

    // ======================================================================
    // Persistence.
    // ======================================================================

    // Save this commander's records under its own key. Answers [bool, text].
    case "save": {
        _result = [false, ""];
        private _k = [_logic] call _fnc_kernel;
        if (_k isEqualTo []) exitWith { _result = [false, "ALiVE Military air tasking orders - save refused: the module has not started"] };
        if !(call _fnc_dataUp) exitWith { _result = [false, "ALiVE Military air tasking orders - save skipped: sys_data absent or disabled"] };
        private _key = [_k, "instanceKey", ""] call ALIVE_fnc_hashGet;
        if ([_k, "keyCollision", false] call ALIVE_fnc_hashGet) exitWith {
            _result = [false, format ["ALiVE Military air tasking orders - save refused: instance key %1 is already claimed by another module", _key]];
        };
        // Two same faction modules with no variable names are told apart by
        // their map order alone, and a mission maker who moves one between
        // sessions re-keys both and doubles their aircraft on the next load.
        // Refused with the fix in the message rather than saved wrong.
        if ([_k, "keyUnstable", false] call ALIVE_fnc_hashGet) exitWith {
            _result = [false, format ["ALiVE Military air tasking orders - save refused for %1: give each same-faction Air Component Commander a variable name in Eden so its records have a stable key", _key]];
        };
        private _ledger = [_logic, "ledger"] call _fnc_piece;
        if (_ledger isEqualTo []) exitWith { _result = [false, "ALiVE Military air tasking orders - save refused: no ledger"] };
        private _store = call _fnc_dataHandler;
        ([_logic] call _fnc_storeKeys) params ["_ownKey"];
        private _r = [_ledger, "save", [_store, _ownKey]] call ALIVE_fnc_ATOLedger;
        // Both shipped backends answer with a STRING on success and the data
        // layer answers "ERROR" when it is disabled, so success is anything
        // that is neither false nor that word.
        private _ok = !isNil "_r" && {!(_r isEqualTo false)} && {!(_r isEqualTo "ERROR")};
        private _n = count (([_ledger, "view"] call ALIVE_fnc_ATOLedger) select 1);
        _result = [_ok, format ["ALiVE Military air tasking orders - %1: saved %2 aircraft under %3, result %4", _key, _n, _ownKey, if (isNil "_r") then { "nothing" } else { _r }]];
        ["ALIVE_fnc_ATOKernel - %1", _result select 1] call ALiVE_fnc_dump;
    };

    // Load this commander's records: its own key first, and only when that
    // holds nothing the one shared key the old module wrote, filtered to this
    // commander's faction. The old store held every faction in one document
    // and the ledger's legacy import takes all of it, so the filtering is
    // done here or every commander would be given every faction's aircraft.
    // Answers [kept, unplaceable, unknown, legacyKept].
    case "load": {
        _result = [0, [], [], 0];
        private _k = [_logic] call _fnc_kernel;
        if (_k isEqualTo []) exitWith {};
        if !(call _fnc_dataUp) exitWith {
            ["ALIVE_fnc_ATOKernel - load skipped: sys_data absent or disabled"] call ALiVE_fnc_dump;
        };
        if ([_k, "keyCollision", false] call ALIVE_fnc_hashGet) exitWith {
            ["ALIVE_fnc_ATOKernel - load skipped: the instance key is already claimed, loading the same set twice would double every aircraft"] call ALiVE_fnc_dump;
        };
        private _ledger = [_logic, "ledger"] call _fnc_piece;
        if (_ledger isEqualTo []) exitWith {};
        private _store = call _fnc_dataHandler;
        ([_logic] call _fnc_storeKeys) params ["_ownKey", "_legacyKey"];

        private _own = [_ledger, "load", [_store, _ownKey, ""]] call ALIVE_fnc_ATOLedger;
        if !(_own isEqualType [] && {count _own >= 3}) then { _own = [0, [], []] };
        private _legacyKept = 0;
        if ((_own select 0) == 0) then {
            private _legacy = [_store, "bulkLoad", ["mil_ato", _legacyKey, false]] call ALIVE_fnc_Data;
            if (!isNil "_legacy" && {[_legacy] call ALIVE_fnc_isHash}) then {
                if (isNil QGVAR(legacyImported)) then { GVAR(legacyImported) = [] };
                private _faction = [_ledger, "faction", ""] call ALIVE_fnc_hashGet;
                if (!(_faction isEqualTo "") && {!(_faction in GVAR(legacyImported))}) then {
                    private _mine = [_legacy, _faction, []] call ALIVE_fnc_hashGet;
                    if ([_mine] call ALIVE_fnc_isHash) then {
                        private _sub = [] call ALIVE_fnc_hashCreate;
                        [_sub, _faction, _mine] call ALIVE_fnc_hashSet;
                        private _r = [_ledger, "importLegacy", _sub] call ALIVE_fnc_ATOLedger;
                        if (_r isEqualType [] && {count _r > 0}) then { _legacyKept = _r select 0 };
                        // Remembered for the session, so a second instance
                        // of the same faction does not take them again. The
                        // shared document itself is never deleted: an older
                        // build must still find its aircraft.
                        GVAR(legacyImported) pushBack _faction;
                    };
                };
            };
        };
        _result = [_own select 0, _own select 1, _own select 2, _legacyKept];
        ["ALIVE_fnc_ATOKernel - load for %1: %2 records restored (%3 unplaceable, %4 unknown), %5 taken from the old store",
            _ownKey, _own select 0, count (_own select 1), count (_own select 2), _legacyKept] call ALiVE_fnc_dump;
    };

    // ======================================================================
    // Methods.
    // ======================================================================

    // Take an aircraft off the books on purpose. NOT through the table's
    // RETIRE command: that lands on LOST, which counts as a loss and lets
    // resupply order a replacement for an aircraft nobody lost.
    case "retire": {
        _result = false;
        private _k = [_logic] call _fnc_kernel;
        if (_k isEqualTo [] || {!(_args isEqualType [])}) exitWith {};
        _args params [["_tail", "", [""]], ["_reason", "retired", [""]]];
        if (_tail isEqualTo "") exitWith {};
        private _effect = [_logic, "effect"] call _fnc_piece;
        private _surface = [_logic, "surface"] call _fnc_piece;
        private _ledger = [_logic, "ledger"] call _fnc_piece;
        private _place = [_logic, "place"] call _fnc_piece;
        private _task = [_logic, "task"] call _fnc_piece;
        private _home = [_logic, _tail] call _fnc_homeOf;
        private _obj = objNull;
        if !(_place isEqualTo []) then { _obj = [_place, "objFor", _tail] call ALIVE_fnc_ATOPlace };

        if (!isNull _obj && {!(_effect isEqualTo [])}) then {
            { [_effect, "apply", [_x, _obj, _home, []]] call ALIVE_fnc_ATOEffect } forEach ["standDownCrew","clearOrders","engineOff"];
            // The effector has no unshield yet, so the stamp is cleared by
            // hand. Left on, the hull would be refused by every sweep as
            // spoken for, for the rest of the mission.
            _obj setVariable ["ALiVE_mil_ato_tail", nil, true];
            _obj setVariable ["ALIVE_profileIgnore", nil, true];
        };
        if !(_surface isEqualTo []) then {
            [_surface, "unlock", _tail] call ALIVE_fnc_ATOSurface;
            [_surface, "unstampPad", _tail] call ALIVE_fnc_ATOSurface;
        };
        if !(_ledger isEqualTo []) then { [_ledger, "retire", [_tail, _reason]] call ALIVE_fnc_ATOLedger };
        if !(_place isEqualTo []) then { [_place, "detach", _tail] call ALIVE_fnc_ATOPlace };

        private _sortieOf = [_k, "sortieOf", []] call ALIVE_fnc_hashGet;
        private _sid = [_sortieOf, _tail, ""] call ALIVE_fnc_hashGet;
        if (!(_sid isEqualTo "") && {!(_task isEqualTo [])}) then {
            [_task, "complete", [_sid, "retired"]] call ALIVE_fnc_ATOTask;
            [[_k, "tuples", []] call ALIVE_fnc_hashGet, _sid] call ALIVE_fnc_hashRem;
        };
        {
            [[_k, _x, []] call ALIVE_fnc_hashGet, _tail] call ALIVE_fnc_hashRem;
        } forEach ["rows","sortieOf","lastObs","lastLivePos","pendingCmd","pendingSortie","rehomeFailedAt","protectWarned"];
        ["ALIVE_fnc_ATOKernel - %1 retired: %2", _tail, _reason] call ALiVE_fnc_dump;
        _result = true;
    };

    // Register a profile with the commander. The legacy shape, [profileID,
    // airspaceMarker]. Adoption waits inside placement, so it is spawned and
    // the answer is the fact that it was started; the tail turns up on the
    // roster once the hull is in hand.
    //
    // A CREW id is accepted too, and resolved to the aircraft it commands
    // before adoption is asked for. The operation this replaces did that, and
    // a caller holding one half of a crewed pair is as likely to hold the
    // crew as the aircraft, so refusing a crew id would have been a silent
    // change of meaning behind an unchanged name.
    case "registerProfile": {
        _result = ["refused", "no profile id"];
        private _place = [_logic, "place"] call _fnc_piece;
        if (_place isEqualTo []) exitWith { _result = ["refused", "the module has not started"] };
        private _id = "";
        if (_args isEqualType "") then { _id = _args };
        if (_args isEqualType [] && {count _args > 0} && {(_args select 0) isEqualType ""}) then { _id = _args select 0 };
        if (_id isEqualTo "") exitWith {};
        [_place, _id] spawn {
            params ["_place", "_id"];
            // A crew id names the aircraft it commands. Resolved here, inside
            // the spawn, because reading a profile is a read and this is
            // already off the caller's thread.
            private _veh = _id;
            if (!isNil "ALiVE_profileHandler") then {
                private _prof = [ALiVE_profileHandler, "getProfile", _id] call ALiVE_fnc_ProfileHandler;
                if (!isNil "_prof" && {_prof isEqualType []}) then {
                    if (([_prof, "type", ""] call ALIVE_fnc_hashGet) isEqualTo "entity") then {
                        private _owned = [_prof, "vehiclesInCommandOf", []] call ALIVE_fnc_hashGet;
                        if (_owned isEqualType [] && {count _owned > 0} && {(_owned select 0) isEqualType ""}) then {
                            _veh = _owned select 0;
                            ["ALIVE_fnc_ATOKernel - registerProfile %1 is a crew; its aircraft is %2", _id, _veh] call ALiVE_fnc_dump;
                        };
                    };
                };
            };
            private _r = [_place, "adoptPair", [_veh, "", [], ""]] call ALIVE_fnc_ATOPlace;
            ["ALIVE_fnc_ATOKernel - registerProfile %1: %2", _veh, _r] call ALiVE_fnc_dump;
        };
        _result = ["spawned", _id];
    };

    // Hand something to players as a task: [type, targets, friendly].
    case "requestPlayerTask": {
        _result = ["denied", "the module has not started"];
        private _task = [_logic, "task"] call _fnc_piece;
        if (_task isEqualTo [] || {!(_args isEqualType [])}) exitWith {};
        _args params [["_type", "", [""]], ["_targets", [], [[]]], ["_friendly", "", ["", [], objNull]]];
        _result = [_task, "playerTask", [_type, _targets, _friendly]] call ALIVE_fnc_ATOTask;
    };

    // Offer a downed crew as a rescue. A tail, or the legacy asset hash
    // carrying vehicleClass and currentPos.
    case "requestCSARPlayerTask": {
        _result = ["denied", "the module has not started"];
        private _task = [_logic, "task"] call _fnc_piece;
        if (_task isEqualTo []) exitWith {};
        private _tail = "";
        private _class = "";
        private _pos = [];
        if (_args isEqualType "") then {
            _tail = _args;
            _class = [_logic, _tail, "vehicleClass", ""] call _fnc_recField;
            private _k = [_logic] call _fnc_kernel;
            if !(_k isEqualTo []) then { _pos = [[_k, "lastLivePos", []] call ALIVE_fnc_hashGet, _tail, []] call ALIVE_fnc_hashGet };
        };
        if (_args isEqualType [] && {[_args] call ALIVE_fnc_isHash}) then {
            _class = [_args, "vehicleClass", ""] call ALIVE_fnc_hashGet;
            _pos = [_args, "currentPos", []] call ALIVE_fnc_hashGet;
            _tail = [_args, "profileID", ""] call ALIVE_fnc_hashGet;
        };
        if !(_pos isEqualType []) then { _pos = [] };
        _result = [_task, "csar", [_tail, _class, _pos]] call ALIVE_fnc_ATOTask;
    };

    // Somebody saw an air defence. An object or a profile id; the watch files
    // it under the airspace it is in.
    case "registerThreat": {
        _result = false;
        private _watch = [_logic, "watch"] call _fnc_piece;
        if (_watch isEqualTo []) exitWith {};
        if !(_args isEqualType objNull || {_args isEqualType ""}) exitWith {};
        _result = [_watch, "registerThreat", [_args, ""]] call ALIVE_fnc_ATOWatch;
    };

    // The legacy accessor against the public patrol clock, kept verbatim.
    // The watch keeps its own per-instance clock and mirrors it here.
    // Read and write through THIS commander's own entry.
    //
    // The name, the call shape and the answer are the old ones. What changed
    // underneath is that the watch now files its patrol clocks per commander,
    // because two commanders over one map each want their own, so the old
    // flat read by airspace name answered zero for every airspace and the old
    // flat write put a number in beside the per-commander entries. Kept
    // working rather than retired: the shape is public and costs nothing.
    case "airspaceLastCAP": {
        _result = 0;
        if (isNil QGVAR(lastCAP)) then { GVAR(lastCAP) = [] call ALiVE_fnc_hashCreate };
        private _kCap = [_logic] call _fnc_kernel;
        private _mine = "default";
        if !(_kCap isEqualTo []) then {
            private _key = [_kCap, "instanceKey", ""] call ALIVE_fnc_hashGet;
            if (_key isEqualType "" && {!(_key isEqualTo "")}) then { _mine = _key };
        };
        private _zones = [GVAR(lastCAP), _mine, []] call ALiVE_fnc_hashGet;
        if !([_zones] call ALIVE_fnc_isHash) then {
            _zones = [] call ALiVE_fnc_hashCreate;
            [GVAR(lastCAP), _mine, _zones] call ALiVE_fnc_hashSet;
        };
        if (_args isEqualType "") then {
            _result = [_zones, _args, 0] call ALiVE_fnc_hashGet;
        };
        if (_args isEqualType [] && {count _args > 1}) then {
            _result = [_zones, _args select 0, _args select 1] call ALiVE_fnc_hashSet;
        };
    };

    // ======================================================================
    // The bus.
    // ======================================================================

    // Register with the event log, once. Called by the base's readiness
    // callback BEFORE the flag goes up, so the first request the ground
    // commander raises on reading the flag has somewhere to land.
    case "listen": {
        _result = false;
        if (isNil "ALIVE_eventLog") exitWith {
            ["ALIVE_fnc_ATOKernel - no event log to listen on"] call ALiVE_fnc_dump;
        };
        private _held = _logic getVariable ["listenerID", ""];
        if (!(_held isEqualType "") || {!(_held isEqualTo "")}) exitWith { _result = true };
        private _id = [ALIVE_eventLog, "addListener", [_logic, ["ATO_REQUEST","ATO_STATUS_REQUEST","ATO_CANCEL_REQUEST","LOGISTICS_COMPLETE"]]] call ALIVE_fnc_eventLog;
        _logic setVariable ["listenerID", _id];
        private _k = [_logic] call _fnc_kernel;
        if !(_k isEqualTo []) then { [_k, "listenerID", _id] call ALIVE_fnc_hashSet };
        _result = true;
    };

    // Dispatch an event to the case named after its type. The event log
    // calls this from a per-listener worker that drains the listener's queue
    // serially, so a case that waited would hold up every request behind it.
    case "handleEvent": {
        if (_args isEqualType [] && {[_args] call ALIVE_fnc_isHash}) then {
            private _type = [_args, "type", ""] call ALIVE_fnc_hashGet;
            if (_type isEqualType "" && {!(_type isEqualTo "")}) then {
                [_logic, _type, _args] call MAINCLASS;
            };
        };
    };

    // A request for air support. The legacy five slot payload, with two more
    // when a player raised it:
    //   [type, side, faction, airspaceOrPos, [roe, height, speed, minWeapon,
    //    minFuel, range, durationMinutes, targets], requestId, playerId]
    case "ATO_REQUEST": {
        if !(_args isEqualType [] && {[_args] call ALIVE_fnc_isHash}) exitWith {};
        private _k = [_logic] call _fnc_kernel;
        private _task = [_logic, "task"] call _fnc_piece;
        if (_k isEqualTo [] || {_task isEqualTo []}) exitWith {
            ["ALIVE_fnc_ATOKernel - a request arrived before the module started and was dropped"] call ALiVE_fnc_dump;
        };
        private _data = [_args, "data", []] call ALIVE_fnc_hashGet;
        if !(_data isEqualType [] && {count _data >= 5}) exitWith {
            ["ALIVE_fnc_ATOKernel - request with a payload this does not read: %1", _data] call ALiVE_fnc_dump;
        };
        _data params [["_type", "", [""]], "_sideRaw", ["_faction", "", [""]], "_airspaceRaw", ["_ato", [], [[]]]];
        if (isNil "_airspaceRaw") then { _airspaceRaw = "" };
        private _from = [_args, "from", ""] call ALIVE_fnc_hashGet;
        if !(_from isEqualType "") then { _from = "" };
        private _eventId = [_args, "id", 0] call ALIVE_fnc_hashGet;

        // ---- whose request is it -------------------------------------------
        // Ours when the faction is one this commander answers for. Before
        // the base has merged the synced ground commanders' factions, a
        // request from one of them would be refused for the whole of the
        // commander wait, so in that window a friendly faction that a synced
        // commander owns (or might, its handler not being up yet) is accepted
        // and the tasker told so. The base's own merge settles the list.
        private _factions = [_logic, "factions"] call MAINCLASS;
        if !(_factions isEqualType []) then { _factions = [] };
        private _ours = _faction in _factions;
        if (!_ours && {!(_faction isEqualTo "")}) then {
            private _base = [_logic, "base"] call _fnc_piece;
            private _phase = if (_base isEqualTo []) then { "idle" } else { [_base, "phase", "idle"] call ALIVE_fnc_ATOBase };
            if (_phase in EARLY_PHASES) then {
                private _mine = [[_logic, "side"] call MAINCLASS] call ALIVE_fnc_sideTextToObject;
                private _theirs = _faction call ALiVE_fnc_factionSide;
                if ([_theirs, _mine] call BIS_fnc_sideIsFriendly) then {
                    private _match = false;
                    private _unknown = false;
                    {
                        if (!isNull _x && {(typeOf _x) isEqualTo "ALiVE_mil_OPCOM"}) then {
                            private _h = _x getVariable ["handler", []];
                            if ([_h] call ALIVE_fnc_isHash) then {
                                private _hf = [_h, "factions", []] call ALIVE_fnc_hashGet;
                                if (_hf isEqualType [] && {_faction in _hf}) then { _match = true };
                            } else {
                                _unknown = true;
                            };
                        };
                    } forEach (synchronizedObjects _logic);
                    if (_match || _unknown) then {
                        _ours = true;
                        private _early = [_k, "earlyFactions", []] call ALIVE_fnc_hashGet;
                        if !(_faction in _early) then {
                            _early pushBack _faction;
                            [_k, "earlyFactions", _early] call ALIVE_fnc_hashSet;
                            ["ALIVE_fnc_ATOKernel - accepting requests from %1 before the base has merged its commanders", _faction] call ALiVE_fnc_dump;
                        };
                        // ADDED to whatever the tasker already has, never
                        // written over it.
                        //
                        // This pushed the logic's own list plus this one
                        // faction, and the logic's list is the module's own
                        // faction alone at this point, so a second early
                        // faction evicted the first. The base then sets the
                        // tasker's list from its own reading part way through
                        // its start-up and only restores the merged list at
                        // the end, so between those two points a request the
                        // bus had just accepted was refused by the planner as
                        // not ours and read out on the radio as a denial.
                        private _taskFactions = [_task, "factions", []] call ALIVE_fnc_hashGet;
                        if !(_taskFactions isEqualType []) then { _taskFactions = [] };
                        _taskFactions = +_taskFactions;
                        { _taskFactions pushBackUnique _x } forEach (_factions + [_faction]);
                        [_task, "configure", [["factions", _taskFactions]]] call ALIVE_fnc_ATOTask;
                    };
                };
            };
        };
        // Silently: another instance may own it.
        if (!_ours) exitWith {};

        // ---- the requester -------------------------------------------------
        // A player's request carries its own id in slot five, and their
        // status and cancel requests quote THAT id, so it is the record id.
        // Anyone else's is keyed by who sent it and the event log's number.
        private _player = count _data > 6;
        private _requestId = "";
        if (count _data > 5) then {
            private _slot = _data select 5;
            if (_slot isEqualType "" && {!(_slot isEqualTo "")}) then { _requestId = _slot };
            if (_slot isEqualType 0) then { _requestId = str _slot };
        };
        if (_requestId isEqualTo "") then { _requestId = format ["%1_%2", if (_from isEqualTo "") then { "REQ" } else { _from }, _eventId] };
        private _playerId = if (_player) then { _data select 6 } else { "" };
        if (isNil "_playerId") then { _playerId = "" };
        private _requester = [[
            ["kind", if (_player) then { "player" } else { if (_from isEqualTo "") then { "OPCOM" } else { _from } }],
            ["playerId", _playerId],
            ["requestId", _requestId]
        ]] call ALIVE_fnc_hashCreate;

        // ---- where ---------------------------------------------------------
        // The airspace as a marker name. Blank means the first one; a name
        // is kept when it is ours or at least a marker; a position, which is
        // what the ground commander sends, is the airspace it falls in.
        private _airspaces = [_logic] call _fnc_airspaces;
        private _first = _airspaces param [0, ""];
        private _airspace = _first;
        private _givenPos = [];
        if (_airspaceRaw isEqualType "" && {!(_airspaceRaw isEqualTo "")}) then {
            if (_airspaceRaw in _airspaces || {!((markerShape _airspaceRaw) isEqualTo "")}) then {
                _airspace = _airspaceRaw;
            } else {
                ["ALIVE_fnc_ATOKernel - request names airspace %1, which is not a marker; using %2", _airspaceRaw, _first] call ALiVE_fnc_dump;
            };
        };
        if (_airspaceRaw isEqualType [] && {count _airspaceRaw >= 2} && {(_airspaceRaw select 0) isEqualType 0}) then {
            _givenPos = +_airspaceRaw;
            private _inside = "";
            { if (_inside isEqualTo "" && {_givenPos inArea _x}) then { _inside = _x } } forEach _airspaces;
            if !(_inside isEqualTo "") then { _airspace = _inside };
        };
        private _targets = _ato param [7, []];
        if !(_targets isEqualType []) then { _targets = [] };
        private _targetPos = _givenPos;
        if (count _targetPos < 2) then {
            { if (count _targetPos < 2) then { _targetPos = [_x] call _fnc_positionOf } } forEach _targets;
        };
        if (count _targetPos < 2 && {!(_airspace isEqualTo "")}) then { _targetPos = getMarkerPos _airspace };
        if (count _targetPos < 2) then { _targetPos = getPosATL _logic };

        // ---- the type gate ----------------------------------------------
        // The Available ATOs setting on the module. The old handler refused a
        // type that was not in it and said so; the tasker checks only the
        // fixed list of types that exist, so the mission maker's list is
        // applied here, where every commander request arrives.
        private _types = [_logic, "types"] call MAINCLASS;
        if !(_types isEqualType []) then { _types = +DEFAULT_ATO_TYPES };
        if !(_type in _types) exitWith {
            ["ALIVE_fnc_ATOKernel - %1 request from %2 refused: %1 is not in this commander's list of available ATOs %3", _type, _from, _types] call ALiVE_fnc_dump;
            [_logic, _type, _targetPos, _requester, "type not enabled on this commander"] call _fnc_denyOnRadio;
        };

        // ---- the record -------------------------------------------------
        private _sideText = "";
        if (!isNil "_sideRaw") then {
            if (_sideRaw isEqualType "") then { _sideText = _sideRaw };
            if (_sideRaw isEqualType sideUnknown) then { _sideText = [_sideRaw] call ALiVE_fnc_sideToSideText };
        };
        if (_sideText isEqualTo "" || {_sideText isEqualTo "NULL"}) then { _sideText = [_logic, "side"] call MAINCLASS };
        private _duration = _ato param [6, DEFAULT_OP_DURATION];
        if !(_duration isEqualType 0) then { _duration = DEFAULT_OP_DURATION };
        if (_duration <= 0) then { _duration = DEFAULT_OP_DURATION };
        private _record = [[
            ["id", _requestId],
            ["eventId", _eventId],
            ["type", _type],
            ["side", _sideText],
            ["faction", _faction],
            ["airspace", _airspace],
            ["targetPos", +_targetPos],
            ["targets", +_targets],
            ["roe", _ato param [0, DEFAULT_ROE]],
            ["height", _ato param [1, DEFAULT_OP_HEIGHT]],
            ["speed", _ato param [2, DEFAULT_SPEED]],
            ["minWeapon", _ato param [3, DEFAULT_MIN_WEAP_STATE]],
            ["minFuel", _ato param [4, DEFAULT_MIN_FUEL_STATE]],
            ["range", _ato param [5, DEFAULT_RANGE]],
            // Raisers send minutes; every piece compares seconds.
            ["duration", _duration * 60],
            ["requester", _requester],
            ["receivedAt", time]
        ]] call ALIVE_fnc_hashCreate;

        private _r = [_task, "submit", _record] call ALIVE_fnc_ATOTask;
        if (_r isEqualType "") then {
            private _factionName = getText ((_faction call ALiVE_fnc_configGetFactionClass) >> "displayName");
            if (_factionName isEqualTo "") then { _factionName = _faction };
            [_logic, "STR_ALIVE_ATO_REQUEST_ACKNOWLEDGED", [[_logic] call _fnc_hqName, _factionName, _type, [_targetPos] call _fnc_grid]] call _fnc_radio;
            if ([_logic] call _fnc_debugOn) then {
                ["ALIVE_fnc_ATOKernel - %1 request %2 from %3 accepted as sortie %4", _type, _requestId, _from, _r] call ALiVE_fnc_dump;
            };
        } else {
            private _reason = if (_r isEqualType [] && {count _r > 1}) then { _r select 1 } else { "refused" };
            if !(_reason isEqualType "") then { _reason = str _reason };
            [_logic, _type, _targetPos, _requester, _reason] call _fnc_denyOnRadio;
        };
    };

    // A player asking after their request: [faction, side, requestId,
    // playerId]. Answered with the old module's list-of-items shape.
    case "ATO_STATUS_REQUEST": {
        if !(_args isEqualType [] && {[_args] call ALIVE_fnc_isHash}) exitWith {};
        private _task = [_logic, "task"] call _fnc_piece;
        private _place = [_logic, "place"] call _fnc_piece;
        if (_task isEqualTo []) exitWith {};
        private _data = [_args, "data", []] call ALIVE_fnc_hashGet;
        if !(_data isEqualType [] && {count _data >= 4}) exitWith {};
        _data params [["_faction", "", [""]], "_sideRaw", "_requestId", "_playerId"];
        if (isNil "_requestId") then { _requestId = "" };
        if (isNil "_playerId") then { _playerId = "" };
        private _factions = [_logic, "factions"] call MAINCLASS;
        if !(_factions isEqualType [] && {_faction in _factions}) exitWith {};
        if (_requestId isEqualType 0) then { _requestId = str _requestId };

        private _response = [];
        private _s = [_task, "status", _requestId] call ALIVE_fnc_ATOTask;
        if (_s isEqualType [] && {count _s >= 3}) then {
            private _sortie = [_task, "sortie", _s select 0] call ALIVE_fnc_ATOTask;
            private _type = if ([_sortie] call ALIVE_fnc_isHash) then { [_sortie, "type", ""] call ALIVE_fnc_hashGet } else { "" };
            private _positions = [];
            if !(_place isEqualTo []) then {
                {
                    private _o = [_place, "objFor", _x] call ALIVE_fnc_ATOPlace;
                    if (!isNull _o) then { _positions pushBack (getPosATL _o) };
                } forEach (_s select 2);
            };
            _response pushBack [_type, _requestId, _s select 1, _positions];
        };
        if (!isNil "ALIVE_eventLog") then {
            private _e = ["ATO_RESPONSE", [_requestId, _playerId, _response], "Military Air Component Commander", "STATUS"] call ALIVE_fnc_event;
            [ALIVE_eventLog, "addEvent", _e] call ALIVE_fnc_eventLog;
        };
    };

    // A player cancelling a request: [faction, side, requestId, playerId,
    // cancelRequestId]. The sortie is closed in the tasker and every aircraft
    // on it is told to come home on the next roster tick.
    case "ATO_CANCEL_REQUEST": {
        if !(_args isEqualType [] && {[_args] call ALIVE_fnc_isHash}) exitWith {};
        private _k = [_logic] call _fnc_kernel;
        private _task = [_logic, "task"] call _fnc_piece;
        if (_k isEqualTo [] || {_task isEqualTo []}) exitWith {};
        private _data = [_args, "data", []] call ALIVE_fnc_hashGet;
        if !(_data isEqualType [] && {count _data >= 5}) exitWith {};
        _data params [["_faction", "", [""]], "_sideRaw", "_requestId", "_playerId", "_cancelId"];
        if (isNil "_requestId") then { _requestId = "" };
        if (isNil "_playerId") then { _playerId = "" };
        if (isNil "_cancelId") then { _cancelId = "" };
        private _factions = [_logic, "factions"] call MAINCLASS;
        if !(_factions isEqualType [] && {_faction in _factions}) exitWith {};
        if (_cancelId isEqualType 0) then { _cancelId = str _cancelId };

        private _s = [_task, "status", _cancelId] call ALIVE_fnc_ATOTask;
        private _ok = [_task, "cancel", _cancelId] call ALIVE_fnc_ATOTask;
        if !(_ok isEqualType true) then { _ok = false };
        if (_ok && {_s isEqualType []} && {count _s >= 3}) then {
            private _pendingCmd = [_k, "pendingCmd", []] call ALIVE_fnc_hashGet;
            private _pendingSortie = [_k, "pendingSortie", []] call ALIVE_fnc_hashGet;
            {
                [_pendingCmd, _x, "CANCEL"] call ALIVE_fnc_hashSet;
                [_pendingSortie, _x] call ALIVE_fnc_hashRem;
            } forEach (_s select 2);
        };
        if (!isNil "ALIVE_eventLog") then {
            private _e = ["LOGCOM_RESPONSE", [_requestId, _playerId, []], "air tasking orders", if (_ok) then { "CANCEL_OK" } else { "CANCEL_FAILED" }] call ALIVE_fnc_event;
            [ALIVE_eventLog, "addEvent", _e] call ALIVE_fnc_eventLog;
        };
    };

    // A logistics delivery arrived. Every commander hears every completion
    // and resupply matches the event id; an unknown id returns quietly.
    // Always spawned: taking the delivery waits inside placement, and this
    // case runs in the event log's worker, which drains the queue serially.
    case "LOGISTICS_COMPLETE": {
        if !(_args isEqualType [] && {[_args] call ALIVE_fnc_isHash}) exitWith {};
        private _resupply = [_logic, "resupply"] call _fnc_piece;
        if (_resupply isEqualTo []) exitWith {};
        private _data = [_args, "data", []] call ALIVE_fnc_hashGet;
        if !(_data isEqualType []) exitWith {};
        [_resupply, _data] spawn {
            params ["_resupply", "_data"];
            [_resupply, "onLogisticsComplete", _data] call ALIVE_fnc_ATOResupply;
        };
    };

    // ======================================================================
    // Pause and un-pause.
    // ======================================================================

    // A BOOL is always a set, true or false; only a non-bool is a read. The
    // old case treated anything that was not exactly true as a read, and
    // main un-pauses every module by calling pause with FALSE, so under that
    // shape the module could be paused and never un-paused: the drivers
    // stayed stopped and the clock shift below never ran. Setting true while
    // already true is still a no-op, and so is false while already false,
    // because there is nothing to shift.
    //
    // Never suspends: main may reach this through the network bus in an
    // unscheduled call.
    case "pause": {
        if !(_args isEqualType true) exitWith {
            _result = [_logic, "pause", objNull, false] call ALIVE_fnc_OOsimpleOperation;
        };
        private _state = [_logic, "pause", objNull, false] call ALIVE_fnc_OOsimpleOperation;
        _result = _args;
        if (_args isEqualTo _state) exitWith {};
        [_logic, "pause", _args, false] call ALIVE_fnc_OOsimpleOperation;
        ["Pausing state of %1 instance set to %2!", QMOD(ADDON), _args] call ALiVE_fnc_dumpR;

        private _k = [_logic] call _fnc_kernel;
        if (_k isEqualTo []) exitWith {};
        private _base = [_logic, "base"] call _fnc_piece;
        private _watch = [_logic, "watch"] call _fnc_piece;

        if (_args) then {
            [_k, "paused", true] call ALIVE_fnc_hashSet;
            [_k, "pausedAt", time] call ALIVE_fnc_hashSet;
            if !(_base isEqualTo []) then { [_base, "pause", true] call ALIVE_fnc_ATOBase };
            if !(_watch isEqualTo []) then { [_watch, "pause", true] call ALIVE_fnc_ATOWatch };
        } else {
            // Mission time ran on while the module did not. Every clock the
            // module keeps is moved by the length of the pause, in ONE
            // unscheduled step so no driver can see a half-shifted roster,
            // and BEFORE the drivers are released, so the first tick after
            // un-pausing finds every deadline exactly where it was.
            private _pausedAt = [_k, "pausedAt", -1] call ALIVE_fnc_hashGet;
            private _delta = if (_pausedAt isEqualType 0 && {_pausedAt >= 0}) then { time - _pausedAt } else { 0 };
            private _surface = [_logic, "surface"] call _fnc_piece;
            private _task = [_logic, "task"] call _fnc_piece;
            private _resupply = [_logic, "resupply"] call _fnc_piece;
            private _moved = 0;
            isNil {
                private _rows = [_k, "rows", []] call ALIVE_fnc_hashGet;
                if ([_rows] call ALIVE_fnc_isHash) then {
                    {
                        private _row = [_rows, _x, []] call ALIVE_fnc_hashGet;
                        if ([_row] call ALIVE_fnc_isHash) then {
                            {
                                _x params ["_key", "_floor"];
                                private _v = [_row, _key, 0] call ALIVE_fnc_hashGet;
                                if (_v isEqualType 0 && {_v >= _floor}) then {
                                    [_row, _key, _v + _delta] call ALIVE_fnc_hashSet;
                                };
                            } forEach [["deadlineAt", 1], ["enteredAt", 0], ["readyAt", 1], ["playerFreeSince", 0]];
                            _moved = _moved + 1;
                        };
                    } forEach (_rows select 1);
                };
                private _retry = [_k, "rehomeFailedAt", []] call ALIVE_fnc_hashGet;
                if ([_retry] call ALIVE_fnc_isHash) then {
                    {
                        private _t = [_retry, _x, 0] call ALIVE_fnc_hashGet;
                        if (_t isEqualType 0) then { [_retry, _x, _t + _delta] call ALIVE_fnc_hashSet };
                    } forEach (_retry select 1);
                };
                {
                    private _t = [_k, _x, -1] call ALIVE_fnc_hashGet;
                    if (_t isEqualType 0 && {_t >= 0}) then { [_k, _x, _t + _delta] call ALIVE_fnc_hashSet };
                } forEach ["lastKeepAlive", "lastPublish", "lastSweep"];
                if !(_surface isEqualTo []) then { [_surface, "shiftLocks", _delta] call ALIVE_fnc_ATOSurface };
                if !(_task isEqualTo []) then { [_task, "shiftClocks", _delta] call ALIVE_fnc_ATOTask };
                if !(_resupply isEqualTo []) then { [_resupply, "shiftClocks", _delta] call ALIVE_fnc_ATOResupply };
                [_k, "paused", false] call ALIVE_fnc_hashSet;
                [_k, "pausedAt", -1] call ALIVE_fnc_hashSet;
            };
            if !(_base isEqualTo []) then { [_base, "pause", false] call ALIVE_fnc_ATOBase };
            if !(_watch isEqualTo []) then { [_watch, "pause", false] call ALIVE_fnc_ATOWatch };
            ["ALIVE_fnc_ATOKernel - un-paused after %1 s; %2 row clock(s) moved", round _delta, _moved] call ALiVE_fnc_dump;
        };
    };

    // ======================================================================
    // Start-up.
    // ======================================================================

    case "init": {
        // The module's own airspace out of sight on every machine with a
        // screen, the server included: in single player and on a hosted
        // server the player's machine IS the server.
        if (hasInterface) then {
            private _areas = [_logic, "airspace", _logic getVariable ["airspace", DEFAULT_AIRSPACE]] call MAINCLASS;
            if (_areas isEqualType []) then { { _x setMarkerAlpha 0 } forEach _areas };
        };

        if (isServer) then {
            _logic setVariable ["super", SUPERCLASS];
            _logic setVariable ["class", MAINCLASS];
            _logic setVariable ["moduleType", "ALIVE_ATO"];
            _logic setVariable ["startupComplete", false];
            _logic setVariable ["listenerID", ""];
            _logic setVariable ["registryID", ""];
            _logic setVariable ["position", getPosATL _logic];

            // Every global is created only when missing. The old init reset
            // two of them on every module init, so a second commander wiped
            // the first one's threats and patrol clocks.
            if (isNil "ALiVE_ATO_runwayLockTimeout") then { ALiVE_ATO_runwayLockTimeout = RUNWAY_LOCK_TIMEOUT };
            if (isNil QGVAR(threats)) then { GVAR(threats) = [] call ALiVE_fnc_hashCreate };
            if (isNil QGVAR(lastCAP)) then { GVAR(lastCAP) = [] call ALiVE_fnc_hashCreate };
            if (isNil QGVAR(playerRequests)) then { GVAR(playerRequests) = [] call ALiVE_fnc_hashCreate };
            if (isNil QGVAR(instanceKeys)) then { GVAR(instanceKeys) = [] call ALiVE_fnc_hashCreate };
            if (isNil QGVAR(legacyImported)) then { GVAR(legacyImported) = [] };
            if (isNil "ALIVE_globalATO") then { ALIVE_globalATO = [] call ALiVE_fnc_hashCreate };

            // Read and normalise every attribute through its accessor, so
            // what is stored on the logic from here on is the typed value.
            private _debug = [_logic, "debug"] call MAINCLASS;
            private _faction = [_logic, "faction"] call MAINCLASS;
            private _side = [_faction call ALiVE_fnc_factionSide] call ALiVE_fnc_sideToSideText;
            if (!(_side isEqualType "") || {_side isEqualTo "NULL"}) then { _side = DEFAULT_SIDE };
            [_logic, "side", _side] call MAINCLASS;
            [_logic, "factions", [_faction]] call MAINCLASS;
            [_logic, "types", _logic getVariable ["types", DEFAULT_ATO_TYPES]] call MAINCLASS;
            [_logic, "airspace", _logic getVariable ["airspace", DEFAULT_AIRSPACE]] call MAINCLASS;
            {
                [_logic, _x] call MAINCLASS;
            } forEach ["persistent","createHQ","placeAir","generateTasks","generateSEADTasks","resupply","broadcastOnRadio",
                       "placeDrones","useUAVs","droneTypes","sortieDuration","minAssetsForOffensive","maxConcurrentSorties",
                       "pilotbuilding","runwaystartpos","runwayendpos","runwaywidth","objectiveObjects","objectiveObjectsCount",
                       "objectiveObjectsChance","objectiveObjectsBehaviour"];

            if (_debug) then {
                ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
                ["ATO - Init %1 (kernel)", _logic] call ALiVE_fnc_dump;
                {
                    ["ATO - %1: %2", _x, [_logic, _x] call MAINCLASS] call ALiVE_fnc_dump;
                } forEach ["faction","side","factions","types","airspace","persistent","createHQ","placeAir","resupply",
                           "generateTasks","generateSEADTasks","placeDrones","useUAVs","droneTypes","sortieDuration",
                           "minAssetsForOffensive","maxConcurrentSorties","runwaystartpos","runwayendpos","runwaywidth"];
            };

            [_logic, "start"] call MAINCLASS;
        } else {
            [_logic, "airspace", _logic getVariable ["airspace", DEFAULT_AIRSPACE]] call MAINCLASS;
        };
    };

    // Create the pieces, wire them, load the campaign, establish the base and
    // start the three drivers. Never waits: the base's establish does not
    // sleep before the readiness flag, so this returns to the module init in
    // the same frame.
    case "start": {
        if (!isServer) exitWith {};
        if !(([_logic] call _fnc_kernel) isEqualTo []) exitWith {
            ["ALIVE_fnc_ATOKernel - start refused: %1 has already started", _logic] call ALiVE_fnc_dump;
        };
        private _debug = [_logic] call _fnc_debugOn;
        private _faction = [_logic, "faction"] call MAINCLASS;
        private _side = [_logic, "side"] call MAINCLASS;

        // ---- the ten pieces --------------------------------------------
        private _ledger   = [nil, "create"] call ALIVE_fnc_ATOLedger;
        private _surface  = [nil, "create"] call ALIVE_fnc_ATOSurface;
        private _machine  = [nil, "create"] call ALIVE_fnc_ATOMachine;
        private _observe  = [nil, "create"] call ALIVE_fnc_ATOObserve;
        private _effect   = [nil, "create"] call ALIVE_fnc_ATOEffect;
        private _place    = [nil, "create"] call ALIVE_fnc_ATOPlace;
        private _task     = [nil, "create"] call ALIVE_fnc_ATOTask;
        private _watch    = [nil, "create"] call ALIVE_fnc_ATOWatch;
        private _resupply = [nil, "create"] call ALIVE_fnc_ATOResupply;
        private _base     = [nil, "create"] call ALIVE_fnc_ATOBase;

        // ---- the instance key ------------------------------------------
        ([_logic, _faction] call _fnc_instanceKey) params ["_key", "_peers"];
        if (isNil QGVAR(instanceKeys)) then { GVAR(instanceKeys) = [] call ALiVE_fnc_hashCreate };
        private _held = [GVAR(instanceKeys), _key, objNull] call ALIVE_fnc_hashGet;
        if !(_held isEqualType objNull) then { _held = objNull };
        private _collision = !isNull _held && {!(_held isEqualTo _logic)};
        if (_collision) then {
            ["ALIVE_fnc_ATOKernel - instance key %1 is already claimed by %2; %3 will run but will neither load nor save", _key, _held, _logic] call ALiVE_fnc_dumpR;
        } else {
            [GVAR(instanceKeys), _key, _logic] call ALIVE_fnc_hashSet;
        };
        private _persistent = [_logic, "persistent"] call MAINCLASS;
        private _unstable = _persistent && {(vehicleVarName _logic) isEqualTo ""} && {_peers > 1};
        if (_unstable) then {
            ["ALIVE_fnc_ATOKernel - %1 is persistent and one of %2 %3 commanders with no variable name; its key %4 depends on map order, so saving is refused until it is named in Eden", _logic, _peers, _faction, _key] call ALiVE_fnc_dumpR;
        };

        private _k = [[
            ["ledger", _ledger], ["surface", _surface], ["machine", _machine], ["observe", _observe],
            ["effect", _effect], ["place", _place], ["task", _task], ["watch", _watch],
            ["resupply", _resupply], ["base", _base],
            // tail -> the state table's row. The kernel is the only writer.
            ["rows", [] call ALIVE_fnc_hashCreate],
            // tail -> one of ASSIGN CANCEL REROUTE RELEASE, consumed next tick
            ["pendingCmd", [] call ALIVE_fnc_hashCreate],
            // tail -> [sortieId, tuple, previous sortieId, previous tuple],
            // held until the roster confirms the command took
            ["pendingSortie", [] call ALIVE_fnc_hashCreate],
            // tail -> sortie id, "" when none
            ["sortieOf", [] call ALIVE_fnc_hashCreate],
            // sortie id -> its tuple
            ["tuples", [] call ALIVE_fnc_hashCreate],
            // tail -> the last observation
            ["lastObs", [] call ALIVE_fnc_hashCreate],
            // tail -> where it was last seen ALIVE, for the rescue
            ["lastLivePos", [] call ALIVE_fnc_hashCreate],
            // tail -> when its last rehome failed
            ["rehomeFailedAt", [] call ALIVE_fnc_hashCreate],
            // tail -> the reasons it was last found unprotected
            ["protectWarned", [] call ALIVE_fnc_hashCreate],
            // "tail|effect" -> the last refusal detail written down
            ["refusalsSeen", [] call ALIVE_fnc_hashCreate],
            ["earlyFactions", []],
            ["lockKey", format ["%1:runway", _key]],
            ["instanceKey", _key],
            ["keyCollision", _collision],
            ["keyUnstable", _unstable],
            ["listenerID", ""],
            ["paused", false],
            ["pausedAt", -1],
            ["stopped", false],
            ["lastKeepAlive", -1],
            ["lastPublish", -1],
            ["lastSweep", -1],
            ["queueTicks", 0],
            ["baseMirrored", false],
            ["baseDone", false],
            ["handles", []]
        ]] call ALIVE_fnc_hashCreate;
        _logic setVariable [QGVAR(kernel), _k];

        [_ledger, "setInstance", [_key, _faction]] call ALIVE_fnc_ATOLedger;

        // ---- the campaign, before the base looks -------------------------
        // Loaded now so the base's restore sees the records.
        if (_persistent) then { [_logic, "load"] call MAINCLASS };

        // ---- wiring ------------------------------------------------------
        private _types = [_logic, "types"] call MAINCLASS;
        private _generateTasks = [_logic, "generateTasks"] call MAINCLASS;
        [_place, "configure", [
            ["ledger", _ledger], ["surface", _surface], ["effect", _effect],
            ["useUAVs", [_logic, "useUAVs"] call MAINCLASS],
            ["placeAir", [_logic, "placeAir"] call MAINCLASS],
            ["placeDrones", [_logic, "placeDrones"] call MAINCLASS],
            ["droneTypes", [_logic, "droneTypes"] call MAINCLASS]
        ]] call ALIVE_fnc_ATOPlace;
        [_task, "configure", [
            ["maxConcurrentSorties", parseNumber ([_logic, "maxConcurrentSorties"] call MAINCLASS)],
            ["minAssetsForOffensive", parseNumber ([_logic, "minAssetsForOffensive"] call MAINCLASS)],
            ["sortieDuration", (parseNumber ([_logic, "sortieDuration"] call MAINCLASS)) * 60],
            ["generateTasks", _generateTasks],
            ["chanceOfRescue", CHANCE_OF_RESCUE],
            ["types", +_types]
        ]] call ALIVE_fnc_ATOTask;
        [_watch, "configure", [
            ["types", +_types],
            ["generateTasks", _generateTasks],
            ["generateSEADTasks", [_logic, "generateSEADTasks"] call MAINCLASS],
            ["task", _task],
            ["key", _key]
        ]] call ALIVE_fnc_ATOWatch;
        [_resupply, "configure", [
            ["ledger", _ledger], ["place", _place], ["task", _task],
            ["side", _side], ["faction", _faction], ["factions", [_faction]],
            ["enabled", [_logic, "resupply"] call MAINCLASS]
        ]] call ALIVE_fnc_ATOResupply;

        // ---- the base ----------------------------------------------------
        // The ready callback registers the listener. Called by the base
        // before it flips the flag, and it must not suspend.
        private _deps = [[
            ["surface", _surface], ["place", _place], ["task", _task], ["effect", _effect], ["watch", _watch],
            ["ready", { params ["_m", "_b"]; [_m, "listen"] call ALIVE_fnc_ATOKernel; true }]
        ]] call ALIVE_fnc_hashCreate;

        // The base has its own short watchdog around the callback; this one
        // also covers establish refusing outright, so readiness is reported
        // whatever happens. The ground commander waits thirty seconds.
        [_logic] spawn {
            params ["_m"];
            sleep READY_WATCHDOG;
            if (!isNull _m && {!(_m getVariable ["startupComplete", false])}) then {
                _m setVariable ["startupComplete", true];
                ["ALIVE_fnc_ATOKernel - readiness flag set by the kernel watchdog after %1 s", READY_WATCHDOG] call ALiVE_fnc_dumpR;
            };
        };
        [_base, "establish", [_logic, _deps]] call ALIVE_fnc_ATOBase;

        // ---- the registry ------------------------------------------------
        // After the kernel state exists, because registering asks this module
        // for its assets. Asked to init WITHOUT persistence on purpose: the
        // kernel loads its own records, and the registry's own load path
        // reads a debug flag it never declares.
        if (isNil "ALIVE_ATOGlobalRegistry") then {
            ALIVE_ATOGlobalRegistry = [nil, "create"] call ALIVE_fnc_ATOGlobalRegistry;
            [ALIVE_ATOGlobalRegistry, "init", false] call ALIVE_fnc_ATOGlobalRegistry;
            [ALIVE_ATOGlobalRegistry, "debug", _debug] call ALIVE_fnc_ATOGlobalRegistry;
        };
        [ALIVE_ATOGlobalRegistry, "register", _logic] call ALIVE_fnc_ATOGlobalRegistry;

        // ---- the three drivers -------------------------------------------
        // Each is a scheduled loop that tests stopped and paused on every
        // iteration and hands the work to a kernel operation, so the tick
        // runs scheduled (placement and resupply need to be able to wait)
        // and the loop itself holds no state.
        private _hRoster = [_logic] spawn {
            params ["_logic"];
            private _k = _logic getVariable [QGVAR(kernel), []];
            private _interval = ROSTER_SLOW;
            while { !isNull _logic && {[_k] call ALIVE_fnc_isHash} && {!([_k, "stopped", false] call ALIVE_fnc_hashGet)} } do {
                sleep _interval;
                if (!isNull _logic && {!([_k, "stopped", false] call ALIVE_fnc_hashGet)}) then {
                    if ([_k, "paused", false] call ALIVE_fnc_hashGet) then {
                        _interval = ROSTER_SLOW;
                    } else {
                        private _r = [_logic, "tick_roster"] call ALIVE_fnc_ATOKernel;
                        _interval = if (!isNil "_r" && {_r isEqualType 0} && {_r > 0}) then { _r } else { ROSTER_SLOW };
                    };
                };
            };
        };
        private _hQueue = [_logic] spawn {
            params ["_logic"];
            private _k = _logic getVariable [QGVAR(kernel), []];
            while { !isNull _logic && {[_k] call ALIVE_fnc_isHash} && {!([_k, "stopped", false] call ALIVE_fnc_hashGet)} } do {
                sleep QUEUE_INTERVAL;
                if (!isNull _logic && {!([_k, "stopped", false] call ALIVE_fnc_hashGet)} && {!([_k, "paused", false] call ALIVE_fnc_hashGet)}) then {
                    [_logic, "tick_queue"] call ALIVE_fnc_ATOKernel;
                };
            };
        };
        private _hWatch = [_logic] spawn {
            params ["_logic"];
            private _k = _logic getVariable [QGVAR(kernel), []];
            while { !isNull _logic && {[_k] call ALIVE_fnc_isHash} && {!([_k, "stopped", false] call ALIVE_fnc_hashGet)} } do {
                // Slept in slices, so a pause or a stop is honoured within
                // ten seconds rather than after the whole interval.
                private _wait = WATCH_MIN + (random WATCH_SPREAD);
                private _t0 = time;
                waitUntil {
                    sleep 10;
                    isNull _logic || {[_k, "stopped", false] call ALIVE_fnc_hashGet} || {(time - _t0) >= _wait}
                };
                if (!isNull _logic && {!([_k, "stopped", false] call ALIVE_fnc_hashGet)} && {!([_k, "paused", false] call ALIVE_fnc_hashGet)}) then {
                    [_logic, "tick_watch"] call ALIVE_fnc_ATOKernel;
                };
            };
        };
        [_k, "handles", [_hRoster, _hQueue, _hWatch]] call ALIVE_fnc_hashSet;

        ["ALIVE_fnc_ATOKernel - %1 (%2) started as instance %3%4", _faction, _side, _key,
            if (_persistent) then { ", persistent" } else { "" }] call ALiVE_fnc_dump;
        _result = true;
    };

    // ======================================================================
    // The three ticks. Internal: called by the drivers, never by hand.
    // ======================================================================

    // One pass over the roster. Answers the interval until the next pass.
    case "tick_roster": {
        _result = ROSTER_SLOW;
        private _k = [_logic] call _fnc_kernel;
        if (_k isEqualTo []) exitWith {};
        private _now = time;
        private _ledger = [_logic, "ledger"] call _fnc_piece;
        private _machine = [_logic, "machine"] call _fnc_piece;
        private _observe = [_logic, "observe"] call _fnc_piece;
        private _effect = [_logic, "effect"] call _fnc_piece;
        private _place = [_logic, "place"] call _fnc_piece;
        private _task = [_logic, "task"] call _fnc_piece;
        private _surface = [_logic, "surface"] call _fnc_piece;
        if (_ledger isEqualTo [] || {_machine isEqualTo []} || {_observe isEqualTo []} || {_place isEqualTo []} || {_surface isEqualTo []}) exitWith {};

        private _rows = [_k, "rows", []] call ALIVE_fnc_hashGet;
        private _pendingCmd = [_k, "pendingCmd", []] call ALIVE_fnc_hashGet;
        private _pendingSortie = [_k, "pendingSortie", []] call ALIVE_fnc_hashGet;
        private _sortieOf = [_k, "sortieOf", []] call ALIVE_fnc_hashGet;
        private _tuples = [_k, "tuples", []] call ALIVE_fnc_hashGet;
        private _lastObs = [_k, "lastObs", []] call ALIVE_fnc_hashGet;
        private _lastLivePos = [_k, "lastLivePos", []] call ALIVE_fnc_hashGet;
        private _lockKey = [_k, "lockKey", ""] call ALIVE_fnc_hashGet;

        // ---- rows for aircraft placement now holds ---------------------
        // Only tails whose attach actually took: a deferred hull is still
        // owned by another machine and a row around it goes LOST at once.
        private _attached = [_place, "attachedTails"] call ALIVE_fnc_ATOPlace;
        if !(_attached isEqualType []) then { _attached = [] };
        {
            if (([_rows, _x, []] call ALIVE_fnc_hashGet) isEqualTo []) then {
                private _row = [_machine, "newRow", [_x, [_logic, _x] call _fnc_homeOf]] call ALIVE_fnc_ATOMachine;
                [_rows, _x, _row] call ALIVE_fnc_hashSet;
                [_sortieOf, _x, ""] call ALIVE_fnc_hashSet;
                ["ALIVE_fnc_ATOKernel - row opened for %1", _x] call ALiVE_fnc_dump;
            };
        } forEach _attached;

        // ---- one step per row, indivisibly -------------------------------
        // Observe, step, store, inside one unscheduled block per row, so a
        // pause arriving between two statements cannot catch a row that has
        // been observed and not yet stepped. Everything that acts on the
        // world is done afterwards, outside the block, from what was
        // collected here.
        private _stepped = [];
        private _tails = +(_rows select 1);
        {
            private _tail = _x;
            isNil {
                private _row = [_rows, _tail, []] call ALIVE_fnc_hashGet;
                if ([_row] call ALIVE_fnc_isHash) then {
                    private _obj = [_place, "objFor", _tail] call ALIVE_fnc_ATOPlace;
                    if !(_obj isEqualType objNull) then { _obj = objNull };
                    private _home = [_logic, _tail] call _fnc_homeOf;
                    private _lockHeld = ([_surface, "holder", _lockKey] call ALIVE_fnc_ATOSurface) isEqualTo _tail;
                    private _cmd = [_pendingCmd, _tail, ""] call ALIVE_fnc_hashGet;
                    if !(_cmd isEqualType "") then { _cmd = "" };
                    if !(_cmd isEqualTo "") then { [_pendingCmd, _tail] call ALIVE_fnc_hashRem };
                    private _pend = [_pendingSortie, _tail, []] call ALIVE_fnc_hashGet;
                    if !(_pend isEqualType []) then { _pend = [] };
                    if !(_pend isEqualTo []) then { [_pendingSortie, _tail] call ALIVE_fnc_hashRem };
                    private _taking = count _pend >= 4 && {_cmd in ["ASSIGN","REROUTE"]};

                    // The table is handed the row WITH the new sortie, so
                    // the deadline it sets on entry is the new sortie's;
                    // if the command does not take, the old sortie is put
                    // back below.
                    private _rowIn = _row;
                    if (_taking) then {
                        _rowIn = [_row] call ALIVE_fnc_hashCopy;
                        [_rowIn, "sortie", +(_pend select 1)] call ALIVE_fnc_hashSet;
                    };

                    private _obs = [_observe, "observe", [_obj, _home, _lockHeld, [_rowIn] call _fnc_tupleOf, _now]] call ALIVE_fnc_ATOObserve;
                    if !([_obs] call ALIVE_fnc_isHash) then { _obs = [] call ALIVE_fnc_hashCreate };
                    [_lastObs, _tail, _obs] call ALIVE_fnc_hashSet;
                    if ([_obs, "objectLive", false] call ALIVE_fnc_hashGet) then {
                        private _p = [_obs, "pos", []] call ALIVE_fnc_hashGet;
                        if (_p isEqualType [] && {count _p >= 2}) then { [_lastLivePos, _tail, +_p] call ALIVE_fnc_hashSet };
                    };

                    private _out = [_machine, "step", [_rowIn, _obs, _cmd, _now]] call ALIVE_fnc_ATOMachine;
                    if !(_out isEqualType [] && {count _out >= 3}) then { _out = [_rowIn, [], []] };
                    _out params [["_row2", [], [[]]], ["_orders", [], [[]]], ["_effects", [], [[]]]];

                    // ---- did the command take -----------------------------
                    // The table accepts an assignment only from a parked,
                    // ready aircraft and a reroute only from one on station;
                    // any other state ignores the command without a word.
                    // Left there, the sortie would keep its aircraft for the
                    // rest of the mission with nothing to report a failure or
                    // re-plan it. So the state is checked after the step and
                    // an ignored command is treated as a failed assignment,
                    // which the tasker re-plans with this tail excluded.
                    private _failedSortie = "";
                    if (_taking) then {
                        _pend params [["_sid", "", [""]], ["_tuple", [], [[]]], ["_prevSid", "", [""]], ["_prevTuple", [], [[]]]];
                        private _expected = if (_cmd isEqualTo "REROUTE") then { "ENROUTE" } else { "ASSIGNED" };
                        if (([_row2, "state", ""] call ALIVE_fnc_hashGet) isEqualTo _expected) then {
                            [_sortieOf, _tail, _sid] call ALIVE_fnc_hashSet;
                            [_tuples, _sid, +_tuple] call ALIVE_fnc_hashSet;
                            // A patrol turned onto a new job is over as a
                            // patrol. Closed in the tasker, or the airspace
                            // it was over would count as patrolled for the
                            // rest of the mission and no other patrol would
                            // ever be raised for it.
                            if (!(_prevSid isEqualTo "") && {!(_prevSid isEqualTo _sid)} && {!(_task isEqualTo [])}) then {
                                [_task, "complete", [_prevSid, "rerouted"]] call ALIVE_fnc_ATOTask;
                                [_tuples, _prevSid] call ALIVE_fnc_hashRem;
                            };
                        } else {
                            [_row2, "sortie", +_prevTuple] call ALIVE_fnc_hashSet;
                            _failedSortie = _sid;
                        };
                    };

                    [_rows, _tail, _row2] call ALIVE_fnc_hashSet;
                    _stepped pushBack [_tail, _row, _row2, _orders, _effects, _obj, _home, _obs, _failedSortie];
                };
            };
        } forEach _tails;

        // ---- act on what the table asked for -----------------------------
        private _changed = false;
        private _drop = [];
        private _anyFlying = false;
        {
            _x params ["_tail", "_row", "_row2", "_orders", "_effects", "_obj", "_home", "_obs", "_failedSortie"];
            private _from = [_row, "state", ""] call ALIVE_fnc_hashGet;
            private _to = [_row2, "state", ""] call ALIVE_fnc_hashGet;

            if !(_from isEqualTo _to) then {
                _changed = true;
                [_logic, _tail, _from, _to, _row2, _obs, _effects, _obj, _home, _now] call _fnc_transition;
                // The stand may have MOVED, so it is read again before
                // anything is put on it.
                //
                // The hook above checks whether the home is still a home and,
                // when something else is sitting on it, asks placement for
                // another, which writes a new home into the record. The
                // effects below are what actually set the aircraft down, and
                // with the home read once at the top of the tick they would
                // set it down on the stand the hook had just called occupied.
                // The next tick would then see it away from home, recover it,
                // and set it down again: two jumps on consecutive ticks, in
                // front of whoever is watching.
                _home = [_logic, _tail] call _fnc_homeOf;
            };
            if ([_logic, _tail, _row2, _effects, _obj, _home, _obs, _now] call _fnc_routeEffects) then { _drop pushBack _tail };
            [_logic, _tail, _row2, _orders, _obj, _home] call _fnc_issueOrders;

            if (_to in FLYING_STATES || {[_obs, "airborne", false] call ALIVE_fnc_hashGet}) then { _anyFlying = true };
        } forEach _stepped;

        // ---- a sortie only PART of its aircraft took ---------------------
        // Answered per SORTIE rather than per aircraft.
        //
        // A suppression sortie goes out as a pair and each aircraft takes its
        // orders on its own. Telling the tasker the assignment failed when
        // one of them DID take it clears the sortie's aircraft list and puts
        // it back to being planned, so the next pass sends a fresh pair while
        // the first aircraft is still flying the old job: it no longer
        // appears on the sortie, a status request cannot find it, a cancel
        // cannot reach it, and whichever aircraft lands first closes the
        // sortie under the rest.
        //
        // So if anything took it, the sortie goes ahead with what it has and
        // only the aircraft that refused is dropped from it. Only a sortie
        // nobody took is handed back to be planned again, and then every
        // aircraft that refused is named, so the tasker excludes them all
        // rather than just the first.
        if !(_task isEqualTo []) then {
            private _failedSids = [];
            { if !((_x select 8) isEqualTo "") then { _failedSids pushBackUnique (_x select 8) } } forEach _stepped;
            {
                private _sid = _x;
                private _refused = [];
                { if ((_x select 8) isEqualTo _sid) then { _refused pushBackUnique (_x select 0) } } forEach _stepped;
                private _kept = [];
                {
                    if (([_sortieOf, _x, ""] call ALIVE_fnc_hashGet) isEqualTo _sid) then { _kept pushBackUnique _x };
                } forEach (_sortieOf select 1);
                if (count _kept > 0) then {
                    [_task, "dispatch", [_sid, _kept]] call ALIVE_fnc_ATOTask;
                    ["ALIVE_fnc_ATOKernel - %1 did not take sortie %2; it goes ahead with %3", _refused, _sid, _kept] call ALiVE_fnc_dump;
                } else {
                    {
                        private _answer = [_task, "onRowEvent", [_sid, _x, "assignFailed", _now]] call ALIVE_fnc_ATOTask;
                        ["ALIVE_fnc_ATOKernel - %1 did not take sortie %2; nothing took it, the tasker says %3", _x, _sid, _answer] call ALiVE_fnc_dump;
                    } forEach _refused;
                };
            } forEach _failedSids;
        };

        // A lost hull's row goes, and everything keyed by its tail with it.
        {
            private _sid = [_sortieOf, _x, ""] call ALIVE_fnc_hashGet;
            if !(_sid isEqualTo "") then { [_tuples, _sid] call ALIVE_fnc_hashRem };
            private _gone = _x;
            {
                [[_k, _x, []] call ALIVE_fnc_hashGet, _gone] call ALIVE_fnc_hashRem;
            } forEach ["rows","sortieOf","lastObs","lastLivePos","pendingCmd","pendingSortie","rehomeFailedAt","protectWarned"];
            ["ALIVE_fnc_ATOKernel - row closed for %1", _gone] call ALiVE_fnc_dump;
        } forEach _drop;

        // ---- the runway ---------------------------------------------------
        private _holders = [];
        {
            private _row = [_rows, _x, []] call ALIVE_fnc_hashGet;
            if ([_row] call ALIVE_fnc_isHash && {([_row, "state", ""] call ALIVE_fnc_hashGet) in LOCK_STATES}) then { _holders pushBack _x };
        } forEach (_rows select 1);
        [_surface, "reconcileLocks", _holders] call ALIVE_fnc_ATOSurface;

        // ---- the stands of aircraft that are away -----------------------
        if ((_now - ([_k, "lastKeepAlive", -1] call ALIVE_fnc_hashGet)) >= KEEPALIVE_EVERY) then {
            {
                private _o = [_lastObs, _x, []] call ALIVE_fnc_hashGet;
                if ([_o] call ALIVE_fnc_isHash && {[_o, "airborne", false] call ALIVE_fnc_hashGet}) then {
                    [_surface, "keepAlive", [[_logic, _x] call _fnc_homeOf, _x]] call ALIVE_fnc_ATOSurface;
                };
            } forEach (_rows select 1);
            [_k, "lastKeepAlive", _now] call ALIVE_fnc_hashSet;
        };

        // ---- protection ---------------------------------------------------
        // Measured every pass, never trusted to a flag. Said once per change
        // of reason, and put right where it can be.
        private _warned = [_k, "protectWarned", []] call ALIVE_fnc_hashGet;
        {
            private _tail = _x;
            private _o = [_place, "objFor", _tail] call ALIVE_fnc_ATOPlace;
            if (_o isEqualType objNull && {!isNull _o} && {alive _o}) then {
                private _p = [_observe, "isProtected", _o] call ALIVE_fnc_ATOObserve;
                if (_p isEqualType [] && {!(_p param [0, true])}) then {
                    private _reasons = _p param [1, []];
                    if !((str _reasons) isEqualTo ([_warned, _tail, ""] call ALIVE_fnc_hashGet)) then {
                        [_warned, _tail, str _reasons] call ALIVE_fnc_hashSet;
                        ["ALIVE_fnc_ATOKernel - %1 is not protected: %2", _tail, _reasons] call ALiVE_fnc_dump;
                    };
                    if (!(_effect isEqualTo []) && {"profileID" in _reasons}) then {
                        [_effect, "apply", ["shield", _o, [_logic, _tail] call _fnc_homeOf, [_tail]]] call ALIVE_fnc_ATOEffect;
                    };
                    if (!(_effect isEqualTo []) && {"not local" in _reasons}) then {
                        [_effect, "apply", ["takeOwnership", _o, [], []]] call ALIVE_fnc_ATOEffect;
                    };
                } else {
                    if !(([_warned, _tail, ""] call ALIVE_fnc_hashGet) isEqualTo "") then { [_warned, _tail] call ALIVE_fnc_hashRem };
                };
            };
        } forEach (_rows select 1);

        // ---- publish ------------------------------------------------------
        if (_changed || {(_now - ([_k, "lastPublish", -1] call ALIVE_fnc_hashGet)) >= PUBLISH_EVERY}) then {
            [_logic] call _fnc_publish;
        };

        _result = if (_anyFlying) then { ROSTER_FAST } else { ROSTER_SLOW };
    };

    // The queue pass: mirror the base, plan, resupply, sweep, retry stands.
    case "tick_queue": {
        _result = false;
        private _k = [_logic] call _fnc_kernel;
        if (_k isEqualTo []) exitWith {};
        private _now = time;
        private _base = [_logic, "base"] call _fnc_piece;
        private _place = [_logic, "place"] call _fnc_piece;
        private _resupply = [_logic, "resupply"] call _fnc_piece;
        private _watch = [_logic, "watch"] call _fnc_piece;
        private _ticks = ([_k, "queueTicks", 0] call ALIVE_fnc_hashGet) + 1;
        [_k, "queueTicks", _ticks] call ALIVE_fnc_hashSet;
        private _phase = if (_base isEqualTo []) then { "idle" } else { [_base, "phase", "idle"] call ALIVE_fnc_ATOBase };

        // ---- the base's answers, mirrored onto the logic -----------------
        // Once when the base has chosen where it stands and who it fights,
        // and once more when it is done, so the readers of the raw logic
        // variables and the pieces that want the HQ see them.
        if (!([_k, "baseMirrored", false] call ALIVE_fnc_hashGet) && {!(_base isEqualTo [])} && {!(_phase in ["idle","establishing","ready","building"])}) then {
            private _v = [_base, "view"] call ALIVE_fnc_ATOBase;
            if ([_v] call ALIVE_fnc_isHash) then {
                [_logic, "isCarrier", [_v, "isCarrier", false] call ALIVE_fnc_hashGet] call MAINCLASS;
                private _hq = [_v, "hq", objNull] call ALIVE_fnc_hashGet;
                if !(_hq isEqualType objNull) then { _hq = objNull };
                [_logic, "HQBuilding", _hq] call MAINCLASS;
                [_logic, "currentBase", [[
                    ["center", [_v, "basePos", [0,0,0]] call ALIVE_fnc_hashGet],
                    ["size", [_v, "baseSize", 150] call ALIVE_fnc_hashGet],
                    ["clusterID", [_v, "clusterID", ""] call ALIVE_fnc_hashGet],
                    ["nodes", [_v, "baseNodes", []] call ALIVE_fnc_hashGet]
                ]] call ALIVE_fnc_hashCreate] call MAINCLASS;
                [_logic, "enemyFactions", [_v, "enemyFactions", []] call ALIVE_fnc_hashGet] call MAINCLASS;
                [_logic, "enemySides", [_v, "enemySides", []] call ALIVE_fnc_hashGet] call MAINCLASS;
                if !(_watch isEqualTo []) then { [_watch, "start"] call ALIVE_fnc_ATOWatch };
                [_k, "baseMirrored", true] call ALIVE_fnc_hashSet;
                ["ALIVE_fnc_ATOKernel - base is %1; the watch is running", _phase] call ALiVE_fnc_dump;
            };
        };
        if (!([_k, "baseDone", false] call ALIVE_fnc_hashGet) && {!(_base isEqualTo [])} && {_phase in ["established","failed"]}) then {
            private _v = [_base, "view"] call ALIVE_fnc_ATOBase;
            if ([_v] call ALIVE_fnc_isHash) then {
                private _merged = [_v, "factions", []] call ALIVE_fnc_hashGet;
                if !(_merged isEqualType []) then { _merged = [] };

                // Anything accepted before the merge is put back into both
                // lists. The base builds its list from the commanders synced
                // to it, and a faction this kernel took requests from early
                // is not in that list unless one of those commanders owns it,
                // so without this its requests silently stop being planned
                // the moment the base finishes starting up.
                private _early = [_k, "earlyFactions", []] call ALIVE_fnc_hashGet;
                if !(_early isEqualType []) then { _early = [] };
                { _merged pushBackUnique _x } forEach _early;

                if (count _merged > 0) then { [_logic, "factions", +_merged] call MAINCLASS };
                if (count _early > 0) then {
                    private _taskHere = [_logic, "task"] call _fnc_piece;
                    if !(_taskHere isEqualTo []) then {
                        private _tf = [_taskHere, "factions", []] call ALIVE_fnc_hashGet;
                        if !(_tf isEqualType []) then { _tf = [] };
                        _tf = +_tf;
                        { _tf pushBackUnique _x } forEach _early;
                        [_taskHere, "configure", [["factions", _tf]]] call ALIVE_fnc_ATOTask;
                    };
                };
                private _hq = [_v, "hq", objNull] call ALIVE_fnc_hashGet;
                private _hqPos = if (_hq isEqualType objNull && {!isNull _hq}) then { getPosATL _hq } else { [_v, "basePos", [0,0,0]] call ALIVE_fnc_hashGet };
                if !(_resupply isEqualTo []) then {
                    [_resupply, "configure", [
                        ["hqPos", +_hqPos],
                        ["isCarrier", [_v, "isCarrier", false] call ALIVE_fnc_hashGet],
                        ["isVirtual", [_v, "isVirtual", false] call ALIVE_fnc_hashGet],
                        ["factions", +_merged]
                    ]] call ALIVE_fnc_ATOResupply;
                };
                [_k, "baseDone", true] call ALIVE_fnc_hashSet;
                ["ALIVE_fnc_ATOKernel - base %1: %2 aircraft on the books, factions %3, HQ %4 (%5)%6", _phase,
                    [_v, "assetCount", 0] call ALIVE_fnc_hashGet, _merged,
                    if (_hq isEqualType objNull) then { typeOf _hq } else { "none" },
                    [_v, "hqKind", "none"] call ALIVE_fnc_hashGet,
                    if (_phase isEqualTo "failed") then { format [": %1", [_v, "failed", ""] call ALIVE_fnc_hashGet] } else { "" }] call ALiVE_fnc_dump;
            };
        };

        // ---- planning -------------------------------------------------------
        [_logic, _now] call _fnc_drain;

        // ---- replacements ---------------------------------------------------
        // At most one lost record per pass. Building one waits inside
        // placement, which this driver can do.
        if !(_resupply isEqualTo []) then { [_resupply, "sweep", _now] call ALIVE_fnc_ATOResupply };

        // ---- adoption -------------------------------------------------------
        // Once the base stands, a sweep every minute picks up aircraft of the
        // merged factions that appeared later and retries hulls still owned
        // elsewhere. Two consecutive passes adopt, by placement's own rule.
        if (_phase isEqualTo "established" && {!(_place isEqualTo [])} && {(_ticks mod SWEEP_EVERY) == 0}) then {
            [_place, "sweep", ["", _now, []]] call ALIVE_fnc_ATOPlace;
            [_k, "lastSweep", _now] call ALIVE_fnc_hashSet;
        };

        // ---- stands that could not be moved ------------------------------
        private _retry = [_k, "rehomeFailedAt", []] call ALIVE_fnc_hashGet;
        private _rows = [_k, "rows", []] call ALIVE_fnc_hashGet;
        private _lastObs = [_k, "lastObs", []] call ALIVE_fnc_hashGet;
        if ([_retry] call ALIVE_fnc_isHash && {!(_place isEqualTo [])}) then {
            {
                private _tail = _x;
                private _t = [_retry, _tail, _now] call ALIVE_fnc_hashGet;
                if (_t isEqualType 0 && {(_now - _t) >= REHOME_RETRY}) then {
                    private _row = [_rows, _tail, []] call ALIVE_fnc_hashGet;
                    private _o = [_lastObs, _tail, []] call ALIVE_fnc_hashGet;
                    private _onGround = [_o] call ALIVE_fnc_isHash && {!([_o, "airborne", false] call ALIVE_fnc_hashGet)};
                    if ([_row] call ALIVE_fnc_isHash && {([_row, "state", ""] call ALIVE_fnc_hashGet) in ["PARKED","RECOVERING"]} && {_onGround}) then {
                        private _h = [_place, "rehome", _tail] call ALIVE_fnc_ATOPlace;
                        if (_h isEqualType [] && {count _h >= 3}) then {
                            [_retry, _tail] call ALIVE_fnc_hashRem;
                        } else {
                            [_retry, _tail, _now] call ALIVE_fnc_hashSet;
                        };
                    } else {
                        [_retry, _tail] call ALIVE_fnc_hashRem;
                    };
                };
            } forEach (+(_retry select 1));
        };
        _result = true;
    };

    // One look at the air picture. The watch raises through the tasker.
    case "tick_watch": {
        _result = [];
        private _watch = [_logic, "watch"] call _fnc_piece;
        if (_watch isEqualTo []) exitWith {};
        ([_logic] call _fnc_projections) params ["_records", "_rowsProj"];
        private _raised = [_watch, "tick", [time, _records, _rowsProj]] call ALIVE_fnc_ATOWatch;
        if !(_raised isEqualType []) then { _raised = [] };
        if (count _raised > 0 && {[_logic] call _fnc_debugOn}) then {
            ["ALIVE_fnc_ATOKernel - the watch raised %1", _raised] call ALiVE_fnc_dump;
        };
        _result = _raised;
    };

    // ======================================================================
    // Tear-down.
    // ======================================================================

    // The event log resolved this module's class when the listener was added
    // and keeps calling it, so the listener is removed before anything else
    // goes; then the three drivers and the base's own script are stopped,
    // the instance key released, and the logic itself destroyed.
    case "destroy": {
        [_logic, "debug", false] call MAINCLASS;
        if (isServer) then {
            private _k = [_logic] call _fnc_kernel;
            if !(_k isEqualTo []) then {
                [_k, "stopped", true] call ALIVE_fnc_hashSet;
                private _id = _logic getVariable ["listenerID", ""];
                if (!isNil "ALIVE_eventLog" && {!(_id isEqualType "" && {_id isEqualTo ""})}) then {
                    [ALIVE_eventLog, "removeListener", _id] call ALIVE_fnc_eventLog;
                };
                _logic setVariable ["listenerID", ""];
                {
                    if (_x isEqualType scriptNull && {!scriptDone _x}) then { terminate _x };
                } forEach ([_k, "handles", []] call ALIVE_fnc_hashGet);
                private _base = [_logic, "base"] call _fnc_piece;
                if !(_base isEqualTo []) then {
                    private _h = [_base, "continueHandle", scriptNull] call ALIVE_fnc_hashGet;
                    if (_h isEqualType scriptNull && {!scriptDone _h}) then { terminate _h };
                };
                private _key = [_k, "instanceKey", ""] call ALIVE_fnc_hashGet;
                if (!isNil QGVAR(instanceKeys) && {!(_key isEqualTo "")}) then {
                    private _held = [GVAR(instanceKeys), _key, objNull] call ALIVE_fnc_hashGet;
                    if (_held isEqualType objNull && {_held isEqualTo _logic}) then {
                        [GVAR(instanceKeys), _key] call ALIVE_fnc_hashRem;
                    };
                };
                _logic setVariable [QGVAR(kernel), nil];
            };
            _logic setVariable ["super", nil];
            _logic setVariable ["class", nil];
            [_logic, "destroy"] call SUPERCLASS;
        };
    };

    default {
        _result = [_logic, _operation, _args] call SUPERCLASS;
    };
};

TRACE_1("ATO Kernel - output",_result);

_result;
