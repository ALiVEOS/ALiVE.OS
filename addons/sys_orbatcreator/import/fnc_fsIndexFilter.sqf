#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsIndexFilter);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsIndexFilter

Description:
Picks rows from the class index (uiNamespace ALiVE_FS_index). The text is
matched with in against the lower-cased display name and the lower-cased class.
Pure: reads the index, changes nothing.

Parameters:
    _text    - STRING - search text, "" for everything
    _faction - STRING - faction class, "" for all factions
    _kind    - NUMBER - 0 men, 1 vehicles, -1 both
    _side    - NUMBER - 0..3, -1 for all sides
    _limit   - NUMBER - most rows returned (the browser passes 500)

Returns:
    ARRAY - [rows, total]: the rows (as ALiVE_fnc_fsIndexBuild), at most _limit,
            and how many matched in all

Examples:
    (begin example)
    (["rifleman", "blu_f", 0, -1, 500] call ALiVE_fnc_fsIndexFilter) params ["_rows", "_total"];
    (end)

See Also:
    ALiVE_fnc_fsIndexBuild

Author:
    Jman
---------------------------------------------------------------------------- */

#include "\x\alive\addons\sys_orbatcreator\fs_defines.hpp"

params [["_text", "", [""]], ["_faction", "", [""]], ["_kind", -1, [0]], ["_side", -1, [0]], ["_limit", 500, [0]]];

private _index = uiNamespace getVariable ["ALiVE_FS_index", createHashMap];
private _rows = _index getOrDefault ["rows", []];
private _numbers = if (_faction isEqualTo "") then { [] } else { (_index getOrDefault ["byFaction", createHashMap]) getOrDefault [toLower _faction, []] };
private _pool = if (_faction isEqualTo "") then { _rows } else { _numbers apply { _rows select _x } };

private _find = toLower _text;
private _out = [];
private _total = 0;
{
    _x params ["_class", "_lowerName", "", "", "_rowSide", "_rowKind"];
    if ((_kind < 0 || {_rowKind == _kind}) && {_side < 0 || {_rowSide == _side}}
        && {_find isEqualTo "" || {_find in _lowerName} || {_find in (toLower _class)}}) then {
        _total = _total + 1;
        if ((count _out) < _limit) then { _out pushBack _x };
    };
} forEach _pool;

[_out, _total]
