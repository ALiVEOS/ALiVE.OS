#include "\x\alive\addons\x_lib\script_component.hpp"

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_configGetDifferences

Description:
Retrieves a list of attributes that a child
class contains that another class doesn't

Parameters:
Class - Child Class
Class - Parent Class

Returns:
Array - Array containing nested [attribute,value] arrays

Examples:
_childClass = configFile >> "CfgVehicles" >> "B_Soldier_F";
_parentClass = configFile >> "CfgVehicles" >> "B_Soldier_base_F";
_differences = [_childClass,_parentClass] call ALiVE_fnc_configGetDifferences;

Author:
SpyderBlack723
---------------------------------------------------------------------------- */

private ["_attribute","_childClassValue","_parentClassValue"];

params ["_childClass","_parentClass"];

private _childClassProperties = [_childClass] call ALiVE_fnc_configProperties;
private _parentClassProperties = [_parentClass] call ALiVE_fnc_configProperties;

private _attributes = _childClassProperties select 1;
_differences = [];

{
    _attribute = _x;

    _childClassValue = [_childClassProperties,_attribute] call ALiVE_fnc_hashGet;
    _parentClassValue = [_parentClassProperties,_attribute] call ALiVE_fnc_hashGet;

    if (isnil "_parentClassValue") then {
        _differences pushback [_attribute,_childClassValue];
    } else {
        if !(_childClassValue isEqualTo _parentClassValue) then {
            _differences pushback [_attribute,_childClassValue];
        };
    };
} foreach _attributes;

_differences