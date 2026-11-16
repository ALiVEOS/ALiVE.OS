#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsDataFromPlain);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsDataFromPlain

Description:
Turns a plain form back into a studio faction. The schema walk is the validator:
the reader is driven by the schema table, never by the shape of the data.

For every map: it must be an array of two-element arrays whose first element is
a string (only then createHashMapFromArray), then for every schema row the value
or the default is taken, its type checked and its rule run.
    - a missing key takes its default (this is what lets a newer build add keys);
    - an unknown key is dropped and counted in the notes;
    - a wrong type, a failed rule or a broken limit is a problem: the whole
      faction is refused;
    - dangling references (a member, crew or gunner id that does not exist, a
      category id that does not exist) are repaired and noted, not refused;
    - meta.counter is raised to the highest id number in use, with a note;
    - class names that are not loaded here (base, crew, gunner, outside group
      members, loadout gear) are kept and listed in the notes.

Parameters:
    _plain - ARRAY - the plain form (already migrated to FS_SCHEMA)
    _spec  - STRING - optional, default "faction". Another spec name ("identity",
             "turret", "member", ...) walks one map of that spec only, with no
             repairs and no notes; the edit operations use it to check a value.

Returns:
    ARRAY - [ok, faction, problems, notes]
        ok       - BOOL
        faction  - HASHMAP, empty when refused
        problems - ARRAY of [key, detail]; key is "S_PASTE_BAD", detail a short
                   English place and reason (at most 20 are listed)
        notes    - ARRAY of STRING

Examples:
    (begin example)
    ([_plain] call ALiVE_fnc_fsDataFromPlain) params ["_ok", "_faction", "_problems", "_notes"];
    (end)

See Also:
    ALiVE_fnc_fsDataToPlain, ALiVE_fnc_fsDataSchema, ALiVE_fnc_fsDataCheckValue

Author:
    Jman
---------------------------------------------------------------------------- */

#include "\x\alive\addons\sys_orbatcreator\fs_defines.hpp"

params [["_plain", [], [[]]], ["_spec", "faction", [""]]];

private _schema = call ALiVE_fnc_fsDataSchema;
private _problems = [];
private _notes = [];
private _unknown = 0;

private _bad = {
    params ["_where", "_why"];
    if ((count _problems) < 20) then { _problems pushBack ["S_PASTE_BAD", format ["%1: %2", _where, _why]] };
};

// A value that is a list (LS, L:, D:) within its limit.
private _isList = {
    params ["_v", "_limit"];
    _v isEqualType [] && {_limit <= 0 || {(count _v) <= _limit}}
};

private _readMap = {
    params ["_value", "_spec", "_where"];
    private _isMap = !(isNil "_value") && {_value isEqualType []} && {(count _value) <= 100} && {
        (_value findIf { (isNil "_x") || {!(_x isEqualType [])} || {(count _x) != 2} || {isNil {_x select 0}} || {!((_x select 0) isEqualType "")} }) < 0
    };
    private _out = createHashMap;
    if (!_isMap) then {
        [_where, "not a map"] call _bad;
    } else {
        private _in = createHashMapFromArray _value;
        private _rows = _schema getOrDefault [_spec, []];
        private _known = _rows apply { _x select 0 };
        { if !(_x in _known) then { _unknown = _unknown + 1 }; } forEach (keys _in);
        {
            _x params ["_key", "_type", "_default", "_rule", ["_limit", 0], ["_orderKey", ""], ["_letter", ""]];
            private _at = format ["%1.%2", _where, _key];
            private _v = if (_key in _in) then { _in get _key } else { if (_default isEqualType []) then { +_default } else { _default } };
            // A nil value is a type problem; the default stands in so the walk can go on.
            if (isNil "_v") then {
                [_at, "no value"] call _bad;
                _v = if (_default isEqualType []) then { +_default } else { _default };
            };
            private _sub = _type select [2];
            switch (_type select [0, 2]) do {
                case "B": {
                    if !(_v isEqualType true) then { [_at, "not true or false"] call _bad };
                    _out set [_key, _v];
                };
                case "LS": {
                    if (!([_v, _limit] call _isList) || {(_v findIf { !(([_x, _rule] call ALiVE_fnc_fsDataCheckValue) isEqualTo "") }) >= 0}) then {
                        [_at, "not a list of allowed names"] call _bad;
                        _v = [];
                    };
                    _out set [_key, +_v];
                };
                case "M:": {
                    _out set [_key, [_v, _sub, _at] call _readMap];
                };
                case "L:": {
                    private _list = [];
                    if !([_v, _limit] call _isList) then {
                        [_at, "not a list, or too many entries"] call _bad;
                    } else {
                        { _list pushBack ([_x, _sub, format ["%1[%2]", _at, _forEachIndex toFixed 0]] call _readMap) } forEach _v;
                    };
                    _out set [_key, _list];
                };
                case "D:": {
                    private _dict = createHashMap;
                    private _order = [];
                    if !([_v, _limit] call _isList) then {
                        [_at, "not a list, or too many entries"] call _bad;
                    } else {
                        {
                            private _entry = [_x, _sub, format ["%1[%2]", _at, _forEachIndex toFixed 0]] call _readMap;
                            private _id = _entry getOrDefault ["id", ""];
                            if (_id isEqualType "" && {!(_id isEqualTo "")}) then {
                                if (!((_id select [0, 1]) isEqualTo _letter) || {_id in _dict}) then {
                                    [format ["%1[%2]", _at, _forEachIndex toFixed 0], "id missing, repeated or of the wrong kind"] call _bad;
                                } else {
                                    _dict set [_id, _entry];
                                    _order pushBack _id;
                                };
                            };
                        } forEach _v;
                    };
                    _out set [_key, _dict];
                    _out set [_orderKey, _order];
                };
                default {
                    // S, N and A: one rule each.
                    private _why = [_v, _rule] call ALiVE_fnc_fsDataCheckValue;
                    if !(_why isEqualTo "") then { [_at, _why] call _bad };
                    // Copied, so the faction never shares an array with the profile
                    // variable or the plain form it was read from.
                    _out set [_key, if (_v isEqualType []) then { +_v } else { _v }];
                };
            };
        } forEach _rows;
    };
    _out
};

