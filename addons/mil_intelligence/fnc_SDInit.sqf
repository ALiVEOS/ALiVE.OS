#include <\x\alive\addons\mil_intelligence\script_component.hpp>
SCRIPT(SDInit);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_SDInit
Description:
Creates the server side object to store settings

Parameters:
_this select 0: OBJECT - Reference to module
_this select 1: ARRAY - Synchronized units

Returns:
Nil

See Also:
- <ALIVE_fnc_MI>

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
ASSERT_DEFINED("ALIVE_fnc_SD","Main function missing");

_moduleID = [_logic, true] call ALIVE_fnc_dumpModuleInit;

[_logic, "runEvery", _logic getVariable ["runEvery","1"]] call ALIVE_fnc_SD;

[_logic, "init"] call ALIVE_fnc_SD;

[_logic, false, _moduleID] call ALIVE_fnc_dumpModuleInit;
