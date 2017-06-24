#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(configGetFactionUnitsByGroups);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_configGetFactionUnitsByGroups

Description:
Returns config path of given faction
searches missionConfigFile before configFile

Parameters:
String - faction

Returns:
Config Path - path to faction config

Examples:
(begin example)
_side = "OPF_F" call ALiVE_fnc_configGetFactionUnitsByGroups;
(end)

See Also:
- nil

Author:
SpyderBlack723

Peer reviewed:
nil
---------------------------------------------------------------------------- */

private ["_groupCategory","_group"];

private _units = [];
private _groups = _this call ALiVE_fnc_configGetFactionGroups;

for "_i" from 0 to (count _groups - 1) do {
    _groupCategory = _groups select _i;
    for "_j" from 0 to (count _groupCategory - 1) do {
        _group = _groupCategory select _j;
        for "_k" from 0 to (count _group - 1) do {
            private _unit = _group select _k;
            if (isClass _unit) then { _units pushBackUnique (getText (_unit >> "vehicle")); };
        };
    };
};

_units