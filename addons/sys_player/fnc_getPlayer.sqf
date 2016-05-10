#include <\x\alive\addons\sys_player\script_component.hpp>
SCRIPT(getPlayer);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_getPlayer
Description:
Apply player state data to current player object

Parameters:
Object - If Nil, return a new instance. If Object, reference an existing instance.
Array - The selected parameters

Returns:
Hash - Array of player data

Examples:
(begin example)
//
(end)

See Also:
- <ALIVE_fnc_playerInit>
- <ALIVE_fnc_playerMenuDef>

Author:
Tupolov

Peer reviewed:
nil
---------------------------------------------------------------------------- */

private ["_logic","_args","_player","_find","_saveLoadout","_saveHealth","_savePosition","_saveScores","_data","_playerHash","_result","_data"];

_logic = [_this, 0, objNull, [objNull,[]]] call BIS_fnc_param;
_args = [_this, 1, objNull, [objNull,[],"",0,true,false]] call BIS_fnc_param;

_player = _args select 0;
_playerHash = _args select 1;

_result = false;

TRACE_2("SYS_PLAYER GET PLAYER ON CLIENT", _player, _playerHash);

if (local _player) then {

	// Store the data on client in case of reset requested
	_player setVariable [QGVAR(player_data), _playerHash];
	GVAR(resetAvailable) = true;

	// Store the document revision number on the player object
	_player setVariable ["_rev", [_playerHash,"_rev"] call CBA_fnc_hashGet, true];

	// Get save options
	_saveLoadout = _logic getvariable ["saveLoadout",true];
	_saveHealth = _logic getvariable ["saveHealth",true];
	_savePosition = _logic getvariable ["savePosition",true];
	_saveScores = _logic getvariable ["saveScores",true];
	_saveAmmo = _logic getvariable ["saveAmmo",false];

	// Create Data Command Array
	_data = GVAR(UNIT_DATA);

	if ( _savePosition) then {
		_data = _data + GVAR(POSITION_DATA);
	};

	if ( _saveHealth) then {
		_data = _data + GVAR(HEALTH_DATA);
	};

	if ( _saveLoadout) then {
		_data =_data + GVAR(LOADOUT_DATA);
	};

	if ( _saveScores) then {
		_data =_data + GVAR(SCORE_DATA);
	};

	TRACE_5("SYS_PLAYER GET PLAYER SETTINGS",_saveLoadout,_saveHealth,_savePosition,_saveScores, count _data);

	// Run data commands
	{
		private ["_key","_cmd","_value"];
		_key = _x select 0;
		_value = [_playerHash, _key] call CBA_fnc_hashGet;
		_cmd = _x select 2;

		if (typeName _cmd != "STRING") then {
			// Execute
			[_player,_value] call _cmd;

			TRACE_3("SYS_PLAYER GET PLAYER DATA", _player, _key, _value);
		} else {
			TRACE_1("SKIPPING GET PLAYER CMD",_cmd);
		};

	} foreach _data;

	_player setVariable[QGVAR(playerloaded), true];

	_result = true;
};

_result;
