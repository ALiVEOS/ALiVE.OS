#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(groupFinder);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_groupFinder

Description:
Finds all groups with given part of name

Parameters:
type - String like "AA_"
faction or side - cfg type like "BLU_F" or WEST

Returns:
Array of Groups

Examples:
(begin example)
_grp = ["AA","BLU_F"] call ALIVE_fnc_groupFinder;
(end)

See Also:

Author:
Wolffy, Highhead
---------------------------------------------------------------------------- */

private ["_logic","_find","_type","_fac","_facs","_sidex","_side","_grpx","_grps","_grp","_fx","_facx","_s","_spawnGrp","_wp","_nonConfigs","_factionInput"];

_find = _this select 0;
_fac = if (count _this > 1) then {_this select 1} else {east};

_nonConfigs = [""];
_factionInput = _fac;

_facs = [];
_grps = [];
_side = nil;

// get all factions
if(isNil QGVAR(ALLFACTIONS)) then {
	GVAR(ALLFACTIONS) = [] call BIS_fnc_getFactions;
};

// if default or selection by side
if (typeName _fac == "ANY" || {typeName _fac == "SIDE"}) then {
        
        if(typeName _fac == "SIDE") then {
                _side = _fac;
        };
        
        switch(_side) do {
                case east: {
                        _sidex = 0;
                };
                case west: {
                        _sidex = 1;
                };
                case resistance: {
                        _sidex = 2;
                };
                case civilian: {
                        _sidex = 3;
                };
        };
        
        {
                _fx = getNumber(configFile >> "CfgFactionClasses" >> _x >> "side");
                if (_fx == _sidex) then {
                        _facs pushback _x;
                };
        } forEach GVAR(ALLFACTIONS);
        _fac = nil;
} else {
        switch(toUpper(typeName _fac)) do {
                case "STRING": {
                        _facs = [_fac];
                };
                // if multiple factions
                case "ARRAY": {
                        _facs = _fac;
                };
        };
        _fac = nil;
};

//["FACS1: %1", _facs] call ALiVE_fnc_Dump;

if(!isNil "_facs") then {
        _facx = [];
        {
                _s = switch(_x) do {
                        case resistance : {"Indep"};
                        case civilian : {"Civilian"};
                        default {str _x};
                };
                
                private ["_x"];
                // Confirm there are units for this faction in this type
                {
                    _typex = count(configFile >> "CfgGroups" >> _s >> _x);
                    for "_z" from 0 to _typex - 1 do {
                        
                        _type = configName((configFile >> "CfgGroups" >> _s >> _x) select _z);
                    
                        _grpx = count(configFile >> "CfgGroups" >> _s >> _x >> _type);
                        for "_y" from 1 to _grpx - 1 do {
                         	_entry = configName((configFile >> "CfgGroups" >> _s >> _x >> _type) select _y);
                            
                            if (_entry find _find > -1) then {
                                _grps pushback _entry;
                            };
                        };
                	};
                } forEach _facs;
        } forEach [west,east,resistance,civilian];
};

_grps;