#include <\x\alive\addons\sys_orbatcreator\script_component.hpp>
SCRIPT(orbatCreatorInit);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_orbatCreatorInit
Description:
Initializes the group configurator

Parameters:
_this select 0: OBJECT - Reference to module logic

Returns:
Nil

See Also:
- <ALIVE_fnc_orbatCreator>

Author:
SpyderBlack723

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

private ["_logic","_moduleID"];

params ["_logic","_syncedObjects"];

// Confirm init function available

ASSERT_DEFINED("ALIVE_fnc_orbatCreator","Main function missing");

if (isnil "_logic") then {_logic = [nil, "create"] call ALIVE_fnc_orbatCreator};

_moduleID = [_logic, true] call ALIVE_fnc_dumpModuleInit;

[_logic, "init", _syncedObjects] call ALIVE_fnc_orbatCreator;

[_logic, false, _moduleID] call ALIVE_fnc_dumpModuleInit;

true