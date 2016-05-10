#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(sortCFGVehiclesByFactionClass);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_sortCFGVehiclesByFactionClass

Description:
Sorts CFGVehicles into a hash categorised by vehicleClass

Parameters:

STRING - faction to filter by

Returns:
Array - hash of categorised vehicles

Examples:
(begin example)
//
_result = ["BLU_F"] call ALIVE_fnc_sortCFGVehiclesByFactionClass;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_configPath","_sideNumber","_sortedVehicles","_item","_configName","_vehicleClass","_scope","_vehicleFaction","_side","_subSorted"];

params [
    ["_faction", "none", [""]],
    ["_blacklist", [], [[]]],
    ["_whitelist", [], [[]]]
];

_configPath = configFile >> "CFGVehicles";
_sortedVehicles = [] call ALIVE_fnc_hashCreate;

for "_i" from 0 to ((count _configPath) - 1) do
{

    private ["_item","_configName","_name"];

    _item = _configPath select _i;

    if (isClass _item) then {

        _configName = configName _item;
        _vehicleClass = getText(_item >> "vehicleClass");
        _scope = getNumber(_item >> "scope");
        _vehicleFaction = getText(_item >> "faction");
        _side = getNumber(_item >> "side");

        if(_scope == 2 && (_vehicleFaction == _faction || _side == 3)) then {

            if(isNil "_vehicleClass") then {
                _vehicleClass = "Unknown";
            };
            
            if ((count _whitelist > 0 && {!(_configName in _whitelist)}) || {count _blacklist > 0 && {_configName in _blacklist}}) exitwith {};

            if!(_vehicleClass in (_sortedVehicles select 1)) then {
                [_sortedVehicles,_vehicleClass,[_configName]] call ALIVE_fnc_hashSet;
            }else{
                _subSorted = [_sortedVehicles,_vehicleClass] call ALIVE_fnc_hashGet;
                _subSorted pushback _configName;
                [_sortedVehicles,_vehicleClass,_subSorted] call ALIVE_fnc_hashSet;
            };

        };
    };
};

_sortedVehicles
