#include "\x\alive\addons\x_lib\script_component.hpp"
#include "\x\cba\addons\hashes\script_hashes.hpp"
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

PROFILE_SCOPE(EVENTCREATE, "ALiVE event: create")

params [
	"_type",
	["_data", []],
	["_from",""],
	["_message",""]
];

[TYPE_HASH, ["type","data","from","message","id"], [_type,_data,_from,_message,0], nil]
