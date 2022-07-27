#include "\x\alive\addons\sys_acemenu\script_component.hpp"

SCRIPT(aceMenuC2);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_aceMenuC2
Description:
Adds C2ISTAR items to players ACE selfinteraction menu

Parameters:

Returns:

Examples:
(begin example)
[] spawn ALiVE_fnc_aceMenuC2;
(end)

See Also:
<ALiVE_fnc_C2MenuDef>

Author:
Whigital

Peer reviewed:
nil
---------------------------------------------------------------------------- */

// Define a global var with c2 items once instead of calling the function each time the menu condition is evaluated //
MOD(MIL_C2ISTAR_Items) = [([MOD(MIL_C2ISTAR), "c2_item"] call ALIVE_fnc_C2ISTAR), "ALIVE_Tablet"];

// Define local menu vars //
private _menu = "ALiVE_C2ISTAR";
private _menupath = +GVAR(MenuRoot);

// Condition code for C2 menu items //
private _c2Cond = {({([(toLower(str((assignedItems player) + (uniformItems player) + (backpackItems player) + (vestItems player)))), toLower(_x)] call CBA_fnc_find) > -1} count MOD(MIL_C2ISTAR_Items)) > 0};


// Add "ALiVE_C2ISTAR" parent //
private _action = [
    _menu,
    "C2ISTAR",
    QMENUICON(c2),
    {},
    {true}
] call ace_interact_menu_fnc_createAction;

[player, 1, _menupath, _action] call ace_interact_menu_fnc_addActionToObject;

// Populate local path var with path of this component //
_menupath pushBack _menu;


// Personnel item //
private _action = [
    "C2_Personnel",
    "Personnel",
    QMENUICON2(c2,pers),
    {["OPEN",[]] call ALIVE_fnc_GMTabletOnAction},
    _c2Cond
] call ace_interact_menu_fnc_createAction;

[player, 1, _menupath, _action] call ace_interact_menu_fnc_addActionToObject;

// Intel item //
private _action = [
    "C2_Intel",
    "Intel",
    QMENUICON2(c2,intel),
    {["OPEN_INTEL",[]] call ALIVE_fnc_SCOMTabletOnAction},
    _c2Cond
] call ace_interact_menu_fnc_createAction;

[player, 1, _menupath, _action] call ace_interact_menu_fnc_addActionToObject;

// Tasks item //
private _action = [
    "C2_Tasks",
    "Tasks",
    QMENUICON2(c2,task),
    {["OPEN",[]] call ALIVE_fnc_C2TabletOnAction},
    _c2Cond
] call ace_interact_menu_fnc_createAction;

[player, 1, _menupath, _action] call ace_interact_menu_fnc_addActionToObject;

// Operations item //
private _action = [
    "C2_Operations",
    "Operations",
    QMENUICON2(c2,ops),
    {["OPEN_OPS",[]] call ALIVE_fnc_SCOMTabletOnAction},
    _c2Cond
] call ace_interact_menu_fnc_createAction;

[player, 1, _menupath, _action] call ace_interact_menu_fnc_addActionToObject;


// ##### Start of Reporting submenu section ##### //

// Add "Reporting" menu under "C2" //
private _menu = "ALiVE_C2ISTAR_REP";

private _action = [
    _menu,
    "Reporting",
    QMENUICON2(c2,rep),
    {},
    _c2Cond
] call ace_interact_menu_fnc_createAction;

[player, 1, _menupath, _action] call ace_interact_menu_fnc_addActionToObject;

// Populate local path var with path of this component //
_menupath pushBack _menu;

// SITREP item //
private _action = [
    "C2_SITREP",
    "Send SITREP",
    QMENUICON2(c2,rep),
    {["situation"] call ALiVE_fnc_aceMenu_repDialog},
    _c2Cond
] call ace_interact_menu_fnc_createAction;

[player, 1, _menupath, _action] call ace_interact_menu_fnc_addActionToObject;

// PATROLREP item //
private _action = [
    "C2_PATREP",
    "Send PATROLREP",
    QMENUICON2(c2,rep),
    {["patrol"] call ALiVE_fnc_aceMenu_repDialog},
    _c2Cond
] call ace_interact_menu_fnc_createAction;

[player, 1, _menupath, _action] call ace_interact_menu_fnc_addActionToObject;

// ##### End of Reporting submenu section ##### //
