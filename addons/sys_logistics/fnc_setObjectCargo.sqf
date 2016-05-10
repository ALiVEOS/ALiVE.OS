#include <\x\alive\addons\sys_logistics\script_component.hpp>
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

private ["_input","_id","_cargo","_cargoR","_cargoT","_cargoL","_cargoWMI","_cargoW","_cargoM","_cargoI","_typesLogistics","_typesWeapons","_global"];

_input = [_this, 0, objNull, [objNull]] call BIS_fnc_param;
_id = [MOD(SYS_LOGISTICS),"id",_input] call ALiVE_fnc_Logistics;

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
if (isMultiplayer && {isServer}) then {_global = "Global"} else {_global = ""};

// Reset Magazines state
call (compile format["
			{_input removeMagazine%1 _x} forEach (magazines _input);
			{_input addMagazine [_x select 0,_x select 1]} foreach _ammo;
		",
	    _global
    ]
);

// Reset weapons and items state
_typesWeapons = [[_cargoW,"WeaponCargo"],[_cargoM,"MagazineCargo"],[_cargoI,"ItemCargo"]];
{
	private ["_content","_current","_operation"];
    
	_content = _x select 0;
    _operation = _x select 1;
    _current = call (compile format["get%1 _input",_operation]);
    
	if !(str(_content) == str(_current)) then {
        
        if (count (_current select 0) > 0) then {call (compile format["clear%1%2 _input",_operation,_global])};
        
		for "_i" from 0 to (count (_content select 0))-1 do {
	        private ["_type","_count"];
	        
		    _type = _content select 0 select _i;
		    _count = _content select 1 select _i;
	
		    call (compile format["_input add%1%2 %3",_operation,_global,[_type,_count]]);
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
