#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(inspectArray);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_inspectArray

Description:
Inspect an array to the RPT

Parameters:

Returns:

Examples:
(begin example)
// inspect config class
_array call ALIVE_fnc_inspectArray;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_target","_text","_level","_inspectRecurse"];
	
_target = _this;

_level = 0;

_text = " ------------------ Inspecting Array -------------------- ";
[_text] call ALIVE_fnc_dump;

_inspectRecurse = {
	private ["_target","_level","_value","_indent"];
	
	_target = _this select 0;
	_level = _this select 1;
	_level = _level + 1;
	
	{
	    if!(isNil '_x')then {
            _value = _x;

            if(typeName _value == "ARRAY") then {
                _indent = " ";
                for "_i" from 0 to _level-1 do {
                    _indent = format["%1%2",_indent,_indent];
                };
                ["%1 [%2] array",_indent,_forEachIndex] call ALIVE_fnc_dump;
                [_value,_level] call _inspectRecurse;
            } else {
                _indent = " ";
                for "_i" from 0 to _level-1 do {
                    _indent = format["%1%2",_indent,_indent];
                };
                ["%1 [%3] v: %2",_indent,_value,_forEachIndex] call ALIVE_fnc_dump;
            };
        };
	} forEach (_target);
	
	_level = _level - 1;
};

[_target,_level] call _inspectRecurse;

_text = " ------------------ Inspection Complete -------------------- ";
[_text] call ALIVE_fnc_dump;