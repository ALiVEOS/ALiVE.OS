#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(factionIsVanilla);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_factionIsVanilla

Description:
True when a faction is defined by the game itself (the base game or an official
expansion), so falling back to the game's default lists is not a gap for it.
Creator DLC factions and mods count as not vanilla. Answers are cached.

Parameters:
String - faction class name

Returns:
Bool - also true for a faction that is not loaded, so nothing is reported for it

Examples:
(begin example)
["OPF_F"] call ALiVE_fnc_factionIsVanilla; // true
(end)

See Also:
- ALiVE_fnc_reportVanillaFallback
- ALiVE_fnc_listVanillaFallbacks

Author:
Jman
---------------------------------------------------------------------------- */

params [["_faction", "", [""]]];

if (isNil "ALiVE_factionIsVanillaCache") then { ALiVE_factionIsVanillaCache = createHashMap };

private _key = toLower _faction;
private _known = ALiVE_factionIsVanillaCache get _key;
if (!isNil "_known") exitWith { _known };

private _config = configFile >> "CfgFactionClasses" >> _faction;
private _vanilla = !isClass _config || {
    ((configSourceAddonList _config) findIf { ((toLower _x) select [0, 3]) == "a3_" }) != -1
};

ALiVE_factionIsVanillaCache set [_key, _vanilla];
_vanilla
