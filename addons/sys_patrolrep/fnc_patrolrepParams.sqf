#include <\x\alive\addons\sys_patrolrep\script_component.hpp>
SCRIPT(patrolrepParams);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_patrolrepParams
Description:

Creates the parameter configuration module

Parameters:
_this select 0: OBJECT - Reference to module logic

Returns:
Nil

See Also:
- <ALIVE_fnc_patrolrep>

Author:
Highhead

Peer Reviewed:
nil
---------------------------------------------------------------------------- */
if !(isServer) exitwith {};

private ["_logic"];

PARAMS_1(_logic);

_debug = _logic getvariable ["DEBUG","false"];

waituntil {!isnil QMOD(SYS_patrolrep)};

MOD(SYS_patrolrep) setvariable ["DEBUG", call compile _debug, true];

_logic