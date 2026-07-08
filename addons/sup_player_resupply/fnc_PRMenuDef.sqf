#include "\x\alive\addons\sup_player_resupply\script_component.hpp"
#include "\a3\editor_f\Data\Scripts\dikCodes.h"

SCRIPT(PRMenuDef);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_PRMenuDef
Description:
This function controls the View portion

Parameters:
Object - The object to attach the menu too
Array - The menu parameters

Returns:
Array - Returns the menu definitions for FlexiMenu

Examples:
(begin example)
// initialise main menu
[
    "player",
    [221,[false,false,false]],
    -9500,
    ["call ALIVE_fnc_vdistMenuDef","main"]
] call CBA_fnc_flexiMenu_Add;
(end)

See Also:
- <ALIVE_fnc_PR>
- CBA_fnc_flexiMenu_Add

Author:
ARJay
Jman
Peer reviewed:
nil
---------------------------------------------------------------------------- */

private ["_menuDef","_target","_params","_menuName","_menuRsc","_menus","_result"];
// _this==[_target, _menuNameOrParams]

PARAMS_2(_target,_params);

_menuName = "";
_menuRsc = "popup";
// shared access-item gate: expands Trigger Item Categories + Custom Trigger Items
// and matches against one player pool, so this menu, the C2ISTAR tablet and the
// ACE self-interaction all agree on who can open the resupply tablet
_result = [
    [MOD(SUP_PLAYER_RESUPPLY),"pr_item"] call ALIVE_fnc_PR,
    [MOD(SUP_PLAYER_RESUPPLY),"pr_item_custom"] call ALIVE_fnc_PR,
    ["ALIVE_Tablet"]
] call ALIVE_fnc_playerHasAccessItems;

if (typeName _params == typeName []) then {
    if (count _params < 1) exitWith {["Error: Invalid params: %1, %2", _this, __FILE__] call ALiVE_fnc_dump;};
    _menuName = _params select 0;
    _menuRsc = if (count _params > 1) then {_params select 1} else {_menuRsc};
} else {
    _menuName = _params;
};
//-----------------------------------------------------------------------------
/*
        ["Menu Caption", "flexiMenu resource dialog", "optional icon folder", menuStayOpenUponSelect],
        [
            ["caption",
                "action",
                "icon",
                "tooltip",
                {"submenu"|["menuName", "", {0|1} (optional - use embedded list menu)]},
                -1 (shortcut DIK code),
                {0|1/"0"|"1"/false|true} (enabled),
                {-1|0|1/"-1"|"0"|"1"/false|true} (visible)
            ],
             ...
*/
_menus =
[
    [
        ["main", "ALiVE", _menuRsc],
        [
            [localize "STR_ALIVE_PR",
                {["OPEN",[]] call ALIVE_fnc_PRTabletOnAction},
                "",
                localize "STR_ALIVE_PR_COMMENT",
                "",
                -1,
                (MOD(Require) getVariable [format["ALIVE_MIL_LOG_AVAIL_%1", (side group player)], false]),
                !([QMOD(mil_c2istar)] call ALiVE_fnc_isModuleAvailable) && {_result}
            ]
        ]
    ]
];


//-----------------------------------------------------------------------------
// Normalize CBA flexiMenu code-block actions to the string form required by
// buttonSetAction (CBA fnc_list.sqf / fnc_menu.sqf passes the action slot
// straight through, which strictly needs STRING).
_menus call ALiVE_fnc_normalizeFlexiMenuActions;

_menuDef = [];
{
    if (_x select 0 select 0 == _menuName) exitWith {_menuDef = _x};
} forEach _menus;

if (count _menuDef == 0) then {
    hintC format ["Error: Menu not found: %1\n%2\n%3", str _menuName, if (_menuName == "") then {_this}else{""}, __FILE__];
    ["Error: Menu not found: %1, %2, %3", str _menuName, _this, __FILE__] call ALiVE_fnc_dump;
};

_menuDef // return value
