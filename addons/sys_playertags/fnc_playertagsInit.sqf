#include <\x\alive\addons\sys_playertags\script_component.hpp>
SCRIPT(playertagsInit);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_playertagsInit
Description:
Creates the server side object to store settings

Parameters:
_this select 0: OBJECT - Reference to module
_this select 1: ARRAY - Synchronized units

Returns:
Nil

See Also:
- <ALIVE_fnc_playertags>

Author:
Jman

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

private ["_logic","_moduleID"];

PARAMS_1(_logic);

// Confirm init function available
ASSERT_DEFINED("ALIVE_fnc_playertags","Main function missing");

_moduleID = [_logic, true] call ALIVE_fnc_dumpModuleInit;

[_logic, "init"] call ALIVE_fnc_playertags;

[_logic, false, _moduleID] call ALIVE_fnc_dumpModuleInit;

