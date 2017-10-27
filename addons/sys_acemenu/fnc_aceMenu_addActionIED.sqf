#include <\x\alive\addons\sys_acemenu\script_component.hpp>

SCRIPT(aceMenu_addActionIED);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_aceMenu_addActionIED
Description:
Adds ACE interaction to dropped intel.

Parameters:
0: OBJECT - object to add the action to

Returns:

Examples:
(begin example)
_object call ALiVE_fnc_aceMenu_addActionIED;
(end)

See Also:
ALiVE_fnc_addActionIED

Author:
Whigital

Peer reviewed:
nil
---------------------------------------------------------------------------- */

params [
    "_object"
];

// Sanity check for ALiVE_sys_acemenu_enable //
if (isNil QGVAR(enable)) exitWith {["aceMenu_addActionIED : ALiVE_sys_acemenu not enabled."] call ALiVE_fnc_dump};

// Abandon if object unavailable //
if (isNull _object) exitWith {};

// Code to run for the action //
private _actCode = {
    params [
        "_target",
        "_player"
    ];

    private _actionIDs = (actionIDs _target);
    private _actionID = 0;

    {
        if ((((_target actionParams _x) select 0) find "Disarm IED") != -1) then {
            _actionID = _x;
        };
    } forEach _actionIDs;

    [_target, _player, _actionID] call ALiVE_fnc_disarmIED;
};

// Add "Disarm IED" item to object //
private _action = [
    "ALiVE_DisarmIED",
    "Disarm IED",
    QMENUICON(ied),
    _actCode,
    {true}
] call ace_interact_menu_fnc_createAction;

[_object, 0, ["ACE_MainActions"], _action] call ace_interact_menu_fnc_addActionToObject;
