#include "script_component.hpp"
SCRIPT(getData);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_getData

Description:
Gets a custom variable to mission data

Parameters:
STRING - Key name

Returns:
ANY - value

Examples:
(begin example)
 _result = ["key"] call ALIVE_fnc_getData
(end)

Author:
Tupolov
Peer Reviewed:

---------------------------------------------------------------------------- */
private ["_key", "_result"];

_key = _this select 0;

if (typeName _key == "STRING") then {
	_result = [GVAR(mission_data), _key] call ALiVE_fnc_hashGet;
} else {
	_result = "ERROR";
};

_result;