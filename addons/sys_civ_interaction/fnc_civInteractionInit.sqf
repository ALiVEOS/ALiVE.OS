#include <\x\alive\addons\sys_civ_interaction\script_component.hpp>
SCRIPT(civInteractionInit);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_civInteractionInit
Description:
Initializes civilian interaction

Parameters:
_this select 0: OBJECT - Reference to module logic

Returns:
Nil

See Also:
- <ALiVE_fnc_civInteraction>

Author:
SpyderBlack723

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

private ["_logic","_moduleID"];

params ["_logic","_syncedObjects"];

// Confirm init function available

ASSERT_DEFINED("ALiVE_fnc_civInteraction","Main function missing");

if (isnil "_logic") then {_logic = [nil, "create"] call ALiVE_fnc_civInteraction};

_moduleID = [_logic, true] call ALIVE_fnc_dumpModuleInit;

[_logic, "init", _syncedObjects] call ALiVE_fnc_civInteraction;

[_logic, false, _moduleID] call ALIVE_fnc_dumpModuleInit;

true