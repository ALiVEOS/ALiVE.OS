#include <\x\alive\addons\sys_perf\script_component.hpp>
SCRIPT(perfDisable);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_perfDisable
Description:
Disables the Perf Module

Parameters:
None

Returns:
Nil

See Also:
- <ALIVE_fnc_statistics>

Author:
Tupolov

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

GVAR(ENABLED) = false;
PublicVariable QGVAR(ENABLED);

GVAR(DISABLED) = true;
PublicVariable QGVAR(DISABLED);

