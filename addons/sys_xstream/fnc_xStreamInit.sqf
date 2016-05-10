#include <\x\alive\addons\sys_xstream\script_component.hpp>
SCRIPT(xstreamInit);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_xstreamInit
Description:
Creates the server side object to store settings

Parameters:
_this select 0: OBJECT - Reference to module
_this select 1: ARRAY - Synchronized units

Returns:
Nil

See Also:
- <ALIVE_fnc_xstream>

Author:
Tupolov

Peer Reviewed:

---------------------------------------------------------------------------- */

private ["_logic","_moduleID"];

PARAMS_1(_logic);
//DEFAULT_PARAM(1,_syncunits, []);

// Confirm init function available
ASSERT_DEFINED("ALIVE_fnc_xstream","Main function missing");

_moduleID = [_logic, true] call ALIVE_fnc_dumpModuleInit;

[_logic, "init"] call ALIVE_fnc_xstream;

[_logic, false, _moduleID] call ALIVE_fnc_dumpModuleInit;