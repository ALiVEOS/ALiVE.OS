#include "\x\alive\addons\mil_ato\script_component.hpp"
SCRIPT(base);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_ATOBase
Description:
The airbase. Where the air component lives, who it fights, and the one promise
that it is open for business.

This piece runs once, at start-up, and its job is to turn a placed module into
an established base: the cluster data is loaded, the airspace markers are
checked and hidden, the nearest airfield is chosen, the ground under the module
is classified as terrain or a carrier deck, the enemy is worked out, an HQ is
found or built, the aircraft already standing about are adopted, the ground
commanders it is tied to are waited for and their factions merged, the initial
aircraft are placed, the commander is told the airfield is worth holding, and
the side is told on the radio. It never touches an airframe itself: adoption
and placement are Placement's, and the base only asks.

ONE promise outranks everything else in here. The module must report itself
started within thirty seconds of mission start, because the ground commander
waits exactly that long for it before raising its first air request and then
drops the request on the floor. So the readiness flag is flipped as soon as the
airspace list is validated and the Tasker has been told who this commander is,
and EVERYTHING after that point is best effort: a step that fails writes down a
reason and carries on, and no step can withhold the flag. The old module set
the flag after cluster loading, base selection, HQ construction and the guard
garrison, which is the heaviest and most throw-prone stretch of the module, and
one script error anywhere in it left the flag false for the whole mission with
nothing in the log to say why. The first design of this piece put the flag in
the same place. It was moved once that was pointed out with the evidence, and
the reasoning is written at the step so nobody moves it back.

Two other things the old start-up got wrong are corrected here rather than
copied, and the reasons are written at the step in question:

  It read the persistence flag and the military building lists before the
  system that produces them had finished, so on a persistent mission the guard
  garrison was skipped or doubled depending on which script happened to run
  first, and with no profile system placed at all the building lists did not
  exist and the read threw. Both are now read after a bounded wait for the
  profile system, and the lists are read with a default.

  It looked for a road to align the field HQ with using a search that grows
  its radius until it finds one, which on a bare heliport with no road inside
  the limit never ends. One bounded pass now, and no road means north.

establish(logic, deps) -> the base record. Failure is a FIELD of that record,
`failed`, holding the reason, and never a different return type: a caller
tests it with the `failed` operation. On failure the Tasker is told, so every
request is refused with that reason within a tick, the ledger is left empty
because Placement was never asked to sweep, and readiness is still reported.

Parameters:
Nil or Array - If Nil, return a new instance. If a hash, reference an existing one.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function

Examples:
(begin example)
_b = [nil, "create"] call ALIVE_fnc_ATOBase;
_deps = [[["surface", _s], ["place", _p], ["task", _t], ["effect", _e]]] call ALIVE_fnc_hashCreate;
[_b, "establish", [_moduleLogic, _deps]] call ALIVE_fnc_ATOBase;
_why = [_b, "failed"] call ALIVE_fnc_ATOBase;

(end)

See Also:
<ALIVE_fnc_ATOPlace>, <ALIVE_fnc_ATOTask>, <ALIVE_fnc_ATOSurface>, <ALIVE_fnc_ATOEffect>

Author:
Jman
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClassHash

// How big a base with no airfield is taken to be. The hold points sit on a ring
// of about ninety metres, so this is that with room around it. Used for the
// same things a cluster's own size is: how far out to look for what belongs to
// this base.
#define VIRTUAL_BASE_SIZE 150
#define MAINCLASS ALIVE_fnc_ATOBase

// How long the base waits for a synced ground commander to finish starting,
// for ALL of them together rather than each in turn. The old module allowed
// this per commander, one after the other. The figure itself is the old one:
// measured on a dedicated server on Cam Lao Nam, a commander was still working
// ten minutes in, and the earlier two minute limit gave up on it on every run.
// Fifteen minutes is also what the start-up screen allows before deciding
// nothing is happening, so the two agree about how long is too long.
#define OPCOM_WAIT 900

// How long to wait for the profile system to finish, when one is placed. The
// old module waited for it without limit, and could only afford to because it
// refused to start at all without one. Same span as the commander wait, for
// the same reason.
#define PROFILE_WAIT 900

// A bound on waiting for a static data load or a cluster load that another
// module started. Both are one compile of one file, so anything past this is
// a load that died.
#define STATIC_WAIT 120

// How long the readiness watchdog gives the Kernel's callback before it sets
// the flag itself. See the readiness step for why there is a watchdog at all.
#define READY_GRACE 5

// The gap between the two sweep passes. MUST equal Placement's own figure: a
// candidate is adopted only when it has been seen on two passes at least this
// far apart, so a shorter gap here would make the second pass adopt nothing.
#define SIGHTING_GAP 20

// Search radii, all the old module's figures.
#define HQ_SEARCH 750
#define ROAD_SEARCH 750
#define CARRIER_CLUSTER 700
#define SCENERY_RADIUS 350

// A ship has to be this close for the deck's ship to be looked up. The same
// figure Surface's classify uses, so the ship this records is the ship
// classify found.
#define SHIP_SEARCH 400

// The priority the airfield is registered at with the ground commander. High
// enough that it is held as a reserve objective rather than traded away.
#define OBJECTIVE_PRIORITY 500

// The types the old module fell back to when a faction shipped no airfield or
// heliport composition.
#define HQ_CATEGORIES ["HQ","FieldHQ","Communications"]

private ["_result"];

TRACE_1("ATO Base - input",_this);

params [
    ["_logic", objNull, [objNull,[]]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,[],"",0,true,false]]
];

_result = true;

// ---- file-scope helpers ----------------------------------------------------
// Each takes what it needs and reads its collaborators out of _logic. Code run
// with `call` inherits the caller's variables, so a helper that mentioned a
// collaborator without binding it would silently pick up whatever the calling
// case named that way, and the fault would move with the caller.

// One of the wired dependencies (surface, place, task, effect, watch), or []
// when it was never wired. Both reads pass a default and are type-tested,
// because a two-argument hashGet answers nil for a missing key and a nil
// assigned to a variable deletes it, so the next read would throw "undefined
// variable" two lines away from the real cause.
private _fnc_dep = {
    params ["_logic", ["_name", "", [""]]];
    private _out = [];
    private _deps = [_logic, "deps", []] call ALIVE_fnc_hashGet;
    if ([_deps] call ALIVE_fnc_isHash) then {
        private _got = [_deps, _name, []] call ALIVE_fnc_hashGet;
        if ([_got] call ALIVE_fnc_isHash) then { _out = _got };
    };
    _out
};

// A list of cluster hashes out of one of the mil_placement cluster globals,
// or [] when that global does not exist or is not a hash. The cluster hashes
// themselves are NOT copied: everything downstream works on references, and
// a deep copy of a whole terrain's cluster index is a lot of work for nothing.
private _fnc_clusterList = {
    params [["_name", "", [""]]];
    private _out = [];
    private _h = missionNamespace getVariable [_name, []];
    if (_h isEqualType [] && {count _h > 2} && {[_h] call ALIVE_fnc_isHash}) then {
        _out = _h select 2;
    };
    if !(_out isEqualType []) then { _out = [] };
    _out
};

// Turn a Placement answer into a list of tails. Placement is being rebuilt
// alongside this piece, so its sweep and placeInitial may answer with an old
// refusal shape, with nothing at all, or with something new; every one of
// those is counted as "that step placed nothing" and said once, rather than
// letting a wrong shape reach the counts or throw here.
private _fnc_tails = {
    params [["_answer", false, [[], "", objNull, 0, true, false]], ["_op", "", [""]]];
    private _tails = [];
    if (_answer isEqualType []
        && {(_answer findIf { !(_x isEqualType "") }) == -1}
        && {!((_answer param [0, ""]) isEqualTo "refused")}) then {
        _tails = _answer;
    } else {
        ["ALIVE_fnc_ATOBase - placement %1 answered %2 rather than a list of tails; counted as nothing placed", _op, _answer] call ALiVE_fnc_dump;
    };
    _tails
};

// How many airframes Placement holds right now, pushed to the Tasker. Asked of
// Placement rather than added up here, because the running total counts what
// each step said it did and Placement's own attached list is the truth. The
// total is the fallback for a Placement that does not answer the question.
private _fnc_pushAssetCount = {
    params ["_logic", ["_fallback", 0, [0]]];
    private _n = _fallback;
    private _place = [_logic, "place"] call _fnc_dep;
    if ([_place] call ALIVE_fnc_isHash) then {
        private _got = [_place, "attachedTails"] call ALIVE_fnc_ATOPlace;
        if (!isNil "_got" && {_got isEqualType []}) then { _n = count _got };
    };
    private _task = [_logic, "task"] call _fnc_dep;
    if ([_task] call ALIVE_fnc_isHash) then {
        [_task, "assetCount", _n] call ALIVE_fnc_ATOTask;
    };
    [_logic, "assetCount", _n] call ALIVE_fnc_hashSet;
    _n
};

// Push a set of pairs to a dependency, if it is wired. The three pieces that
// take settings all take them this way, so one helper serves all of them.
private _fnc_configure = {
    params ["_logic", ["_name", "", [""]], ["_pairs", [], [[]]]];
    private _dep = [_logic, _name] call _fnc_dep;
    private _ok = [_dep] call ALIVE_fnc_isHash;
    if (_ok) then {
        switch (_name) do {
            case "task":  { [_dep, "configure", _pairs] call ALIVE_fnc_ATOTask };
            case "place": { [_dep, "configure", _pairs] call ALIVE_fnc_ATOPlace };
            case "watch": { [_dep, "configure", _pairs] call ALIVE_fnc_ATOWatch };
            default { _ok = false };
        };
    };
    _ok
};

// An Eden attribute that is meant to be a yes or no. Eden stores these as the
// strings "true" and "false"; a Kernel that has already read them stores the
// BOOL. Both are accepted, and anything else is the default.
private _fnc_boolAttr = {
    params ["_module", ["_name", "", [""]], ["_default", false, [false]]];
    private _out = _default;
    private _raw = _module getVariable [_name, _default];
    if (_raw isEqualType true) then { _out = _raw };
    if (_raw isEqualType "") then {
        if ((toLower _raw) isEqualTo "true") then { _out = true };
        if ((toLower _raw) isEqualTo "false") then { _out = false };
    };
    _out
};

