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
if (count _fails == 0) then {
    diag_log "=== ATO Ledger test: ALL PASS ===";
} else {
    diag_log format ["=== ATO Ledger test: %1 FAILURE(S): %2 ===", count _fails, _fails];
};

count _fails == 0
