#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(findVehicleType);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_findVehicleType

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

private ["_id","_fac","_allvehs","_entry","_entryConfigName","_cargoslots","_type","_noWeapons","_nonconfigs","_nonsims","_facUnits","_err"];

PARAMS_1(_cargoslots);
_err = "cargo slots not valid";
ASSERT_DEFINED("_cargoslots",_err);
ASSERT_TRUE(typeName _cargoslots == "SCALAR",_err);

DEFAULT_PARAM(1,_fac,nil);
DEFAULT_PARAM(2,_type,nil);
DEFAULT_PARAM(3,_noWeapons,false);
DEFAULT_PARAM(4,_minScope,1);

_id = _fac;

if (typeName _fac == "ARRAY") then {
    _id = str(_fac);
    _id = [_id, "[", ""] call CBA_fnc_replace;
    _id = [_id, "]", ""] call CBA_fnc_replace;
    _id = [_id, "'", ""] call CBA_fnc_replace;
    _id = [_id, """", ""] call CBA_fnc_replace;
};

private _searchBag = format["ALiVE_X_LIB_SEARCHBAG_%1_%2_%3",_id,_type,_noWeapons];

if !(isnil {call compile _searchBag}) exitwith {call compile _searchBag};

_nonConfigs = ["StaticWeapon","CruiseMissile1","CruiseMissile2","Chukar_EP1","Chukar","Chukar_AllwaysEnemy_EP1"];
_nonSims = ["parachute","house"];

_facUnits = [];
if (typename _fac == "STRING") then {
    private _factionConfigMission = missionConfigFile >> "CfgFactionClasses" >> _fac;

    if (isClass _factionConfigMission) then {
        _facUnits append (_fac call ALiVE_fnc_configGetFactionUnitsByGroups);
    };
} else {
    {
        private _factionConfigMission = missionConfigFile >> "CfgFactionClasses" >> _x;

        if (isClass _factionConfigMission) then {
            _facUnits append (_x call ALiVE_fnc_configGetFactionUnitsByGroups);
        };
    } foreach _fac;
};

_allvehs = [];

for "_y" from 1 to count(configFile >> "CfgVehicles") - 1 do {
    _entry = (configFile >> "CfgVehicles") select _y;

    if(getNumber (_entry >> "scope") >= _minScope) then {
        if (!(getText(_entry >> "simulation") in _nonsims)) then {
            _entryConfigName = configName _entry;

            if ({(_entryConfigName isKindOf _x)} count _nonconfigs == 0) then {
                if (getNumber(_entry >> "TransportSoldier") >= _cargoslots) then {
                    private _entryFaction = getText (_entry >> "faction");

                    if (_fac isEqualType []) then {
                        if (_entryFaction in _fac || {_entryConfigName in _facUnits}) then {
                            if (!isnil "_type") then {
                                if (_entryConfigName isKindOf _type) then {
                                    if (_noWeapons) then {
                                        if ([_entryConfigName] call ALiVE_fnc_isArmed) then {_allvehs pushback _entryConfigName};
                                    } else {
                                        _allvehs pushback _entryConfigName;
                                    };
                                };
                            } else {
                                if (_noWeapons) then {
                                    if ([_entryConfigName] call ALiVE_fnc_isArmed) then {_allvehs pushback _entryConfigName};
                                } else {
                                    _allvehs pushback _entryConfigName;
                                };
                            };
                        };
                    } else {
                        if (_entryFaction == _fac || {_entryConfigName in _facUnits}) then {
                            if (!isnil "_type") then {
                                if (_entryConfigName isKindOf _type) then {
                                    if (_noWeapons) then {
                                        if ([_entryConfigName] call ALiVE_fnc_isArmed) then {_allvehs pushback _entryConfigName};
                                    } else {
                                        _allvehs pushback _entryConfigName;
                                    };
                                };
                            } else {
                                if (_noWeapons) then {
                                    if ([_entryConfigName] call ALiVE_fnc_isArmed) then {_allvehs pushback _entryConfigName};
                                } else {
                                    _allvehs pushback _entryConfigName;
                                };
                            };
                        };
                    };
                };
            };
        };
    };
};

//call compile (format["%1 = %2",_searchbag,_allvehs]);

_allvehs