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

Peer reviewed:
nil
---------------------------------------------------------------------------- */

// Define a global var with c2 items once instead of calling the function each time the menu condition is evaluated //
MOD(MIL_CS_Items) = [NEO_radioLogic getVariable ["combatsupport_item", "LaserDesignator"]];

// Define local menu vars //
private _menu = "ALiVE_CS";

// Condition code for CS menu items //
private _csCond = {({([(toLower(str((assignedItems player) + (uniformItems player) + (backpackItems player) + (vestItems player)))), toLower(_x)] call CBA_fnc_find) > -1} count MOD(MIL_CS_Items)) > 0};

private _action = [
    _menu,
    "Combat Support",
    QMENUICON(cs),
    {["radio"] call ALIVE_fnc_radioAction},
    _csCond
] call ace_interact_menu_fnc_createAction;

[player, 1, GVAR(MenuRoot), _action] call ace_interact_menu_fnc_addActionToObject;
