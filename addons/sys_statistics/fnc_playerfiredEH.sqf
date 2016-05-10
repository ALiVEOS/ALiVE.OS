/*
 * Filename:
 * playerFiredEH.sqf
 *
 * Description: Keeps a record of shots fired for each player. Fires globally, but only executed where player is local. Does not capture players firing from vehicles, see firedEH.
 *
 *
 * Created by Tupolov
 * Creation date: 19/05/2012
 *
 * */

// ====================================================================================
// MAIN

// #define DEBUG_MODE_FULL
#include "script_component.hpp"
if (GVAR(ENABLED)) then {
	private ["_player","_weapon","_muzzle"];

	_player = _this select 0;
	_weapon = _this select 1;
	_muzzle = _this select 2;

	if (player == _player || local _player) then {

		private ["_shotsfired","_weaponName","_i","_shots","_idx"];

		//diag_log format["playerFired: type:%1, vehicle:%2, %3", typeof _player, typeof vehicle _player, _this];

		_shotsfired = GVAR(playerShotsFired);

		// Find weapon in array
		_i = 0;
		_idx = 0;
		{
			private ["_currentWeapon"];
			_currentWeapon = _x;
			if ((_currentWeapon select 0) == _muzzle) then {
				_idx = _i;
			};
			_i = _i + 1;
		} foreach _shotsfired;

		_weaponName = getText (configFile >> "cfgWeapons" >> _weapon >> "displayName");

		if (_weaponName == "Throw") then {
			_weaponName = getText (configFile >> "cfgWeapons" >> _weaponName >> _muzzle >> "displayName");
			_weapon = _muzzle;
		};

		// Add weapon count to array
		if (_idx == 0) then {
			_shotsfired set [_i, [_muzzle, 1, _weapon, _weaponName]];

		} else {
			_shots = (_shotsfired select _idx) select 1;
			_shotsfired set [_idx, [_muzzle, _shots + 1, _weapon, _weaponName]];
		};

		// diag_log format["SF: %1", _shotsfired];

		GVAR(playerShotsFired) = _shotsfired;
	};
};
// ====================================================================================