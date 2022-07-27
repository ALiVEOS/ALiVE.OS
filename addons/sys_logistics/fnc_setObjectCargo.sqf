#include "\x\alive\addons\sys_logistics\script_component.hpp"
SCRIPT(setObjectCargo);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_setObjectCargo
Description:

Sets the cargo on the given object.

Parameters:
ARRAY - select 0: Logistics Cargo (Array)
ARRAY - select 1: Towed vehicles (Array)
ARRAY - select 2: Lifted vehicles (Array)
ARRAY - select 3: Weapons/Magazines/Items (Array)
ARRAY - select 4: Current Ammo (Array)

Returns:
Cargo Array

See Also:
- <ALIVE_fnc_setObjectCargo>

Author:
Highhead

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

private ["_input","_id","_cargo","_cargoR","_cargoT","_cargoL","_cargoWMI","_cargoW","_cargoM","_cargoI","_typesLogistics","_typesWeapons", "_acreActive", "_baseRadio"];

_input = [_this, 0, objNull, [objNull]] call BIS_fnc_param;
_id = [MOD(SYS_LOGISTICS),"id",_input] call ALiVE_fnc_Logistics;

_acreActive = isClass(configFile >> "CfgPatches" >> "acre_main");

if (count _this > 1) then {
    _cargo = [_this, 1, [], [[]]] call BIS_fnc_param;
    //["Using provided cargo set for %1: %2!",_input, _cargo] call ALiVE_fnc_DumpR;
} else {
    _cargo = [[GVAR(STORE),_id] call ALiVE_fnc_HashGet,QGVAR(CARGO)] call ALiVE_fnc_HashGet;
    //["Using stored cargo set for %1: %2!",_input, _cargo] call ALiVE_fnc_DumpR;
};

// Provided Data
_cargoR = [_cargo, 0, [], [[]]] call BIS_fnc_param;
_cargoT = [_cargo, 1, [], [[]]] call BIS_fnc_param;
_cargoL = [_cargo, 2, [], [[]]] call BIS_fnc_param;
_cargoWMI = [_cargo, 3, [], [[]]] call BIS_fnc_param;
_Ammo = [_cargo, 4, [], [[]]] call BIS_fnc_param;

_cargoW = [_cargoWMI, 0, [], [[]]] call BIS_fnc_param;
_cargoM = [_cargoWMI, 1, [], [[]]] call BIS_fnc_param;
_cargoI = [_cargoWMI, 2, [], [[]]] call BIS_fnc_param;

// Detect local/global commands
private _global = isMultiplayer && isServer;

// Reset Magazines state
if (_global) then {
    {_input removeMagazineGlobal _x} forEach (magazines _input);
} else {
    {_input removeMagazine _x} forEach (magazines _input);
};

 {_input addMagazine [_x select 0,_x select 1]} forEach _ammo;

// Reset weapons and items state. Replace ACRE radios with Base Class if ACRE is running

_typesWeapons = [[_cargoW,"WeaponCargo"],[_cargoM,"MagazineCargo"],[_cargoI,"ItemCargo"]];
{
    private ["_content","_current","_operation"];
    private _actions = if (_global) then {
        [{clearWeaponCargoGlobal _input}, {clearMagazineCargoGlobal _input},{clearItemCargoGlobal _input}];
    } else {
        [{clearWeaponCargo _input}, {clearMagazineCargo _input},{clearItemCargo _input}];
    };

    private _actions2 = if (_global) then {
        [{_input addWeaponCargoGlobal [_type,_count]}, {_input addMagazineCargoGlobal [_type,_count]},{
            if !(_acreActive) then {
                _input addItemCargoGlobal [_type,_count];
            } else {
               if (_type call acre_api_fnc_isRadio) then {
                    _baseRadio = _type call acre_api_fnc_isBaseRadio;
                    if !(_baseRadio) then {_type = _type call acre_api_fnc_getBaseRadio};
                    _input addItemCargoGlobal [_type, _count];
                } else {
                    _input addItemCargoGlobal [_type, _count];
                };
            };
        }]; 
    } else {
        [{_input addWeaponCargo [_type,_count]}, {_input addMagazineCargo [_type,_count]},{
            if !(_acreActive) then {
                _input addItemCargo [_type,_count];
            } else {
                if (_type call acre_api_fnc_isRadio) then {
                    _baseRadio = _type call acre_api_fnc_isBaseRadio;
                    if !(_baseRadio) then {_type = _type call acre_api_fnc_getBaseRadio};
                    _input addItemCargo [_type, _count];
                } else {
                    _input addItemCargo [_type, _count];
                };
            };
        }];
    };

    _content = _x select 0;
    _operation = _x select 1;

    _currenttemp = [{getWeaponCargo _input}, {getMagazineCargo _input},{getItemCargo _input}];
    _current = call (_currenttemp select (["weaponcargo","magazinecargo","itemcargo"] find (tolower _operation)));

    if !(_content isEqualTo _current) then {
        if (count (_current select 0) > 0) then {
            call (_actions select _forEachIndex); 
        };

        for "_i" from 0 to (count (_content select 0))-1 do {
            private ["_type","_count"];

            _type = _content select 0 select _i;
            _count = _content select 1 select _i;

            call (_actions2 select _forEachIndex);
        };
    };
} foreach _typesWeapons;

//Reset non weapons and items (static, boxes, towed vehicles etc.)
_typesLogistics = [[_cargoR,"stowObject"],[_cargoT,"towObject"],[_cargoL,"liftObject"]];
{
    private ["_contents","_operation","_container"];

    _contents = _x select 0;
    _operation = _x select 1;
    _container = _input;

    for "_i" from 0 to ((count _contents)-1) do {
        private ["_id","_pos","_type","_content","_object"];

        if (_i > (count _contents)-1) exitwith {};

        _id = _contents select _i;

        _pos = [[GVAR(STORE),_id] call ALiVE_fnc_HashGet,QGVAR(POSITION)] call ALiVE_fnc_HashGet;
        _type = [[GVAR(STORE),_id] call ALiVE_fnc_HashGet,QGVAR(TYPE)] call ALiVE_fnc_HashGet;
        _cargo = [[GVAR(STORE),_id] call ALiVE_fnc_HashGet,QGVAR(CARGO)] call ALiVE_fnc_HashGet;
        _object = (nearestObjects [_pos,[_type],3]) select 0;

        [_object,_cargo] call ALiVE_fnc_setObjectCargo;

        //Perform operation
        [MOD(SYS_LOGISTICS),_operation,[_object,_container]] call ALiVE_fnc_logistics;
    };
} foreach _typesLogistics;

_cargo;
