#include "\x\alive\addons\civ_placement\script_component.hpp"
SCRIPT(COInit);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_COInit
Description:
Creates the server side object to store settings

Parameters:
_this select 0: OBJECT - Reference to module
_this select 1: ARRAY - Synchronized units

Returns:
Nil

See Also:
- <ALIVE_fnc_CO>

Author:
Wolffy.au
Peer Reviewed:
nil
---------------------------------------------------------------------------- */

params ["_logic"];
//DEFAULT_PARAM(1,_syncunits, []);

// Confirm init function available
ASSERT_DEFINED("ALIVE_fnc_CP","Main function missing");

private _moduleID = [_logic, true] call ALIVE_fnc_dumpModuleInit;

[_logic, "init"] call ALIVE_fnc_CP;

[_logic, false, _moduleID] call ALIVE_fnc_dumpModuleInit;