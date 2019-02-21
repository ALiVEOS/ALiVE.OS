#include "\x\alive\addons\sys_statistics\script_component.hpp"
#include "\a3\editor_f\Data\Scripts\dikCodes.h"

SCRIPT(statisticsMenuDef);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_statisticsMenuDef
Description:
This function controls the View portion of statistics.

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
    ["call ALIVE_fnc_statisticsMenuDef","main"]
] call CBA_fnc_flexiMenu_Add;
(end)

See Also:
- <ALIVE_fnc_statistics>
- <CBA_fnc_flexiMenu_Add>

Author:
Wolffy.au

Peer reviewed:
nil
---------------------------------------------------------------------------- */
private ["_menuDef", "_target", "_params", "_menuName", "_menuRsc", "_menus"];
// _this==[_target, _menuNameOrParams]

PARAMS_2(_target,_params);

_menuName = "";
_menuRsc = "popup";

if (typeName _params == typeName []) then {
    if (count _params < 1) exitWith {diag_log format["Error: Invalid params: %1, %2", _this, __FILE__];};
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
        ]
    ],
    [
        ["adminOptions", "Admin Options", "popup"],
        [
        ]
    ]
];


TRACE_2("Menu setup",GVAR(ENABLED),GVAR(DISABLED));

if (_menuName == "statistics") then {
    _menus set [count _menus,
        [
            ["statistics", localize "STR_ALIVE_STATISTICS", "popup"],
            [
                [localize "STR_ALIVE_STATISTICS_ENABLE",
                    { GVAR(ENABLED) = true; PublicVariable QGVAR(ENABLED); },
                    "",
                    localize "STR_ALIVE_STATISTICS_ENABLE_COMMENT",
                    "",
                    -1,
                    !(GVAR(ENABLED)),
                    !(GVAR(ENABLED))
                ],
                [localize "STR_ALIVE_DISABLE_STATISTICS",
                    { GVAR(ENABLED) = false; PublicVariable QGVAR(ENABLED); },
                    "",
                    localize "STR_ALIVE_STATISTICS_ENABLE_COMMENT",
                    "",
                    -1,
                    (GVAR(ENABLED)),
                    (GVAR(ENABLED))
                ]
            ]
        ]
    ];
};

//-----------------------------------------------------------------------------
_menuDef = [];
{
    if (_x select 0 select 0 == _menuName) exitWith {_menuDef = _x};
} forEach _menus;

if (count _menuDef == 0) then {
    hintC format ["Error: Menu not found: %1\n%2\n%3", str _menuName, if (_menuName == "") then {_this}else{""}, __FILE__];
    diag_log format ["Error: Menu not found: %1, %2, %3", str _menuName, _this, __FILE__];
};

_menuDef // return value
