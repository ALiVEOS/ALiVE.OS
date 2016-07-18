#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(getFactions);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_getFactions

Description:
Returns all config factions
checks configFile and missionConfigFile

Parameters:
None

Returns:
Array - All factions

Examples:
(begin example)
_side = [] call ALiVE_fnc_getFactions;
(end)

See Also:
- nil

Author:
SpyderBlack723

Peer reviewed:
nil
---------------------------------------------------------------------------- */

private _faction = [];

private _configPaths = [
    missionConfigFile,
    configFile
];

{
    _configPath = _x;

    for "_i" from 0 to (count _configPath - 1) do {
        _faction = _configPath select _i;

    };
} foreach _configPaths;