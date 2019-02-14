#include "\x\alive\addons\amb_civ_placement\script_component.hpp"
SCRIPT(AMBCPInit);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_AMBCPInit
Description:
Creates the server side object to store settings

Parameters:
_this select 0: OBJECT - Reference to module
_this select 1: ARRAY - Synchronized units

Returns:
Nil

See Also:

Author:
ARJay
Peer Reviewed:
nil
---------------------------------------------------------------------------- */

params ["_logic"];

// Confirm init function available
ASSERT_DEFINED("ALIVE_fnc_AMBCP","Main function missing");

private _moduleID = [_logic, true] call ALIVE_fnc_dumpModuleInit;

[_logic, "init"] call ALIVE_fnc_AMBCP;

[_logic, false, _moduleID] call ALIVE_fnc_dumpModuleInit;