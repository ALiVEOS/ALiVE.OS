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

// Access is asked through the shared gate, which is the same pool and the same
// matcher the flexiMenu, the tablet, Combat Support and Player Resupply all use,
// so none of them can disagree about whether a player may open C2ISTAR.
//
// What this replaces built its own list and then substring-matched each entry
// against the player's inventory as text. Two faults came out of that. The
// setting holds CATEGORY KEYS, so the default of LaserDesignators was compared
// against inventory that contains Laserdesignator and never matched, and on ACE
// the whole C2ISTAR entry then vanished, because ACE hides a parent whose
// children all read false. And the Custom Access Items field was pushed in whole,
// so a list of two classnames was compared as one literal string and could only
// ever match nothing. Reported by a tester on the dev build, who had the Resupply
// menu and no C2ISTAR menu: Resupply already went through the shared gate.
//
// The gate reads the settings itself when ACE evaluates it, which is also why
// there is no list to keep: ACE runs these conditions long after the code around
// them has gone out of scope, and a changed attribute or a picked-up item now
// takes effect on the next menu open rather than needing a restart.

// Define local menu vars //
private _menu = "ALiVE_C2ISTAR";
private _menupath = +GVAR(MenuRoot);

// Condition code for C2 menu items //
private _c2Cond = {
    [
        [MOD(MIL_C2ISTAR), "c2_item"] call ALIVE_fnc_C2ISTAR,
        [MOD(MIL_C2ISTAR), "c2_item_custom"] call ALIVE_fnc_C2ISTAR,
        ["ALIVE_Tablet"]
    ] call ALIVE_fnc_playerHasAccessItems
};


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
// Operations is the ONLY place an instant join can be ended, and a player who
// has taken over another unit is carrying that unit's kit rather than their own
// tablet. Gating it on the item alone therefore strands them as the unit they
// joined. The same exemption already exists on the CBA menu; without it here a
// player using the ACE self interaction menu is still stuck, which is what a
// tester reported after the first fix.
//
// Self-contained on purpose. ACE evaluates this long after everything around it
// has gone out of scope, so it asks the shared gate itself rather than borrowing
// _c2Cond, as the Command View condition below also does.
private _opsCond = {
    private _hasItem = [
        [MOD(MIL_C2ISTAR), "c2_item"] call ALIVE_fnc_C2ISTAR,
        [MOD(MIL_C2ISTAR), "c2_item_custom"] call ALIVE_fnc_C2ISTAR,
        ["ALIVE_Tablet"]
    ] call ALIVE_fnc_playerHasAccessItems;

    private _joinActive = false;
    if (!isNil "ALIVE_SUP_COMMAND") then {
        private _joinState = [ALIVE_SUP_COMMAND,"commandState"] call ALIVE_fnc_SCOM;
        if (!isNil "_joinState") then {
            private _flag = [_joinState,"opsGroupInstantJoin",false] call ALiVE_fnc_hashGet;
            if (_flag isEqualType false) then { _joinActive = _flag };
        };
    };

    _hasItem || _joinActive
};

private _action = [
    "C2_Operations",
    "Operations",
    QMENUICON2(c2,ops),
    {["OPEN_OPS",[]] call ALIVE_fnc_SCOMTabletOnAction},
    _opsCond
] call ace_interact_menu_fnc_createAction;

[player, 1, _menupath, _action] call ace_interact_menu_fnc_addActionToObject;

// Command View toggle item — only surfaces when the mission-maker opted
// in via copCommandViewEnabled AND the player carries a c2_item. The
// in-game HUD label rendered by COPRender provides ON/OFF feedback so a
// static menu label is sufficient. Condition asks the shared gate itself
// rather than re-using `_c2Cond`, which goes out of scope before ACE
// evaluates the condition.
private _cvCond = {
    (missionNamespace getVariable ["ALIVE_COP_CommandViewEnabled", false])
    && {
        [
            [MOD(MIL_C2ISTAR), "c2_item"] call ALIVE_fnc_C2ISTAR,
            [MOD(MIL_C2ISTAR), "c2_item_custom"] call ALIVE_fnc_C2ISTAR,
            ["ALIVE_Tablet"]
        ] call ALIVE_fnc_playerHasAccessItems
    }
};
private _action = [
    "C2_CommandView",
    "Toggle Command View",
    QMENUICON2(c2,ops),
    {
        ALIVE_COP_CommandViewOn = !(missionNamespace getVariable ["ALIVE_COP_CommandViewOn", false]);
    },
    _cvCond
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
