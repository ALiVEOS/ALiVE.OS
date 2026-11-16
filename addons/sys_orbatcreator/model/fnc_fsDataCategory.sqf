#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsDataCategory);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsDataCategory

Description:
Adds, renames and deletes the Eden editor categories (subcategories) of a studio
faction. Deleting one moves its units and vehicles to the first category left;
the last category cannot be deleted, since every unit and vehicle needs one.

Parameters:
    _op      - STRING - "add", "rename" or "delete"
    _args    - ARRAY - its arguments
    _faction - HASHMAP - optional, default missionNamespace ALiVE_FS_faction

Operations:
    "add"    - [name]: Returns the new id, or "" (bad name or FS_MAX_CATEGORIES reached).
    "rename" - [id, name]: Returns "" or the problem key (S_TEXT_BAD, S_PASTE_BAD).
    "delete" - [id]: Returns BOOL.

Returns:
    per operation, see above

Examples:
    (begin example)
    private _cid = ["add", ["Recon"]] call ALiVE_fnc_fsDataCategory;
    (end)

See Also:
    ALiVE_fnc_fsDataUnit

Author:
    Jman
---------------------------------------------------------------------------- */

#include "\x\alive\addons\sys_orbatcreator\fs_defines.hpp"

params [["_op", "", [""]], ["_args", [], [[]]], ["_faction", objNull]];

if !(_faction isEqualType createHashMap) then { _faction = missionNamespace getVariable ["ALiVE_FS_faction", createHashMap] };

private _dict = _faction getOrDefault ["categories", createHashMap];
if !("categories" in _faction) then { _faction set ["categories", _dict] };
private _order = _faction getOrDefault ["categoryOrder", []];
if !("categoryOrder" in _faction) then { _faction set ["categoryOrder", _order] };

switch (_op) do {

    case "add": {
        _args params [["_name", "", [""]]];
        if ((count _dict) >= FS_MAX_CATEGORIES || {_name isEqualTo ""} || {!(([_name, "text60"] call ALiVE_fnc_fsDataCheckValue) isEqualTo "")}) then {
            ""
        } else {
            private _id = [_faction, "c"] call ALiVE_fnc_fsDataId;
            _dict set [_id, createHashMapFromArray [["id", _id], ["name", _name]]];
            _order pushBack _id;
            _id
        };
    };

    case "rename": {
        _args params [["_id", "", [""]], ["_name", "", [""]]];
        private _why = [_name, "text60"] call ALiVE_fnc_fsDataCheckValue;
        if (_name isEqualTo "") then { _why = "S_TEXT_BAD" };
        if !(_id in _dict) then { _why = "S_PASTE_BAD" };
        if (_why isEqualTo "") then { (_dict get _id) set ["name", _name] };
        _why
    };

    case "delete": {
        _args params [["_id", "", [""]]];
        if (!(_id in _dict) || {(count _dict) < 2}) then {
            false
        } else {
            _dict deleteAt _id;
            private _left = _order - [_id];
            _faction set ["categoryOrder", _left];
            private _first = _left param [0, (keys _dict) select 0];
            {
                { if ((_y getOrDefault ["category", ""]) isEqualTo _id) then { _y set ["category", _first] } } forEach (_faction getOrDefault [_x, createHashMap]);
            } forEach ["units", "vehicles"];
            true
        };
    };

    default {
        diag_log format ["ALiVE_fnc_fsDataCategory - unknown operation: %1", _op];
        nil
    };
}
