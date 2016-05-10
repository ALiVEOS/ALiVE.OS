#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(dumpH);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_dumpH

Description:
Dumps variables to the RPT file and also displays a hint

Parameters:
Mixed

Returns:

Examples:
(begin example)
// dump variable 
[getPos player] call ALIVE_fnc_dumpH;

// dump as format 
["position: %1", getPos player] call ALIVE_fnc_dumpH;
(end)

See Also:

Author:
Highhead, Arjay
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
hint _output;