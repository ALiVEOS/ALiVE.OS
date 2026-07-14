#include "\x\alive\addons\sys_acemenu\script_component.hpp"

SCRIPT(aceMenuPR);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_aceMenuPR
Description:
Adds PR items to players ACE selfinteraction menu

Parameters:

Returns:

Examples:
(begin example)
[] spawn ALiVE_fnc_aceMenuPR;
(end)

See Also:
<ALiVE_fnc_PRMenuDef>

Author:
Whigital
Jman

Peer reviewed:
nil
---------------------------------------------------------------------------- */

// Define local menu vars //
private _menu = "ALiVE_PR";

// Condition code for PR menu items - shared access-item gate (categories + custom
// classnames, same pool and matcher as the flexiMenu and C2ISTAR tablet entries;
// evaluated per menu-open so attribute and inventory changes apply live) //
private _prCond = {
    ([
        [MOD(SUP_PLAYER_RESUPPLY), "pr_item"] call ALIVE_fnc_PR,
        [MOD(SUP_PLAYER_RESUPPLY), "pr_item_custom"] call ALIVE_fnc_PR,
        ["ALIVE_Tablet"]
    ] call ALIVE_fnc_playerHasAccessItems)
    && {(MOD(Require) getVariable [(format ["ALIVE_MIL_LOG_AVAIL_%1", (side group player)]), false])}
};

private _action = [
    _menu,
    "Resupply",
    QMENUICON(pr),
    {["OPEN",[]] call ALIVE_fnc_PRTabletOnAction},
    _prCond
] call ace_interact_menu_fnc_createAction;

[player, 1, GVAR(MenuRoot), _action] call ace_interact_menu_fnc_addActionToObject;
