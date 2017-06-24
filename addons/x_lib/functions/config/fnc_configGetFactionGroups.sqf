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

private _faction = _this;
private _factionSide = _faction call ALiVE_fnc_factionSide;

if (!isnil "ALiVE_factionCustomMappings") then {
    if (_faction in (ALiVE_factionCustomMappings select 1)) then {
        private _factionData = [ALiVE_factionCustomMappings, _faction] call ALiVE_fnc_hashGet;
        _factionSide = [_factionData,"GroupSideName"] call ALiVE_fnc_hashGet;
        _faction = [_factionData,"GroupFactionName"] call ALiVE_fnc_hashGet;
    };
};

if !(_factionSide isEqualType "") then {
    if (_factionSide isEqualTo RESISTANCE) then { _factionSide = "Indep"; } else { _factionSide = str _factionSide; };
} else {
    if (_factionSide == "GUER") then { _factionSide = "Indep"; };
};

private _path = missionConfigFile >> "CfgGroups" >> _factionSide >> _faction;

if !(isClass _path) then {_path = configFile >> "CfgGroups" >> _factionSide >> _faction};

_path