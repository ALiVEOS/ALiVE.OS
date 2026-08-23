#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(initFindVehicleTypeCache);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_initFindVehicleTypeCache

Description:
Adds one or more factions to the index used by ALIVE_fnc_findVehicleType.
Factions already present are skipped. Only matching CfgVehicles classes and
mission-group overrides are retained.

Parameters:
String or Array - faction class name(s)

Returns:
Boolean - true

Author:
SpyderBlack723
---------------------------------------------------------------------------- */

params [
    ["_factions", [], ["", []]]
];

if (_factions isEqualType "") then {
    _factions = [_factions];
};

if (isNil "ALiVE_findVehicleTypeFactionIndex") then { ALiVE_findVehicleTypeFactionIndex = createHashMap };
if (isNil "ALiVE_findVehicleTypeClassMetadata") then { ALiVE_findVehicleTypeClassMetadata = createHashMap };
if (isNil "ALiVE_findVehicleTypeCache") then { ALiVE_findVehicleTypeCache = createHashMap };
if (isNil "ALiVE_findVehicleTypeMissionFactionUnitsCache") then { ALiVE_findVehicleTypeMissionFactionUnitsCache = createHashMap };
if (isNil "ALiVE_findVehicleTypeArmedCache") then { ALiVE_findVehicleTypeArmedCache = createHashMap };
if (isNil "ALiVE_findVehicleTypeCachedFactions") then { ALiVE_findVehicleTypeCachedFactions = createHashMap };

private _normalizedFactions = [];
{
    if (_x isEqualType "") then {
        private _faction = trim _x;
        if (_faction != "" && {_faction != "NONE"}) then {
            _normalizedFactions pushBackUnique _faction;
        };
    } else {
        if (_x isEqualType []) then {
            {
                if (_x isEqualType "") then {
                    private _faction = trim _x;
                    if (_faction != "" && {_faction != "NONE"}) then {
                        _normalizedFactions pushBackUnique _faction;
                    };
                };
            } forEach _x;
        };
    };
} forEach _factions;

private _missingFactions = _normalizedFactions select {!(_x in ALiVE_findVehicleTypeCachedFactions)};
if (_missingFactions isEqualTo []) exitWith {true};

private _missingLookup = createHashMap;
{
    _missingLookup set [_x, true];
    ALiVE_findVehicleTypeFactionIndex set [_x, []];
} forEach _missingFactions;

private _cfgVehicles = configFile >> "CfgVehicles";
private _nonConfigs = ["StaticWeapon","CruiseMissile1","CruiseMissile2","Chukar_EP1","Chukar","Chukar_AllwaysEnemy_EP1"];
private _nonSims = ["parachute","house"];

private _cacheClass = {
    params ["_class", "_faction"];

    if !(_class in ALiVE_findVehicleTypeClassMetadata) then {
        private _entry = configFile >> "CfgVehicles" >> _class;
        if (!isClass _entry) exitWith {false};
        if (getText (_entry >> "simulation") in _nonSims) exitWith {false};
        if ((_nonConfigs findIf {_class isKindOf _x}) != -1) exitWith {false};

        ALiVE_findVehicleTypeClassMetadata set [_class, [
            getNumber (_entry >> "scope"),
            getNumber (_entry >> "TransportSoldier")
        ]];
    };

    private _classes = ALiVE_findVehicleTypeFactionIndex get _faction;
    _classes pushBackUnique _class;
    ALiVE_findVehicleTypeFactionIndex set [_faction, _classes];
    true
};

for "_i" from 1 to (count _cfgVehicles - 1) do {
    private _entry = _cfgVehicles select _i;

    if (isClass _entry) then {
        private _faction = getText (_entry >> "faction");
        if (_faction in _missingLookup) then {
            [configName _entry, _faction] call _cacheClass;
        };
    };
};

{
    private _faction = _x;
    private _missionUnits = [];

    if (isClass (missionConfigFile >> "CfgFactionClasses" >> _faction)) then {
        _missionUnits = _faction call ALiVE_fnc_configGetFactionUnitsByGroups;
        {
            [_x, _faction] call _cacheClass;
        } forEach _missionUnits;
    };

    ALiVE_findVehicleTypeMissionFactionUnitsCache set [_faction, _missionUnits];
    ALiVE_findVehicleTypeCachedFactions set [_faction, true];
} forEach _missingFactions;

true
