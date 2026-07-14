#include "\x\alive\addons\mil_artillery\script_component.hpp"
SCRIPT(ARTILLERYInit);
/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_MilArtilleryInit
Description:
Module initialisation

Parameters:
_this select 0: OBJECT - Reference to module

Returns:
Nil

See Also:
- <ALIVE_fnc_MilArtillery>

Author:
Jman

Peer Reviewed:
nil
---------------------------------------------------------------------------- */
private ["_logic","_moduleID"];

PARAMS_1(_logic);

// Confirm init function available
ASSERT_DEFINED("ALIVE_fnc_MilArtillery","Main function missing");

_moduleID = [_logic, true] call ALIVE_fnc_dumpModuleInit;

[_logic, "init"] call ALIVE_fnc_MilArtillery;

[_logic, false, _moduleID] call ALIVE_fnc_dumpModuleInit;
