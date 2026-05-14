#include "\x\alive\addons\mil_C2ISTAR\script_component.hpp"
SCRIPT(C2ISTARInit);
/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_C2ISTARInit
Description:
Creates the server side object to store settings

Parameters:
_this select 0: OBJECT - Reference to module
_this select 1: ARRAY - Synchronized units

Returns:
Nil

See Also:
- <ALIVE_fnc_C2ISTAR>

Author:
ARJay

Peer Reviewed:
---------------------------------------------------------------------------- */

private ["_logic","_moduleID"];

PARAMS_1(_logic);
//DEFAULT_PARAM(1,_syncunits, []);

// Confirm init function available
ASSERT_DEFINED("ALIVE_fnc_C2ISTAR","Main function missing");

// In normal operation, calling ALiVE_fnc_C2ISTAR with no args produces an
// empty hash from the default case. If the function has a compilation
// error it returns nil. Catch that here and release the startupComplete
// gate so ALiVE_fnc_aliveInit (which waits on every synced module's
// startupComplete before clearing the loading screen) doesn't hang.
// Same pattern as mil_opcom's fnc_OPCOMInit.sqf compilation-error guard.
if (isnil {[] call ALiVE_fnc_C2ISTAR}) exitwith {
    private _errorMessage = "Compilation error detected in ALiVE_fnc_C2ISTAR";

    ["ALiVE_fnc_C2ISTARInit - %1. Aborting Init", _errorMessage] call ALiVE_fnc_DumpR;

    _logic setvariable ["initError", [_errorMessage]];
    _logic setvariable ["startupComplete", true, true];
};

_moduleID = [_logic, true] call ALIVE_fnc_dumpModuleInit;

[_logic, "init"] call ALIVE_fnc_C2ISTAR;

[_logic, false, _moduleID] call ALIVE_fnc_dumpModuleInit;