#include "\x\alive\addons\fnc_analysis\script_component.hpp"
SCRIPT(indexTerrainMenu);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_indexTerrainMenu

Description:
Sets up the "Index this terrain" entry under ALiVE in the editor's top menu
for the terrain that is open.

The entry itself is config (fnc_analysis/config.cpp), greyed by default and
pointing at the bare index page. This finds it in the menu, works out which
Workshop item the terrain comes from and whether ALiVE already carries an
index for it, then:
  - Workshop terrain, no index:            "Index this terrain", enabled
  - Workshop terrain, index older than 3.1: "Re-index this terrain", enabled
  - Workshop terrain, index 3.1 or later:  "(already indexed, vX)", greyed
  - not a Workshop terrain (base game,
    Creator DLC, a local unpublished mod): "(Workshop terrains only)", greyed
When enabled, the link carries the Workshop id and the terrain name, which
the index page reads to fill its form in.

Registered in CfgFunctions, and inline-compiled in main/XEH_preInit.sqf as
well, because pure Eden has no CfgFunctions postInit. A loop started there runs
it each time the editor display is built (launch, terrain switch, back from
preview). Cheap and safe to run again, so it has no latch. Every run writes
one RPT line with everything it decided on.

Parameters: none

Returns: nothing

Author:
Jman
---------------------------------------------------------------------------- */

if (!is3DEN || {is3DENPreview}) exitWith {
    ["ALiVE Index terrain menu: not in the editor (or in preview), exiting."] call ALiVE_fnc_dump;
};

// -------------------------------------------------------------------
// 1. The menu entry. The top menu is control 120 on the editor display.
// Called from a spawn, so it can wait for the editor to finish building
// it; uiSleep because mission time does not move in the editor.
// -------------------------------------------------------------------
private _ctrl = (findDisplay 313) displayCtrl 120;
if (isNull _ctrl && {canSuspend}) then {
    private _giveUpAt = diag_tickTime + 30;
    waitUntil {
        uiSleep 1;
        _ctrl = (findDisplay 313) displayCtrl 120;
        !isNull _ctrl || {diag_tickTime > _giveUpAt}
    };
};
if (isNull _ctrl) exitWith {
    ["ALiVE Index terrain menu: world=%1, the editor's top menu was not found, entry left greyed.", worldName] call ALiVE_fnc_dump;
};

private _path = [];
for "_i" from 0 to ((_ctrl menuSize []) - 1) do {
    for "_j" from 0 to ((_ctrl menuSize [_i]) - 1) do {
        if ((_ctrl menuData [_i, _j]) isEqualTo "ALIVE_IndexTerrain") then {
            _path = [_i, _j];
        };
    };
};
if (_path isEqualTo []) exitWith {
    ["ALiVE Index terrain menu: world=%1, path=[], the entry was not found in the top menu, left greyed.", worldName] call ALiVE_fnc_dump;
};

// -------------------------------------------------------------------
// 2. Which mod folder the terrain comes from. configSourceAddonList
// names the addons that define the world class; the first is taken
// as the one that defines it, and its folder wins over
// configSourceMod on the world, which can name a mod that only
// patches it. Both are logged so a disagreement shows.
// -------------------------------------------------------------------
private _worldCfg = configFile >> "CfgWorlds" >> worldName;
private _worldMod = configSourceMod _worldCfg;
private _addons = configSourceAddonList _worldCfg;
private _definerMod = "";
if (count _addons > 0) then {
    _definerMod = configSourceMod (configFile >> "CfgPatches" >> (_addons select 0));
};
// The world's own source is the fallback when the definer's folder
// cannot be read, so a missing CfgPatches class does not lose the id.
private _mod = if (_definerMod != "") then { _definerMod } else { _worldMod };

// -------------------------------------------------------------------
// 3. Workshop id. Element 1 of a getLoadedModsInfo row is the folder
// (joins with configSourceMod), element 3 is true for an official
// Creator DLC, element 7 is the Steam published file id, "0" for a
// mod not from the Workshop (sys_presets/fnc_presetAddons.sqf,
// measured 2026-09-21).
// -------------------------------------------------------------------
private _row = [];
if (_mod != "") then {
    private _low = toLower _mod;
    private _loaded = getLoadedModsInfo;
    private _at = _loaded findIf { (toLower (_x param [1, ""])) isEqualTo _low };
    if (_at >= 0) then { _row = _loaded select _at };
};
private _id = _row param [7, "0"];
if !(_id isEqualType "") then { _id = str _id };
private _isDLC = _row param [3, false];
private _hasWorkshop = _mod != "" && {!_isDLC} && {_id != "0"} && {_id != ""} && {parseNumber _id > 0};

// -------------------------------------------------------------------
// 4. Whether ALiVE carries an index, and which format. Same read as
// fnc_assessIndexViability.sqf: the static data file's
// ALiVE_indexVersion line; an index without one predates 3.1.
// -------------------------------------------------------------------
private _staticText = loadFile format ["\x\alive\addons\main\static\%1_staticData.sqf", worldName];
private _indexed = _staticText != "" || {fileExists format ["\x\alive\addons\fnc_analysis\data\data.%1.sqf", toLower worldName]};
private _version = "";
private _versionAt = _staticText find "ALiVE_indexVersion";
if (_versionAt >= 0) then {
    private _quoted = (_staticText select [_versionAt, 80]) splitString """";
    if (count _quoted > 1) then { _version = _quoted select 1 };
};
private _versionParts = (_version splitString ".") apply { parseNumber _x };
private _measured = (count _versionParts >= 2) && {
    ((_versionParts select 0) > 3) || {((_versionParts select 0) == 3) && {(_versionParts select 1) >= 1}}
};

// -------------------------------------------------------------------
// 5. What the entry says and whether it can be clicked. The Workshop
// test comes first, so a base game terrain greys for that reason
// even though ALiVE indexes it.
// -------------------------------------------------------------------
private _state = switch (true) do {
    case (!_hasWorkshop):         { ["workshop_only", localize "STR_ALIVE_INDEX_TERRAIN_WORKSHOP_ONLY", false] };
    case (_indexed && _measured): { ["done", format [localize "STR_ALIVE_INDEX_TERRAIN_DONE", _version], false] };
    case (_indexed):              { ["reindex", localize "STR_ALIVE_INDEX_TERRAIN_REINDEX", true] };
    default                       { ["index", localize "STR_ALIVE_INDEX_TERRAIN", true] };
};
_state params ["_stateName", "_text", "_enabled"];

// -------------------------------------------------------------------
// 6. Apply. No encoding needed: worldName is a config class name and
// the id is digits.
// -------------------------------------------------------------------
private _url = format ["https://www.alivemod.com/public/alive3/index_terrain.htm?workshop=%1&world=%2", _id, worldName];
_ctrl menuSetText [_path, _text];
_ctrl menuEnable [_path, _enabled];
if (_enabled) then {
    _ctrl menuSetURL [_path, _url];
};

["ALiVE Index terrain menu: world=%1 mod=%2 worldMod=%3 addons=%4 id=%5 dlc=%6 version=%7 indexed=%8 state=%9 path=%10 url=%11",
    worldName, _mod, _worldMod, _addons, _id, _isDLC, _version, _indexed, _stateName, _path, [_url, ""] select (!_enabled)
] call ALiVE_fnc_dump;
