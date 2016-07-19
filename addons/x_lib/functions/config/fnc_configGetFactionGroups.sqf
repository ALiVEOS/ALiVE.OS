#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(configGetFactionGroups);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_configGetFactionGroups

Description:
Returns config path of given faction's CfgGroups
searches missionConfigFile before configFile

Parameters:
String - faction

Returns:
Config Path - path to faction config

Examples:
(begin example)
_side = "OPF_F" call ALiVE_fnc_configGetFactionGroups;
(end)

See Also:
- nil

Author:
SpyderBlack723

Peer reviewed:
nil
---------------------------------------------------------------------------- */

private _factionSide = _this call ALiVE_fnc_factionSide;

if (_factionSide == RESISTANCE) then {
    _factionSide = "Indep";
} else {
    _factionSide = str _factionSide;
};

private _path = missionConfigFile >> "CfgGroups" >> _factionSide >> _this;

if !(isClass _path) then {_path = configFile >> "CfgGroups" >> _factionSide >> _this};

_path