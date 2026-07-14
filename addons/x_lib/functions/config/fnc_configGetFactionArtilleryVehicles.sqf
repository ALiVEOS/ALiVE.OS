#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(configGetFactionArtilleryVehicles);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_configGetFactionArtilleryVehicles

Description:
List every public artillery vehicle class a faction owns. Some factions have
artillery vehicles but define no artillery groups at all (e.g. RHS MSV's 2S3),
so group-based pulls can never field them - this scan is the basis for
composing batteries directly from vehicles. Results are cached per faction
for the mission's lifetime (the CfgVehicles walk is expensive).

Parameters:
String - faction classname

Returns:
Array of vehicle classnames (may be empty)

Examples:
(begin example)
_classes = "rhs_faction_msv" call ALIVE_fnc_configGetFactionArtilleryVehicles;
(end)

Author:
Jman
---------------------------------------------------------------------------- */

private _faction = _this;

if (isNil "ALIVE_factionArtilleryVehicleCache") then {
    ALIVE_factionArtilleryVehicleCache = [] call ALIVE_fnc_hashCreate;
};

private _cached = [ALIVE_factionArtilleryVehicleCache, _faction] call ALIVE_fnc_hashGet;
if (!isNil "_cached") exitWith { _cached };

private _result = [];
private _condition = format ["toLower getText (_x >> 'faction') == '%1' && {getNumber (_x >> 'scope') == 2}", toLower _faction];
{
    private _class = configName _x;
    if ([_class] call ALIVE_fnc_isArtillery) then {
        _result pushBack _class;
    };
} forEach (_condition configClasses (configFile >> "CfgVehicles"));

[ALIVE_factionArtilleryVehicleCache, _faction, _result] call ALIVE_fnc_hashSet;

_result
