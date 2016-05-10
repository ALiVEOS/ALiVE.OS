#include <\x\alive\addons\sys_spotrep\script_component.hpp>
SCRIPT(spotrepParams);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_spotrepParams
Description:

Creates the parameter configuration module

Parameters:
_this select 0: OBJECT - Reference to module logic

Returns:
Nil

See Also:
- <ALIVE_fnc_spotrep>

Author:
Highhead

Peer Reviewed:
nil
---------------------------------------------------------------------------- */
if !(isServer) exitwith {};

private ["_logic"];

PARAMS_1(_logic);

_debug = _logic getvariable ["DEBUG","false"];

waituntil {!isnil QMOD(SYS_spotrep)};

MOD(SYS_spotrep) setvariable ["DEBUG", call compile _debug, true];

_logic