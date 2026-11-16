#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsDataId);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsDataId

Description:
Gives out the next id of a studio faction: one counter, meta.counter, serves
units, vehicles, groups and categories, so an id is never given out twice.

Parameters:
    _faction - HASHMAP - the faction
    _letter  - STRING - "u" unit, "v" vehicle, "g" group, "c" category

Returns:
    STRING - the new id, e.g. "u12"

Examples:
    (begin example)
    private _id = [_faction, "u"] call ALiVE_fnc_fsDataId;
    (end)

See Also:
    ALiVE_fnc_fsDataUnit, ALiVE_fnc_fsDataGroup, ALiVE_fnc_fsDataCategory

Author:
    Jman
---------------------------------------------------------------------------- */

#include "\x\alive\addons\sys_orbatcreator\fs_defines.hpp"

params [["_faction", createHashMap, [createHashMap]], ["_letter", "u", [""]]];

private _meta = _faction getOrDefault ["meta", createHashMap];
if !("meta" in _faction) then { _faction set ["meta", _meta] };

private _n = (_meta getOrDefault ["counter", 0]) + 1;
_meta set ["counter", _n];

_letter + (_n toFixed 0)
