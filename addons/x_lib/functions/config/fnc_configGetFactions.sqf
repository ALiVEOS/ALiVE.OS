#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(configGetFactions);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_configGetFactions

Description:
Returns all config factions
checks configFile and missionConfigFile

Parameters:
None

Returns:
Array - All factions

Examples:
(begin example)
_side = [] call ALiVE_fnc_configGetFactions;
(end)

See Also:
- nil

Author:
SpyderBlack723

Peer reviewed:
nil
---------------------------------------------------------------------------- */

private ["_faction"];

private _factions = [];

private _configPaths = [
    missionConfigFile >> "CfgFactionClasses",
    configFile >> "CfgFactionClasses"
];

{
    _configPath = _x;

    for "_i" from 0 to (count _configPath - 1) do {
        _faction = _configPath select _i;

        if (isClass _faction) then {
            _factions pushback (configname _faction);
        };
    };
} foreach _configPaths;

_factions