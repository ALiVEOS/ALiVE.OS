#include <\x\alive\addons\sup_combatSupport\script_component.hpp>
SCRIPT(unpackMortar);

/*
	File: fn_unpackStaticWeapon.sqf
	Author: Dean "Rocket" Hall, updated by Tupolov

	Description:
	Function which uses a weapon team to pack a static weapon such
	as the HMG or Mortar. Requires three personnel in the team as
	a minimum (leader, gunner, assistant).

	Parameter(s):
	_this select 0: the support team group (group)
	_this select 1: location to place gun (position)
	_this select 2: location of target (position)
*/
private ["_group","_position","_targetPos","_leader","_units","_gunner","_assistant","_weapon"];

//diag_log str(_this);

_group = 		[_this, 0, grpNull] call bis_fnc_param;
_position =		[_this, 1, grpNull] call bis_fnc_param;
_targetPos = 	[_this, 2, grpNull] call bis_fnc_param;
_weapon = 		[_this, 3, grpNull] call bis_fnc_param;
_units = 		(units _group);

{
	if (vehicle _x != _x) then {
		doGetOut _x;
	};
	if (_x getVariable ["supportWeaponGunner",objNull] == _weapon) then {
		_gunner = _x;
	};
	if (_x getVariable ["supportWeaponAsst",objNull] == _weapon) then {
		_assistant = _x;
	};
} foreach _units;

if (isNil "_gunner" || isNil "_assistant") exitWith {
	diag_log "Someone from the mortar team died";
	// reduce mortar count
    _sptCount = _grp getVariable ["supportWeaponCount",3];
    _grp setVariable ["supportWeaponCount", _sptCount - 1];
};

[_gunner, _assistant, _targetPos, _weapon, _group] spawn {

	private ["_gunner","_assistant","_pos","_tPos","_wait","_dirTo","_sptarr","_weapont", "_weapon","_grp","_timein","_timer","_sptCount"];

	_gunner = _this select 0;
	_assistant = _this select 1;
	_tPos = _this select 2;
	_weapont = typeOf (_this select 3);
	_grp = _this select 4;

	waitUntil{sleep 0.1; _gunner call ALiVE_fnc_unitReadyRemote};

	_gunner disableAI "move";

	_assistant disableAI "move";

	_assistant setpos (position _gunner);

	_assistant setUnitPos "Middle";

	_assistant action ["PutBag",_assistant];
	_gunner action ["Assemble",unitbackpack _gunner];

	_wait = true;
	_timein = true;
	_timer = time;
	while {_wait && _timein} do {
		_weapon = (nearestObjects [position _gunner, [_weapont], 3]) select 0;
		if (!isNil "_weapon") then {
			if (alive _weapon) then {_wait = false};
		};
		if (time-_timer > 60) then {_timein = false};
		sleep 1;
	};

	if (!_timein && _wait) then {
		diag_log format["unpack timedout %1",(nearestObjects [position _gunner, [], 3])];
		removeBackpackGlobal _gunner;
		removeBackpackGlobal _assistant;
		_weapon = createVehicle [_weapont, position _gunner, [], 3, "NONE"];
	};

    _sptarr = _grp getVariable ["supportWeaponArray",[]];
    _sptarr pushback _weapon;
    _grp setvariable ["supportWeaponArray", _sptarr];

	_dirTo = [position _weapon, _tPos] call BIS_fnc_dirTo;

	sleep 5;
	_gunner assignAsGunner _weapon;
	_gunner moveInGunner _weapon;
	sleep 5;

	_gunner commandWatch _tPos;

	_assistant selectWeapon "Binocular";
	sleep 6;
	_assistant commandWatch _tPos;
	_assistant setDir _dirTo;

	_gunner setVariable ["unpacked", true];
	_assistant setVariable ["packAssistant", false];

//	diag_log str(_grp getVariable ["supportWeaponArray",[]]);
};

_gunner