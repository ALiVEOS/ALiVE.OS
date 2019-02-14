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

Peer reviewed:
nil
---------------------------------------------------------------------------- */

// Define a global var with PR items once instead of calling the function each time the menu condition is evaluated //
MOD(SUP_PR_Items) = [([MOD(SUP_PLAYER_RESUPPLY), "pr_item"] call ALIVE_fnc_PR), "ALIVE_Tablet"];

// Define local menu vars //
private _menu = "ALiVE_PR";

// Condition code for PR menu items //
private _prCond = {(({([(toLower(str((assignedItems player) + (uniformItems player) + (backpackItems player) + (vestItems player)))), toLower(_x)] call CBA_fnc_find) > -1} count MOD(SUP_PR_Items)) > 0) && {(MOD(Require) getVariable [(format ["ALIVE_MIL_LOG_AVAIL_%1", (side player)]), false])}};

private _action = [
    _menu,
    "Resupply",
    QMENUICON(pr),
    {["OPEN",[]] call ALIVE_fnc_PRTabletOnAction},
    _prCond
] call ace_interact_menu_fnc_createAction;

[player, 1, GVAR(MenuRoot), _action] call ace_interact_menu_fnc_addActionToObject;
