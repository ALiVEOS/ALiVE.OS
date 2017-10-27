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
ALiVE_fnc_removeActionIED

Author:
Whigital

Peer reviewed:
nil
---------------------------------------------------------------------------- */

params [
    "_object"
];

// Sanity check for ALiVE_sys_acemenu_enable //
if (isNil QGVAR(enable)) exitWith {["aceMenu_removeActionIED : ALiVE_sys_acemenu not enabled."] call ALiVE_fnc_dump};

// Abandon if object unavailable //
if (isNull _object) exitWith {};

[_object, 0, ["ACE_MainActions", "ALiVE_DisarmIED"]] call ace_interact_menu_fnc_removeActionFromObject;
