#include <\x\alive\addons\sys_sitrep\script_component.hpp>
SCRIPT(sitrepParams);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_sitrepParams
Description:

Creates the parameter configuration module

Parameters:
_this select 0: OBJECT - Reference to module logic

Returns:
Nil

See Also:
- <ALIVE_fnc_sitrep>

Author:
Highhead

Peer Reviewed:
nil
---------------------------------------------------------------------------- */
if !(isServer) exitwith {};

private ["_logic"];

PARAMS_1(_logic);

_debug = _logic getvariable ["DEBUG","false"];

waituntil {!isnil QMOD(SYS_sitrep)};

MOD(SYS_sitrep) setvariable ["DEBUG", call compile _debug, true];

_logic