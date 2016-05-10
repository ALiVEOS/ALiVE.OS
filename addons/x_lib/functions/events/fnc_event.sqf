#include <\x\alive\addons\x_lib\script_component.hpp>
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

private ["_type","_data","_from","_message","_event"];

_type = _this select 0;
_data = if(count _this > 1) then {_this select 1} else {[]};
_from = if(count _this > 2) then {_this select 2} else {""};
_message = if(count _this > 3) then {_this select 3} else {""};

_event = [] call ALIVE_fnc_hashCreate;

[_event, "type", _type] call ALIVE_fnc_hashSet;
[_event, "data", _data] call ALIVE_fnc_hashSet;
[_event, "from", _from] call ALIVE_fnc_hashSet;
[_event, "message", _message] call ALIVE_fnc_hashSet;
[_event, "id", 0] call ALIVE_fnc_hashSet;

_event

