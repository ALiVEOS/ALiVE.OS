/*
 * Filename:
 * fnc_stats_onPlayerConnected.sqf
 *
 * Description:
 * handled onPlayerConnected event for sys_statistics, reading player stats profile
 *
 * Created by Tupolov
 * Creation date: 06/07/2013
 *
 * */

// ====================================================================================
// MAIN

#include "script_component.hpp"

if (GVAR(ENABLED) && isDedicated) then {
	private ["_data","_unit","_id","_uid","_name","_module"];

	_unit = objNull;
	_module = "players";

	TRACE_1("STATS PLAYER CONNECT", _this);

	_id = _this select 0;
	_name = _this select 1;
	_uid = _this select 2;

	if (_name == "__SERVER__" || _uid == "") exitWith {};

    [_uid, _module] spawn {

        private ["_owner","_uid","_unit","_module"];

        _uid = _this select 0;
        _module = _this select 1;

        _unit = [_uid] call ALIVE_fnc_getPlayerByUIDOnConnect;

       	_owner = owner _unit;

		if (isNull _unit) then {
			diag_log["SYS_STATS: PLAYER UNIT NOT FOUND IN PLAYABLEUNITS"];

			/// Hmmmm connecting player isn't found...

		} else {
			private ["_profile","_stats","_tmp","_call","_cmd"];
			_profile = [GVAR(datahandler), "read", [_module, [], _uid]] call ALIVE_fnc_data;

			// CRAZY CALL TO GET STATS

			_call = format["events/_design/playerPage/_view/playerTotals?group_level=1&key=""%1""&stale=ok",_uid];
			_cmd = format ["SendJSON ['GET','%1','']", _call];

			_stats = [_cmd] call ALIVE_fnc_sendToPlugIn;

			_data = ((([nil,"decode", _stats] call ALIVE_fnc_JSON) select 1) select 0) select 3;

			// diag_log str(_data);

			if (!isNil "_data") then {

				_tmp = [] call CBA_fnc_hashCreate;
				for "_i" from 0 to ((count _data) - 1) step 2 do {
					private ["_key","_value"];
					_key = _data select _i;
					_value = _data select (_i + 1);
					[_tmp, _key, _value] call CBA_fnc_hashSet;
				};
				_data = _tmp;

				[_data, "Server Group", [_profile, "ServerGroup","Unknown"] call ALIVE_fnc_hashGet] call ALIVE_fnc_hashSet;
				[_data, "Username", [_profile, "username","Unknown"] call ALIVE_fnc_hashGet] call ALIVE_fnc_hashSet;

				// Send Data
				STATS_PLAYER_PROFILE = _data;
				_owner publicVariableClient "STATS_PLAYER_PROFILE";

				TRACE_3("SENDING PROFILE DATA TO CLIENT", _owner, _data, _unit);
			};

			// Set player startTime
			[GVAR(PlayerStartTime), getPlayerUID _unit, diag_tickTime] call ALIVE_fnc_hashSet;

			// Add an EH for your player object on everyone's locality - (Thanks BIS!)
			// Call is persistent so that all players are synced to any JIPs
			[[_unit], "ALIVE_fnc_addHandleHeal", true, true, true] spawn BIS_fnc_MP;

		};
	};

};

// ====================================================================================

