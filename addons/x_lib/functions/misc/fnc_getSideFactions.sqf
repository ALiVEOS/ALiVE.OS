#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(getSideFactions);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_getSideFactions

Description:
Returns factions of given side

Parameters:
String - side

Returns:
Array - factions

Examples:
(begin example)
_factions = "CIV" call ALiVE_fnc_getSideFactions;
(end)

See Also:
- nil

Author:
Tupolov

Peer reviewed:
nil
---------------------------------------------------------------------------- */

private ["_side","_factions","_configPaths","_configPath"];

_sideNum = [_this] call ALIVE_fnc_sideTextToNumber;
_factions = [];

_configPaths = [
    missionConfigFile >> "CfgFactionClasses",
    configFile >> "CfgFactionClasses"
];

{
    _configPath = _x;

    for "_i" from 0 to (count _configPath - 1) do {

        private _element = _configPath select _i;

        if (isclass _element) then {
            if ((getnumber(_element >> "side")) == _sideNum) then {
                _factions pushbackunique (configname _element);
            };
        };
    };
} foreach _configPaths;

_factions