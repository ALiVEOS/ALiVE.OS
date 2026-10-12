#include "\x\alive\addons\sup_ground\script_component.hpp"
SCRIPT(GROUNDInit);
/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_GROUNDInit
Description:
Ground transport support module (#690): holds the settings Combat Support reads when it
spawns the vehicle.

Parameters:
_this select 0: OBJECT - Reference to module

Returns:
Nil

See Also:
- <ALIVE_fnc_GROUND>

Author:
Jman
---------------------------------------------------------------------------- */
params [["_logic", objNull, [objNull]]];

ASSERT_DEFINED("ALIVE_fnc_GROUND","Main function missing");

private _moduleID = [_logic, true] call ALIVE_fnc_dumpModuleInit;

[_logic, "init"] call ALIVE_fnc_GROUND;

[_logic, false, _moduleID] call ALIVE_fnc_dumpModuleInit;