private _faction = [_plain, _spec, _spec] call _readMap;

if ((count _problems) > 0) exitWith { [false, createHashMap, _problems, []] };

// One map of another spec (a unit's identity, a turret, a member): the walk only,
// with no faction-wide repairs.
if !(_spec isEqualTo "faction") exitWith { [true, _faction, [], []] };

if (_unknown > 0) then { _notes pushBack format ["%1 unknown key(s) were dropped.", _unknown toFixed 0] };

_faction set ["schema", FS_SCHEMA];

private _categories = _faction get "categories";
private _units = _faction get "units";
private _vehicles = _faction get "vehicles";
private _groups = _faction get "groups";
private _meta = _faction get "meta";

// The id counter must stay above every id in use, or the next new entry would
// take an id that already exists. An id past 999999 is refused: the counter could
// not stay above it.
private _top = 0;
{
    { _top = _top max (parseNumber (_x select [1])) } forEach (keys _x);
} forEach [_categories, _units, _vehicles, _groups];
if (_top > 999999) exitWith { [false, createHashMap, [["S_PASTE_BAD", "faction: an id number is over 999999"]], []] };
if ((_meta get "counter") < _top) then {
    _meta set ["counter", _top];
    _notes pushBack format ["The id counter was raised to %1.", _top toFixed 0];
};

// Units and vehicles need a category to sit in.
if ((count _categories) == 0 && {(count _units) + (count _vehicles) > 0}) then {
    private _n = (_meta get "counter") + 1;
    _meta set ["counter", _n];
    private _cid = "c" + (_n toFixed 0);
    _categories set [_cid, createHashMapFromArray [["id", _cid], ["name", "Infantry"]]];
    _faction set ["categoryOrder", [_cid]];
    _notes pushBack "The faction had no editor category, so one was added.";
};
private _firstCat = (_faction get "categoryOrder") param [0, ""];

{
    private _unit = _y;
    if !((_unit get "category") in _categories) then {
        _unit set ["category", _firstCat];
        _notes pushBack format ["%1 was moved to the first editor category.", _unit get "id"];
    };
} forEach _units;

{
    private _veh = _y;
    if (!((_veh get "category") in _categories)) then {
        _veh set ["category", _firstCat];
        _notes pushBack format ["%1 was moved to the first editor category.", _veh get "id"];
    };
    if (!((_veh get "crewUnit") isEqualTo "") && {!((_veh get "crewUnit") in _units)}) then {
        _notes pushBack format ["%1: crew %2 does not exist, set back to the crew of the base vehicle.", _veh get "id", _veh get "crewUnit"];
        _veh set ["crewUnit", ""];
    };
    {
        if (!((_x get "gunnerUnit") isEqualTo "") && {!((_x get "gunnerUnit") in _units)}) then {
            _notes pushBack format ["%1: gunner %2 does not exist, set back to the gunner of the base vehicle.", _veh get "id", _x get "gunnerUnit"];
            _x set ["gunnerUnit", ""];
        };
    } forEach (_veh get "turrets");
} forEach _vehicles;

{
    private _grp = _y;
    private _kept = (_grp get "members") select {
        private _ref = _x get "ref";
        ((_ref select [0, 1]) isEqualTo "#") || {_ref in _units} || {_ref in _vehicles}
    };
    if ((count _kept) != (count (_grp get "members"))) then {
        _notes pushBack format ["%1: %2 member(s) that do not exist were dropped.", _grp get "id", ((count (_grp get "members")) - (count _kept)) toFixed 0];
        _grp set ["members", _kept];
    };
} forEach _groups;

// Class names that are not loaded here: kept, listed once each.
private _names = createHashMap;
private _gather = {
    params ["_a"];
    {
        if (_x isEqualType "") then {
            _names set [toLower _x, _x];
        } else {
            if (_x isEqualType []) then { [_x] call _gather };
        };
    } forEach _a;
};
{
    _names set [toLower (_y get "base"), _y get "base"];
    [_y get "loadout"] call _gather;
} forEach _units;
{
    _names set [toLower (_y get "base"), _y get "base"];
    _names set [toLower (_y get "crewClass"), _y get "crewClass"];
    { _names set [toLower (_x get "gunnerClass"), _x get "gunnerClass"] } forEach (_y get "turrets");
} forEach _vehicles;
{
    {
        private _ref = _x get "ref";
        if ((_ref select [0, 1]) isEqualTo "#") then { _names set [toLower (_ref select [1]), _ref select [1]] };
    } forEach (_y get "members");
} forEach _groups;
_names deleteAt "";
{
    private _c = _y;
    private _loaded = isClass (configFile >> "CfgVehicles" >> _c) || {isClass (configFile >> "CfgWeapons" >> _c)}
        || {isClass (configFile >> "CfgMagazines" >> _c)} || {isClass (configFile >> "CfgGlasses" >> _c)};
    if (!_loaded) then { _notes pushBack format ["Not loaded here: %1", _c] };
} forEach _names;

[true, _faction, [], _notes]
