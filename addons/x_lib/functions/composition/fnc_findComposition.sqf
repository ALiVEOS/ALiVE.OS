#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(findComposition);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_findComposition

Description:
Reads CfgGroups to find named alive composition

Parameters:
String - class name
String - Category name i.e. Civilian, Military, Guerilla

Returns:
Config - composition
OR
Array - empty array if not found

Examples:
(begin example)
//
_result = ["L_NatoCheckpoint","Military"] call ALiVE_fnc_findComposition;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_configPath","_item","_comp","_name","_foundComp"];
params ["_className", ["_cat", "Military"]];

private _configPaths = [
    missionConfigFile >> "CfgGroups" >> "Empty" >> _cat,
    configFile >> "CfgGroups" >> "Empty" >> _cat
];

scopeName "main";

{
    _configPath = _x;

    for "_i" from 0 to ((count _configPath) - 1) do {
        _item = _configPath select _i;
        if (isClass _item) then {
            for "_i" from 0 to ((count _item) - 1) do {
                _comp = _item select _i;
                if (isClass _comp) then {
                    _name = configName _comp;
                    if(_className == _name) then {
                        _foundComp = _comp;
                        breakTo "main";
                    };
                };
            };
        };
    };
} count _configPaths;

if!(isNil "_foundComp") then { _comp } else { [] };
