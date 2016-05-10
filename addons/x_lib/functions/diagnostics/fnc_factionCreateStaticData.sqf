#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(factionCreateStaticData);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_factionCreateStaticData

Description:
Creates static data entries for a 3rd party faction

Parameters:
Config - config file

Returns:

Examples:
(begin example)
// inspect config class
["BLU_F"] call ALIVE_fnc_factionCreateStaticData;

// inspect all factions
_factions = configfile >> "CfgFactionClasses";
for "_i" from 0 to count _factions -1 do {

    _faction = _factions select _i;
    if(isClass _faction) then {
        _configName = configName _faction;
        _side = getNumber(_faction >> "side");
        if((_side < 3) && !(_configName == "Default") && !(_configName == "None") && !(_configName == "OPF_G_F") && !(_configName == "BLU_G_F") && !(_configName == "IND_G_F") && !(_configName == "IND_F") && !(_configName == "OPF_F") && !(_configName == "BLU_F")) then {
            [configName (_factions select _i), false, false] call ALIVE_fnc_factionCreateStaticData;
        };
    };
};
[true] call ALIVE_fnc_dumpClipboard;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_dump","_cfgFindFaction","_faction","_customGroups"];

_faction = _this select 0;
_customGroups = if(count _this > 1) then {_this select 1} else {true};
_dump = if(count _this > 2) then {_this select 2} else {true};

_cfgFindFaction = {
    private ["_cfg","_faction","_detailed","_item","_text","_result","_findRecurse","_className"];

    _cfg = _this select 0;
    _faction = _this select 1;

    _result = [];

    _findRecurse = {
    	private ["_root","_class","_path","_currentPath","_currentFaction"];

    	_root = (_this select 0);
    	_path = +(_this select 1);

        _currentFaction = [_root >> "faction"] call ALIVE_fnc_getConfigValue;

    	if!(isNil "_currentFaction") then {
    	    if(_currentFaction == _faction) then {
    	        _result pushback _root;
    	    };
    	};

    	for "_i" from 0 to count _root -1 do {

    		_class = _root select _i;

    		if (isClass _class) then {
    			_currentPath = _path + [_i];

    			_className = configName _class;

    			_class = _root >> _className;

    			[_class, _currentPath] call _findRecurse;
    		};
    	};
    };

    [_cfg, []] call _findRecurse;

    _result
};



[""] call ALIVE_fnc_dumpClipboard;
[""] call ALIVE_fnc_dumpClipboard;
["// %1",_faction] call ALIVE_fnc_dumpClipboard;
[""] call ALIVE_fnc_dumpClipboard;
[""] call ALIVE_fnc_dumpClipboard;



// first check the faction

private ["_factionOK","_text","_config","_displayName","_side","_sideToText"];

_factionOK = false;

_config = configfile >> "CfgFactionClasses" >> _faction;

if(count _config > 0) then {
    _displayName = [_config >> "displayName"] call ALIVE_fnc_getConfigValue;
    _side = [_config >> "side"] call ALIVE_fnc_getConfigValue;
    _sideToText = [_side] call ALIVE_fnc_sideNumberToText;
    _factionOK = true;
};



// check groups matching the faction

private ["_factionToGroupMappingOK","_factionGroups"];

_factionToGroupMappingOK = false;

_config = configfile >> "CfgGroups" >> _sideToText >> _faction;

if(count _config > 0) then {
    _factionToGroupMappingOK = true;
    _factionGroups = [_config,_faction] call _cfgFindFaction;
};


// if the direct mapping check failed try reverse lookup groups > faction

private ["_groupToFactionMappingOK"];

_groupToFactionMappingOK = false;

if!(_factionToGroupMappingOK) then {

    _config = configfile >> "CfgGroups" >> _sideToText;
    _factionGroups = [_config,_faction] call _cfgFindFaction;

    if(count _factionGroups > 0) then {
        _groupToFactionMappingOK = true;
    };
};


// found some groups for the faction - investigate them

private ["_factionCategoryGroups","_config","_class","_categoryName","_aliveCategory","_groups","_factionGroupCategory","_arrayContent","_delimit"];

_factionCategoryGroups = [] call ALIVE_fnc_hashCreate;

