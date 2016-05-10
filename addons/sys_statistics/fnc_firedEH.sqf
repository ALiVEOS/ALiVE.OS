/* 
 * Filename:
 * FiredEH.sqf 
 *
 * Description: Records information if a player in a vehicle, aircraft, ship or static weapon fires in game
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
	private ["_weapon","_muzzle","_unit","_projSim"];
	_unit = _this select 0; 
	_weapon = _this select 1;
	_muzzle = _this select 2;
	_projectile = _this select 4;

	if (isPlayer _unit) exitWith {
		_projSim = getText (configFile >> "cfgAmmo" >> _projectile >> "simulation");
		if (_projSim != "shotMissile") then {
			[_unit, _weapon, _muzzle] call GVAR(fnc_playerfiredEH);
		};
	};

	TRACE_5("FiredEH",_unit,_weapon,_muzzle,_projectile, _projSim);
		
		//diag_log["unitFired: ", _this];
};
// ====================================================================================