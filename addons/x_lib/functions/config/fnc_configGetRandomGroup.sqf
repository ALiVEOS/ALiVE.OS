#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(configGetRandomGroup);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_configGetRandomGroup

Description:
Get a group from the config files by group name

Parameters:
String - type Infantry,Motorized,Mechanized,Armored,Air
String - faction
String - side East,West,Guer,Civ

Returns:
String group name

Examples:
(begin example)
// get random group config group
_result = [] call ALIVE_fnc_configGetRandomGroup;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_type","_typeg","_faction","_side","_factionConfig","_factionSide","_typeConfig","_groups","_class","_countUnits", "_unit","_group","_groupName","_customMappings","_groupFactionTypes","_customGroup","_mappedType"];

_type = if(count _this > 0) then {_this select 0} else {"Infantry"};
_faction = if(count _this > 1) then {_this select 1} else {"OPF_F"};
_side = if(count _this > 2) then {_this select 2} else {"EAST"};

// ["Side: %1 Type: %2 Faction: %3",_side,_type,_faction] call ALIVE_fnc_dump;

_customGroup = false;

if(!isNil "ALIVE_factionCustomMappings") then {
    if(_faction in (ALIVE_factionCustomMappings select 1)) then {
        _customMappings = [ALIVE_factionCustomMappings, _faction] call ALIVE_fnc_hashGet;
        // _customMappings call ALIVE_fnc_inspectHash;
        _side = [_customMappings, "GroupSideName"] call ALIVE_fnc_hashGet;
        //_faction = [_customMappings, "FactionName"] call ALIVE_fnc_hashGet;
        _faction = [_customMappings, "GroupFactionName"] call ALIVE_fnc_hashGet;
        _groupFactionTypes = [_customMappings, "GroupFactionTypes"] call ALIVE_fnc_hashGet;
        _mappedType = [_groupFactionTypes, _type] call ALIVE_fnc_hashGet;

        if!(isNil "_mappedType") then {
            _type = _mappedType;
        };

        if("Groups" in (_customMappings select 1)) then {

            _groups = [_customMappings, "Groups"] call ALIVE_fnc_hashGet;

            //["Groups: %1",_groups] call ALIVE_fnc_dump;

            if (count (_groups select 1) > 0) then {

                if(_type in (_groups select 1)) then {

                    _groups = [_groups, _type] call ALIVE_fnc_hashGet;

                    if(count _groups > 0) then {
                        _groupName = _groups select floor(random count _groups);
                    }else{
                        _groupName = "FALSE";
                    };

                    _customGroup = true;

                } else {
                    ["Warning Side: %1 Faction: %3 could not find a %2 group",_side,_type,_faction] call ALIVE_fnc_dump;
                    _factionConfig = (configFile >> "CfgFactionClasses" >> _faction);
                    _factionSide = getNumber(_factionConfig >> "side");
                    _side = _factionSide call ALIVE_fnc_sideNumberToText;
                };
            } else {
                ["Warning Side: %1 Faction: %3 maybe incorrectly configured for ALiVE (Group Type: %2)",_side,_type,_faction] call ALIVE_fnc_dump;
                _factionConfig = (configFile >> "CfgFactionClasses" >> _faction);
                _factionSide = getNumber(_factionConfig >> "side");
                _side = _factionSide call ALIVE_fnc_sideNumberToText;
            };
        };
    }else{
        _factionConfig = (configFile >> "CfgFactionClasses" >> _faction);
        _factionSide = getNumber(_factionConfig >> "side");
        _side = _factionSide call ALIVE_fnc_sideNumberToText;
    };
}else{
    _factionConfig = (configFile >> "CfgFactionClasses" >> _faction);
    _factionSide = getNumber(_factionConfig >> "side");
    _side = _factionSide call ALIVE_fnc_sideNumberToText;
};

if(_side == "GUER") then {
	_side = "INDEP";
};

// If someone accidentally defined mappings as groups revert back to basics
if(typename _type == "ARRAY") then {
    _type = _this select 0;
};

// ["Side: %1 Type: %2 Faction: %3",_side,_type,_faction] call ALIVE_fnc_dump;

if!(_customGroup) then {

    _typeConfig = (configFile >> "CfgGroups" >> _side >> _faction >> _type);
    _groups = [];

    // ["Config: %1",_typeConfig] call ALIVE_fnc_dump;

    for "_i" from 0 to count _typeConfig -1 do {
        _class = _typeConfig select _i;

        if (isClass _class) then {

            _countUnits = 0;
            for "_y" from 0 to count _class -1 do {
                _unit = _class select _y;

                if (isClass _unit) then {
                    _countUnits = _countUnits + 1;
                };
            };

            if(_countUnits > 0) then {
                _groups pushback _class;
            };
        };
    };

    if(count _groups > 0) then {
        _group = _groups select floor(random count _groups);
        _groupName = configName _group;
    }else{
        _groupName = "FALSE";
    };

};

_groupName