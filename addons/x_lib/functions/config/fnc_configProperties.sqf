#include "\x\alive\addons\x_lib\script_component.hpp"

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_configProperties

Description:
Retrieves class config properties and sorts them
into a CBA hash

Parameters:
Class - Class to inspect

Returns:
Array - CBA hash of attributes-values

Examples:
_classProperties = [configFile >> "CfgVehicles" >> "B_Soldier_F"] call ALiVE_fnc_configProperties;

Author:
SpyderBlack723
---------------------------------------------------------------------------- */

private ["_entry","_attribute","_value"];

params ["_class"];

private _propertiesRead = [] call ALiVE_fnc_hashCreate;

if (_class isEqualType configNull) then {

    for "_i" from 0 to (count _class - 1) do {
        _entry = _class select _i;

        _attribute = configName _entry;
        _value = [_entry] call ALiVE_fnc_getConfigValue;

        if (_value isEqualType configNull) then {
            _value = [_value] call ALiVE_fnc_configProperties;
        };

        [_propertiesRead,_attribute,_value] call ALiVE_fnc_hashSet;
    };

};

_propertiesRead