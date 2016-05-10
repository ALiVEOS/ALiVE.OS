#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(baseClass);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_baseClass
Description:
Base class

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Attributes:
Nil - create - Create instance
Nil - destroy - Destroy instance

Examples:
(begin example)
// Create instance
_logic = [nil, "create"] call ALIVE_fnc_BaseClass;

// Destroy instance
[_logic, "destroy"] call ALIVE_fnc_BaseClass;
(end)

See Also:
- nil

Author:
Wolffy.au

Peer reviewed:
nil
---------------------------------------------------------------------------- */
private ["_result"];

if(
	isNil "_this" ||
	{typeName _this != "ARRAY"} ||
	{count _this == 0} ||
	{typeName (_this select 0) != "OBJECT"}
) then {
	_this = [objNull, "create"];
};

TRACE_1("baseClass - input",_this);

params [
    ["_logic", objNull, [objNull]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,[],"",0,true,false]]
];
_result = true;

switch(_operation) do {
	default {
		private["_err"];
		_err = format["%1 does not support ""%2"" operation", _logic, _operation];
		_err call ALiVE_fnc_logger;
	};
	case "create": {
		// Create a module object for settings and persistence
		_logic = createAgent ["LOGIC", [0,0], [], 0, "NONE"];
		_logic setVariable ["class", ALIVE_fnc_baseClass];
		_logic enableSimulation false;
		_result = _logic;
	};
	case "destroy": {
		_logic setVariable ["class", nil];
		deleteVehicle _logic;
	};
};
TRACE_1("baseClass - output",_result);
_result;
