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
Jman
Peer Reviewed:

---------------------------------------------------------------------------- */
private ["_key", "_result"];

_key = _this select 0;

// A key never set answers nothing. Handed back straight from the lookup, as returning the unset _result logged an
// undefined-variable error every time a mission asked for a value it hadn't saved yet.
if !(typeName _key == "STRING") exitWith { "ERROR" };

[GVAR(mission_data), _key] call ALiVE_fnc_hashGet