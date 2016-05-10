#include <\x\alive\addons\sys_adminactions\script_component.hpp>
SCRIPT(adminActionsInit);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_adminActionsInit
Description:
Creates the server side object to store settings

Parameters:
_this select 0: OBJECT - Reference to module
_this select 1: ARRAY - Synchronized units

Returns:
Nil

See Also:
- <ALIVE_fnc_adminActions>

Author:
Wolffy.au

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

private ["_logic","_moduleID"];

PARAMS_1(_logic);
//DEFAULT_PARAM(1,_syncunits, []);

// Confirm init function available
ASSERT_DEFINED("ALIVE_fnc_adminActions","Main function missing");

if (isnil "_logic") then {_logic = [nil, "create"] call ALIVE_fnc_adminActions};

_moduleID = [_logic, true] call ALIVE_fnc_dumpModuleInit;
//_moduleID = [_logic, true] call ALIVE_fnc_dumpModuleInit;

[_logic, "init"] call ALIVE_fnc_adminActions;
//[_logic, "syncunits", _syncunits] call ALIVE_fnc_adminActions;

[_logic, false, _moduleID] call ALIVE_fnc_dumpModuleInit;
//[_logic, false, _moduleID] call ALIVE_fnc_dumpModuleInit;

