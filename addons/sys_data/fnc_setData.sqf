#include "script_component.hpp"
SCRIPT(setData);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_setData

Description:
sets a custom variable to mission data

Parameters:
STRING - Key name
ANY - Value

Returns:
BOOL - success

Examples:
(begin example)
 _result = ["key", _value] call ALIVE_fnc_setData
(end)

Author:
Tupolov
Peer Reviewed:

---------------------------------------------------------------------------- */
private ["_key","_value", "_result"];

_key = _this select 0;
_value = _this select 1;

if (typeName _key == "STRING" && [str(_value)] call CBA_fnc_strLen < 10000) then {
	[GVAR(mission_data), _key, _value] call ALiVE_fnc_hashSet;
	_result = true;
} else {
	_result = false;
};

_result;