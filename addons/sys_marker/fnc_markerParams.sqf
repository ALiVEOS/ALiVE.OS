#include <\x\alive\addons\sys_marker\script_component.hpp>
SCRIPT(markerParams);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_markerParams
Description:

Creates the parameter configuration module

Parameters:
_this select 0: OBJECT - Reference to module logic

Returns:
Nil

See Also:
- <ALIVE_fnc_marker>

Author:
Highhead

Peer Reviewed:
nil
---------------------------------------------------------------------------- */
if !(isServer) exitwith {};

private ["_logic"];

PARAMS_1(_logic);

_debug = _logic getvariable ["DEBUG","false"];

waituntil {!isnil QMOD(SYS_marker)};

MOD(SYS_marker) setvariable ["DEBUG", call compile _debug, true];

_logic