#include "\x\alive\addons\mil_placement\script_component.hpp"
SCRIPT(MPInit);
/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_MPInit
Description:
Creates the server side object to store settings
Parameters:
_this select 0: OBJECT - Reference to module
_this select 1: ARRAY - Synchronized units
Returns:
Nil
See Also:
- <ALIVE_fnc_MP>
Author:
Wolffy.au
Peer Reviewed:
nil
---------------------------------------------------------------------------- */

params ["_logic","_syncedUnits"];

ASSERT_DEFINED("ALIVE_fnc_MP","Main function missing");

private _moduleID = [_logic, true] call ALIVE_fnc_dumpModuleInit;

[_logic,"init"] call ALIVE_fnc_MP;

[_logic, false, _moduleID] call ALIVE_fnc_dumpModuleInit;