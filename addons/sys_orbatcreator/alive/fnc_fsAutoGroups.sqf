#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsAutoGroups);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsAutoGroups

Description:
AUTO GROUPS: makes the groups ALiVE draws from (fireteams, squads, motor patrols,
armour, batteries, aircraft, boats) out of the faction's own men and vehicles,
so a new faction can be placed by ALiVE without building every group by hand.

Each group made here carries its recipe key in "auto" ("inf_squad", "mot_v3").
    "add"     - every recipe whose group is missing is added. A group already
                made for a recipe is left exactly as it is, edited or not, and
                groups made by hand are never touched. A group with the same
                category and the same members in the same order counts as
                made too (an imported export's groups have no auto mark).
    "rebuild" - every group AUTO GROUPS made is deleted first, then "add" runs.

Men by their part (ALiVE_fnc_fsAutoRole); infantry recipes leave out crew,
pilots and special forces, unless there are no other men. Vehicles by kind
(ALiVE_fnc_fsAutoKind), each carrying as many men as it has seats, vehicle first.
Motorized_MTP and Mechanized_MTP are never filled: ALiVE draws them only as a
fallback. A civilian faction gets none.

Parameters:
    _faction - HASHMAP - the studio faction
    _mode    - STRING - "add" or "rebuild"

Returns:
    ARRAY - [added, kept, removed, notes]

Examples:
    (begin example)
    ([missionNamespace getVariable "ALiVE_FS_faction", "add"] call ALiVE_fnc_fsAutoGroups) params ["_added", "_kept"];
    (end)

See Also:
    ALiVE_fnc_fsAutoRole, ALiVE_fnc_fsAutoKind, ALiVE_fnc_fsDataGroup

Author:
    Jman
---------------------------------------------------------------------------- */

#include "\x\alive\addons\sys_orbatcreator\fs_defines.hpp"

params [["_faction", createHashMap, [createHashMap]], ["_mode", "add", [""]]];

private _notes = [];
if ((_faction getOrDefault ["side", 1]) == 3) exitWith { [0, 0, 0, [localize "STR_ALIVE_FS_S_AUTO_CIV"]] };

private _groups = _faction getOrDefault ["groups", createHashMap];

private _removed = 0;
if (_mode isEqualTo "rebuild") then {
    {
        if !(((_groups getOrDefault [_x, createHashMap]) getOrDefault ["auto", ""]) isEqualTo "") then {
            if (["delete", [_x], _faction] call ALiVE_fnc_fsDataGroup) then { _removed = _removed + 1 };
        };
    } forEach +(_faction getOrDefault ["groupOrder", []]);
};

private _made = createHashMap;
{ private _k = _y getOrDefault ["auto", ""]; if !(_k isEqualTo "") then { _made set [_k, true] } } forEach _groups;
// a group already in the faction with the same category and members (in order) counts as made: an imported
// export's groups come back without their auto mark, and making them again would double every category
private _sig = { params ["_category", "_refs"]; _category + "|" + str _refs };
private _have = createHashMap;
{ _have set [[_y getOrDefault ["category", ""], (_y getOrDefault ["members", []]) apply { _x getOrDefault ["ref", ""] }] call _sig, true] } forEach _groups;

// men and their parts
private _units = _faction getOrDefault ["units", createHashMap];
private _men = (_faction getOrDefault ["unitOrder", []]) apply { [_x, [_units get _x] call ALiVE_fnc_fsAutoRole, (_units get _x) getOrDefault ["specOps", false]] };
private _inf = _men select { !((_x select 1) in ["crew", "pilot"]) && {!(_x select 2)} };
if (count _inf == 0) then { _inf = _men };
private _sf = _men select { _x select 2 };

// the first man of a part in a pool, else a rifleman, else the first man
private _pick = {
    params ["_pool", "_role", ["_fallback", true]];
    private _i = _pool findIf { (_x select 1) isEqualTo _role };
    if (_i < 0 && {_fallback}) then { _i = _pool findIf { (_x select 1) isEqualTo "rifleman" } };
    if (_i < 0 && {_fallback}) then { _i = 0 };
    if (_i < 0 || {count _pool == 0}) then { "" } else { (_pool select _i) select 0 }
};
private _has = { params ["_pool", "_role"]; (_pool findIf { (_x select 1) isEqualTo _role }) >= 0 };
private _shape = {
    params ["_pool", "_roles"];
    private _out = [[_pool, "leader"] call _pick];
    { _out pushBack ([_pool, _x] call _pick) } forEach _roles;
    _out select { !(_x isEqualTo "") }
};
private _fireteam = [_inf, ["mg", "at", "rifleman"]] call _shape;
private _squad = [_inf, ["mg", "at", "medic", "marksman", "rifleman", "rifleman", "rifleman"]] call _shape;

// [key, category, name, rarity, member refs]
private _recipes = [];
if (count _inf > 0) then {
    _recipes pushBack ["inf_fireteam", "Infantry", localize "STR_ALIVE_FS_AG_FIRETEAM", 0.5, _fireteam];
    _recipes pushBack ["inf_squad", "Infantry", localize "STR_ALIVE_FS_AG_SQUAD", 0.6, _squad];
    if ([_inf, "mg"] call _has && {[_inf, "at"] call _has}) then {
        _recipes pushBack ["inf_weapons", "Infantry", localize "STR_ALIVE_FS_AG_WEAPONS", 0.3, [_inf, ["mg", "mg", "at", "at", "rifleman"]] call _shape];
    };
    _recipes pushBack ["inf_sentry", "Infantry", localize "STR_ALIVE_FS_AG_SENTRY", 0.3, [[_inf, "rifleman"] call _pick, [_inf, "rifleman"] call _pick]];
};
if (count _sf > 0) then {
    _recipes pushBack ["sf_team", "SpecOps", localize "STR_ALIVE_FS_AG_RECON", 0.4, ([_sf, ["mg", "at", "medic", "marksman", "rifleman", "rifleman", "rifleman"]] call _shape) select [0, 6]];
};
private _vehicles = _faction getOrDefault ["vehicles", createHashMap];
{
    private _id = _x;
    private _veh = _vehicles get _id;
    ([_veh] call ALiVE_fnc_fsAutoKind) params ["_kind", "_seats"];
    private _vname = _veh getOrDefault ["name", _id];
    switch (_kind) do {
        case "carrier_soft": { _recipes pushBack ["mot_" + _id, "Motorized", format [localize "STR_ALIVE_FS_AG_MOTOR", _vname], 0.5, [_id] + (_fireteam select [0, _seats])] };
        case "carrier_armoured": { _recipes pushBack ["mech_" + _id, "Mechanized", format [localize "STR_ALIVE_FS_AG_MECH", _vname], 0.4, [_id] + (_squad select [0, _seats])] };
        case "tank": {
            _recipes pushBack ["arm_" + _id, "Armored", format [localize "STR_ALIVE_FS_AG_ARMOUR", _vname], 0.4, [_id]];
            _recipes pushBack ["arm2_" + _id, "Armored", format [localize "STR_ALIVE_FS_AG_ARMOUR2", _vname], 0.2, [_id, _id]];
        };
        case "artillery": { _recipes pushBack ["art_" + _id, "Artillery", format [localize "STR_ALIVE_FS_AG_BATTERY", _vname], 0.3, [_id, _id]] };
        case "heli";
        case "plane": { _recipes pushBack ["air_" + _id, "Air", format [localize "STR_ALIVE_FS_AG_AIR", _vname], 0.4, [_id]] };
        case "boat": { _recipes pushBack ["nav_" + _id, "Naval", format [localize "STR_ALIVE_FS_AG_BOAT", _vname], 0.4, [_id] + (_fireteam select [0, _seats])] };
        case "support": { _recipes pushBack ["sup_" + _id, "Support", format [localize "STR_ALIVE_FS_AG_SUPPORT", _vname], 0.3, [_id]] };
        default {};
    };
} forEach (_faction getOrDefault ["vehicleOrder", []]);

private _added = 0;
private _kept = 0;
private _autoCount = { !((_x getOrDefault ["auto", ""]) isEqualTo "") } count (values _groups);
private _capped = false;
{
    _x params ["_key", "_category", "_name", "_rarity", "_refs"];
    if (_key in _made || {([_category, _refs] call _sig) in _have}) then {
        _kept = _kept + 1;
    } else {
        if (_autoCount >= FS_MAX_AUTO_GROUPS || {count _groups >= FS_MAX_GROUPS}) then {
            _capped = true;
        } else {
            // the leader a sergeant, the next a corporal, the rest privates
            private _members = [];
            {
                _members pushBack createHashMapFromArray [["ref", _x], ["rank", ["SERGEANT", "CORPORAL", "PRIVATE"] select (_forEachIndex min 2)]];
            } forEach _refs;
            private _entry = createHashMapFromArray [["name", _name select [0, 60]], ["category", _category], ["rarity", _rarity], ["members", _members], ["auto", _key]];
            if !((["add", [_entry], _faction] call ALiVE_fnc_fsDataGroup) isEqualTo "") then {
                _added = _added + 1;
                _autoCount = _autoCount + 1;
            };
        };
    };
} forEach _recipes;
if (_capped) then { _notes pushBack format [localize "STR_ALIVE_FS_S_AUTO_CAP", FS_MAX_AUTO_GROUPS] };

[_added, _kept, _removed, _notes]
