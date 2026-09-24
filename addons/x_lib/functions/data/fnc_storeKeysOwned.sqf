#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(storeKeysOwned);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_storeKeysOwned

Description:
Every saved-data variable in profileNamespace that belongs to this mission on
this map, and what the move to per-map saves and Clear Current Mission's Data
each do with it. Both use this one list, so they always agree.

Every name is built, never searched for: allVariables returns nothing for
profileNamespace on a dedicated server. The names only a module can work out
at run time, such as an air commander's own key, come from the parts modules
pass to ALiVE_fnc_storeMigrate as they start.

Modes:
"self"  - already kept under this map's name. Clear removes it; the move
          leaves it alone.
"move"  - an old name, all of it this mission's. The move takes it to <to>
          and removes it; Clear removes it.
"slots" - an old name with the map joined on by an underscore, written by the
          mission date and player saves since May 2026. Only its sys_data and
          sys_player slots are this mission's, because the same name is a whole
          old save for a mission called <mission>_<map>. The move takes those
          two slots to <to>; Clear strips them.
"clear" - old custom-variable dictionaries, which the local backend never reads
          back. Clear removes them; the move ignores them.

Names alone cannot tell this mission from one whose name is this one's plus
_<map>, or the other way round; the modes take this mission's reading.

Only names that exist are returned, each once.

Parameters:
none

Returns:
Array - [[name, to, mode], ...]

See Also:
ALiVE_fnc_storeKeys, ALiVE_fnc_storeMigrate, ALiVE_fnc_ProfileNameSpaceClear

Author:
Jman
---------------------------------------------------------------------------- */

private _base = ([""] call ALiVE_fnc_storeKeys) select 0;

// The parts of save names that only a module can build, passed to
// ALiVE_fnc_storeMigrate as each module starts.
private _suffixes = missionNamespace getVariable ["ALiVE_storeSuffixes", []];

// Old names used the mission name with "%20" turned into "-" for the module
// saves, and as it came for the mission date saves, so both spellings are
// looked for when they differ.
private _missions = [[missionName, "%20", "-"] call CBA_fnc_replace];
_missions pushBackUnique missionName;

private _result = [];
private _seen = [];

private _fnc_add = {
    params ["_name", "_to", "_mode"];
    if ((toLower _name) in _seen) exitWith {};
    if (isNil {profileNamespace getVariable _name}) exitWith {};
    _seen pushBack (toLower _name);
    _result pushBack [_name, _to, _mode];
};

// A dictionary too big for one variable was written in parts: the name itself,
// then _1, _2 and on with no gaps. So the parts are counted up to the first one
// missing.
private _fnc_addDictionary = {
    params ["_name", "_mode"];
    [_name, "", _mode] call _fnc_add;
    private _i = 1;
    while {!isNil {profileNamespace getVariable format ["%1_%2", _name, _i]}} do {
        [format ["%1_%2", _name, _i], "", _mode] call _fnc_add;
        _i = _i + 1;
    };
};

// This map's names first, so nothing below can list one of them twice. A fixed
// suffix any module saves under belongs in this list and in the one below.
{
    [_base + _x, "", "self"] call _fnc_add;
} forEach (["", "_DATA", "_COMPOSITIONS", "_TASK", "_FORCE_POOL", "_ATO"] + _suffixes);
["dictionary_" + _base, "self"] call _fnc_addDictionary;

// Then the old names.
{
    private _old = format ["%1_%2", ALIVE_sys_data_GROUP_ID, _x];
    private _oldWorld = format ["%1_%2", _old, worldName];

    // The names with the map after an underscore first. They only exist since May
    // 2026, so they are always newer than the same saves in the names without the
    // map, and ALiVE_fnc_storeMigrate keeps whichever it meets first. The other way
    // round, a campaign played before and after May would lose its current mission
    // date and player saves to the older ones.
    [_oldWorld, _base + "_DATA", "slots"] call _fnc_add;
    [_oldWorld + "_COMPOSITIONS", _base + "_COMPOSITIONS", "move"] call _fnc_add;
    // The whole old module base. ALiVE_fnc_storeMigrate sends its sys_data and
    // sys_player slots to _DATA and the rest to the base.
    [_old, _base, "move"] call _fnc_add;
    {
        [_old + _x, _base + _x, "move"] call _fnc_add;
    } forEach (["_TASK", "_FORCE_POOL", "_ATO", "_COMPOSITIONS"] + _suffixes);
    // The old dictionary without the map is taken on its own: its numbered parts
    // would share their names with another mission's, one called <mission>_1.
    ["dictionary_" + _old, "", "clear"] call _fnc_add;
    ["dictionary_" + _oldWorld, "clear"] call _fnc_addDictionary;
} forEach _missions;

_result
