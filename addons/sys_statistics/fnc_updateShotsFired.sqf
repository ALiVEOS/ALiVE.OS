/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_updateShotsFired
Description:
Updates shots fired count on server

Parameters:
String - player UID
Array - players shots fired count

Returns:
Nothing

Attributes:
None

Parameters:
_this select 0: STRING - uid
_this select 1: ARRAY - shots fired array

Examples:
(begin example)
        [[_uid, GVAR(playerShotsFired)],"ALiVE_fnc_updateShotsFired", false, true] call BIS_fnc_MP;
(end)

See Also:
- <ALIVE_sys_stat_fnc_playerFired>

Author:
Tupolov
---------------------------------------------------------------------------- */
// MAIN
#define DEBUG_MODE_FULL

#include "script_component.hpp"

private ["_uid","_shots"];

// diag_log str(_this);

_uid = _this select 0;
_shots = _this select 1;

[GVAR(shotsFired), _uid, _shots] call ALiVE_fnc_hashSet;
