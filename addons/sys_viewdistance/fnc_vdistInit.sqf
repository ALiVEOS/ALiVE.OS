#include "\x\alive\addons\sys_viewdistance\script_component.hpp"
SCRIPT(vdistInit);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_vdistInit
Description:
Creates the server side object to store settings

Parameters:
_this select 0: OBJECT - Reference to module


Returns:
Nil

See Also:
- <ALIVE_fnc_vdist>

Author:
Gunny
Peer Reviewed:
nil
---------------------------------------------------------------------------- */

private ["_logic","_moduleID"];

PARAMS_1(_logic);
//DEFAULT_PARAM(1,_syncunits, []);

// Confirm init function available
ASSERT_DEFINED("ALIVE_fnc_vdist","Main function missing");

_moduleID = [_logic, true] call ALIVE_fnc_dumpModuleInit;

[_logic, "init"] call ALIVE_fnc_vdist;

[_logic, false, _moduleID] call ALIVE_fnc_dumpModuleInit;