// The airspace setting as a list of marker names. Eden hands over the text
// the mission maker typed, which is a comma separated list and may carry the
// brackets and quotes of an array typed by hand; a Kernel that has already
// parsed it hands over the array. Blank entries are dropped HERE, because the
// Eden default is the empty string and the old parser turned that into a list
// holding one empty name, so every untouched module warned that airspace ""
// did not exist before falling back to the whole map.
private _fnc_parseAirspace = {
    params [["_raw", "", ["", []]]];
    private _names = [];
    if (_raw isEqualType []) then {
        _names = _raw select { _x isEqualType "" };
    } else {
        _names = _raw splitString "[]""', ;";
    };
    (_names apply { trim _x }) select { !(_x isEqualTo "") }
};

// The CfgHQIdentities class the radio speaks under, by side text.
private _fnc_hqClass = {
    params [["_side", "", [""]]];
    switch (toUpper _side) do {
        case "WEST": { "BLU" };
        case "EAST": { "OPF" };
        case "GUER": { "IND" };
        default { "HQ" };
    }
};

// Hold while the base is paused. A pause is deliberate and has no bound; the
// readiness flag is already up by the time anything can pause this, so nothing
// the ground commander waits on is behind it.
private _fnc_waitUnpaused = {
    params ["_logic"];
    if (canSuspend) then {
        waitUntil { !([_logic, "paused", false] call ALIVE_fnc_hashGet) };
    };
    true
};

