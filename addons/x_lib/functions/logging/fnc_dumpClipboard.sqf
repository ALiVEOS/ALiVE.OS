#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(dumpClipboard);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_dumpClipboard

Description:
Dumps string to clipboard

Parameters:
Mixed

Returns:

Examples:
(begin example)

// dump as format 
["position: %1", getPos player] call ALIVE_fnc_dumpClipboard;

// flush to clipboard
[true] call ALIVE_fnc_dumpClipboard;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */
private ["_variable","_variableType","_output"];
	
_variable = _this select 0;
_variableType = typename _variable;
_output = "";

if(isNil "ALIVE_dumpClipboard") then {
    ALIVE_dumpClipboard = "";
};

if(_variableType == "BOOL") then {
    ["Results dumped to clipboard.. %1",_variable] call ALIVE_fnc_dump;
    copyToClipboard ALIVE_dumpClipboard;
}else{
    _variable = str(formatText _this);
    ALIVE_dumpClipboard = ALIVE_dumpClipboard + (_variable + '@');
};