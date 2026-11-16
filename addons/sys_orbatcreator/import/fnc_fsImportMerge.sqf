#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsImportMerge);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsImportMerge

Description:
Merges an incoming faction (from ALiVE_fnc_fsImportFaction or a share text) into
a target faction, skipping what the target already has. What is already in the
target is never changed by a merge.

    1. categories merge by name, case-insensitive;
    2. units, then vehicles: an incoming entry is a duplicate when the non-empty
       src of both are equal (case-insensitive), or, both src empty, their class.
       A duplicate is skipped and its incoming id maps to the existing id. Any
       other entry gets a new id from the target's counter and, when its class is
       automatic or taken in the target, a new automatic class (with the target's
       tag);
    3. every crewUnit, gunnerUnit and member ref of the added entries is rewritten
       through the old-id to new-id map;
    4. groups: a duplicate when src is equal, or category, name and the list of
       member refs are equal; skipped the same way;
    5. meta.legacyPatches of the incoming faction are added (unique, at most 8);
    6. one throttled ALiVE_fnc_fsDataTouch, when _touch is true.
The incoming faction is used up: its entries move into the target.

Parameters:
    _target   - HASHMAP - the faction merged into
    _incoming - HASHMAP - the faction merged from
    _touch    - BOOL - optional, default true: mark the working faction changed

Returns:
    ARRAY - [added, skipped, notes]

Examples:
    (begin example)
    ([missionNamespace getVariable "ALiVE_FS_faction", _incoming] call ALiVE_fnc_fsImportMerge) params ["_added", "_skipped", "_notes"];
    (end)

See Also:
    ALiVE_fnc_fsImportFaction, ALiVE_fnc_fsDataUnit, ALiVE_fnc_fsDataGroup

Author:
    Jman
---------------------------------------------------------------------------- */

#include "\x\alive\addons\sys_orbatcreator\fs_defines.hpp"

params [["_target", createHashMap, [createHashMap]], ["_incoming", createHashMap, [createHashMap]], ["_touch", true, [true]]];

private _added = 0;
private _skipped = 0;
private _notes = [];

// 1. Categories by name.
private _catMap = createHashMap;
private _targetCats = _target getOrDefault ["categories", createHashMap];
{
    private _name = _y getOrDefault ["name", ""];
    private _found = "";
    { if ((_y getOrDefault ["name", ""]) == _name) exitWith { _found = _x } } forEach _targetCats;
    if (_found isEqualTo "") then { _found = ["add", [_name], _target] call ALiVE_fnc_fsDataCategory };
    _catMap set [_x, _found];
} forEach (_incoming getOrDefault ["categories", createHashMap]);

// 2. Units, then vehicles.
private _idMap = createHashMap;
private _newEntries = [];
{
    _x params ["_dictKey", "_orderKey", "_fnc"];
    private _have = values (_target getOrDefault [_dictKey, createHashMap]);
    private _dict = _incoming getOrDefault [_dictKey, createHashMap];
    private _order = _incoming getOrDefault [_orderKey, keys _dict];
    {
        private _entry = _dict getOrDefault [_x, createHashMap];
        if ((count _entry) > 0) then {
            private _oldId = _x;
            private _src = toLower (_entry getOrDefault ["src", ""]);
            private _class = toLower (_entry getOrDefault ["class", ""]);
            private _at = _have findIf {
                private _hSrc = toLower (_x getOrDefault ["src", ""]);
                if (_src isEqualTo "" && {_hSrc isEqualTo ""}) then { (toLower (_x getOrDefault ["class", ""])) isEqualTo _class } else { _hSrc isEqualTo _src }
            };
            if (_at >= 0) then {
                _idMap set [_oldId, (_have select _at) get "id"];
                _skipped = _skipped + 1;
            } else {
                _entry set ["category", _catMap getOrDefault [_entry getOrDefault ["category", ""], ""]];
                private _newId = ["add", [_entry], _target] call _fnc;
                if (_newId isEqualTo "") then {
                    _notes pushBack format ["%1: the faction is full, so it was left out.", _entry getOrDefault ["name", _oldId]];
                } else {
                    _idMap set [_oldId, _newId];
                    _newEntries pushBack _entry;
                    _added = _added + 1;
                };
            };
        };
    } forEach _order;
} forEach [["units", "unitOrder", ALiVE_fnc_fsDataUnit], ["vehicles", "vehicleOrder", ALiVE_fnc_fsDataVehicle]];

// 3. References of the added entries, through the id map.
{
    if ("crewUnit" in _x) then { _x set ["crewUnit", _idMap getOrDefault [_x get "crewUnit", ""]] };
    { _x set ["gunnerUnit", _idMap getOrDefault [_x getOrDefault ["gunnerUnit", ""], ""]] } forEach (_x getOrDefault ["turrets", []]);
} forEach _newEntries;

// 4. Groups.
private _refsOf = {
    params ["_grp"];
    (_grp getOrDefault ["members", []]) apply { toLower (_x getOrDefault ["ref", ""]) }
};
private _haveGroups = values (_target getOrDefault ["groups", createHashMap]);
private _groupDict = _incoming getOrDefault ["groups", createHashMap];
{
    private _grp = _groupDict getOrDefault [_x, createHashMap];
    if ((count _grp) > 0) then {
        {
            private _ref = _x getOrDefault ["ref", ""];
            if !((_ref select [0, 1]) isEqualTo "#") then { _x set ["ref", _idMap getOrDefault [_ref, ""]] };
        } forEach (_grp getOrDefault ["members", []]);
        _grp set ["members", (_grp getOrDefault ["members", []]) select { !((_x get "ref") isEqualTo "") }];
        private _src = toLower (_grp getOrDefault ["src", ""]);
        private _refs = [_grp] call _refsOf;
        private _at = _haveGroups findIf {
            (!(_src isEqualTo "") && {(toLower (_x getOrDefault ["src", ""])) isEqualTo _src})
            || {(_x getOrDefault ["category", ""]) == (_grp getOrDefault ["category", ""])
                && {(_x getOrDefault ["name", ""]) == (_grp getOrDefault ["name", ""])}
                && {([_x] call _refsOf) isEqualTo _refs}}
        };
        if (_at >= 0) then {
            _skipped = _skipped + 1;
        } else {
            if ((["add", [_grp], _target] call ALiVE_fnc_fsDataGroup) isEqualTo "") then {
                _notes pushBack format ["%1: the faction is full, so it was left out.", _grp getOrDefault ["name", ""]];
            } else {
                _added = _added + 1;
            };
        };
    };
} forEach (_incoming getOrDefault ["groupOrder", keys _groupDict]);

// 5. Old mod names.
private _meta = _target getOrDefault ["meta", createHashMap];
private _legacy = +(_meta getOrDefault ["legacyPatches", []]);
{ if ((count _legacy) < 8) then { _legacy pushBackUnique _x } } forEach ((_incoming getOrDefault ["meta", createHashMap]) getOrDefault ["legacyPatches", []]);
_meta set ["legacyPatches", _legacy];

// 6. Throttled save.
if (_touch) then { ["merge", false] call ALiVE_fnc_fsDataTouch };

[_added, _skipped, _notes]
