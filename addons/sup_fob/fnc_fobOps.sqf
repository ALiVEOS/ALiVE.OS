#include "\x\alive\addons\sup_fob\script_component.hpp"
SCRIPT(fobOps);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fobOps

Description:
Every change to a FOB, done on the server: deploy, build, recycle, resupply, repair,
dismantle, upgrade and a side taking it. Reached only through ALiVE_fnc_fobRequest (a player)
or from the server itself (the watchdog, Military Logistics). The operations arrive in the
next parts of the module; this part answers that it doesn't know them yet.

Parameters:
String - The operation
Array - Its arguments
Object - The player asking (objNull from the server itself)

Returns:
Any

Author:
Jman
---------------------------------------------------------------------------- */

if (isRemoteExecuted && {remoteExecutedOwner != 2} && {isNil "_ALiVE_fobCaller"}) exitWith {};
if (!isServer) exitWith {};

params [["_op", "", [""]], ["_args", [], [[]]], ["_caller", objNull, [objNull]]];

private _result = nil;

switch (_op) do {
    default {
        ["ALiVE Player FOBs - no operation called %1 yet", _op] call ALiVE_fnc_dump;
    };
};

if (isNil "_result") then { nil } else { _result }
