#include "\x\alive\addons\sup_fob\script_component.hpp"
SCRIPT(fobLoadData);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fobLoadData

Description:
Loads the saved FOBs into the registry. Called once at start, after the AI Commanders and
Military Logistics have finished starting.

Parameters:
None

Returns:
BOOL - true when something was loaded

Author:
Jman
---------------------------------------------------------------------------- */

if (isRemoteExecuted && {remoteExecutedOwner != 2}) exitWith {false};
if (!isServer) exitWith {false};

["load"] call ALiVE_fnc_fobPersistence
