#include <\x\alive\addons\sys_player\script_component.hpp>
SCRIPT(setGear);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_setGear
Description:
Get current player loadout data and save to in memory store

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

private ["_logic","_args","_player","_find","_data","_gearHash","_result","_data"];

_logic = [_this, 0, objNull, [objNull,[]]] call BIS_fnc_param;
_args = [_this, 1, objNull, [objNull,[],"",0,true,false]] call BIS_fnc_param;

_data =  [];

_player = _args select 0;

_gearHash = [] call CBA_fnc_hashCreate;

// Create Data Command Array
_data = GVAR(LOADOUT_DATA);

TRACE_5("SYS_PLAYER GEAR SET", count _data);

// Run data collection commands
{
	private ["_key","_cmd","_value"];
	_key = _x select 0;
	_cmd = _x select 1;
	_value = [_player] call _cmd;
	if (isNil "_value") then {
		TRACE_2("SYS_PLAYER ERROR TRYING TO COLLECT GEAR DATA",_player, _cmd);
		_value = "";
	} else {
		TRACE_3("SYS_PLAYER SET GEAR DATA",_player, _key, _value);
	};
	[_gearHash, _key, _value] call CBA_fnc_hashSet;
} foreach _data;

// Add player hash to player data
_result = _gearHash;

_result;