switch(_operation) do {

    case "create": {
        _result = [[
            ["class", MAINCLASS],

            // idle | establishing | ready | building | ownSweep | opcomWait |
            // mergedSweep | placing | established | failed
            ["phase", "idle"],

            // "" while the base stands. Otherwise the reason it does not,
            // which is also what the Tasker refuses every request with.
            ["failed", ""],

            // The placed module logic, and the pieces this one asks things
            // of. `deps` is a hash of instances and is the one key `view`
            // leaves out, because copying it would copy the whole Tasker.
            ["module", objNull],
            ["deps", []],

            // ---- the base record ----------------------------------------
            ["faction", ""],
            ["side", ""],
            ["factions", []],
            ["enemyFactions", []],
            ["enemySides", []],
            ["airspaces", []],
            // The whole-map marker this created when none was configured,
            // "" otherwise. Diagnostic only; `airspaces` is the list.
            ["airspaceCreated", ""],
            ["position", [0,0,0]],
            ["createHQ", true],
            ["broadcastOnRadio", true],
            ["debug", false],
            // The raw runway override strings, uninterpreted. Surface reads
            // them off the logic itself; they are carried here so the record
            // says what the module was told.
            ["runway", [] call ALIVE_fnc_hashCreate],

            // What the base stands on. `basePos` is the cluster centre, not
            // the module's position; `baseNodes` are the cluster's objects.
            // The cluster hash itself is not stored: it belongs to the shared
            // terrain index and a view of this record should not copy it.
            ["basePos", [0,0,0]],
            ["baseSize", 150],
            ["baseNodes", []],
            ["clusterID", ""],
            ["isCarrier", false],
            ["carrier", objNull],

            // A base with no airfield: the marker its aircraft fly from, how
            // many to create there, and whether that is what this one is.
            // Blank marker means the fallback is off, which is how an
            // untouched mission behaves exactly as before.
            ["ingressMarker", ""],
            ["virtualSlots", 0],
            ["isVirtual", false],

            // The HQ, and how it came to be one: building (a suitable one
            // stood nearby), composition (a field HQ was built), nominal
            // (the first cluster object, so something always answers), none.
            ["hq", objNull],
            ["hqKind", "none"],
            ["garrisonSpawned", false],

            // The synced commanders this merged with, by id and side. The
            // handler hashes themselves are not kept: they are live commander
            // state and a copy of this record must not drag them along.
            ["opcomIDs", []],
            ["opcomSides", []],
            ["objectiveId", ""],
            ["sceneryPlaced", 0],

            // What each placement step reported, and the Tasker's count.
            ["restored", 0],
            ["adoptedBeforeWait", 0],
            ["adoptedAfterWait", 0],
            ["placedInitial", 0],
            ["assetCount", 0],

            // Stamps, all on diag_tickTime, which does not stop while the
            // start-up screen is up. `time` does, on a local run, and stays
            // at zero for the whole of start-up. The one exception is
            // readyAtMissionTime, kept on the mission clock so a test can
            // measure readiness against mission start.
            ["startedAt", -1],
            ["readyAt", -1],
            ["readyAtMissionTime", -1],
            ["ownSweepDoneAt", -1],
            ["opcomWaitStartedAt", -1],
            ["opcomWaitEndedAt", -1],
            ["mergedSweepDoneAt", -1],
            ["doneAt", -1],

            ["paused", false],
            ["continueHandle", scriptNull]
        ]] call ALIVE_fnc_hashCreate;
    };

    // ---- the establishment -------------------------------------------------
    // establish([module, deps]). Everything that happens before readiness is
    // in here and none of it waits, none of it loads a file, and none of it
    // calls a helper that reads data it does not own. Everything else is in
    // "continue", which this spawns after the flag is up.
    //
    // Refusals are collected into one string and tested once. No exitWith:
    // the result of this case is assigned exactly once, at the end.
    case "establish": {
        _args params [["_module", objNull, [objNull]], ["_deps", [], [[]]]];

        private _refused = "";
        if (!isServer) then { _refused = "not the server" };
        if (_refused isEqualTo "" && {isNull _module}) then { _refused = "no module logic" };
        if (_refused isEqualTo "" && {!(([_logic, "phase", "idle"] call ALIVE_fnc_hashGet) isEqualTo "idle")}) then {
            _refused = format ["this instance is already %1", [_logic, "phase", "idle"] call ALIVE_fnc_hashGet];
        };
        // Runs once is anchored on the MODULE, not on this instance. A fresh
        // instance starts idle whatever happened before, so the instance
        // check above cannot see a previous establishment of the same logic,
        // and everything below is non-idempotent: a marker is created, a
        // composition is built, a garrison is spawned, an objective is
        // registered. The flag on the logic is what stops a second instance
        // doing all of that again.
        if (_refused isEqualTo "" && {_module getVariable [QGVAR(baseEstablished), false]}) then {
            _refused = "this module has already been established";
        };

        if !(_refused isEqualTo "") then {
            ["ALIVE_fnc_ATOBase - establish refused: %1", _refused] call ALiVE_fnc_dump;
        } else {
            _module setVariable [QGVAR(baseEstablished), true];
            [_logic, "module", _module] call ALIVE_fnc_hashSet;
            if ([_deps] call ALIVE_fnc_isHash) then {
                [_logic, "deps", _deps] call ALIVE_fnc_hashSet;
            } else {
                ["ALIVE_fnc_ATOBase - no dependencies wired; the base will be chosen but nothing can be adopted, placed, asked or announced"] call ALiVE_fnc_dump;
            };
            [_logic, "phase", "establishing"] call ALIVE_fnc_hashSet;
            [_logic, "startedAt", diag_tickTime] call ALIVE_fnc_hashSet;
            ["ALIVE_fnc_ATOBase - establishing %1", _module] call ALiVE_fnc_dump;

            // ---- who this commander is ----------------------------------
            // Read raw off the logic. The settings are written there by the
            // Kernel's bus, or by Eden, and this piece only reads them.
            private _faction = _module getVariable ["faction", "OPF_F"];
            if (!(_faction isEqualType "") || {_faction isEqualTo ""}) then { _faction = "OPF_F" };
            // A faction built by the faction compiler is stored under the
            // name the compiler gave it and resolves to the faction it
            // actually stands for. The old accessor resolved it on every
            // read; here it is resolved once, and only when the resolver
            // exists, because the compiler is its own module.
            if (!isNil "ALiVE_fnc_factionCompilerResolveForModule") then {
                private _resolved = [_module] call ALiVE_fnc_factionCompilerResolveForModule;
                if (!isNil "_resolved" && {_resolved isEqualType ""} && {!(_resolved isEqualTo "")}) then {
                    _faction = _resolved;
                };
            };

            // Side text as the rest of the mod spells it, "GUER" for the
            // resistance, so the old remap of RESISTANCE to GUER is not
            // needed. The NULL fallback is the ground commander's, kept: a
            // faction whose config carries no side would otherwise be a
            // commander that can never tell friend from enemy.
            private _side = [_faction call ALiVE_fnc_factionSide] call ALiVE_fnc_sideToSideText;
            if !(_side isEqualType "") then { _side = "NULL" };
            if (_side isEqualTo "NULL") then {
                ["ALIVE_fnc_ATOBase - faction %1 resolves to no usable side, treating it as EAST", _faction] call ALiVE_fnc_dumpR;
                _side = "EAST";
            };

            private _debug = [_module, "debug", false] call _fnc_boolAttr;
            private _createHQ = [_module, "createHQ", true] call _fnc_boolAttr;
            private _onRadio = [_module, "broadcastOnRadio", true] call _fnc_boolAttr;

            private _runway = [] call ALIVE_fnc_hashCreate;
            {
                private _v = _module getVariable [_x, ""];
                if !(_v isEqualType "") then { _v = str _v };
                [_runway, _x, _v] call ALIVE_fnc_hashSet;
            } forEach ["runwaystartpos", "runwayendpos", "runwaywidth"];

            [_logic, "faction", _faction] call ALIVE_fnc_hashSet;
            [_logic, "side", _side] call ALIVE_fnc_hashSet;
            [_logic, "factions", [_faction]] call ALIVE_fnc_hashSet;
            [_logic, "debug", _debug] call ALIVE_fnc_hashSet;
            [_logic, "createHQ", _createHQ] call ALIVE_fnc_hashSet;
            [_logic, "broadcastOnRadio", _onRadio] call ALIVE_fnc_hashSet;
            [_logic, "runway", _runway] call ALIVE_fnc_hashSet;
            [_logic, "position", getPosATL _module] call ALIVE_fnc_hashSet;

            // ---- the airspace -------------------------------------------
            // Names that are not markers are dropped with a warning naming
            // them, so a typo costs the intended boundary rather than the
            // whole commander: the old module let a misspelled name reach
            // the cluster lookup, which found nothing and aborted start-up
            // with one log line, and the commander simply never ran.
            private _wanted = [_module getVariable ["airspace", ""]] call _fnc_parseAirspace;
            private _valid = _wanted select { !((markerShape _x) isEqualTo "") };
            if (count _valid < count _wanted) then {
                ["ALIVE_fnc_ATOBase - airspace marker(s) %1 do not exist and have been ignored. Check the spelling in this module's Airspace Markers setting.", _wanted - _valid] call ALiVE_fnc_dumpR;
            };
            // Nothing left means the whole map, as one hidden rectangle, so
            // every later step has a real marker list to work with.
            private _created = "";
            if (count _valid == 0) then {
                _created = createMarker [format ["ATO_%1_%2_%3", _faction, ceil (random 10000), floor diag_tickTime], [worldSize / 2, worldSize / 2]];
                _created setMarkerShape "RECTANGLE";
                _created setMarkerSize [(worldSize / 2) - 100, (worldSize / 2) - 100];
                _created setMarkerAlpha 0;
                _valid = [_created];
            };
            // Hidden on the server; markers are global, so this reaches
            // every client that joins later as well.
            { _x setMarkerAlpha 0 } forEach _valid;

            [_logic, "airspaces", _valid] call ALIVE_fnc_hashSet;
            [_logic, "airspaceCreated", _created] call ALIVE_fnc_hashSet;

            // Where to fly from when there is no airfield to fly from.
            //
            // Read but not acted on here: whether it is NEEDED is not known
            // until the cluster search has run and found nothing, and a
            // commander with a perfectly good airfield must carry on using it
            // whatever this says. Blank is the default and means off.
            private _ingress = _module getVariable ["ingressMarker", ""];
            if !(_ingress isEqualType "") then { _ingress = "" };
            _ingress = [_ingress, " ", ""] call CBA_fnc_replace;
            [_logic, "ingressMarker", _ingress] call ALIVE_fnc_hashSet;

            private _slotsRaw = _module getVariable ["virtualSlots", "6"];
            private _slots = 6;
            if (_slotsRaw isEqualType 0) then { _slots = round _slotsRaw };
            if (_slotsRaw isEqualType "" && {!(_slotsRaw isEqualTo "")}) then {
                _slots = round (parseNumber _slotsRaw);
            };
            [_logic, "virtualSlots", ((_slots max 1) min 12)] call ALIVE_fnc_hashSet;
            // Written back as the list, so whoever reads the setting later
            // gets marker names rather than the text the mission maker typed.
            _module setVariable ["airspace", +_valid];

            // The Tasker exists before the flag goes up and knows who it is
            // answering for, so a request arriving on the same tick as
            // readiness is filed under the right side and airspace.
            if !([_logic, "task", [["side", _side], ["faction", _faction], ["airspaces", +_valid]]] call _fnc_configure) then {
                ["ALIVE_fnc_ATOBase - no tasker wired: requests will have nowhere to go"] call ALiVE_fnc_dump;
            };

            // ---- READINESS ----------------------------------------------
            // Here, and nowhere later. The airspace is validated and the
            // Tasker is configured, which is everything the contract asks
            // for before the flag; the cluster load, the base choice, the
            // HQ, the garrison and every wait live in "continue", after it.
            //
            // The Kernel's callback registers the event listener, and it is
            // called BEFORE the flag on purpose: the ground commander raises
            // its first request on the very tick it reads the flag, and this
            // is a scheduled script that can be interrupted between any two
            // statements, so a flag set before the listener is a request
            // lost. The callback must not suspend and must answer true.
            //
            // And because the callback is somebody else's code, a watchdog
            // is started before it runs. If the callback throws, this script
            // ends right there and nothing below it executes, including the
            // line that sets the flag; the watchdog sets it a few seconds
            // later and says so. That is the whole of the promise that
            // nothing can withhold readiness, and it costs one small script.
            [_logic, "phase", "ready"] call ALIVE_fnc_hashSet;
            private _ready = false;
            private _depsHash = [_logic, "deps", []] call ALIVE_fnc_hashGet;
            if ([_depsHash] call ALIVE_fnc_isHash) then {
                _ready = [_depsHash, "ready", false] call ALIVE_fnc_hashGet;
            };
            if (_ready isEqualType {}) then {
                [_module] spawn {
                    params ["_m"];
                    sleep READY_GRACE;
                    if (!isNull _m && {!(_m getVariable ["startupComplete", false])}) then {
                        _m setVariable ["startupComplete", true];
                        ["ALIVE_fnc_ATOBase - readiness flag set by the watchdog: the readiness callback did not return"] call ALiVE_fnc_dumpR;
                    };
                };
                private _answer = [_module, _logic] call _ready;
                if (isNil "_answer" || {!(_answer isEqualType true)} || {!_answer}) then {
                    ["ALIVE_fnc_ATOBase - the readiness callback did not report success; the flag is set regardless"] call ALiVE_fnc_dump;
                };
            };
            _module setVariable ["startupComplete", true];
            [_logic, "readyAt", diag_tickTime] call ALIVE_fnc_hashSet;
            [_logic, "readyAtMissionTime", time] call ALIVE_fnc_hashSet;
            ["ALIVE_fnc_ATOBase - %1 (%2) ready at mission time %3, airspace %4",
                _faction, _side, round time, _valid] call ALiVE_fnc_dump;

            // Everything else happens in its own script, so nothing after
            // the flag can hold up whoever called establish, and nothing
            // after the flag can reach back and unset it.
            private _h = [_logic, "continue"] spawn MAINCLASS;
            [_logic, "continueHandle", _h] call ALIVE_fnc_hashSet;
        };

        _result = _logic;
    };

    // ---- everything after readiness ----------------------------------------
    // Scheduled, because it waits: for a profile system, for a sighting gap,
    // for the ground commanders. Each step is guarded on `_failed` being
    // empty, so a failure early on skips straight to the announcement; and
    // each step reads what it needs with a default, so a missing global is a
    // notice and a skipped step rather than a script error that ends this.
    case "continue": {
        if (!canSuspend) exitWith {
            ["ALIVE_fnc_ATOBase - continue must run scheduled; it is spawned by establish and should not be called by hand"] call ALiVE_fnc_dump;
        };
        if !(([_logic, "phase", "idle"] call ALIVE_fnc_hashGet) isEqualTo "ready") exitWith {
            ["ALIVE_fnc_ATOBase - continue refused: the base is %1, not ready", [_logic, "phase", "idle"] call ALIVE_fnc_hashGet] call ALiVE_fnc_dump;
        };
        [_logic, "phase", "building"] call ALIVE_fnc_hashSet;

        private _module = [_logic, "module", objNull] call ALIVE_fnc_hashGet;
        private _faction = [_logic, "faction", "OPF_F"] call ALIVE_fnc_hashGet;
        private _side = [_logic, "side", "EAST"] call ALIVE_fnc_hashGet;
        private _airspaces = [_logic, "airspaces", []] call ALIVE_fnc_hashGet;
        private _debug = [_logic, "debug", false] call ALIVE_fnc_hashGet;
        private _createHQ = [_logic, "createHQ", true] call ALIVE_fnc_hashGet;
        private _onRadio = [_logic, "broadcastOnRadio", true] call ALIVE_fnc_hashGet;
        private _position = [_logic, "position", [0,0,0]] call ALIVE_fnc_hashGet;
        private _surface = [_logic, "surface"] call _fnc_dep;
        private _place = [_logic, "place"] call _fnc_dep;
        private _task = [_logic, "task"] call _fnc_dep;
        private _effect = [_logic, "effect"] call _fnc_dep;

        private _failed = "";

        // ---- B1 the cluster index ---------------------------------------
        // The military cluster file for this terrain, compiled once. The
        // guard, the compile and the completion flag are one unscheduled
        // call, exactly as the placement module does it, so two modules
        // starting together cannot both see "not loaded" and both compile
        // it. Only the military file: nothing in this piece reads the
        // civilian index, and on a large terrain it is the biggest data file
        // in the mod.
        [{
            if (isNil "ALIVE_clustersMil" && {isNil "ALIVE_loadedMilClusters"}) then {
                private _file = format ["x\alive\addons\mil_placement\clusters\clusters.%1_mil.sqf", toLower worldName];
                ALIVE_loadedMilClusters = false;
                call compile preprocessFileLineNumbers _file;
                ALIVE_loadedMilClusters = true;
            };
        }] call CBA_fnc_directCall;
        // Somebody else may be mid-load outside that guard. Bounded, because
        // the old module's wait here had no limit.
        private _t0 = diag_tickTime;
        waitUntil {
            !isNil "ALIVE_clustersMil"
            || {missionNamespace getVariable ["ALIVE_loadedMilClusters", false]}
            || {(diag_tickTime - _t0) > STATIC_WAIT}
        };

        // The file defines four independent globals, so one existing proves
        // nothing about the other three. A terrain with no file at all leaves
        // all of them undefined: a missing file compiles to nothing rather
        // than to an error, and the old module then threw on the first
        // `select` of an undefined name.
        private _airClusters = ["ALIVE_clustersMilAir"] call _fnc_clusterList;
        private _heliClusters = ["ALIVE_clustersMilHeli"] call _fnc_clusterList;
        private _milClusters = ["ALIVE_clustersMil"] call _fnc_clusterList;
        if (count _airClusters == 0 && {count _heliClusters == 0} && {count _milClusters == 0}) then {
            _failed = format ["no military cluster data for %1", worldName];
        };

        // ---- B2 the base cluster, B3 what it stands on ------------------
        // Runways first, then heliports, then anything military, all inside
        // the airspace. Nearest to the module wins.
        private _cluster = [];
        private _isCarrier = false;
        private _carrier = objNull;
        if (_failed isEqualTo "") then {
            private _found = [_airClusters, _airspaces] call ALIVE_fnc_clustersInsideMarker;
            if (count _found == 0) then { _found = [_heliClusters, _airspaces] call ALIVE_fnc_clustersInsideMarker };
            if (count _found == 0) then { _found = [_milClusters, _airspaces] call ALIVE_fnc_clustersInsideMarker };
            if (count _found > 0) then {
                // A cluster with no centre is sorted to the far end rather
                // than dereferenced.
                private _sorted = [_found, [_position], {
                    private _c = [_x, "center", []] call ALIVE_fnc_hashGet;
                    if (_c isEqualType [] && {count _c >= 2}) then { _input0 distance2D _c } else { 1e10 }
                }, "ASCEND"] call ALiVE_fnc_SortBy;
                _cluster = _sorted select 0;
            };

            // Deck or terrain is Surface's answer and nobody else's. Not the
            // module's carrier setting, not a bare distance to a ship, not
            // whether there is water underneath: a destroyer moored off a
            // coastal airfield is within 700 m of the apron and the apron is
            // still terrain. Asked of the module's own position, which is
            // where the mission maker put the commander.
            private _kind = "terrain";
            if ([_surface] call ALIVE_fnc_isHash) then {
                private _k = [_surface, "classify", _position] call ALIVE_fnc_ATOSurface;
                if (!isNil "_k" && {_k isEqualType ""}) then { _kind = _k };
            } else {
                ["ALIVE_fnc_ATOBase - no surface wired; the base is taken to be terrain"] call ALiVE_fnc_dump;
            };

            if (_kind isEqualTo "deck") then {
                _isCarrier = true;
                _carrier = (nearestObjects [_position, ["StaticShip"], SHIP_SEARCH]) param [0, objNull];
                // The ship's own parts make the base cluster, as the old
                // module did it. When nothing strategic is found the deck
                // is still an airbase, so a nominal cluster is built from
                // the ship rather than the base declared failed. `param`
                // rather than `select 0`, because select on an empty list
                // answers nil and a nil written into a hash deletes the key.
                private _parts = [(AGLtoASL _position) nearObjects ["Strategic", CARRIER_CLUSTER]] call ALiVE_fnc_findClusters;
                if (!isNil "_parts" && {_parts isEqualType []}) then {
                    _cluster = _parts param [0, []];
                } else {
                    _cluster = [];
                };
                if !([_cluster] call ALIVE_fnc_isHash) then {
                    ["ALIVE_fnc_ATOBase - deck with no strategic objects within %1 m; the ship itself is the base", CARRIER_CLUSTER] call ALiVE_fnc_dump;
                    _cluster = [nil, "create"] call ALIVE_fnc_cluster;
                    [_cluster, "nodes", if (isNull _carrier) then { [] } else { [_carrier] }] call ALIVE_fnc_cluster;
                };
            };

            if !([_cluster] call ALIVE_fnc_isHash) then {
                _failed = format ["no usable military buildings within airspace %1", _airspaces];
            };

            // Say so when the field we just took sits inside ground somebody
            // hostile has drawn for itself. REPORTED, NOT ENFORCED, and the
            // distinction is deliberate.
            //
            // Ownership is not consulted above: the search is geometry, so a
            // commander will stand its HQ, its guards and its aircraft up on an
            // enemy-held airfield and fly from there. Two designs for refusing
            // that were built and both were abandoned, for reasons worth
            // keeping so nobody spends the week again.
            //
            // The first asked who was physically there, through
            // getDominantFaction. It cannot work: ALiVE never garrisons AIR
            // clusters, so the vote can only reach a neighbouring ground
            // cluster and 122 of 640 indexed air clusters have none, the
            // aircraft placement does put on a field are uncrewed and cast no
            // vote at all, and the grid it reads is only filled once every
            // placement module has finished, which would have moved the base
            // choice behind a wait on all of them.
            //
            // The second asked whose TAOR covers it, which is what this reads.
            // As a REFUSAL it fails too: a TAOR restricts placement rather than
            // claiming ground, its own tooltip says so, and blank means the
            // whole map and blank is the default, so the ordinary enemy that
            // garrisons everything is invisible to it. Worse, the mission maker
            // already has an exact control for this and it is the airspace
            // marker above: an airfield they do not want this commander using
            // is one they leave outside it.
            //
            // So the honest thing this signal can do is tell them. A line they
            // can act on, no start-up cost, and no mission changes behaviour.
            // Refusing properly needs the live answer after the ground
            // commander has analysed occupation, which is the fall-forward work
            // (#961) and is a re-base operation this module does not have.
            if (_failed isEqualTo "" && {!_isCarrier} && {[_cluster] call ALIVE_fnc_isHash}) then {
                private _centre = [_cluster, "center", []] call ALIVE_fnc_hashGet;
                if (_centre isEqualType [] && {count _centre >= 2}) then {
                    private _claims = [];
                    {
                        // allMissionObjects by class, which is how placement
                        // finds its own neighbours. Not an entities "Module_F"
                        // scan: Logic is the PARENT of Module_F, so that scan
                        // cannot see a bare Logic and is a trap in a test.
                        {
                            private _m = _x;
                            private _theirFaction = _m getVariable ["faction", ""];
                            // Resolved the same way this module resolves its
                            // own above, because a faction the compiler built
                            // is stored under the compiler's name and would
                            // otherwise fail the class test below and be
                            // skipped in silence.
                            if (!isNil "ALiVE_fnc_factionCompilerResolveForModule") then {
                                private _r = [_m] call ALiVE_fnc_factionCompilerResolveForModule;
                                if (!isNil "_r" && {_r isEqualType ""} && {!(_r isEqualTo "")}) then {
                                    _theirFaction = _r;
                                };
                            };
                            // factionSide answers EAST for a faction it does
                            // not know, so an unresolvable one is skipped
                            // rather than reported as hostile.
                            if (_theirFaction isEqualType ""
                                && {!(_theirFaction isEqualTo "")}
                                && {isClass (_theirFaction call ALiVE_fnc_configGetFactionClass)}) then {
                                private _theirSide = _theirFaction call ALiVE_fnc_factionSide;
                                private _ourSideObj = [_side] call ALiVE_fnc_sideTextToObject;
                                // The module's own hostility idiom, the same
                                // one the observer and the tasker use.
                                if (!(_theirSide isEqualTo civilian)
                                    && {(_ourSideObj getFriend _theirSide) < 0.6}) then {
                                    private _taor = [_m getVariable ["taor", ""]] call _fnc_parseAirspace;
                                    _taor = _taor select { [_x] call ALIVE_fnc_markerExists };
                                    // Drawn means an area, not an icon. The
                                    // markerShape lesson from dd690cea.
                                    private _covers = _taor findIf {
                                        (markerShape _x) in ["ELLIPSE", "RECTANGLE"]
                                        && {[_centre, _x] call ALiVE_fnc_inArea}
                                    } > -1;
                                    if (_covers) then {
                                        // A blacklist cancels the claim, because
                                        // placement subtracts it from the very
                                        // clusters this mirrors.
                                        private _black = [_m getVariable ["blacklist", ""]] call _fnc_parseAirspace;
                                        _black = _black select { [_x] call ALIVE_fnc_markerExists };
                                        private _excluded = _black findIf {
                                            (markerShape _x) in ["ELLIPSE", "RECTANGLE"]
                                            && {[_centre, _x] call ALiVE_fnc_inArea}
                                        } > -1;
                                        if (!_excluded) then {
                                            _claims pushBackUnique _theirFaction;
                                        };
                                    };
                                };
                            };
                        } forEach (allMissionObjects _x);
                    } forEach ["ALiVE_mil_placement", "ALiVE_civ_placement"];

                    if (count _claims > 0) then {
                        // The remedy has to name something the mission maker
                        // can actually edit. With the Airspace setting left
                        // blank, which is the DEFAULT, this module has already
                        // generated a hidden whole-map rectangle of its own
                        // and named the airspace after it, so printing that
                        // name would send them hunting for a marker they
                        // cannot see and did not make.
                        private _generated = [_logic, "airspaceCreated", ""] call ALIVE_fnc_hashGet;
                        private _remedy = if (_generated isEqualType ""
                            && {!(_generated isEqualTo "")}) then {
                            "give this commander an Airspace Marker that leaves that airfield out, because its airspace is currently the whole map"
                        } else {
                            format ["leave that airfield outside airspace %1", _airspaces]
                        };
                        ["ALIVE_fnc_ATOBase - %1 (%2) is basing on an airfield inside ground drawn for %3. Ownership is not checked when a base is chosen, so this is allowed: if it is not wanted, %4, or name an Ingress Marker so the commander flies from a point instead.",
                            _faction, _side, _claims, _remedy] call ALiVE_fnc_dumpR;
                    };
                };
            };
        };

        // ---- B3a no airfield anywhere, and somewhere to fly from instead --
        // Placed here, after BOTH ways the search can fail, because they fail
        // in different places: a terrain with no cluster data at all fails
        // before the block above opens, and an airspace with no usable
        // buildings fails inside it. A rescue in either one would only ever
        // catch the other.
        //
        // A carrier is never rescued. It has a deck, which is an airbase, and
        // a commander that found one is not a commander with nowhere to fly
        // from.
        private _isVirtual = false;
        private _ingressPos = [0,0,0];
        private _ingress = [_logic, "ingressMarker", ""] call ALIVE_fnc_hashGet;
        if (!(_failed isEqualTo "") && {!_isCarrier} && {!(_ingress isEqualTo "")}) then {
            if ((markerShape _ingress) isEqualTo "") then {
                ["ALIVE_fnc_ATOBase - %1 has no airfield and its ingress marker %2 does not exist, so there is nowhere to fall back to. Check the spelling in this module's Ingress Marker setting.", _faction, _ingress] call ALiVE_fnc_dumpR;
            } else {
                _ingressPos = getMarkerPos _ingress;
                _isVirtual = true;
                ["ALIVE_fnc_ATOBase - %1 has no airfield (%2) and will fly from %3 at %4 instead",
                    _faction, _failed, _ingress, _ingressPos] call ALiVE_fnc_dump;
                _failed = "";
            };
        };

        // What the base is, in plain fields. The centre is flattened to
        // terrain level and the size floored, so a cluster whose stored
        // values are missing still yields a place to search around.
        private _basePos = [_position select 0, _position select 1, 0];
        private _baseSize = 150;
        private _nodes = [];
        private _clusterID = "";
        if (_failed isEqualTo "") then {
            if (_isVirtual) then {
                // The marker IS the base. There is no cluster to read a centre,
                // a size or a node list out of, and asking one of a thing that
                // is not a cluster is how this used to throw.
                _basePos = [_ingressPos select 0, _ingressPos select 1, 0];
                _baseSize = VIRTUAL_BASE_SIZE;
                _nodes = [];
                _clusterID = "";
            } else {
                private _c = [_cluster, "center"] call ALIVE_fnc_cluster;
                if (!isNil "_c" && {_c isEqualType []} && {count _c >= 2}) then { _basePos = [_c select 0, _c select 1, 0] };
                private _s = [_cluster, "size"] call ALIVE_fnc_cluster;
                if (!isNil "_s" && {_s isEqualType 0} && {_s > 0}) then { _baseSize = _s };
                private _n = [_cluster, "nodes", []] call ALIVE_fnc_hashGet;
                if (_n isEqualType []) then { _nodes = _n select { _x isEqualType objNull } };
                private _id = [_cluster, "clusterID", ""] call ALIVE_fnc_hashGet;
                _clusterID = if (_id isEqualType "") then { _id } else { str _id };
            };

            [_logic, "isVirtual", _isVirtual] call ALIVE_fnc_hashSet;
            [_logic, "basePos", +_basePos] call ALIVE_fnc_hashSet;
            [_logic, "baseSize", _baseSize] call ALIVE_fnc_hashSet;
            [_logic, "baseNodes", +_nodes] call ALIVE_fnc_hashSet;
            [_logic, "clusterID", _clusterID] call ALIVE_fnc_hashSet;
            [_logic, "isCarrier", _isCarrier] call ALIVE_fnc_hashSet;
            [_logic, "carrier", _carrier] call ALIVE_fnc_hashSet;

            // The deck is worked out NOW, here, where heavy work belongs.
            //
            // Surface sweeps a carrier's whole footprint the first time
            // anything asks where an airframe may park on it, and measured on
            // a USS Freedom that is 721 ms of tracing. It is done once per
            // ship and the answer is kept, but the first ask can come from an
            // unscheduled caller, and then the whole 721 ms lands in one
            // frame. Asked from here it happens while the base is still being
            // built, in a spawned step that is allowed to take its time, and
            // every later ask reads the cached answer.
            if (_isCarrier && {!isNull _carrier} && {[_surface] call ALIVE_fnc_isHash}) then {
                [_surface, "deckGeometry", _carrier] call ALIVE_fnc_ATOSurface;
            };
        };

        // ---- B11 the enemy ----------------------------------------------
        // Done whether or not the base stands, because the Tasker's player
        // tasks and the air picture want to know who is hostile even when
        // there is nothing to fly. The allegiance helper is the same 0.6
        // friendliness threshold the old inline loop used, with the side's
        // own name already left out.
        ([_side] call ALiVE_fnc_getSideAllegiances) params [["_enemySides", [], [[]]], ["_friendlySides", [], [[]]]];
        private _enemyFactions = [];
        {
            private _f = _x call ALiVE_fnc_getSideFactions;
            if (!isNil "_f" && {_f isEqualType []}) then { _enemyFactions append _f };
        } forEach _enemySides;
        [_logic, "enemySides", _enemySides] call ALIVE_fnc_hashSet;
        [_logic, "enemyFactions", _enemyFactions] call ALIVE_fnc_hashSet;
        [_logic, "task", [["factions", [_faction]], ["enemySides", +_enemySides]]] call _fnc_configure;
        [_logic, "watch", [["airspaces", +_airspaces], ["enemySides", +_enemySides], ["enemyFactions", +_enemyFactions]]] call _fnc_configure;

        // ---- the failure decision ---------------------------------------
        // Said once, with the reason, and the Tasker told so every request
        // is refused with that same reason from the next tick. The first
        // pass flag goes up too: nothing will ever be placed, so nothing
        // should be held waiting for it. The old module's early exit here
        // set no flag at all, so its requests were queued forever and its
        // readiness was never reported.
        if !(_failed isEqualTo "") then {
            ["ALIVE_fnc_ATOBase - %1 (%2) has no airbase: %3. Requests will be refused with that reason.", _faction, _side, _failed] call ALiVE_fnc_dumpR;
            [_logic, "failed", _failed] call ALIVE_fnc_hashSet;
            [_logic, "phase", "failed"] call ALIVE_fnc_hashSet;
            if ([_task] call ALIVE_fnc_isHash) then {
                [_task, "baseFailed", [true, _failed]] call ALIVE_fnc_ATOTask;
                [_task, "firstPassDone"] call ALIVE_fnc_ATOTask;
            };
        };

        // ---- the profile system -----------------------------------------
        // Waited for, bounded, and only when one is placed. Two things
        // downstream depend on it having FINISHED rather than started: the
        // persistence flag, which the profile system sets to its own setting
        // early and then forces back to false when it finds nothing to load,
        // so a read between those two writes says "restoring" on a mission
        // that is not; and the profile handler, which is created partway
        // through and reset again when a load comes in. The old module read
        // both after an unbounded wait for exactly this flag, and got away
        // with the unbounded part only because it refused to run without a
        // profile system at all. With no profile system placed there is
        // nothing to adopt and nobody to garrison, and that is said once.
        private _profilesReady = false;
        private _restoring = false;
        if (_failed isEqualTo "") then {
            if (["ALiVE_sys_profile"] call ALiVE_fnc_isModuleAvailable) then {
                private _t1 = diag_tickTime;
                private _fnc_profilesUp = {
                    !isNil "ALIVE_profileHandler"
                    && {!isNil "ALiVE_ProfileSystem"}
                    && {ALiVE_ProfileSystem isEqualType []}
                    && {[ALiVE_ProfileSystem, "startupComplete", false] call ALIVE_fnc_hashGet}
                };
                waitUntil { (call _fnc_profilesUp) || {(diag_tickTime - _t1) > PROFILE_WAIT} };
                _profilesReady = call _fnc_profilesUp;
                if (!_profilesReady) then {
                    ["ALIVE_fnc_ATOBase - gave up waiting for the profile system after %1 seconds; nothing will be adopted and no garrison placed", round (diag_tickTime - _t1)] call ALiVE_fnc_dumpR;
                };
            } else {
                ["ALIVE_fnc_ATOBase - no Virtual AI module placed: nothing to adopt and no garrison"] call ALiVE_fnc_dump;
            };
            // Read only now. When the wait timed out the value may still be
            // the unsettled early one, and the two things it gates below
            // then err on the side of not building a second of something.
            _restoring = missionNamespace getVariable ["ALIVE_loadProfilesPersistent", false];
            if !(_restoring isEqualType true) then { _restoring = false };

            // The military building lists come from the static data, which
            // this module never loaded for itself: they existed only because
            // some other module happened to load them first, and on a
            // mission with this module alone they did not exist and the HQ
            // search threw before the flag was ever set. Loaded here the way
            // every other module loads them, or waited for, bounded, when
            // another module is mid-load.
            if (isNil "ALiVE_STATIC_DATA_LOADED") then {
                call ALiVE_fnc_staticDataHandler;
            } else {
                private _t2 = diag_tickTime;
                waitUntil {
                    (missionNamespace getVariable ["ALiVE_STATIC_DATA_LOADED", false])
                    || {(diag_tickTime - _t2) > STATIC_WAIT}
                };
            };
        };

        // ---- B4 the HQ, B5 the garrison ---------------------------------
        // A suitable building within reach of the module first, whatever the
        // base stands on. Otherwise, on terrain and when the mission maker
        // asked for one, a field HQ composition. Otherwise the first object
        // of the base cluster, so the HQ is ALWAYS an object: the old code
        // left it unset on two of its three branches and the radio message
        // then asked a nil for its position.
        private _hq = objNull;
        private _hqKind = "none";
        private _garrison = false;
        if (_failed isEqualTo "") then {
            private _types = [];
            {
                private _list = missionNamespace getVariable [_x, []];
                if (_list isEqualType []) then { _types append (_list select { _x isEqualType "" }) };
            } forEach ["ALiVE_militaryBuildingTypes", "ALIVE_militaryHQBuildingTypes"];
            if (count _types == 0) then {
                ["ALIVE_fnc_ATOBase - no military building types are loaded, so no existing building can be matched as the HQ"] call ALiVE_fnc_dump;
            };
            private _lowerTypes = _types apply { toLower _x };
            // The candidate's class is held in its own name: the findIf
            // rebinds _x to the type string it is testing against.
            private _buildings = (nearestObjects [_position, ["Building"], HQ_SEARCH]) select {
                private _cls = toLower (typeOf _x);
                ((_lowerTypes findIf { (_cls find _x) > -1 }) > -1) && {[_x] call ALIVE_fnc_isHouseEnterable}
            };

            if (count _buildings > 0) then {
                _hq = _buildings select 0;
                _hqKind = "building";
            } else {
                // Not at a base with no ground, for the reason a carrier is
                // excluded: the composition is put down at the BASE, and the
                // base here is a point in the air that may be over open water
                // or off the map entirely. An existing building near the module
                // is still taken above, so a commander flying from a marker
                // keeps a real headquarters where the mission maker put it.
                if (!_isCarrier && {!_isVirtual} && {_createHQ}) then {
                    // ---- a field HQ -----------------------------------
                    private _compType = if ((_faction call ALiVE_fnc_factionSide) isEqualTo RESISTANCE) then { "Guerrilla" } else { "Military" };
                    private _comps = [_compType, ["Airports", "Heliports"], [], _faction] call ALiVE_fnc_getCompositions;
                    if (isNil "_comps" || {!(_comps isEqualType [])}) then { _comps = [] };
                    if (count _comps == 0) then {
                        private _more = [_compType, HQ_CATEGORIES, ["Medium"], _faction] call ALiVE_fnc_getCompositions;
                        if (!isNil "_more" && {_more isEqualType []}) then { _comps = _more };
                    };

                    if (count _comps == 0) then {
                        ["ALIVE_fnc_ATOBase - no airport, heliport or HQ composition exists for %1 (%2); no field HQ", _faction, _compType] call ALiVE_fnc_dump;
                    } else {
                        private _comp = selectRandom _comps;

                        // Align with the nearest road, because airfields
                        // tend to. ONE bounded pass, not the shared
                        // closest-road helper: that helper grows its
                        // radius until it finds a road and, once past its
                        // limit, its loop condition is true regardless, so
                        // on a bare heliport with no road within reach it
                        // never returns. Runways and taxiways are roads
                        // too, and are the ones whose name says invisible.
                        private _direction = 0;
                        private _roads = (_basePos nearRoads ROAD_SEARCH) select { ((str _x) find "invisible") == -1 };
                        if (count _roads > 0) then {
                            private _road = ([_roads, [_basePos], { _input0 distance2D _x }, "ASCEND"] call ALiVE_fnc_SortBy) select 0;
                            private _next = (roadsConnectedTo _road) param [0, objNull];
                            _direction = if (isNull _next) then { 90 } else { _road getDir _next };
                        };

                        // A DIAMETER, and passed unhalved on purpose: the
                        // validator halves it and adds its own overhang
                        // allowance. Halving it here as well was got wrong
                        // once elsewhere and the result was every camp on a
                        // wooded map silently failing to place.
                        private _envelope = [_comp] call ALiVE_fnc_getCompositionRadius;
                        if (isNil "_envelope" || {!(_envelope isEqualType 0)}) then { _envelope = 30 };
                        private _spot = [_basePos, _baseSize, _envelope, "military", _direction, _debug] call ALiVE_fnc_findCompositionSpawnPosition;
                        if (isNil "_spot" || {!(_spot isEqualType [])}) then { _spot = [] };

                        if (count _spot < 2) then {
                            ["ALIVE_fnc_ATOBase - no clear position for a field HQ within %1 m of %2 (envelope %3 m); no field HQ", _baseSize, _basePos, _envelope] call ALiVE_fnc_dump;
                        } else {
                            _spot params [["_flatPos", [0,0,0], [[]]], ["_safeDir", 0, [0]]];

                            // Not built when this session is restoring
                            // saved profiles, and not when saved
                            // compositions have already been put back: in
                            // both cases the last session's field HQ is
                            // either already standing or about to be, and
                            // a second one on top of it is the fault the
                            // persistence gate exists for.
                            private _built = false;
                            if (!_restoring && {isNil QMOD(COMPOSITIONS_LOADED)}) then {
                                [_comp, _flatPos, _safeDir, _faction] call ALiVE_fnc_spawnComposition;
                                _built = true;
                            } else {
                                ["ALIVE_fnc_ATOBase - field HQ not built: %1", if (_restoring) then { "profiles are being restored" } else { "saved compositions were restored" }] call ALiVE_fnc_dump;
                            };

                            // The HQ is whatever building now stands at the
                            // spot, looked for within the composition's
                            // own envelope. The old code asked nearestObject
                            // with no radius, which on a session where the
                            // composition was not built answered with the
                            // nearest building anywhere on the terrain.
                            private _near = (nearestObjects [_flatPos, ["Building"], _envelope max 50]) param [0, objNull];
                            if (!isNull _near) then {
                                _hq = _near;
                                _hqKind = if (_built) then { "composition" } else { "building" };
                            };
                        };
                    };
                };

                // Nothing else answered: the first object of the cluster,
                // so every reader downstream gets an object. `param` and a
                // type test, never a bare `select 0`: on an empty list that
                // answers nil, and a nil written into the hash below would
                // delete the `hq` key rather than store nothing.
                if (isNull _hq) then {
                    private _first = _nodes param [0, objNull];
                    if (_first isEqualType objNull) then { _hq = _first };
                    _hqKind = "nominal";
                };
            };

            // ---- the guard garrison -----------------------------------
            // Only for a real building, only with a working profile system,
            // and only when this session is not restoring, because a
            // restored session brings its own garrison back with its
            // profiles. The group lookup answers the string "FALSE" for a
            // faction with no infantry groups, and the old code handed that
            // straight to the profile builder.
            if (_hqKind in ["building", "composition"] && {_profilesReady} && {!_restoring}) then {
                private _group = ["Infantry", _faction] call ALIVE_fnc_configGetRandomGroup;
                if (isNil "_group" || {!(_group isEqualType "")} || {_group in ["", "FALSE"]}) then {
                    ["ALIVE_fnc_ATOBase - %1 has no infantry group to garrison the HQ with", _faction] call ALiVE_fnc_dump;
                } else {
                    private _profiles = [_group, getPosATL _hq, random 360, true, _faction] call ALIVE_fnc_createProfilesFromGroupConfig;
                    if (isNil "_profiles" || {!(_profiles isEqualType [])}) then { _profiles = [] };
                    {
                        if ([_x] call ALIVE_fnc_isHash && {([_x, "type", ""] call ALIVE_fnc_hashGet) isEqualTo "entity"}) then {
                            // No objective centre. These guards man the HQ
                            // building, and the 50 m reaches it from where
                            // they stand. An objective centre would widen
                            // the search to the whole objective and draw
                            // them off the thing they are here for, so that
                            // slot stays [0,0,0] deliberately (#1016).
                            [_x, "setActiveCommand", ["ALIVE_fnc_garrison", "spawn", [50, "false", [0,0,0]]]] call ALIVE_fnc_profileEntity;
                        };
                    } forEach _profiles;
                    _garrison = count _profiles > 0;
                };
            };

            if (_debug && {!isNull _hq} && {!isNil "ALIVE_fnc_placeDebugMarker"}) then {
                [getPosATL _hq, 4, format ["%1 - ATO HQ, %2 (%3)", _side, _hqKind, _faction], "ColorPink", "placement.ato"] call ALIVE_fnc_placeDebugMarker;
            };

            [_logic, "hq", _hq] call ALIVE_fnc_hashSet;
            [_logic, "hqKind", _hqKind] call ALIVE_fnc_hashSet;
            [_logic, "garrisonSpawned", _garrison] call ALIVE_fnc_hashSet;
            ["ALIVE_fnc_ATOBase - %1 base at %2 (%3 m), %4, HQ %5 (%6)%7",
                _faction, _basePos, round _baseSize, if (_isCarrier) then { "carrier deck" } else { "terrain" },
                typeOf _hq, _hqKind, if (_garrison) then { ", garrison placed" } else { "" }] call ALiVE_fnc_dump;
        };

        // ---- Placement is told where the base is --------------------------
        // Before anything is asked of it. Its initial placement refuses
        // outright without a base to anchor on, and its sweep needs the
        // factions and the airspace. The base it gets is a small hash of its
        // own, in the shape it reads, rather than this record.
        private _canSweep = _profilesReady && {[_place] call ALIVE_fnc_isHash};
        if (_failed isEqualTo "" && {[_place] call ALIVE_fnc_isHash}) then {
            private _forPlace = [[
                ["center", +_basePos],
                ["nodes", +_nodes],
                ["hq", _hq],
                ["isCarrier", _isCarrier],
                ["isVirtual", _isVirtual],
                ["virtualSlots", [_logic, "virtualSlots", 6] call ALIVE_fnc_hashGet],
                ["airspace", _airspaces param [0, ""]]
            ]] call ALIVE_fnc_hashCreate;
            [_logic, "place", [
                ["faction", _faction],
                ["factions", [_faction]],
                ["side", _side],
                ["airspaces", +_airspaces],
                ["base", _forPlace]
            ]] call _fnc_configure;
        } else {
            if (_failed isEqualTo "") then {
                ["ALIVE_fnc_ATOBase - no placement wired: nothing will be adopted or placed"] call ALiVE_fnc_dump;
            };
        };

        // ---- records from a previous session -----------------------------
        // Whatever the ledger already holds is put back first, so the sweeps
        // that follow see those aircraft as claimed rather than as candidates.
        // With an empty ledger this is a no-op. The answer is four lists;
        // anything else is counted as nothing restored.
        private _restored = [];
        if (_failed isEqualTo "" && {[_place] call ALIVE_fnc_isHash}) then {
            [_logic] call _fnc_waitUnpaused;
            private _r = [_place, "restoreAll"] call ALIVE_fnc_ATOPlace;
            if (!isNil "_r" && {_r isEqualType []} && {count _r >= 3} && {((_r select [0, 3]) findIf { !(_x isEqualType []) }) == -1}) then {
                _restored = (_r select 0) + (_r select 1) + (_r select 2);
            } else {
                ["ALIVE_fnc_ATOBase - placement restoreAll answered %1 rather than four lists; counted as nothing restored", _r] call ALiVE_fnc_dump;
            };
            [_logic, "restored", count _restored] call ALIVE_fnc_hashSet;
        };

        // ---- the own-faction sweep, BEFORE the commander wait -------------
        // Aircraft of this commander's own faction are adopted now, before
        // anything waits for a ground commander, so a deck full of aircraft
        // is not left as ordinary profiles for up to fifteen minutes. Two
        // passes a sighting gap apart, because Placement adopts nothing it
        // has seen only once; the first pass is only there to be the first
        // sighting. The sweep is handed "" as the airspace, which means every
        // airspace it was configured with. The clock handed to it is the
        // mission clock, because that is the clock it compares against.
        private _own = [];
        if (_failed isEqualTo "" && {_canSweep}) then {
            [_logic, "phase", "ownSweep"] call ALIVE_fnc_hashSet;
            [_logic] call _fnc_waitUnpaused;
            [_place, "sweep", ["", time, []]] call ALIVE_fnc_ATOPlace;
            private _t3 = time;
            waitUntil { (time - _t3) >= SIGHTING_GAP };
            private _second = [_place, "sweep", ["", time, []]] call ALIVE_fnc_ATOPlace;
            _own = [_second, "sweep"] call _fnc_tails;
            [_logic, "adoptedBeforeWait", count _own] call ALIVE_fnc_hashSet;
            [_logic, "ownSweepDoneAt", diag_tickTime] call ALIVE_fnc_hashSet;
            [_logic, (count _restored) + (count _own)] call _fnc_pushAssetCount;
        };

        // ---- B9 the ground commanders -------------------------------------
        // One bounded wait for all of them together, on the flag the
        // commander sets on its own logic when its start has returned. No
        // pause inside the test: a scheduled script yields every frame
        // anyway and the test costs one variable read per commander, and the
        // old ten second pause before each look cost twenty six measured
        // seconds on a mission where every commander had finished long
        // before. Deleted commanders are dropped before the wait, because a
        // null object answers the default forever and would have turned a
        // vanished module into a full fifteen minute stall.
        private _opcomHandlers = [];
        private _opcomIDs = [];
        private _opcomSides = [];
        private _factions = [_faction];
        if (_failed isEqualTo "") then {
            [_logic, "phase", "opcomWait"] call ALIVE_fnc_hashSet;
            [_logic, "opcomWaitStartedAt", diag_tickTime] call ALIVE_fnc_hashSet;

            private _synced = (synchronizedObjects _module) select { !isNull _x && {(typeOf _x) == "ALiVE_mil_OPCOM"} };
            if (count _synced == 0) then {
                ["ALIVE_fnc_ATOBase - no AI Commanders are synced to the Military Air Component Commander for %1. No CAS, Strike or Recce ATOs available", _faction] call ALiVE_fnc_dump;
            } else {
                private _t4 = diag_tickTime;
                waitUntil {
                    ((_synced findIf { !isNull _x && {!(_x getVariable ["startupComplete", false])} }) == -1)
                    || {(diag_tickTime - _t4) > OPCOM_WAIT}
                };
                private _late = _synced select { !isNull _x && {!(_x getVariable ["startupComplete", false])} };
                if (count _late > 0) then {
                    // How long it actually waited, so the line says what
                    // happened rather than what was configured.
                    ["ALIVE_fnc_ATOBase - gave up waiting for AI Commander(s) %1 after %2 seconds; carrying on without them", _late, round (diag_tickTime - _t4)] call ALiVE_fnc_dumpR;
                };

                {
                    if (!isNull _x) then {
                        private _h = _x getVariable ["handler", []];
                        if !([_h] call ALIVE_fnc_isHash) then {
                            ["ALIVE_fnc_ATOBase - AI Commander %1 has no handler and was skipped", _x] call ALiVE_fnc_dumpR;
                        } else {
                            // The logic-level flag goes up when the
                            // commander's start RETURNS, which a script
                            // error inside it also does; the handler's own
                            // flag only goes up when it finishes. A
                            // commander with the first and not the second is
                            // half started, and is merged with a warning
                            // rather than silently.
                            if !([_h, "startupComplete", false] call ALIVE_fnc_hashGet) then {
                                ["ALIVE_fnc_ATOBase - AI Commander %1 reports started but its handler never finished; its factions are merged anyway", _x] call ALiVE_fnc_dumpR;
                            };
                            private _mSide = [_h, "side", "EAST"] call ALIVE_fnc_hashGet;
                            if !(_mSide isEqualType "") then { _mSide = "EAST" };
                            // Skipped with a plain if, never an exitWith:
                            // an exitWith here leaves the forEach and every
                            // commander after this one would go unmerged.
                            if ([[_mSide] call ALIVE_fnc_sideTextToObject, [_side] call ALIVE_fnc_sideTextToObject] call BIS_fnc_sideIsFriendly) then {
                                _opcomHandlers pushBack _h;
                                _opcomSides pushBackUnique _mSide;
                                private _id = [_h, "opcomID", ""] call ALIVE_fnc_hashGet;
                                if (_id isEqualType "") then { _opcomIDs pushBackUnique _id };
                                private _mf = [_h, "factions", []] call ALIVE_fnc_hashGet;
                                if (_mf isEqualType []) then {
                                    { if (_x isEqualType "") then { _factions pushBackUnique _x } } forEach _mf;
                                };
                            } else {
                                ["ALIVE_fnc_ATOBase - AI Commander %1 (%2) is synced to an Air Component Commander of side %3 that it is not friendly to, and was skipped", _x, _mSide, _side] call ALiVE_fnc_dumpR;
                            };
                        };
                    };
                } forEach _synced;
            };

            [_logic, "opcomWaitEndedAt", diag_tickTime] call ALIVE_fnc_hashSet;
            [_logic, "opcomIDs", _opcomIDs] call ALIVE_fnc_hashSet;
            [_logic, "opcomSides", _opcomSides] call ALIVE_fnc_hashSet;
            [_logic, "factions", +_factions] call ALIVE_fnc_hashSet;

            // The merged list goes to everybody who filters by faction. The
            // vehicle type index is primed for it too; factions already in
            // that index are skipped by the helper itself.
            [_logic, "task", [["factions", +_factions]]] call _fnc_configure;
            [_logic, "place", [["factions", +_factions]]] call _fnc_configure;
            [_factions] call ALiVE_fnc_initFindVehicleTypeCache;
        };

        // ---- the merged-faction sweep -------------------------------------
        // The same two passes over the merged list. Aircraft already adopted
        // are gone from the registry and cannot reappear; aircraft first seen
        // on the own sweep's second pass are adopted here.
        private _merged = [];
        if (_failed isEqualTo "" && {_canSweep}) then {
            [_logic, "phase", "mergedSweep"] call ALIVE_fnc_hashSet;
            [_logic] call _fnc_waitUnpaused;
            [_place, "sweep", ["", time, []]] call ALIVE_fnc_ATOPlace;
            private _t5 = time;
            waitUntil { (time - _t5) >= SIGHTING_GAP };
            private _second = [_place, "sweep", ["", time, []]] call ALIVE_fnc_ATOPlace;
            _merged = [_second, "sweep"] call _fnc_tails;
            [_logic, "adoptedAfterWait", count _merged] call ALIVE_fnc_hashSet;
            [_logic, "mergedSweepDoneAt", diag_tickTime] call ALIVE_fnc_hashSet;
        };

        // ---- the initial placement ----------------------------------------
        // Placement decides for itself whether anything is wanted: the place
        // air setting, the carrier refusal, and the "fewer than two armed
        // records" gate all live there. Asked after both sweeps, as the
        // contract orders it, so what was adopted counts against the gate.
        private _placed = [];
        if (_failed isEqualTo "" && {[_place] call ALIVE_fnc_isHash}) then {
            [_logic, "phase", "placing"] call ALIVE_fnc_hashSet;
            [_logic] call _fnc_waitUnpaused;
            private _p = [_place, "placeInitial"] call ALIVE_fnc_ATOPlace;
            _placed = [_p, "placeInitial"] call _fnc_tails;
            [_logic, "placedInitial", count _placed] call ALIVE_fnc_hashSet;
        };

        // ---- the first pass is done ---------------------------------------
        // The Tasker holds every request as queued until this, and denies
        // for want of aircraft only after it. It is set HERE, after the
        // initial placement, and not after the own-faction sweep as the
        // first design of this piece had it: set there, with the count of
        // that sweep alone, every request arriving during the commander
        // wait, the second sighting gap and the placement was denied for
        // good on a count that the next three steps were about to raise.
        if (_failed isEqualTo "") then {
            [_logic, (count _restored) + (count _own) + (count _merged) + (count _placed)] call _fnc_pushAssetCount;
            if ([_task] call ALIVE_fnc_isHash) then {
                [_task, "firstPassDone"] call ALIVE_fnc_ATOTask;
            };
        };

        // ---- B6 the airfield as an objective ------------------------------
        // One friendly commander is told the airfield is a strategic reserve
        // objective, so its ground forces hold it. Not on a carrier, which
        // no ground force can hold. The answer is the objective hash, or
        // nothing when the commander could not be found.
        // Nor a base with no ground, for the same reason: ground forces cannot
        // hold a point in the air any more than they can hold a ship.
        if (_failed isEqualTo "" && {!_isCarrier} && {!_isVirtual} && {count _opcomHandlers > 0}) then {
            [_logic] call _fnc_waitUnpaused;

            // An airfield that is already an objective is reused rather than
            // registered a second time. This runs again every session, so a
            // persistent campaign used to put a fresh objective on the same
            // ground each reload and hand the commander the same airfield
            // several times over, once per session it had ever run. Every
            // commander is searched rather than only the one picked below,
            // because that pick is random and a later session can land on a
            // different commander than the one holding the objective from the
            // session before. Two questions are asked of every objective,
            // because either one alone misses a real case: whether it carries
            // this cluster's id, and whether it already sits on this ground.
            // No exitWith anywhere below. Inside a forEach whose body is
            // already nested, an exitWith leaves the block it sits in rather
            // than the loop, so the search would carry on and the LAST match
            // would win instead of the first. A sentinel does the same job and
            // cannot be read the wrong way. Inside findIf, _x is the objective
            // and shadows the handler, which is why the handler is captured
            // first.
            private _obj = [];
            private _opcom = [];
            {
                if (_obj isEqualTo []) then {
                    private _here = _x;
                    private _objs = [_here, "objectives", []] call ALIVE_fnc_hashGet;
                    if (_objs isEqualType []) then {
                        private _found = _objs findIf {
                            private _o = _x;
                            private _ok = false;
                            if (_o isEqualType [] && {!([_o, "deleted", false] call ALIVE_fnc_hashGet)}) then {
                                private _cid = [_o, "clusterID", ""] call ALIVE_fnc_hashGet;
                                if (!(_clusterID isEqualTo "") && {_cid isEqualType ""} && {_cid isEqualTo _clusterID}) then {
                                    _ok = true;
                                };
                                // The id on its own is not enough, and this is
                                // the case that matters. Cluster generation
                                // MERGES the air clusters into the military
                                // list before consolidating it, and that merged
                                // list is what placement hands the commander as
                                // its objectives. So an airfield inside a
                                // placement area is ALREADY an objective, under
                                // the military cluster's id and centre, while
                                // the base here was chosen from the separate
                                // pre-consolidation air copy and carries a
                                // different id and a centre some way off. On
                                // Stratis those two sit 249 m apart. Asking
                                // about the ground as well as the id is what
                                // actually catches it.
                                if (!_ok) then {
                                    private _c = [_o, "center", []] call ALIVE_fnc_hashGet;
                                    if (_c isEqualType [] && {count _c > 1}) then {
                                        private _dx = (_c select 0) - (_basePos select 0);
                                        private _dy = (_c select 1) - (_basePos select 1);
                                        _ok = ((_dx * _dx) + (_dy * _dy)) < (_baseSize * _baseSize);
                                    };
                                };
                            };
                            _ok
                        };
                        if (_found > -1) then { _obj = _objs select _found; _opcom = _here; };
                    };
                };
            } forEach _opcomHandlers;

            private _reused = !(_obj isEqualTo []);
            private _opcomID = "";

            if (_reused) then {
                _opcomID = [_opcom, "opcomID", ""] call ALIVE_fnc_hashGet;
                if !(_opcomID isEqualType "") then { _opcomID = "" };
                ["ALIVE_fnc_ATOBase - this airfield is already an objective for AI Commander %1, so that one is reused rather than a second being registered on the same ground", _opcomID] call ALiVE_fnc_dump;
            } else {
                _opcom = selectRandom _opcomHandlers;
                _opcomID = [_opcom, "opcomID", ""] call ALIVE_fnc_hashGet;
                if !(_opcomID isEqualType "") then { _opcomID = "" };
                private _objId = format ["OPCOM_%1_objective_ATO_%2", _opcomID, ceil (random 1000)];
                private _objArgs = [_objId, +_basePos, _baseSize, "strategic", OBJECTIVE_PRIORITY, "unassigned", _clusterID];
                // The last three are the commander id, whether a player asked
                // for this objective, and where it goes in the list. The id is
                // read the same way the commander would have read its own, so
                // passing it changes nothing except that the two arguments
                // after it become reachable.
                //
                // THE FRONT IS THE POINT. A commander takes the FIRST match in
                // array order within a state, with no sort by priority, so an
                // objective added to the back of a long list is one it may
                // never reach: the airfield was registered and then ignored.
                // This only reorders within the unassigned group. The order the
                // states themselves are considered in is untouched.
                _objArgs pushBack _opcomID;
                _objArgs pushBack false;
                _objArgs pushBack true;
                _obj = [_opcom, "addObjective", _objArgs] call ALiVE_fnc_OPCOM;
            };

            if (isNil "_obj" || {!(_obj isEqualType [])} || {_obj isEqualTo []}) then {
                ["ALIVE_fnc_ATOBase - the airfield objective could not be registered with AI Commander %1", _opcomID] call ALiVE_fnc_dumpR;
            } else {
                [_logic, "objectiveId", [_obj, "objectiveID", ""] call ALIVE_fnc_hashGet] call ALIVE_fnc_hashSet;

                // Who actually holds the field, asked now that there is a real
                // objective to ask about. This is the one moment the question
                // can be answered: the airfield only becomes an objective here,
                // and the ground commanders have already finished, so the
                // profile grid this rests on is filled.
                //
                // Ownership is NOT consulted when the base is chosen, which
                // happens long before any of that is knowable, so a commander
                // can and does stand up on a field the enemy is sitting on.
                // This does not change that. It says so, which the existing
                // notice about drawn ground could only guess at: that one reads
                // a marker somebody drew in the editor, and this reads who is
                // standing there.
                if (!isNil "ALiVE_fnc_isHeldObjective") then {
                    private _ours = [_obj, _side, 300, false] call ALiVE_fnc_isHeldObjective;
                    if (_ours) then {
                        ["ALIVE_fnc_ATOBase - %1 (%2) is based on an airfield its own side holds", _faction, _side] call ALiVE_fnc_dump;
                    } else {
                        ["ALIVE_fnc_ATOBase - %1 (%2) is based on an airfield its own side does NOT hold: hostile forces are standing within 300 m of it. The commander will still fly from there, because a base is chosen before anyone knows who holds it. If that is not wanted, draw this module's Airspace Marker to leave that airfield out, or name an Ingress Marker so it flies from a point instead.",
                            _faction, _side] call ALiVE_fnc_dumpR;
                    };
                };
            };
        };

        // ---- B7 scenery ---------------------------------------------------
        // The objective objects the mission maker picked, around the module.
        // The helper reads the picker's own setting off the logic; only the
        // count, chance and behaviour are read here, and Eden stores the
        // first two as text. Skipped on a carrier: the helper places on
        // land only and would spend its two hundred attempts per object
        // finding none.
        // Skipped at a base with no ground as well, and for exactly the reason
        // given above: the helper places on land only and would spend its two
        // hundred attempts per object finding none.
        if (_failed isEqualTo "" && {!_isCarrier} && {!_isVirtual}) then {
            private _countRaw = _module getVariable ["objectiveObjectsCount", "0"];
            private _count = switch (true) do {
                case (_countRaw isEqualType 0): { _countRaw };
                case (_countRaw isEqualType "" && {!(_countRaw isEqualTo "")}): { parseNumber _countRaw };
                default { 0 };
            };
            private _chanceRaw = _module getVariable ["objectiveObjectsChance", "100"];
            private _chance = switch (true) do {
                case (_chanceRaw isEqualType 0): { (_chanceRaw max 0) min 100 };
                case (_chanceRaw isEqualType "" && {!(_chanceRaw isEqualTo "")}): { ((parseNumber _chanceRaw) max 0) min 100 };
                default { 100 };
            };
            private _behaviour = _module getVariable ["objectiveObjectsBehaviour", "dispersed"];
            if !(_behaviour isEqualType "") then { _behaviour = "dispersed" };
            if (_count > 0) then {
                [_logic] call _fnc_waitUnpaused;
                private _n = [_module, getPosATL _module, SCENERY_RADIUS, _count, _behaviour, _debug, _chance] call ALiVE_fnc_spawnObjectiveObjects;
                if (!isNil "_n" && {_n isEqualType 0}) then {
                    [_logic, "sceneryPlaced", _n] call ALIVE_fnc_hashSet;
                };
            };
        };

        // ---- B13 done, B14 said, N3 published ------------------------------
        if (_failed isEqualTo "") then {
            [_logic, "phase", "established"] call ALIVE_fnc_hashSet;
        };
        [_logic, "doneAt", diag_tickTime] call ALIVE_fnc_hashSet;

        // The side is told, through the Effector, which owns the radio. The
        // words are the two keys the old module used, with the HQ's name
        // where each key wants it. Established with no aircraft is said as
        // not established, with a warning that says what to check, because
        // an airbase with nothing on it answers every request the same way
        // as no airbase at all.
        private _assets = [_logic, "assetCount", 0] call ALIVE_fnc_hashGet;
        if ([_effect] call ALIVE_fnc_isHash) then {
            private _hqClass = [_side] call _fnc_hqClass;
            private _hqName = "HQ";
            private _named = [_effect, "hqName", _hqClass] call ALIVE_fnc_ATOEffect;
            if (!isNil "_named" && {_named isEqualType ""} && {!(_named isEqualTo "")}) then { _hqName = _named };
            private _factionName = getText ((_faction call ALiVE_fnc_configGetFactionClass) >> "displayName");
            if (_factionName isEqualTo "") then { _factionName = _faction };

            // The grid of the BASE for a commander with no airfield, and the
            // HQ's for every other one.
            //
            // Heard on the radio in a test: "forward airbase established at
            // grid 019057" when the aircraft were at grid 018006, five
            // kilometres away and out at sea. An ordinary base and its HQ stand
            // in the same place so the two agree; a base with no airfield does
            // not, because its HQ is a building found near the MODULE while its
            // base is the ingress marker. Different words too: nothing has been
            // established at an ingress point, aircraft simply fly from it.
            private _key = if (_isVirtual) then { "STR_ALIVE_ATO_ESTABLISHED_INGRESS" } else { "STR_ALIVE_ATO_ESTABLISHED" };
            private _sayAt = if (_isVirtual || {isNull _hq}) then { _basePos } else { getPosATL _hq };
            private _say = [_hqName, _factionName, mapGridPosition _sayAt];
            if (!(_failed isEqualTo "") || {_assets == 0}) then {
                if (_failed isEqualTo "") then {
                    // Two different things to check, because a commander with no
                    // airfield has nothing to find inside an airspace: its
                    // aircraft are created for it at its marker, and it refuses
                    // every one that already exists, so the only way it ends with
                    // none is the faction having none this module can fly.
                    private _advice = if (_isVirtual) then {
                        "no aircraft could be held at its ingress point. Check that this module's faction has armed aircraft of its own."
                    } else {
                        "no air assets were found inside its airspace. Check this module's faction, its airspace markers, that armed aircraft of that faction start inside them, and Place Air Assets if this commander should add its own."
                    };
                    ["ALIVE_fnc_ATOBase - %1 (%2): %3 Requests will be refused until aircraft are available.",
                        _faction, _side, _advice] call ALiVE_fnc_dumpR;
                };
                _key = "STR_ALIVE_ATO_NOT_ESTABLISHED";
                _say = [_hqName, _factionName];
            };
            private _r = [_effect, "apply", ["broadcast", objNull, [], [_key, _say, _side, _hqClass, _onRadio]]] call ALIVE_fnc_ATOEffect;
            if (!isNil "_r" && {_r isEqualType []} && {(_r param [0, ""]) isEqualTo "refused"}) then {
                ["ALIVE_fnc_ATOBase - the establishment notice was not sent: %1", _r param [2, ""]] call ALiVE_fnc_dump;
            };
        };

        // Published for each side that now has an air component to ask,
        // which is every friendly commander's side and this module's own.
        // The old module keyed this by the synced commanders alone, so a
        // commander of the same side that was not synced never saw it.
        if (_failed isEqualTo "" && {!isNil "ALiVE_require"}) then {
            private _sides = +_opcomSides;
            _sides pushBackUnique _side;
            {
                ALiVE_require setVariable [format ["ALIVE_MIL_ATO_AVAIL_%1", _x], true, true];
            } forEach _sides;
        };

        ["ALIVE_fnc_ATOBase - %1 (%2) %3: %4 aircraft (%5 restored, %6 adopted before the commander wait, %7 after, %8 placed), %9 commander(s), factions %10, HQ %11, %12 s from establish to ready and %13 s to done",
            _faction, _side, [_logic, "phase", ""] call ALIVE_fnc_hashGet, _assets,
            count _restored, count _own, count _merged, count _placed, count _opcomHandlers, _factions, _hqKind,
            round (([_logic, "readyAt", 0] call ALIVE_fnc_hashGet) - ([_logic, "startedAt", 0] call ALIVE_fnc_hashGet)),
            round (diag_tickTime - ([_logic, "startedAt", 0] call ALIVE_fnc_hashGet))] call ALiVE_fnc_dump;

        _result = [_logic, "phase", ""] call ALIVE_fnc_hashGet;
    };

    // ---- accessors ---------------------------------------------------------

    // "" while the base stands; otherwise why it does not.
    case "failed": { _result = [_logic, "failed", ""] call ALIVE_fnc_hashGet };

    case "phase": { _result = [_logic, "phase", "idle"] call ALIVE_fnc_hashGet };

    // Honoured between steps of "continue". Stored here so the Kernel can
    // forward the module-level pause without knowing what this piece is in
    // the middle of.
    case "pause": {
        private _on = _args;
        if !(_on isEqualType true) then { _on = true };
        [_logic, "paused", _on] call ALIVE_fnc_hashSet;
        _result = true;
    };

    // A copy of the record, for anybody who wants to read it without being
    // able to change it. Built by hand rather than with the hash copier,
    // because the copier follows every value that is a hash, and `deps`
    // holds the Surface, Placement, Tasker and Effector instances: a copy of
    // this record would then be a copy of every sortie in the mission.
    case "view": {
        private _copy = [] call ALIVE_fnc_hashCreate;
        private _values = _logic select 2;
        {
            if !(_x isEqualTo "deps") then {
                private _v = _values select _forEachIndex;
                if (_v isEqualType []) then { _v = +_v };
                [_copy, _x, _v] call ALIVE_fnc_hashSet;
            };
        } forEach (_logic select 1);
        _result = _copy;
    };

    default {
        _result = [_logic, _operation, _args] call SUPERCLASS;
    };
};

TRACE_1("ATO Base - output",_result);

_result;
