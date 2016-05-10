#include <\x\alive\addons\sys_player\script_component.hpp>
SCRIPT(getGear);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_getGear
Description:
Apply player loadout data to current player object

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

_player = _args select 0;
_gearHash = _args select 1;

_result = false;

TRACE_2("SYS_PLAYER GET GEAR ON CLIENT", _player, _gearHash);

if (local _player) then {

	// Store the data on client in case of reset requested
	_player setVariable [QGVAR(gear_data), _gearHash];
	GVAR(gearResetAvailable) = true;

	// Create Data Command Array
	_data = GVAR(LOADOUT_DATA);

	TRACE_5("SYS_PLAYER GET GEAR", count _data);

	// Run data commands
	{
		private ["_key","_cmd","_value"];
		_key = _x select 0;
		_value = [_gearHash, _key] call CBA_fnc_hashGet;
		_cmd = _x select 2;

		if (typeName _cmd != "STRING") then {
			// Execute
			[_player,_value] call _cmd;

			TRACE_3("SYS_PLAYER GET GEAR DATA", _player, _key, _value);
		} else {
			TRACE_1("SKIPPING GET GEAR CMD",_cmd);
		};

	} foreach _data;

	_result = true;
};

_result;
