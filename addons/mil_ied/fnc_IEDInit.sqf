#include "\x\alive\addons\mil_ied\script_component.hpp"
SCRIPT(iedInit);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_iedInit
Description:
Creates the server side object to store settings

Parameters:
_this select 0: OBJECT - Reference to module
_this select 1: ARRAY - Synchronized units

Returns:
Nil

See Also:
- <ALIVE_fnc_Insurgency>

Author:
Tupolov
Jman

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

private ["_logic","_moduleID"];

PARAMS_1(_logic);
//DEFAULT_PARAM(1,_syncunits, []);

// Confirm init function available
ASSERT_DEFINED("ALIVE_fnc_IED","Main function missing");

// This module was the only one doing substantial work at startup without
// bracketing it, so it reported no time at all and its share of the wait was
// invisible in every log. On one reported mission that share was eighty five
// seconds of a four minute startup, and it took a line by line read of the
// log to find it. Every other module reports, so this one does now too.
_moduleID = [_logic, true] call ALIVE_fnc_dumpModuleInit;

[_logic, "init"] call ALIVE_fnc_IED;
//[_logic, "syncunits", _syncunits] call ALIVE_fnc_IED;

[_logic, false, _moduleID] call ALIVE_fnc_dumpModuleInit;

