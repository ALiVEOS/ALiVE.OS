#include <\x\alive\addons\sys_player\script_component.hpp>
SCRIPT(setPlayer);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_setPlayer
Description:
Get current player object data and save to in memory store

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

_data =  [];

_player = _args select 0;

_playerHash = [] call CBA_fnc_hashCreate;

TRACE_1("SET PLAYER",_this);

// ensure last document revision is passed with the new player record if it exists
if (_player getVariable ["_rev","MISSING"] != "MISSING") then {
	[_playerHash, "_rev", _player getVariable "_rev"] call CBA_fnc_hashSet;
};

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

/* LOADOUT IS NOW UPDATED VIA CLIENT UPDATES NOT FROM SERVER, need to incorp GVAR(gear_data)
if ( _saveLoadout) then {
	_data =_data + GVAR(LOADOUT_DATA);
};*/

if ( _saveScores) then {
	_data =_data + GVAR(SCORE_DATA);
};

TRACE_5("SYS_PLAYER SET",_saveLoadout,_saveHealth,_savePosition,_saveScores, count _data);

// Run data collection commands
{
	private ["_key","_cmd","_value"];
	_key = _x select 0;
	_cmd = _x select 1;
	_value = [_player] call _cmd;
	if (isNil "_value") then {
		TRACE_2("SYS_PLAYER ERROR TRYING TO COLLECT PLAYER DATA",_player, _cmd);
		_value = "";
	} else {
		TRACE_3("SYS_PLAYER SET PLAYER DATA",_player, _key, _value);
	};
	[_playerHash, _key, _value] call CBA_fnc_hashSet;
} foreach _data;

// Add gear data to player's hash
private ["_gearHash","_addGear"];
_gearHash = [GVAR(gear_data), getPlayerUID _player, "NONE"] call ALIVE_fnc_hashGet;

_addGear = {
	[_playerHash, _key, _value] call ALIVE_fnc_hashSet;
	TRACE_3("SYS_PLAYER SET PLAYER DATA",_player, _key, _value);
};

if ([_gearHash] call ALIVE_fnc_isHash) then {
	[_gearHash, _addGear] call CBA_fnc_hashEachPair;
} else {
	["No gear found for %1", _player] call ALivE_fnc_dump;
//	_playerHash call ALIVE_fnc_inspectHash;
};


// Add player hash to player data
_result = _playerHash;

_result;




