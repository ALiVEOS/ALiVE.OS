#include "\x\alive\addons\mil_ato\script_component.hpp"

SCRIPT(test_ato_ledger);

/* ----------------------------------------------------------------------------
Ledger test. Needs no mission: paste it into the debug console of an empty
world, or run it from tests/test.sqf.

The gate for build step 1. Every promise in contract.md section 5.1 has an
assertion here, and the ones that matter most are the two that guard against
losing a campaign: a snapshot must not share references with the live records,
and a tail this session never attached to must not be droppable.
---------------------------------------------------------------------------- */

private _fails = [];
private _fnc_check = {
    // _ok is taken as Any on purpose. An assertion whose expression threw
    // arrives here as nil, and `if (nil)` would throw again, abandoning the
    // statement and printing NOTHING: the failure disappears instead of being
    // reported. Three did exactly that on the first run.
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

diag_log "=== ATO Ledger test ===";

// --- create ---------------------------------------------------------------
private _ledger = [nil, "create"] call ALIVE_fnc_ATOLedger;
[_ledger, "setInstance", ["BLU_F_1", "BLU_F"]] call ALIVE_fnc_ATOLedger;

private _tails = [];
{
    _tails pushBack ([_ledger, "createRecord",
        [_x, "BLU_F", ["airspace_1"], [["CAS","Strike"], ["guided"]]]] call ALIVE_fnc_ATOLedger);
} forEach ["B_Plane_CAS_01_F", "B_Heli_Attack_01_F", "B_UAV_02_F"];

["three records created", count _tails == 3] call _fnc_check;
["tails are distinct", count (_tails arrayIntersect _tails) == 3] call _fnc_check;

private _first = [_ledger, "get", _tails select 0] call ALIVE_fnc_ATOLedger;
["roles survive create", count ([_first,"roles",[]] call ALIVE_fnc_hashGet) == 2] call _fnc_check;
["callsign is minted", ([_first,"callsign",""] call ALIVE_fnc_hashGet) != ""] call _fnc_check;

// get must hand back a copy, not the record itself
private _again = [_ledger, "get", _tails select 0] call ALIVE_fnc_ATOLedger;
["get returns a copy, not the record", !(_first isEqualRef _again)] call _fnc_check;

// --- snapshot is a deep copy ----------------------------------------------
[_ledger, "setHome", [_tails select 0, [[100,200,0], 90, "terrain"]]] call ALIVE_fnc_ATOLedger;
private _snap = [_ledger, "snapshot"] call ALIVE_fnc_ATOLedger;

// mutate the LIVE record after snapshotting; the snapshot must not move
[_ledger, "setHome", [_tails select 0, [[999,999,0], 0, "terrain"]]] call ALIVE_fnc_ATOLedger;
private _snapRec = [_snap, _tails select 0, []] call ALIVE_fnc_hashGet;
private _snapHome = [_snapRec, "home", []] call ALIVE_fnc_hashGet;
["snapshot did not follow a later change", (_snapHome select 0) isEqualTo [100,200,0]] call _fnc_check;

private _liveRecs = [_ledger, "records"] call ALIVE_fnc_hashGet;
private _liveRec = [_liveRecs, _tails select 0, []] call ALIVE_fnc_hashGet;
["snapshot record is not the live record", !(_snapRec isEqualRef _liveRec)] call _fnc_check;

// the backend walks the payload pair by pair, so the shape has to survive that
private _pairs = 0;
[_snap, { _pairs = _pairs + 1 }] call CBA_fnc_hashEachPair;
["snapshot walks as 4 pairs (meta + 3)", _pairs == 4] call _fnc_check;
["session state is not in the snapshot",
    ([_snapRec,"attachedThisSession","absent"] call ALIVE_fnc_hashGet) isEqualTo "absent"] call _fnc_check;

// --- the monotone guarantee -----------------------------------------------
// A tail this session never attached to cannot be declared lost. This is the
// whole protection against writing an empty campaign over a full one.
["markLost refused on an unattached tail",
    !([_ledger, "markLost", _tails select 1] call ALIVE_fnc_ATOLedger)] call _fnc_check;

[_ledger, "markPresent", _tails select 1] call ALIVE_fnc_ATOLedger;
["markLost allowed once attached",
    [_ledger, "markLost", _tails select 1] call ALIVE_fnc_ATOLedger] call _fnc_check;

private _lost = [_ledger, "get", _tails select 1] call ALIVE_fnc_ATOLedger;
["status is lost", ([_lost,"status",""] call ALIVE_fnc_hashGet) isEqualTo "lost"] call _fnc_check;
["lossCount bumped to 1", ([_lost,"lossCount",0] call ALIVE_fnc_hashGet) == 1] call _fnc_check;
["a lost record is still a record", count (([_ledger,"records"] call ALIVE_fnc_hashGet) select 1) == 3] call _fnc_check;

// --- save and restore through an injected store ---------------------------
private _store = [] call ALIVE_fnc_hashCreate;
[_ledger, "save", [_store, "BLU_F_1"]] call ALIVE_fnc_ATOLedger;

private _fresh = [nil, "create"] call ALIVE_fnc_ATOLedger;
private _loadResult = [_fresh, "load", [_store, "BLU_F_1", ""]] call ALIVE_fnc_ATOLedger;
_loadResult params ["_kept", "_unplaceable", "_unknown"];

["restore kept all three", _kept == 3] call _fnc_check;
["restore invented nothing", count _unknown == 0] call _fnc_check;
["restored records match", count (([_fresh,"records"] call ALIVE_fnc_hashGet) select 1) == 3] call _fnc_check;

// and a restored record is unattached, so it cannot be dropped next session
["restored record is unattached",
    !([_fresh, "markLost", _tails select 0] call ALIVE_fnc_ATOLedger)] call _fnc_check;

// --- a commander covering two factions, saved and loaded ------------------
// The reported fault: after a load, such a commander's list of aircraft became
// whichever faction most recently flew a sortie, so an aircraft destroyed and
// cleaned up came back onto the books and a replacement delivered for the other
// faction went missing. The cause named was each faction coming back as its own
// saved record with the sortie path treating the current one as the whole list.
//
// Driven here as the sequence that was reported: both factions on one
// commander, each flying in turn, one aircraft lost on each side, a replacement
// minted for the other faction while the first was the one flying, then a save
// and a load into a commander that knows nothing.
private _macc = [nil, "create"] call ALIVE_fnc_ATOLedger;
[_macc, "setInstance", ["MACC_two_factions", "BLU_F"]] call ALIVE_fnc_ATOLedger;

private _bluTails = [];
{
    _bluTails pushBack ([_macc, "createRecord",
        [_x, "BLU_F", ["airspace_1"], [["CAS","Strike"], ["guided"]]]] call ALIVE_fnc_ATOLedger);
} forEach ["B_Plane_CAS_01_F", "B_Heli_Attack_01_F"];

private _indTails = [];
{
    _indTails pushBack ([_macc, "createRecord",
        [_x, "IND_F", ["airspace_1"], [["CAS"], ["guided"]]]] call ALIVE_fnc_ATOLedger);
} forEach ["I_Plane_Fighter_03_CAS_F", "I_Heli_light_03_F"];

["one ledger holds both factions", count (([_macc,"records"] call ALIVE_fnc_hashGet) select 1) == 4] call _fnc_check;
["and their tails are told apart by faction",
    ((_bluTails select 0) find "BLU_F") == 0 && {((_indTails select 0) find "IND_F") == 0}] call _fnc_check;

// The first faction flies. One of its aircraft is lost and a replacement is
// named for it, which is the aircraft logistics would deliver.
[_macc, "markPresent", _bluTails select 0] call ALIVE_fnc_ATOLedger;
[_macc, "markLost", _bluTails select 0] call ALIVE_fnc_ATOLedger;
[_macc, "setReplacement", [_bluTails select 0, "pending_BLU"]] call ALIVE_fnc_ATOLedger;

// The other faction flies. Under the reported fault this is the point where the
// list switched and the first faction's changes stopped being there.
[_macc, "markPresent", _indTails select 1] call ALIVE_fnc_ATOLedger;
[_macc, "markLost", _indTails select 1] call ALIVE_fnc_ATOLedger;

// And an aircraft added while the second faction was the one flying, which is
// the replacement the report says goes missing.
private _lateTail = [_macc, "createRecord",
    ["I_Plane_Fighter_03_CAS_F", "IND_F", ["airspace_1"], [["CAS"], ["guided"]]]] call ALIVE_fnc_ATOLedger;

private _maccStore = [] call ALIVE_fnc_hashCreate;
[_macc, "save", [_maccStore, "MACC_two_factions"]] call ALIVE_fnc_ATOLedger;

// One commander, one document. The fault needs a record per faction to switch
// between, so this is the half of it that cannot happen any more.
["both factions are saved under one key", count (_maccStore select 1) == 1] call _fnc_check;

private _reloaded = [nil, "create"] call ALIVE_fnc_ATOLedger;
([_reloaded, "load", [_maccStore, "MACC_two_factions", ""]] call ALIVE_fnc_ATOLedger) params ["_maccKept"];

["a load restores every aircraft of both factions", _maccKept == 5] call _fnc_check;

private _backBlu = 0;
private _backInd = 0;
{
    private _f = [[_reloaded, "get", _x] call ALIVE_fnc_ATOLedger, "faction", ""] call ALIVE_fnc_hashGet;
    if (_f isEqualTo "BLU_F") then { _backBlu = _backBlu + 1 };
    if (_f isEqualTo "IND_F") then { _backInd = _backInd + 1 };
} forEach (([_reloaded,"records"] call ALIVE_fnc_hashGet) select 1);
diag_log format ["  info  after the load the commander holds %1 of one faction and %2 of the other", _backBlu, _backInd];
["neither faction was replaced by the other", _backBlu == 2 && {_backInd == 3}] call _fnc_check;

// The reported symptom itself: an aircraft destroyed and cleaned up coming back
// onto the books, which is what lets the commander ask for it to be replaced
// twice.
private _wasLost = [_reloaded, "get", _bluTails select 0] call ALIVE_fnc_ATOLedger;
["an aircraft lost before the save is still lost after the load",
    ([_wasLost,"status",""] call ALIVE_fnc_hashGet) isEqualTo "lost"] call _fnc_check;
["and it still has its loss counted",
    ([_wasLost,"lossCount",0] call ALIVE_fnc_hashGet) == 1] call _fnc_check;
["and the replacement named for it survived",
    ([_wasLost,"replacement",""] call ALIVE_fnc_hashGet) isEqualTo "pending_BLU"] call _fnc_check;

// The other reported symptom: a replacement for one faction going missing
// because the other faction was the one flying when it arrived.
["an aircraft added while the other faction was flying is still there",
    count ([_reloaded, "get", _lateTail] call ALIVE_fnc_ATOLedger) > 0] call _fnc_check;

private _lostOther = [_reloaded, "get", _indTails select 1] call ALIVE_fnc_ATOLedger;
["and the second faction's own loss was not undone by the first",
    ([_lostOther,"status",""] call ALIVE_fnc_hashGet) isEqualTo "lost"] call _fnc_check;

// --- housekeeping keys must never become fields ---------------------------
private _dirty = [] call ALIVE_fnc_hashCreate;
private _dirtyRec = [[
    ["vehicleClass", "B_Plane_CAS_01_F"],
    ["home", [[10,10,0], 0, "terrain"]],
    ["_rev", "3-abcdef"],
    ["_id", "some_document_id"]
]] call ALIVE_fnc_hashCreate;
[_dirty, "BLU_F_9", _dirtyRec] call ALIVE_fnc_hashSet;
[_dirty, "_rev", "7-topLevel"] call ALIVE_fnc_hashSet;
[_dirty, "_id", "top_level_id"] call ALIVE_fnc_hashSet;

private _clean = [nil, "create"] call ALIVE_fnc_ATOLedger;
([_clean, "restore", _dirty] call ALIVE_fnc_ATOLedger) params ["_k2", "_u2", "_unknown2"];
["top level housekeeping is not a record", _k2 == 1] call _fnc_check;

private _restored = [_clean, "get", "BLU_F_9"] call ALIVE_fnc_ATOLedger;
["_rev stripped from inside the record",
    ([_restored,"_rev","gone"] call ALIVE_fnc_hashGet) isEqualTo "gone"] call _fnc_check;
["_id stripped from inside the record",
    ([_restored,"_id","gone"] call ALIVE_fnc_hashGet) isEqualTo "gone"] call _fnc_check;

// --- legacy import --------------------------------------------------------
// The old store: keyed by faction, each holding a hash of assets, with the
// backend's own keys mixed in at both levels.
private _legacy = [] call ALIVE_fnc_hashCreate;
private _assets = [] call ALIVE_fnc_hashCreate;
{
    private _a = [[
        ["vehicleClass", _x],
        ["startPos", [500 + _forEachIndex, 600, 0]],
        ["startDir", 45],
        ["isOnCarrier", false],
        ["profileID", format ["BLU_F-vehicle_%1", _forEachIndex]]
    ]] call ALIVE_fnc_hashCreate;
    [_assets, format ["BLU_F-vehicle_%1", _forEachIndex], _a] call ALIVE_fnc_hashSet;
} forEach ["B_Plane_CAS_01_F", "B_Heli_Attack_01_F"];
[_assets, "_rev", "2-assetlevel"] call ALIVE_fnc_hashSet;
[_legacy, "BLU_F", _assets] call ALIVE_fnc_hashSet;
[_legacy, "_id", "legacy_doc"] call ALIVE_fnc_hashSet;

private _imported = [nil, "create"] call ALIVE_fnc_ATOLedger;
([_imported, "importLegacy", _legacy] call ALIVE_fnc_ATOLedger) params ["_k3", "_u3", "_unknown3"];
["legacy import count equals asset count", _k3 == 2] call _fnc_check;
["legacy housekeeping ignored, not imported", count _unknown3 == 0] call _fnc_check;

private _impRecs = ([_imported,"records"] call ALIVE_fnc_hashGet) select 2;
private _anyHome = false;
private _anyLegacyID = false;
{
    if (count ([_x,"home",[]] call ALIVE_fnc_hashGet) == 3) then { _anyHome = true };
    if (([_x,"legacyProfileID",""] call ALIVE_fnc_hashGet) != "") then { _anyLegacyID = true };
} forEach _impRecs;
["imported homes carry position, direction and surface", _anyHome] call _fnc_check;
["old profile id kept so the first session recognises the aircraft", _anyLegacyID] call _fnc_check;

// --- result ---------------------------------------------------------------
// ---- reading one field ------------------------------------------------------
// The cheap read the kernel uses several times per aircraft per tick. What has
// to hold is that it answers the same as fetching the whole record, that it
// answers the default for a record or a field that is not there, and that an
// array it hands back is a COPY: handing out the record's own array would let a
// caller change the record by changing what it was given.
private _lf = [nil, "create"] call ALIVE_fnc_ATOLedger;
[_lf, "setInstance", ["BLU_F_0", "BLU_F"]] call ALIVE_fnc_ATOLedger;
private _tailF = [_lf, "createRecord", ["B_Heli_Attack_01_F", "BLU_F", [], [["CAS"], []]]] call ALIVE_fnc_ATOLedger;
[_lf, "setHome", [_tailF, [[100,200,0], 45, "terrain"]]] call ALIVE_fnc_ATOLedger;

["a field reads the same as the whole record",
    ([_lf, "field", [_tailF, "vehicleClass", ""]] call ALIVE_fnc_ATOLedger) isEqualTo "B_Heli_Attack_01_F"] call _fnc_check;
["a field that is not there answers the default",
    ([_lf, "field", [_tailF, "notAKey", "fallback"]] call ALIVE_fnc_ATOLedger) isEqualTo "fallback"] call _fnc_check;
["a record that is not there answers the default",
    ([_lf, "field", ["NO_SUCH_TAIL", "vehicleClass", "fallback"]] call ALIVE_fnc_ATOLedger) isEqualTo "fallback"] call _fnc_check;

private _homeF = [_lf, "field", [_tailF, "home", []]] call ALIVE_fnc_ATOLedger;
["a field reads an array value",
    _homeF isEqualType [] && {count _homeF == 3} && {(_homeF select 1) isEqualTo 45}] call _fnc_check;
_homeF set [1, 999];
private _homeAgain = [_lf, "field", [_tailF, "home", []]] call ALIVE_fnc_ATOLedger;
["and editing what it handed back does not change the record",
    (_homeAgain select 1) isEqualTo 45] call _fnc_check;

if (count _fails == 0) then {
    diag_log "=== ATO Ledger test: ALL PASS ===";
} else {
    diag_log format ["=== ATO Ledger test: %1 FAILURE(S): %2 ===", count _fails, _fails];
};

count _fails == 0
