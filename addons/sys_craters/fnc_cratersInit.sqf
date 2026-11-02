#include "\x\alive\addons\sys_craters\script_component.hpp"
SCRIPT(cratersInit);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_cratersInit

Description:
Starts the Persistent Craters module. Runs on every machine (isGlobal 2): every machine
watches its own shells, rockets and bombs, and the server keeps the craters.

Parameters:
Object - The module

Returns:
Nil

See Also:
- <ALIVE_fnc_craters>

Author:
Jman
---------------------------------------------------------------------------- */

params [["_logic", objNull, [objNull]]];

ASSERT_DEFINED("ALIVE_fnc_craters","Main function missing");

private _moduleID = [_logic, true] call ALIVE_fnc_dumpModuleInit;

[_logic, "init"] call ALIVE_fnc_craters;

[_logic, false, _moduleID] call ALIVE_fnc_dumpModuleInit;
