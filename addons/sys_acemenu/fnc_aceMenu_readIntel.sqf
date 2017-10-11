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

// Detect ACE and make sure instance has an interface //
if (!(isClass(configFile >> "CfgPatches" >> "ace_interact_menu")) && {!hasInterface}) exitWith {["ACE interact_menu not present or hasInterface false, exiting"] call ALiVE_fnc_dump};

// Delay until 'ace_interact_menu' has initialized //
waitUntil {(!isNil "ace_interact_menu") && {ace_interact_menu && {!isNull player}}};

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

    [_target, 0, ["ACE_MainActions", "ALIVE_Intel"]] call ace_interact_menu_fnc_removeActionFromObject;
};

if (isNull _object) exitWith {};

// Add "Read Intel" item to object //
private _action = [
    "ALIVE_Intel",
    "Read Intel",
    QMENUICON2(c2,intel),
    _actCode,
    {true}
    {},
    [
        _position,
        _side
    ]
] call ace_interact_menu_fnc_createAction;

[_object, 0, ["ACE_MainActions"], _action] call ace_interact_menu_fnc_addActionToObject;
