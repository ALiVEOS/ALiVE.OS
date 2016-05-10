/*
 * Filename:
 * fnc_player_onPlayerConnected.sqf
 *
 * Description:
 * handled onPlayerConnected event for sys_player
 *
 * Created by Tupolov
 * Creation date: 06/08/2013
 *
 * */

// ====================================================================================
// MAIN

#include "script_component.hpp"

if (!isNil QMOD(sys_player) && isDedicated) then {

	private ["_id","_uid","_name","_module", "_result"];

	_module = "players";

	TRACE_1("SYS_PLAYER PLAYER CONNECT", _this);

	_id = _this select 0;
	_name = _this select 1;
	_uid = _this select 2;
	_owner = _this select 3;

	if (_name == "__SERVER__" || _uid == "") exitWith {

		["ALiVE SYS_PLAYER - EXITING AS SERVER IS UNIT CONNECTING OR UID IS NIL", _name, _uid] call ALIVE_fnc_dump;
		// MOVED TO MODULE INIT

	};

	// Disable user input?
	// Disallow damage?
	// Black Screen?

	// If not server then wait for server to load data, wait for player to connect and player object to get assigned then proceed

	[_uid, _name, _owner] spawn {
		private ["_owner","_data","_unit","_uid","_name","_check"];

		_uid = _this select 0;
		_name = _this select 1;
		_owner = _this select 2;

		_unit = objNull;

		_check = MOD(sys_player) getVariable ["init", false];
		// Wait for player module to init
		TRACE_3("Waiting for player module to init",_name, _uid, _check);
		waitUntil  {sleep 0.3; _check = MOD(sys_player) getVariable ["init", false]; TRACE_2("Waiting for init",_check,_name); _check};
		sleep 0.2;
		TRACE_3("Player module init complete",_name, _uid, _check);

		_check = MOD(sys_player) getVariable [_uid, false];

		// Wait for player data to be loaded by server
		TRACE_3("Waiting for player to connect", _name, _uid, _check);
		waitUntil  {sleep 0.3; _check = MOD(sys_player) getVariable [_uid, false]; TRACE_3("Waiting for player", _name, _uid, _check); _check};

		sleep 0.2;
		TRACE_3("Player connected",_name, _uid, _check);

		TRACE_1("Playable Units", playableUnits);

		_unit = [_uid] call ALIVE_fnc_getPlayerByUIDOnConnect;

		if (isNull _unit) then {
			diag_log[format["SYS_PLAYER: PLAYER UNIT NOT FOUND IN PLAYABLEUNITS(%1)",_name]];

			/// Hmmmm connecting player isn't found...

		} else {

			["ALiVE SYS_PLAYER - PLAYER UNIT FOUND IN PLAYABLEUNITS (%1)",_unit] call ALIVE_fnc_dump;
			// Ask player if they want to be restored first?

			["DATA: Restoring player data for %1", _unit] call ALIVE_fnc_dump;
			// Apply data to player object
			TRACE_3("Sending player data to", _name, _uid, _owner);
			_result = [MOD(sys_player), "getPlayer", [_unit, _owner]] call ALIVE_fnc_player;

			TRACE_1("GETTING PLAYER DATA", _result);

		};
	};
};

// ====================================================================================