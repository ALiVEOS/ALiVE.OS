#include <\x\alive\addons\sys_acemenu\script_component.hpp>

SCRIPT(aceMenu_readIntel);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_aceMenu_readIntel
Description:
Adds ACE interaction to dropped intel.

Parameters:
0: OBJECT - object to add the action to
1: ARRAY - position array
2: STRING - intel belonging to this side is revealed

Returns:

Examples:
(begin example)
[_object, _position, _side] call ALiVE_fnc_aceMenu_readIntel;
(end)

See Also:
ALIVE_fnc_OPCOMdropIntel

Author:
Whigital

Peer reviewed:
nil
---------------------------------------------------------------------------- */

params [
    "_object",
    "_position",
    "_side"
];

// Sanity check for ALiVE_sys_acemenu_enable //
if (isNil QGVAR(enable)) exitWith {
    // ToDo: Debug
    //["aceMenu_readIntel : ALiVE_sys_acemenu not enabled."] call ALiVE_fnc_dump;
};

// If object is nonexistant, exit //
if (isNull _object) exitWith {};

// Code to run upon reading the intel //
private _actCode = {
    params [
        "_target",
        "_player",
        "_params"
    ];

    private _pos  = (_params select 0);
    private _side = (_params select 1);

    openmap true;
    [_pos, 1500, _side] call ALiVE_fnc_OPCOMToggleInstallations;

    [_target, 0, ["ACE_MainActions", "ALiVE_Intel"]] call ace_interact_menu_fnc_removeActionFromObject;
};

// Add "Read Intel" item to object //
private _action = [
    "ALiVE_Intel",
    "Read Intel",
    QMENUICON2(c2,intel),
    _actCode,
    {true},
    {},
    [
        _position,
        _side
    ]
] call ace_interact_menu_fnc_createAction;

[_object, 0, ["ACE_MainActions"], _action] call ace_interact_menu_fnc_addActionToObject;
