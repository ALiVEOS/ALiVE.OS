#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(factionOwnTroopTrucks);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_factionOwnTroopTrucks

Description:
The trucks a faction owns that can carry a squad: 6 or more seats, public, and not
an ammo, fuel or repair truck. Used when the faction has no ground transport listed.
The config is searched once per faction.

Parameters:
String - faction class name

Returns:
Array - truck class names, empty when it owns none

Examples:
(begin example)
["UK3CB_MEE_O"] call ALiVE_fnc_factionOwnTroopTrucks;
(end)

See Also:
- ALiVE_fnc_reportVanillaFallback
- ALiVE_fnc_listVanillaFallbacks

Author:
Jman
---------------------------------------------------------------------------- */

params [["_faction", "", [""]]];

if (_faction == "") exitWith { [] };

if (isNil "ALiVE_factionOwnTroopTrucksCache") then { ALiVE_factionOwnTroopTrucksCache = createHashMap };

private _key = toLower _faction;
private _own = ALiVE_factionOwnTroopTrucksCache get _key;

if (isNil "_own") then {
    private _filter = format [
        "getText (_x >> 'faction') == '%1' && {getNumber (_x >> 'scope') == 2} && {getNumber (_x >> 'transportSoldier') >= 6} && {getNumber (_x >> 'transportAmmo') == 0} && {getNumber (_x >> 'transportFuel') == 0} && {getNumber (_x >> 'transportRepair') == 0} && {((configName _x) isKindOf 'Truck_F') || {(configName _x) isKindOf 'Truck'}}",
        _faction
    ];
    _own = (_filter configClasses (configFile >> "CfgVehicles")) apply { configName _x };
    ALiVE_factionOwnTroopTrucksCache set [_key, _own];
};

+_own
