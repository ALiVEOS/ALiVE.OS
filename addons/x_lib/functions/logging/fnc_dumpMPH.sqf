#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(dumpMPH);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_dumpMPH

Description:
Dumps variables to the RPT file and also to the MP clients on hintsilent

Parameters:
Mixed

Returns:

Examples:
(begin example)
// dump variable 
[getPos player] call ALIVE_fnc_dumpMPH;

// dump as format 
["position: %1", getPos player] call ALIVE_fnc_dumpMPH;
(end)

See Also:

Author:
ARJay, Highhead
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
	if(_variableType == "STRING" || {_variableType == "TEXT"}) then {
		_output = _variable;
	} else {
		_output = str _variable;
	};
};

diag_log _output;
[_output] remoteExec ["ALiVE_fnc_hintS",0];