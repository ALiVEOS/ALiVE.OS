#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsGenMan);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsGenMan

Description:
The CfgVehicles class of one man. He inherits straight from his real base: no
stub and no EventHandlers class, since the loadout is applied by the CBA XEH
handlers written by ALiVE_fnc_fsGenConfig. The class arrays (weapons,
magazines, items, linkedItems) and the generated backpack let Eden and Zeus
show him dressed; the exact loadout is in ALiVE_FS_loadout[].
engineer, canDeactivateMines, attendant and uavHacker are written only when
Engineer, EOD, Medic or UAV Hacker was set on the Units tab to differ from his
base class, so he can repair, clear mines, heal and hack drones whatever he
inherits from.

Parameters:
    _plan    - HASHMAP - from ALiVE_fnc_fsGenPlan
    _faction - HASHMAP - the snapshot
    _id      - STRING - unit id

Returns:
    ARRAY - config lines, indented for CfgVehicles

Author:
    Jman
---------------------------------------------------------------------------- */

params [["_plan", createHashMap, [createHashMap]], ["_faction", createHashMap, [createHashMap]], ["_id", "", [""]]];

private _q = { [_this] call ALiVE_fnc_fsGenQuote };
private _a = { [_this] call ALiVE_fnc_fsGenArray };
private _e = (_faction getOrDefault ["units", createHashMap]) getOrDefault [_id, createHashMap];
private _class = (_plan get "classOf") getOrDefault [_id, ""];
private _tag = _plan get "tag";
private _options = _faction getOrDefault ["options", createHashMap];
private _identity = _e getOrDefault ["identity", createHashMap];
private _fixed = _identity getOrDefault ["fixed", false];
private _la = [_e getOrDefault ["loadout", []]] call ALiVE_fnc_fsGenLoadoutArrays;
private _pack = (_plan get "packOf") getOrDefault [_id, _la get "backpack"];
private _i = "        ";

private _lines = [
    format ["    class %1 : %2 {", _class, _e getOrDefault ["base", ""]],
    _i + "author = " + ((_faction getOrDefault ["author", ""]) call _q) + ";",
    _i + "scope = 2;",
    _i + "scopeCurator = 2;",
    _i + "displayName = " + ((_e getOrDefault ["name", _class]) call _q) + ";",
    _i + "side = " + ((_faction getOrDefault ["side", 1]) toFixed 0) + ";",
    _i + "faction = " + ((_faction getOrDefault ["class", _tag]) call _q) + ";",
    _i + "editorSubcategory = " + (((_plan get "subOf") getOrDefault [_e getOrDefault ["category", ""], ""]) call _q) + ";"
];
// Engineer, EOD, Medic and UAV Hacker: -1 leaves the base class's value
{
    _x params ["_key", "_prop"];
    private _v = _e getOrDefault [_key, -1];
    if (_v isEqualType 0 && {_v >= 0}) then { _lines pushBack (_i + _prop + " = " + ((_v min 1) toFixed 0) + ";") };
} forEach [["engineer", "engineer"], ["eod", "canDeactivateMines"], ["medic", "attendant"], ["uavHacker", "uavHacker"]];
private _types = _identity getOrDefault ["types", []];
if (count _types > 0) then { _lines pushBack (_i + "identityTypes[] = " + (_types call _a) + ";") };
if !((_la get "uniform") isEqualTo "") then { _lines pushBack (_i + "uniformClass = " + ((_la get "uniform") call _q) + ";") };
_lines pushBack (_i + "backpack = " + (_pack call _q) + ";");
{
    private _list = (_la get _x) call _a;
    _lines pushBack (_i + _x + "[] = " + _list + ";");
    _lines pushBack (_i + "respawn" + (toUpper (_x select [0, 1])) + (_x select [1]) + "[] = " + _list + ";");
} forEach ["weapons", "magazines", "items", "linkedItems"];
_lines append [
    _i + "ALiVE_FS_owned = 1;",
    _i + "ALiVE_FS_tag = " + (_tag call _q) + ";",
    _i + "ALiVE_FS_rt = 1;",
    _i + "ALiVE_FS_noRandom = " + (["0", "1"] select (_options getOrDefault ["noRandom", true])) + ";",
    _i + "ALiVE_FS_force = " + (["0", "1"] select (_options getOrDefault ["force", false])) + ";",
    _i + "ALiVE_FS_loadout[] = " + ((_e getOrDefault ["loadout", []]) call _a) + ";",
    // the gear pools he wears that have items (class ALiVE_FS_Pools_<tag>)
    _i + "ALiVE_FS_pools[] = " + (((_e getOrDefault ["pools", []]) select { count (((_faction getOrDefault ["pools", createHashMap]) getOrDefault [_x, createHashMap]) getOrDefault ["entries", []]) > 0 }) call _a) + ";",
    _i + "ALiVE_FS_insignia = " + ((_identity getOrDefault ["insignia", ""]) call _q) + ";",
    _i + "ALiVE_FS_face = " + (([_identity getOrDefault ["face", ""], ""] select !_fixed) call _q) + ";",
    _i + "ALiVE_FS_speaker = " + (([_identity getOrDefault ["speaker", ""], ""] select !_fixed) call _q) + ";",
    "    };"
];
_lines
