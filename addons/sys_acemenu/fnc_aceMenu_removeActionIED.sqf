#include <\x\alive\addons\sys_acemenu\script_component.hpp>

SCRIPT(aceMenu_removeActionIED);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_aceMenu_removeActionIED
Description:
Adds ACE interaction to dropped intel.

Parameters:
0: OBJECT - object to add the action to

Returns:

Examples:
(begin example)
_object call ALiVE_fnc_aceMenu_removeActionIED;
(end)

See Also:
ALIVE_fnc_removeActionIED

Author:
Whigital

Peer reviewed:
nil
---------------------------------------------------------------------------- */

params [
    "_object"
];

// Detect ACE and make sure instance has an interface //
if (!(isClass(configFile >> "CfgPatches" >> "ace_interact_menu")) && {!hasInterface}) exitWith {["ACE interact_menu not present or hasInterface false, exiting"] call ALiVE_fnc_dump};

// Delay until 'ace_interact_menu' has initialized //
waitUntil {(!isNil "ace_interact_menu") && {ace_interact_menu && {!isNull player}}};

if (isNull _object) exitWith {};

[_target, 0, ["ACE_MainActions", "ALiVE_DisarmIED"]] call ace_interact_menu_fnc_removeActionFromObject;
