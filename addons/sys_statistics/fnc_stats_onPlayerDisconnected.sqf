/*
 * Filename:
 * fnc_stats_onPlayerDisconnected.sqf
 *
 * Description:
 * handled onPlayerDisconnected event for sys_statistics, saving player data when they disconnect
 *
 * Created by Tupolov
 * Creation date: 06/07/2013
 *
 * */

// ====================================================================================
// MAIN

#include "script_component.hpp"

if (GVAR(ENABLED)) then {
	private ["_class","_puid","_PlayerSide","_PlayerFaction","_startTime","_endTime","_minutesPlayed","_data","_shotsFired","_shotsFiredData","_unit","_playerType","_score","_rating","_id","_uid","_name","_rank"];

	_unit = objNull;

	TRACE_1("STATS PLAYER DISCONNECT", _this);

	_id = _this select 0;
	_name = _this select 1;
	_uid = _this select 2;

	// diag_log [str(_id), _name, _uid];

	if (_name == "__SERVER__") exitWith {

		// _minutesPlayed = floor(( (dateToNumber date) - ( dateToNumber GVAR(timeStarted)) ) * 525600);
		_minutesPlayed = round(( diag_tickTime - GVAR(timeStarted))/60);


			// Format Data
			_data = [ ["Event","OperationFinish"] , ["timePlayed", _minutesPlayed] ];

			// Send Data
			GVAR(UPDATE_EVENTS) = _data;
			publicVariableServer QGVAR(UPDATE_EVENTS);

	};

	// Cater for non player situations
	if (_uid == "" || isHC) exitWith {
		diag_log["SYS_STATS: PLAYER DOES NOT HAVE UID OR IS HEADLESS, EXITING."];
	};

	{
		if (getPlayerUID _x == _uid) exitwith {
			diag_log[format["SYS_STATS: PLAYER UNIT FOUND IN PLAYABLEUNITS (%1)",_x]];
			_unit = _x;
		};
	} foreach playableUnits;

	if (isNull _unit) then {
		diag_log["SYS_STATS: PLAYER UNIT NOT FOUND IN PLAYABLEUNITS"];

		// Can we still send some data to the DB?
		_class = "Unknown";
		_PlayerSide = "Unknown";
		_PlayerFaction = "Unknown";
		_playerType = "Unknown";
		_minutesPlayed = ceil(time / 60);
		_shotsFiredData = [];
		_score = 0;
		_rating = 0;
		_rank = "PRIVATE";

	} else {

		_class = getText (configFile >> "cfgVehicles" >> (typeof _unit) >> "displayName");
		_PlayerSide = side (group _unit); // group side is more reliable
		_PlayerFaction = faction _unit;
		_playerType = typeof _unit;

		// Calculate Minutes Played
		private "_playertime";
		_playertime = [GVAR(PlayerStartTime), _uid, GVAR(timeStarted)] call ALIVE_fnc_hashGet;
		_minutesPlayed = round((diag_tickTime - _playertime)/60);

		// Get score, rating and rank
		_score = score _unit;
		_rating = rating _unit;
		_rank = rank _unit;

		// Get Shots Fired
		_waitTime = diag_tickTime + 3000;
		// Grab shots fired data (wait for it?)
		waitUntil {sleep 1; _shotsfired = [GVAR(shotsFired), _uid, []] call ALiVE_fnc_hashGet; count _shotsfired > 0 || diag_tickTime > _waitTime};

		if (count _shotsfired > 0) then {
			diag_log format["Saving shots fired: %1", _shotsfired];
			_shotsFiredData = [];
			{
				private ["_weaponCount","_weapon","_count","_muzzle","_shotsFiredHash"];
				if (typename _x == "ARRAY") then {
					_shotsFiredHash = [] call CBA_fnc_hashCreate;
					[_shotsFiredHash, "weaponMuzzle", _x select 0] call CBA_fnc_hashSet;
					[_shotsFiredHash, "count", _x select 1] call CBA_fnc_hashSet;
					[_shotsFiredHash, "weaponType", _x select 2] call CBA_fnc_hashSet;
					[_shotsFiredHash, "weaponName", _x select 3] call CBA_fnc_hashSet;
					_shotsFiredData = _shotsFiredData + [ _shotsFiredHash ] ;
				};
			} foreach _shotsFired;
		} else {
			_shotsFiredData = [];
		};

	};

	// Format Data
	_data = [ ["Event","PlayerFinish"] , ["PlayerSide",_PlayerSide] , ["PlayerFaction",_PlayerFaction] , ["PlayerName",_name] , ["PlayerType",_PlayerType] , ["PlayerClass",_class] , ["Player", _uid] , ["shotsFired", _shotsFiredData] , ["timePlayed",_minutesPlayed], ["score",_score], ["rating",_rating], ["PlayerRank",_rank], ["playerGroup", [_unit] call ALiVE_fnc_getPlayerGroup] ];

	// Send Data
	GVAR(UPDATE_EVENTS) = _data;
	publicVariableServer QGVAR(UPDATE_EVENTS);

};

// ====================================================================================