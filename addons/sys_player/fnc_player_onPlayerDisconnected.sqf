/*
 * Filename:
 * fnc_player_onPlayerDisconnected.sqf
 *
 * Description:
 * handled onPlayerDisconnected event for sys_player, saving player data when they disconnect
 *
 * Created by Tupolov
 * Creation date: 06/08/2013
 *
 * */

// ====================================================================================
// MAIN

#include "script_component.hpp"

if (!isNil QMOD(sys_player) && isDedicated) then {
	private ["_unit","_id","_uid","_name","_check","_result","_test"];

	_unit = objNull;

	TRACE_1("SYS PLAYER DISCONNECT", _this);

	["ALiVE SYS_PLAYER - DISCONNECT"] call ALIVE_fnc_dump;

	_id = _this select 0;
	_name = _this select 1;
	_uid = _this select 2;

	if (_name == "__SERVER__") exitWith {

		if (!isNil "ALIVE_sys_data" && {!ALIVE_sys_data_DISABLED}) then {
			_result = [MOD(sys_player), "savePlayers", [false]] call ALIVE_fnc_player;

			["ALiVE SYS_PLAYER - SAVING PLAYER DATA: %1",_result] call ALIVE_fnc_dump;
		};
		MOD(sys_player) setVariable ["saved", true];
	};

	// Cater for non player situations
	if (_uid == "") exitWith {
		["ALiVE SYS_PLAYER -  PLAYER DOES NOT HAVE UID, EXITING."] call ALIVE_fnc_dump;
	};

	{
		if (getPlayerUID _x == _uid) exitwith {
			["ALiVE SYS_PLAYER -  PLAYER UNIT FOUND IN PLAYABLEUNITS (%1)",_x] call ALIVE_fnc_dump;
			_unit = _x;
		};
	} foreach playableUnits;

	if (isNull _unit) then {
		private ["_timeDiff","_lastPlayerSaveTime"];

		["ALiVE SYS_PLAYER - PLAYER UNIT NOT FOUND IN PLAYABLEUNITS (%1)",_name] call ALIVE_fnc_dump;

		// Work out when the last player save was and report the difference

		_lastPlayerSaveTime = [MOD(sys_player), "getPlayerSaveTime", [_uid]] call ALIVE_fnc_player;
		_timeDiff = (dateToNumber date) - _lastPlayerSaveTime;

		["ALiVE SYS_PLAYER - Have not saved player state for %2 for %1 seconds",_timeDiff,_name] call ALIVE_fnc_dump;

	} else {

		if !(_unit getVariable [QGVAR(kicked), false]) then {
			_result = [MOD(sys_player), "setPlayer", [_unit]] call ALIVE_fnc_player;
			TRACE_1("SETTING PLAYER DATA", _result);
		} else {
			_unit setVariable [QGVAR(kicked), false, true];
		};
	};

	MOD(sys_player) setVariable [_uid, false, true];

	_test = MOD(sys_player) getVariable [_uid, false];
	TRACE_1("REMOVING PLAYER GUID FROM LOGIC", _test);

	TRACE_1("",MOD(player_count));

};

// ====================================================================================