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

params ["_class"];

private _propertiesRead = [] call ALiVE_fnc_hashCreate;

if (_class isEqualType configNull) then {

    for "_i" from 0 to (count _class - 1) do {
        _entry = _class select _i;
        private _value = [_entry] call ALiVE_fnc_getConfigValue;
        _value = if (_value isEqualType configNull) then { [_value] call ALiVE_fnc_configProperties } else { _value };
        [_propertiesRead, (configName _entry), _value] call ALiVE_fnc_hashSet;
    };

};

_propertiesRead