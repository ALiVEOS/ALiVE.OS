#include "\x\alive\addons\mil_opcom\script_component.hpp"
SCRIPT(OPCOMInit);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_OPCOMInit
Description:
Creates the server side object to store settings

Parameters:
_this select 0: OBJECT - Reference to module
_this select 1: ARRAY - Synchronized units

Returns:
Nil

See Also:
- <ALIVE_fnc_OPCOM>

Author:
Wolffy.au
Peer Reviewed:
nil
---------------------------------------------------------------------------- */

private ["_logic","_moduleID"];

PARAMS_1(_logic);
//DEFAULT_PARAM(1,_syncunits, []);

ASSERT_DEFINED("ALIVE_fnc_OPCOM","Main function missing");

// in normal operation, calling ALiVE_fnc_OPCOM with no args will produce an empty hash from default operation
// if there was a compilation error ALiVE_fnc_OPCOM will return nil
// use this to validate the function compiled successfully before trying to init
// failing to stop init can trigger infinite loading screen as ALiVE_fnc_aliveInit waits for complete initialization
if (isnil {[] call ALiVE_fnc_OPCOM}) exitwith {
    private _errorMessage = "Compilation error detected in ALiVE_fnc_OPCOM";

    ["ALiVE_fnc_OPCOMInit - %1. Aborting Init", _errorMessage] call ALiVE_fnc_DumpR;

    _logic setvariable ["initError", [_errorMessage]];
    _logic setvariable ["startupComplete", true, true];
};

_moduleID = [_logic, true] call ALIVE_fnc_dumpModuleInit;

[_logic, "init"] call ALIVE_fnc_OPCOM;

[_logic, false, _moduleID] call ALIVE_fnc_dumpModuleInit;
