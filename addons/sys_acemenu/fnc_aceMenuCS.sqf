#include "\x\alive\addons\sys_acemenu\script_component.hpp"

SCRIPT(aceMenuCS);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_aceMenuCS
Description:
Adds CS items to players ACE selfinteraction menu

Parameters:

Returns:

Examples:
(begin example)
[] spawn ALiVE_fnc_aceMenuCS;
(end)

See Also:
<ALiVE_fnc_combatSupportDef>

Author:
Whigital
Jman

Peer reviewed:
nil
---------------------------------------------------------------------------- */

// Wait for NEO_radioLogic to initialize //
waitUntil {!isNil "NEO_radioLogic"};
waitUntil {NEO_radioLogic getVariable ["init", false]};

// Define local menu vars //
private _menu = "ALiVE_CS";

// Condition code for CS menu items - shared access-item gate (categories + custom
// classnames, same pool and matcher as the flexiMenu and C2ISTAR tablet entries;
// evaluated per menu-open so attribute and inventory changes apply live) //
private _csCond = {
    ([
        NEO_radioLogic getVariable ["combatsupport_item", "LaserDesignators"],
        NEO_radioLogic getVariable ["combatsupport_item_custom", ""],
        []
    ] call ALIVE_fnc_playerHasAccessItems)
    && {call ALIVE_fnc_combatSupportIsOperator}
};

private _action = [
    _menu,
    "Combat Support",
    QMENUICON(cs),
    {["radio"] call ALIVE_fnc_radioAction},
    _csCond
] call ace_interact_menu_fnc_createAction;

[player, 1, GVAR(MenuRoot), _action] call ace_interact_menu_fnc_addActionToObject;