if(_factionToGroupMappingOK) then {

    _config = configfile >> "CfgGroups" >> _sideToText >> _faction;

    _arrayContent = "";

    for "_i" from 0 to count _config -1 do {

        _class = _config select _i;

        if (isClass _class) then {
            _categoryName = configName _class;
            _aliveCategory = [_class >> "aliveCategory"] call ALIVE_fnc_getConfigValue;

            if(_i == 0) then {
                _delimit = "";
            }else{
                _delimit = ",";
            };

            _arrayContent = format['%1%2"%3"',_arrayContent,_delimit,_categoryName];

            ['cat: %1 cat: %2',_categoryName,_aliveCategory] call ALIVE_fnc_dumpClipboard;

            if!(isNil "_aliveCategory") then {

                _groups = [];

                for "_o" from 0 to count _class -1 do {

                    _group = _class select _o;

                    if (isClass _group) then {
                        _groupName = configName _group;

                        _groups pushback _groupName;
                    };
                };


                if(_aliveCategory in (_factionCategoryGroups select 1)) then {

                    _existingGroups = [_factionCategoryGroups,_aliveCategory] call ALIVE_fnc_hashGet;

                    _groups = _groups + _existingGroups;

                    [_factionCategoryGroups,_aliveCategory,_groups] call ALIVE_fnc_hashSet;
                }else{
                    [_factionCategoryGroups,_aliveCategory,_groups] call ALIVE_fnc_hashSet;
                }

            }else{

                _groups = [];

                for "_o" from 0 to count _class -1 do {

                    _group = _class select _o;

                    if (isClass _group) then {
                        _groupName = configName _group;

                        _groups pushback _groupName;
                    };
                };

                [_factionCategoryGroups,_categoryName,_groups] call ALIVE_fnc_hashSet;

            };
        };
    };

    [''] call ALIVE_fnc_dumpClipboard;

    ['ALIVE_RHSResupplyGroupOptions_%1 = [] call ALIVE_fnc_hashCreate;',_faction] call ALIVE_fnc_dumpClipboard;
    ['[ALIVE_RHSResupplyGroupOptions_%1, "PR_AIRDROP", ["Armored","Support"%2]] call ALIVE_fnc_hashSet;',_faction,_arrayContent] call ALIVE_fnc_dumpClipboard;
    ['[ALIVE_RHSResupplyGroupOptions_%1, "PR_HELI_INSERT", ["Armored","Mechanized","Motorized","Motorized_MTP","SpecOps","Support"%2]] call ALIVE_fnc_hashSet;',_faction,_arrayContent] call ALIVE_fnc_dumpClipboard;
    ['[ALIVE_RHSResupplyGroupOptions_%1, "PR_STANDARD", ["Support"%2]] call ALIVE_fnc_hashSet;',_faction,_arrayContent] call ALIVE_fnc_dumpClipboard;

    ['[ALIVE_factionDefaultResupplyGroupOptions, "%1", ALIVE_RHSResupplyGroupOptions_%1] call ALIVE_fnc_hashSet;',_faction] call ALIVE_fnc_dumpClipboard;
};


[''] call ALIVE_fnc_dumpClipboard;
[''] call ALIVE_fnc_dumpClipboard;


private ["_groupCategory","_categoryGroups","_arrayContent","_groupClass","_configName","_delimit"];

['%1_mappings = [] call ALIVE_fnc_hashCreate;',_faction] call ALIVE_fnc_dumpClipboard;
[''] call ALIVE_fnc_dumpClipboard;
['%1_factionCustomGroups = [] call ALIVE_fnc_hashCreate;',_faction] call ALIVE_fnc_dumpClipboard;
[''] call ALIVE_fnc_dumpClipboard;
['[%1_mappings, "Side", "%2"] call ALIVE_fnc_hashSet;',_faction,_sideToText] call ALIVE_fnc_dumpClipboard;
['[%1_mappings, "GroupSideName", "%2"] call ALIVE_fnc_hashSet;',_faction,_sideToText] call ALIVE_fnc_dumpClipboard;
['[%1_mappings, "FactionName", "%1"] call ALIVE_fnc_hashSet;',_faction] call ALIVE_fnc_dumpClipboard;
['[%1_mappings, "GroupFactionName", "%1"] call ALIVE_fnc_hashSet;',_faction] call ALIVE_fnc_dumpClipboard;
[''] call ALIVE_fnc_dumpClipboard;
['%1_typeMappings = [] call ALIVE_fnc_hashCreate;',_faction] call ALIVE_fnc_dumpClipboard;
[''] call ALIVE_fnc_dumpClipboard;
['[%1_mappings, "GroupFactionTypes", %1_typeMappings] call ALIVE_fnc_hashSet;',_faction] call ALIVE_fnc_dumpClipboard;
[''] call ALIVE_fnc_dumpClipboard;
{

    _groupCategory = _x;

    _categoryGroups = [_factionCategoryGroups,_groupCategory] call ALIVE_fnc_hashGet;

    _arrayContent = "";

    _delimit = "";

    {
        if(_forEachIndex == 0) then {
            _delimit = "";
        }else{
            _delimit = ",";
        };

        _arrayContent = format['%1%2"%3"',_arrayContent,_delimit,_x];

    } forEach _categoryGroups;

    ['[%1_factionCustomGroups, "%2", [%3]] call ALIVE_fnc_hashSet;',_faction,_groupCategory,_arrayContent] call ALIVE_fnc_dumpClipboard;

} forEach (_factionCategoryGroups select 1);

