#include "\x\alive\addons\sys_classpicker\script_component.hpp"
SCRIPT(classPickerModuleInit);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_classPickerModuleInit

Description:
Module init for the class picker. Hands the module's settings to the picker and
puts its operations on the ALiVE menu.

Parameters:
_this select 0: OBJECT - Reference to module
_this select 1: ARRAY  - Synchronized units

Returns:
Nil

See Also:
- <ALIVE_fnc_classPickerModule>
- <ALIVE_fnc_classPicker>

Author:
Jman
---------------------------------------------------------------------------- */

private ["_logic","_moduleID"];

PARAMS_1(_logic);

ASSERT_DEFINED("ALIVE_fnc_classPickerModule","Main function missing");

_moduleID = [_logic, true] call ALIVE_fnc_dumpModuleInit;

[_logic, "init"] call ALIVE_fnc_classPickerModule;

[_logic, false, _moduleID] call ALIVE_fnc_dumpModuleInit;
