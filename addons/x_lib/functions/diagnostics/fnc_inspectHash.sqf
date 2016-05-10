#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(inspectHash);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_inspectHash

Description:
Inspect an hash to the RPT

Parameters:

Returns:

Examples:
(begin example)
// inspect config class
_hash call ALIVE_fnc_inspectHash;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_target","_text","_level","_inspectRecurse"];
	
_target = _this;

_level = 0;

_text = " ------------------ Inspecting Hash -------------------- ";
[_text] call ALIVE_fnc_dump;

_inspectRecurse = {
	private ["_target","_level","_key","_value","_indent"];
	
	_target = _this select 0;
	_level = _this select 1;
	_level = _level + 1;
	
	{
		_key = _x;
		_value = [_target,_key] call ALIVE_fnc_hashGet;

		if([_value] call ALIVE_fnc_isHash) then {
			_indent = " ";
			for "_i" from 0 to _level-1 do {
				_indent = format["%1%2",_indent,_indent];
			};
			["%1 k: %2",_indent,_key] call ALIVE_fnc_dump;
			[_value,_level] call _inspectRecurse;
		} else {
			_indent = " ";
			for "_i" from 0 to _level-1 do {
				_indent = format["%1%2",_indent,_indent];
			};
			["%1 k [%4]: %2 v: %3",_indent,_key,_value,_forEachIndex] call ALIVE_fnc_dump;
		};		
	} forEach (_target select 1);
	
	_level = _level - 1;
};

[_target,_level] call _inspectRecurse;

_text = " ------------------ Inspection Complete -------------------- ";
[_text] call ALIVE_fnc_dump;