if(count(_factionCategoryGroups select 1) == 0) then {
    ['%1_typeMappings, "Air", "Air"] call ALIVE_fnc_hashSet;',_faction] call ALIVE_fnc_dumpClipboard;
    ['%1_typeMappings, "Armored", "Armored"] call ALIVE_fnc_hashSet;',_faction] call ALIVE_fnc_dumpClipboard;
    ['%1_typeMappings, "Infantry", "Infantry"] call ALIVE_fnc_hashSet;',_faction] call ALIVE_fnc_dumpClipboard;
    ['%1_typeMappings, "Mechanized", "Mechanized"] call ALIVE_fnc_hashSet;',_faction] call ALIVE_fnc_dumpClipboard;
    ['%1_typeMappings, "Motorized", "Motorized"] call ALIVE_fnc_hashSet;',_faction] call ALIVE_fnc_dumpClipboard;
    ['%1_typeMappings, "Motorized_MTP", "Motorized_MTP"] call ALIVE_fnc_hashSet;',_faction] call ALIVE_fnc_dumpClipboard;
    ['%1_typeMappings, "SpecOps", "SpecOps"] call ALIVE_fnc_hashSet;',_faction] call ALIVE_fnc_dumpClipboard;
    ['%1_typeMappings, "Support", "Support"] call ALIVE_fnc_hashSet;',_faction] call ALIVE_fnc_dumpClipboard;
};

[''] call ALIVE_fnc_dumpClipboard;
['[%1_mappings, "Groups", %1_factionCustomGroups] call ALIVE_fnc_hashSet;',_faction] call ALIVE_fnc_dumpClipboard;
[''] call ALIVE_fnc_dumpClipboard;
['[ALIVE_factionCustomMappings, "%1", %1_mappings] call ALIVE_fnc_hashSet;',_faction] call ALIVE_fnc_dumpClipboard;



private ["_factionVehicles","_factionMen","_class","_configName","_currentFaction","_vehicleType","_factionVehicleTypes"];

_factionVehicles = [] call ALIVE_fnc_hashCreate;
_factionMen = [];

_config = configfile >> "CfgVehicles";

for "_i" from 0 to count _config -1 do {
    _class = _config select _i;
    if (isClass _class) then {
        _configName = configName _class;
        _currentFaction = [_class >> "faction"] call ALIVE_fnc_getConfigValue;
        if!(isNil "_currentFaction") then {
            if(_currentFaction == _faction) then {
                if(_configName isKindOf "Man") then {
                    if([_class >> "scope"] call ALIVE_fnc_getConfigValue == 2) then {
                        _factionMen pushback _class;
                    };
                }else{
                    if([_class >> "scope"] call ALIVE_fnc_getConfigValue == 2) then {
                        _vehicleType = [_class >> "vehicleClass"] call ALIVE_fnc_getConfigValue;

                        if!(_vehicleType in (_factionVehicles select 1)) then {
                            [_factionVehicles,_vehicleType,[]] call ALIVE_fnc_hashSet;
                        };

                        _factionVehicleTypes = [_factionVehicles,_vehicleType] call ALIVE_fnc_hashGet;
                        _factionVehicleTypes pushback _class;

                        [_factionVehicles,_vehicleType,_factionVehicleTypes] call ALIVE_fnc_hashSet;
                    };
                };
            };
        };
    };
};


private ["_vehicleType","_vehicleClasses","_array","_vehicleClass","_configName","_delimit"];

{

    _vehicleType = _x;

    _vehicleClasses = [_factionVehicles,_vehicleType] call ALIVE_fnc_hashGet;

    [" "] call ALIVE_fnc_dumpClipboard;
    ["// %1",_vehicleType] call ALIVE_fnc_dumpClipboard;

    _arrayContent = "";
    _delimit = "";

    {

        _vehicleClass = _x;

        _configName = configName _vehicleClass;

        if(_forEachIndex == 0) then {
            _delimit = "";
        }else{
            _delimit = ",";
        };

        _arrayContent = format['%1%2"%3"',_arrayContent,_delimit,_configName];

    } forEach _vehicleClasses;

    _supports = format['[ALIVE_factionDefaultSupports, "%1", [%2]] call ALIVE_fnc_hashSet;',_faction,_arrayContent];
    _supplies = format['[ALIVE_factionDefaultSupplies, "%1", [%2]] call ALIVE_fnc_hashSet;',_faction,_arrayContent];
    _transport = format['[ALIVE_factionDefaultTransport, "%1", [%2]] call ALIVE_fnc_hashSet;',_faction,_arrayContent];
    _air = format['[ALIVE_factionDefaultAirTransport, "%1", [%2]] call ALIVE_fnc_hashSet;',_faction,_arrayContent];

    [_supports] call ALIVE_fnc_dumpClipboard;
    [_supplies] call ALIVE_fnc_dumpClipboard;
    [_transport] call ALIVE_fnc_dumpClipboard;
    [_air] call ALIVE_fnc_dumpClipboard;

} forEach (_factionVehicles select 1);


if(_dump) then {
    [true] call ALIVE_fnc_dumpClipboard;
};