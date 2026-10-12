#include "\x\alive\addons\sup_fob\script_component.hpp"
SCRIPT(FOBInit);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_FOBInit

Description:
Player FOBs module (#882, #693): starts the FOB registry on the server and the read-only
copy of it on every player's machine.

Parameters:
_this select 0: OBJECT - Reference to module

Returns:
Nil

See Also:
- <ALIVE_fnc_FOB>

Author:
Jman
---------------------------------------------------------------------------- */

params [["_logic", objNull, [objNull]]];

ASSERT_DEFINED("ALIVE_fnc_FOB","Main function missing");

private _moduleID = [_logic, true] call ALIVE_fnc_dumpModuleInit;

[_logic, "init"] call ALIVE_fnc_FOB;

[_logic, false, _moduleID] call ALIVE_fnc_dumpModuleInit;
