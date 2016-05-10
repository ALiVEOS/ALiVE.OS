#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(dump);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_dump

Description:
Dumps variables to the RPT file

Parameters:
Mixed

Returns:

Examples:
(begin example)
// dump variable 
[getPos player] call ALIVE_fnc_dump;

// dump as format 
["position: %1", getPos player] call ALIVE_fnc_dump;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */
private ["_variable","_variableType","_output"];
	
_variable = _this select 0;
_variableType = typename _variable;
_output = "";

if(count _this > 1) then {
	_variable = format _this;
};

if(isNil {_variableType}) then {
	_output = ["IS NIL"];
} else {
	if(_variableType == "STRING") then {
		_output = _variable;
	} else {
		_output = str _variable;
	};
};

diag_log text _output;