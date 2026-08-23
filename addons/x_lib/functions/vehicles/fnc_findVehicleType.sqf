#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(findVehicleType);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_findVehicleType

Description:
Used to find vehicles for specific type, side and free cargo slots

Parameters:
Number - Minimum number of cargo slots in the vehicle
String - Faction of the vehicle (optional)
String - Type of the vehicle (optional)

Returns:
Array - A list of vehicles matching the parameters supplied.

Examples:
(begin example)
_types = [0, ALiVE_FACTIONS,"Man"] call ALiVE_fnc_findVehicleType;
_group = [_pos, east, _types] call BIS_fnc_spawnGroup;
(end)

Author:
Wolffy.au
---------------------------------------------------------------------------- */

params [
    "_cargoslots",
    ["_fac", nil],
    ["_type", nil],
    ["_noWeapons", false],
    ["_minScope", 1]
];

if (isNil "ALiVE_findVehicleTypeCache") then {
    ALiVE_findVehicleTypeCache = createHashMap;
};

// Faction-array order does not affect the query, so normalize it to avoid
// duplicate cache entries for equivalent requests.
private _cacheFaction = _fac;
if (_cacheFaction isEqualType []) then {
    _cacheFaction = +_cacheFaction;
    _cacheFaction sort true;
};

private _cacheKey = str [_cargoslots, _cacheFaction, _type, _noWeapons, _minScope];

if (_cacheKey in ALiVE_findVehicleTypeCache) exitWith {
    +(ALiVE_findVehicleTypeCache get _cacheKey)
};

[_cacheFaction] call ALiVE_fnc_initFindVehicleTypeCache;

private _compiledVehicles = [];
if (!isNil "ALiVE_fnc_factionCompilerIsCompiledFaction" && {!isNil "ALiVE_fnc_factionCompilerFindVehicleType"}) then {
    if (_fac isEqualType "") then {
        if ([_fac] call ALiVE_fnc_factionCompilerIsCompiledFaction) then {
            _compiledVehicles = [_cargoslots, _fac, _type, _noWeapons, _minScope] call ALiVE_fnc_factionCompilerFindVehicleType;

            if (count _compiledVehicles == 0) then {
                _fac = [_fac] call ALiVE_fnc_factionCompilerGetConfigFaction;
            } else {
                _fac = [];
            };
        };
    } else {
        if (_fac isEqualType []) then {
            private _resolvedFactions = [];
            {
                if (_x isEqualType "" && {[_x] call ALiVE_fnc_factionCompilerIsCompiledFaction}) then {
                    private _compiledFactionVehicles = [_cargoslots, _x, _type, _noWeapons, _minScope] call ALiVE_fnc_factionCompilerFindVehicleType;

                    if (count _compiledFactionVehicles == 0) then {
                        _resolvedFactions pushBackUnique ([_x] call ALiVE_fnc_factionCompilerGetConfigFaction);
                    } else {
                        _compiledVehicles append _compiledFactionVehicles;
                    };
                } else {
                    _resolvedFactions pushBackUnique _x;
                };
            } forEach _fac;
            _fac = _resolvedFactions;
        };
    };
};
private _factions = if (_fac isEqualType []) then {_fac} else {[_fac]};

[_factions] call ALiVE_fnc_initFindVehicleTypeCache;

private _candidates = [];
{
    if (_x isEqualType "") then {
        _candidates append (ALiVE_findVehicleTypeFactionIndex getOrDefault [_x, []]);
    };
} forEach _factions;

private _seenCandidates = createHashMap;
private _seenResults = createHashMap;
private _allvehs = [];

{
    if !(_x in _seenResults) then {
        _seenResults set [_x, true];
        _allvehs pushBack _x;
    };
} forEach _compiledVehicles;

{
    private _entryConfigName = _x;

    if !(_entryConfigName in _seenCandidates) then {
        _seenCandidates set [_entryConfigName, true];

        if (_entryConfigName in ALiVE_findVehicleTypeClassMetadata) then {
            (ALiVE_findVehicleTypeClassMetadata get _entryConfigName) params ["_scope", "_cargoCapacity"];

            if (_scope >= _minScope && {_cargoCapacity >= _cargoslots}) then {
                if (isNil "_type" || {_entryConfigName isKindOf _type}) then {
                    private _passesWeaponFilter = true;

                    // Despite the legacy name, true has always meant "must be armed".
                    if (_noWeapons) then {
                        if !(_entryConfigName in ALiVE_findVehicleTypeArmedCache) then {
                            ALiVE_findVehicleTypeArmedCache set [_entryConfigName, [_entryConfigName] call ALiVE_fnc_isArmed];
                        };
                        _passesWeaponFilter = ALiVE_findVehicleTypeArmedCache get _entryConfigName;
                    };

                    if (_passesWeaponFilter && {!(_entryConfigName in _seenResults)}) then {
                        _seenResults set [_entryConfigName, true];
                        _allvehs pushBack _entryConfigName;
                    };
                };
            };
        };
    };
} forEach _candidates;

// Store and return separate arrays so callers cannot mutate cached data.
ALiVE_findVehicleTypeCache set [_cacheKey, +_allvehs];

_allvehs
