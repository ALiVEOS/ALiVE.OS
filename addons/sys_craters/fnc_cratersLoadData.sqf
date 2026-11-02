#include "\x\alive\addons\sys_craters\script_component.hpp"
SCRIPT(cratersLoadData);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_cratersLoadData

Description:
Loads the saved craters and puts the ground back. Called once at start by the module's
server loop, after ALiVE Data is up.

Parameters:
None

Returns:
BOOL - true when something was loaded

Author:
Jman
---------------------------------------------------------------------------- */

if (isRemoteExecuted && {remoteExecutedOwner != 2}) exitWith {false};
if (!isServer) exitWith {false};

["load"] call ALiVE_fnc_cratersPersistence
