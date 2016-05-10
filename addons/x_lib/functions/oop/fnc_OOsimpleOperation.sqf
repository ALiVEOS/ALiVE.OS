#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(OOsimpleOperation);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_OOsimpleOperation

Description:
Provides simple set/get code for objects

Parameters:
Object - Reference an existing instance.
String - The selected function operation
Any - The selected parameter(s)
Any - Default value
Array - List of valid values (optional)

Returns:
Any - Returns the validated value

Examples:
(begin example)
_result = [
	_logic,
	_operation,
	_args,
	"SYM",
	["ASYM","SYM"]
] call ALIVE_fnc_OOsimpleOperation;
(end)

Author:
Wolffy.au

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

private ["_logic","_operation","_args","_default","_choices","_limited"];
PARAMS_4(_logic,_operation,_args,_default);
DEFAULT_PARAM(4,_choices,[]);

_limited = false;

// are the option choices empty?
if(typeName _choices == "ARRAY" &&
{count _choices > 0}) then {
	_limited = true;
};

// is _args objNull (default)?
if(typeName _logic == "OBJECT" &&
{typeName _args == "OBJECT"} &&
{isNull _args}) then {
	// if so, grab the default value
	_args = _logic getVariable [_operation, _default];
};
// is _args Hash (default)?
if(typeName _logic == "ARRAY" &&
{typeName _args == "OBJECT"} &&
{isNull _args}) then {
	// if so, grab the default value
	_args = [_logic, _operation, _default] call ALIVE_fnc_hashGet;
};

// is _args the right typeName?
if(typeName _args != typeName _default) then {
	// if so, grab the default value
	_args = _default;
};

if(_limited) then {
	// check if _args is one of the choices
	// otherwise default
	if(!(_args in _choices)) then {_args = _default;};
};

// set final value
if(typeName _logic == "OBJECT") then {
	_logic setVariable [_operation, _args];
};
// is _args Hash
if(typeName _logic == "ARRAY") then {
	// if so, grab the default value
	[_logic, _operation, _args] call ALIVE_fnc_hashSet;
};

//diag_log PFORMAT_2(_fnc_scriptNameParent,_operation,_args);

// return value
_args;
