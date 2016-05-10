#include <\x\alive\addons\sys_statistics\script_component.hpp>
SCRIPT(statisticsDisable);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_statisticsDisable
Description:
Disables the Statistics Module

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

