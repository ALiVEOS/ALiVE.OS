#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(dumpMP);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_dumpMP

Description:
Dumps variables to the RPT file and also to the MP clients on sidechat

Parameters:
Mixed

Returns:

Examples:
(begin example)
// dump variable 
[getPos player] call ALIVE_fnc_dumpMP;

// dump as format 
["position: %1", getPos player] call ALIVE_fnc_dumpMP;
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
	if(_variableType == "STRING") then {
		_output = _variable;
	} else {
		_output = str _variable;
	};
};

diag_log text _output;
[_output] remoteExec ["ALiVE_fnc_sideC",0];