#include "\x\alive\addons\mil_intelligence\script_component.hpp"
SCRIPT(PSDInit);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_PSDInit
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

private ["_logic","_moduleID"];

// DEPRECIATED
if(true) exitWith {};

PARAMS_1(_logic);
//DEFAULT_PARAM(1,_syncunits, []);

// Confirm init function available
ASSERT_DEFINED("ALIVE_fnc_PSD","Main function missing");

_moduleID = [_logic, true] call ALIVE_fnc_dumpModuleInit;

[_logic, "init"] call ALIVE_fnc_PSD;

[_logic, false, _moduleID] call ALIVE_fnc_dumpModuleInit;