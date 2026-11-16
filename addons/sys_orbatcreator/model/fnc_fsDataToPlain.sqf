#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsDataToPlain);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsDataToPlain

Description:
Turns a studio faction (native hashmaps) into its plain form: only strings,
numbers, bools and arrays, the one form used for the profile, the share text and
the data file.

    - a map is an array of [key, value] pairs, in schema order;
    - a dictionary is the list of its maps in list order (the unitOrder,
      vehicleOrder, groupOrder and categoryOrder keys are not written; an entry
      missing from its order list is written after the ordered ones);
    - a raw array (loadout, path, pos, dates) is written as it is, copied.
A key missing from a map is written with its schema default.

Parameters:
    _faction - HASHMAP - the faction
    _spec    - STRING - optional, default "faction"; another spec name writes one
               map of that spec (a unit's identity, a turret, a member)

Returns:
    ARRAY - the plain form

Examples:
    (begin example)
    private _plain = [missionNamespace getVariable "ALiVE_FS_faction"] call ALiVE_fnc_fsDataToPlain;
    (end)

See Also:
    ALiVE_fnc_fsDataFromPlain, ALiVE_fnc_fsDataSchema

Author:
    Jman
---------------------------------------------------------------------------- */

#include "\x\alive\addons\sys_orbatcreator\fs_defines.hpp"

params [["_faction", createHashMap, [createHashMap]], ["_spec", "faction", [""]]];

private _schema = call ALiVE_fnc_fsDataSchema;

private _writeMap = {
    params ["_map", "_spec"];
    if !(_map isEqualType createHashMap) then { _map = createHashMap };
    (_schema getOrDefault [_spec, []]) apply {
        _x params ["_key", "_type", "_default", "_rule", ["_limit", 0], ["_orderKey", ""]];
        private _v = _map getOrDefault [_key, _default];
        private _sub = _type select [2];
        private _pv = switch (_type select [0, 2]) do {
            case "M:": { [_v, _sub] call _writeMap };
            case "L:": {
                if (_v isEqualType []) then { _v apply { [_x, _sub] call _writeMap } } else { [] }
            };
            case "D:": {
                private _dict = if (_v isEqualType createHashMap) then { _v } else { createHashMap };
                private _order = _map getOrDefault [_orderKey, []];
                private _list = [];
                private _seen = createHashMap;
                {
                    if (_x isEqualType "" && {_x in _dict} && {!(_x in _seen)}) then {
                        _seen set [_x, true];
                        _list pushBack ([_dict get _x, _sub] call _writeMap);
                    };
                } forEach _order;
                {
                    if !(_x in _seen) then { _list pushBack ([_y, _sub] call _writeMap) };
                } forEach _dict;
                _list
            };
            default {
                if (_v isEqualType []) then { +_v } else { _v }
            };
        };
        [_key, _pv]
    }
};

[_faction, _spec] call _writeMap
