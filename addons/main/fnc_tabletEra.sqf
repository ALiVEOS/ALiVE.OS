#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(tabletEra);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_tabletEra
Description:
    Which tablet artwork this player sees: "modern", "coldwar", "vietnam" or "ww2".

    In order:
    1. the player's own choice in Addon Options > ALiVE > Game (ALiVE_prefTabletEra),
       unless it is Automatic;
    2. the mission's choice on the ALiVE (Required) module (ALiVE_TABLET_MODEL),
       unless it is Automatic. The old Tablet01 (the previous default) counts as
       Automatic and the old Mapbag01 as Vietnam;
    3. by scenario: a S.O.G. Prairie Fire terrain is Vietnam and a Spearhead 1944
       terrain WW2; on any other terrain the player's own soldier decides
       (S.O.G. Vietnam, Spearhead WW2, Global Mobilization or CSLA Cold War); failing
       that a CUP, Global Mobilization or CSLA terrain is Cold War, and anything
       else Modern.

    Terrain and soldier are told apart by the mod folder their config comes from
    (configSourceMod): "vn" for S.O.G., "spe" for Spearhead, "gm" and "csla" for the
    Cold War CDLCs. CUP terrains are told by their defining addon's CUP_ prefix,
    because the folder a Workshop mod sits in is named by the player's launcher.

Parameters:
    None.

Returns:
    STRING - "modern", "coldwar", "vietnam" or "ww2"

Examples:
    (begin example)
    private _era = [] call ALiVE_fnc_tabletEra;
    (end)

See Also:
    ALiVE_fnc_tabletOpen
Author:
    Jman
Peer Reviewed:
    nil
---------------------------------------------------------------------------- */

private _eras = ["modern", "coldwar", "vietnam", "ww2"];

private _pref = toLower (missionNamespace getVariable ["ALiVE_prefTabletEra", "auto"]);
if (_pref in _eras) exitWith { _pref };

private _mission = toLower (missionNamespace getVariable [QMOD(TABLET_MODEL), "auto"]);
if (_mission == "mapbag01") then { _mission = "vietnam" };
if (_mission in _eras) exitWith { _mission };

private _byMod = createHashMapFromArray [["vn", "vietnam"], ["spe", "ww2"], ["gm", "coldwar"], ["csla", "coldwar"]];

// a mod folder or, failing that (Workshop copies and compatibility data sit in folders named by the
// launcher), the class name's own prefix: vn_, SPE_, gm_, CSLA_
private _byPrefix = {
    params ["_name"];
    private _n = toLower _name;
    private _hit = "";
    {
        _x params ["_pre", "_era"];
        if ((_n select [0, count _pre]) == _pre) exitWith { _hit = _era };
    } forEach [["vn_", "vietnam"], ["cam_lao_nam", "vietnam"], ["spe_", "ww2"], ["gm_", "coldwar"], ["csla_", "coldwar"]];
    _hit
};

private _worldCfg = configFile >> "CfgWorlds" >> worldName;
private _terrain = _byMod getOrDefault [toLower configSourceMod _worldCfg, ""];
if (_terrain == "") then { _terrain = [worldName] call _byPrefix };
if (_terrain in ["vietnam", "ww2"]) exitWith { _terrain };

private _unit = "";
if (!isNull player) then {
    _unit = _byMod getOrDefault [toLower configSourceMod (configOf player), ""];
    if (_unit == "") then { _unit = [typeOf player] call _byPrefix };
};
if (_unit != "") exitWith { _unit };

if (_terrain == "") then {
    private _addon = toLower ((configSourceAddonList _worldCfg) param [0, ""]);
    if ((_addon select [0, 4]) == "cup_") then { _terrain = "coldwar" };
};

[_terrain, "modern"] select (_terrain == "")
