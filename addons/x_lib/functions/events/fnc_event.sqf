#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(event);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_event

Description:
Return an event hash

Parameters:
String - type
Mixed - data
String - from
String - message

Returns:
Hash event

Examples:
(begin example)
// create a new event
_result = ["world",[param1,param2],"OPCOM","Something happened!"] call ALIVE_fnc_event;
(end)

Author:
ARJay

Peer reviewed:
nil
---------------------------------------------------------------------------- */

params [
	"_type",
	["_data", []],
	["_from",""],
	["_message",""]
];

[
	[
		["type", _type],
		["data", _data],
		["from", _from],
		["message", _message],
		["id", 0]
	]
] call ALIVE_fnc_hashCreate