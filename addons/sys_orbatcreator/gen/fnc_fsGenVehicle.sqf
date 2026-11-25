#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsGenVehicle);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsGenVehicle

Description:
The CfgVehicles class of one vehicle. It inherits from its base, or from the
faction's turret stub of that base when a top-level gunner is set. Paint and
parts are config only, so they also apply on a respawn and in Eden:
    - textureList[] = {"<source>",1} for a paint, hiddenSelectionsTextures[]
      for explicit textures;
    - animationList[] for parts (slat armour, camo nets): the base's own list
      with the faction's choices put in at probability 1 (on) or 0 (off). The
      base's init (BIS_fnc_initVehicle) reads both, exactly as for a vehicle
      set up in Eden's Edit Vehicle Appearance. Some mod vehicles never call
      it, so ALiVE_fnc_fsGenConfig also writes an InitPost handler that
      applies the same paint and parts exactly (1 or 0, one paint at weight 1).
    - ALiVE_FS_components[] keeps the choices for a later import.

Parameters:
    _plan    - HASHMAP - from ALiVE_fnc_fsGenPlan
    _faction - HASHMAP - the snapshot
    _id      - STRING - vehicle id

Returns:
    ARRAY - config lines, indented for CfgVehicles

Author:
    Jman
---------------------------------------------------------------------------- */

params [["_plan", createHashMap, [createHashMap]], ["_faction", createHashMap, [createHashMap]], ["_id", "", [""]]];

private _q = { [_this] call ALiVE_fnc_fsGenQuote };
private _a = { [_this] call ALiVE_fnc_fsGenArray };
private _e = (_faction getOrDefault ["vehicles", createHashMap]) getOrDefault [_id, createHashMap];
private _class = (_plan get "classOf") getOrDefault [_id, ""];
private _base = _e getOrDefault ["base", ""];
private _baseCfg = configFile >> "CfgVehicles" >> _base;
private _tag = _plan get "tag";
private _crew = (_plan get "crewOf") getOrDefault [_id, ""];
private _i = "        ";

private _lines = [
    format ["    class %1 : %2 {", _class, (_plan get "parentOf") getOrDefault [_id, _base]],
    _i + "author = " + ((_faction getOrDefault ["author", ""]) call _q) + ";",
    _i + "scope = 2;",
    _i + "scopeCurator = 2;",
    _i + "displayName = " + ((_e getOrDefault ["name", _class]) call _q) + ";",
    _i + "side = " + ((_faction getOrDefault ["side", 1]) toFixed 0) + ";",
    _i + "faction = " + ((_faction getOrDefault ["class", _tag]) call _q) + ";",
    _i + "editorSubcategory = " + (((_plan get "subOf") getOrDefault [_e getOrDefault ["category", ""], ""]) call _q) + ";"
];
if !(_crew isEqualTo "") then {
    _lines pushBack (_i + "crew = " + (_crew call _q) + ";");
    _lines pushBack (_i + "typicalCargo[] = " + ([_crew] call _a) + ";");
};
private _texture = _e getOrDefault ["texture", ""];
if !(_texture isEqualTo "") then { _lines pushBack (_i + "textureList[] = " + ([_texture, 1] call _a) + ";") };
private _textures = _e getOrDefault ["textures", []];
if (count _textures > 0) then { _lines pushBack (_i + "hiddenSelectionsTextures[] = " + (_textures call _a) + ";") };
private _markingsOff = _e getOrDefault ["markingsOff", []];
if (count _markingsOff > 0) then { _lines pushBack (_i + "ALiVE_FS_markingsOff[] = " + (_markingsOff call _a) + ";") };
// the Init Code as typed, one string per line so its comments and line breaks come back on import; it runs from
// the CBA InitPost entry (ALiVE_fnc_fsGenConfig)
private _initCode = _e getOrDefault ["initCode", ""];
if !(_initCode isEqualTo "") then {
    private _codeLines = (_initCode splitString (toString [13])) joinString "";
    _lines pushBack (_i + "ALiVE_FS_initCode[] = {" + (((_codeLines splitString (toString [10])) apply { _x call _q }) joinString ", ") + "};");
};

private _components = (_e getOrDefault ["components", []]) apply { [_x getOrDefault ["source", ""], _x getOrDefault ["value", 0]] } select { !((_x select 0) isEqualTo "") };
if (count _components > 0) then {
    // the base's list as [source, probability] pairs, with the faction's choices put in
    private _list = getArray (_baseCfg >> "animationList");
    private _pairs = [];
    for "_k" from 0 to (count _list) - 2 step 2 do { _pairs pushBack [_list select _k, _list select (_k + 1)] };
    {
        _x params ["_source", "_value"];
        private _at = _pairs findIf { (toLower (_x select 0)) == toLower _source };
        if (_at < 0) then { _pairs pushBack [_source, _value] } else { _pairs set [_at, [_pairs select _at select 0, _value]] };
    } forEach _components;
    private _flat = [];
    { _flat append [_x select 0, [0, 1] select ((_x select 1) > 0.5)] } forEach _pairs;
    _lines pushBack (_i + "animationList[] = " + (_flat call _a) + ";");
    _lines pushBack (_i + "ALiVE_FS_components[] = " + (_components call _a) + ";");
};
// cargo: Empty writes the four Transport classes empty, This list writes exactly the list (a kind with nothing
// in it is written empty too, so none of the base's cargo comes through); As the base vehicle writes nothing
private _cargoMode = _e getOrDefault ["cargoMode", 0];
if (_cargoMode > 0) then {
    private _cargo = if (_cargoMode == 2) then { _e getOrDefault ["cargo", []] } else { [] };
    _lines append ([_cargo, _i] call ALiVE_fnc_fsGenCargo);
};
// on a stub: every turret and pylon it declares, written again with the gunners and pylons set (ALiVE_fnc_fsGenTree)
private _tree = (_plan getOrDefault ["stubTreeOf", createHashMap]) getOrDefault [_id, []];
if (count _tree == 2) then { _lines append ([_tree select 0, 99, _tree select 1, _i] call ALiVE_fnc_fsGenTree) };
_lines append [
    _i + "ALiVE_FS_owned = 1;",
    _i + "ALiVE_FS_stub = 0;",
    _i + "ALiVE_FS_tag = " + (_tag call _q) + ";",
    "    };"
];
_lines
