#include <\x\alive\addons\sys_acemenu\script_component.hpp>

SCRIPT(aceMenu);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_aceMenu
Description:
Adds ALiVE menu to players ACE self interaction.

Parameters:

Returns:

Examples:
(begin example)
[] spawn ALiVE_fnc_aceMenu;
(end)

See Also:

Author:
Whigital

Peer reviewed:
nil
---------------------------------------------------------------------------- */

// Detect ACE and make sure instance has an interface //
if (!(isClass(configFile >> "CfgPatches" >> "ace_interact_menu")) && {!hasInterface}) exitWith {["ACE interact_menu not present or hasInterface false, exiting"] call ALiVE_fnc_dump};

// Delay until 'ace_interact_menu' has initialized //
waitUntil {(!isNil "ace_interact_menu") && {ace_interact_menu && {!isNull player}}};

// Add "ALIVE_Root" root item //
private _action = [
    "ALIVE_Menu",
    "ALiVE",
    QMENUICON(main),
    {},
    {true}
] call ace_interact_menu_fnc_createAction;

[player, 1, ["ACE_SelfActions"], _action] call ace_interact_menu_fnc_addActionToObject;

GVAR(MenuRoot) = ["ACE_SelfActions", "ALIVE_Menu"];


// C2ISTAR //
if ([QMOD(mil_C2ISTAR)] call ALiVE_fnc_isModuleAvailable) then {
    [] spawn FUNCMAIN(aceMenuC2);
};

// Combat Support //
if ([QMOD(SUP_COMBATSUPPORT)] call ALiVE_fnc_isModuleAvailable) then {
    [] spawn FUNCMAIN(aceMenuCS);
};

// Player Resupply | Logistics //
if ([QMOD(SUP_PLAYER_RESUPPLY)] call ALiVE_fnc_isModuleAvailable) then {
    [] spawn FUNCMAIN(aceMenuPR);
};
