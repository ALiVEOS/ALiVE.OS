#include <\x\alive\addons\sup_combatSupport\script_component.hpp>
SCRIPT(packMortar);

/*
	File: fn_packStaticWeapon.sqf
	Author: Dean "Rocket" Hall - Updated by Tupolov for Mortars

	Description:
	Function which uses a weapon team to pack a static weapon such
	as the HMG or Mortar. Requires three personnel in the team as
	a minimum (leader, gunner, assistant).

	Parameter(s):
	_this select 0: the support team group (group)
	_this select 1: the weapon (option if weapon registered as "supportWeaponSetup" variable)
*/
private["_group","_weapon","_position","_leader","_units","_gunner","_assistant","_type","_wait"];

_group = 	[_this, 0, grpNull] call bis_fnc_param;
_weapon = 	[_this, 1, grpNull] call bis_fnc_param;
_type = 	typeOf _weapon;
_position = position _weapon;
_leader = 	leader _group;
_gunner = 	gunner _weapon;
_units = 	(units _group) - [_leader];
_units =	_units - [_gunner];

if (_weapon == objNull || isNil "_weapon" || _group == grpNull || _leader == objNull) exitWith {};

{
	// find a group member that is not in a vehicle or staticweapon and is free
	if !(_x getVariable ["packAssistant",false] || (vehicle _x != _x)) exitWith {
		_assistant = _x;
		_assistant setVariable ["packAssistant",true];
	};
} foreach _units;

// diag_log format ["%1, %2, %3, %4, %5, %6, %7", _group, _weapon, _position, _leader, _gunner, _assistant, _type];

_gunner leaveVehicle _weapon;

_gunner addEventHandler ["WeaponDisassembled", {
	_this spawn {
		private ["_unit","_bag1","_bag2"];
		_unit = _this select 0;
		_bag1 = _this select 1;
		_bag2 = _this select 2;

		_unit setVariable ["supportWeaponBag1", _bag1];
		_unit setVariable ["supportWeaponBag2", _bag2];
	};
}];

_gunner action ["Disassemble",_weapon];

{
	_x enableAI "MOVE";
	_x enableAI "ANIM";
	_x setUnitPos "AUTO";
} forEach [_gunner, _assistant];

{
    [_x,position _weapon] call ALiVE_fnc_doMoveRemote;
} foreach [_gunner, _assistant];

[_weapon, _gunner, _assistant] spawn {
	private ["_weapon","_gunner","_assistant","_position","_wait","_bag2","_bag1","_timeout","_packs"];
	_weapon = _this select 0;
	_gunner = _this select 1;
	_assistant = _this select 2;
	_position = position _weapon;

	_timer = time;
	waitUntil {sleep 0.3; _gunner call ALiVE_fnc_unitReadyRemote || (time-_timer > 30)};

	_gunner action ["Disassemble",_weapon];

	_wait = true;
	_timeout = false;
	_timer = time;
	while {_wait} do {
		_packs = nearestObjects [_position, ["GroundWeaponHolder"], 3];
		if (count _packs > 1) then {_wait = false};
		if ((time-_timer) > 30) exitWith {_timeout = true;};
		sleep 1;
	};

	if (_timeout) then {
        _bag1 = format ["%1_Mortar_01_weapon_F", _weapon select [0,1]];
        _bag2 = format ["%1_Mortar_01_support_F",_weapon select [0,1]];
		deleteVehicle _weapon;
		_gunner addBackpackGlobal _bag1;
		_assistant addBackpackGlobal _bag2;
	} else {
		_bag1 = _gunner getVariable ["supportWeaponBag1", objNull];
		_bag2 = _gunner getVariable ["supportWeaponBag2", objNull];
		_gunner action ["takeBag", _bag1];
		_assistant action ["takeBag", _bag2];
	};

	_timer = time;
	waitUntil {sleep 1; (unitBackpack _gunner == _bag1 && unitBackpack _assistant == _bag2) || (time-_timer) > 30};

	if (unitBackpack _gunner != _bag1) then {
		_gunner addBackpackGlobal (typeOf _bag1);
	};

	if (unitBackpack _assistant != _bag2) then {
		_assistant addBackpackGlobal (typeOf _bag2);
		{
			deleteVehicle _x;
		}foreach _packs;
	};

	_gunner setVariable ["supportWeaponGunner", _weapon];
	_assistant setVariable ["supportWeaponAsst", _weapon];
	_weapon setVariable ["packed",true];


//	diag_log format ["%1 packed up!",_weapon];
};