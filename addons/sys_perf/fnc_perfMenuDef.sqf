#include "\x\alive\addons\sys_perf\script_component.hpp"
#include "\a3\editor_f\Data\Scripts\dikCodes.h"

SCRIPT(perfMenuDef);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_perfMenuDef
Description:
This function controls the View portion of perf.

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
    ["call ALIVE_fnc_perfMenuDef","main"]
] call CBA_fnc_flexiMenu_Add;
(end)

See Also:
- <ALIVE_fnc_perf>
- <CBA_fnc_flexiMenu_Add>

Author:
Wolffy.au
Jman
Peer reviewed:
nil
---------------------------------------------------------------------------- */
private ["_menuDef", "_target", "_params", "_menuName", "_menuRsc", "_menus"];
// _this==[_target, _menuNameOrParams]

PARAMS_2(_target,_params);

_menuName = "";
_menuRsc = "popup";

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
// #1031: the menu only appears to an admin. Whether it appears is not tied to whether
// monitoring runs (GVAR(RUNNING), set by the server), so stopping it never removes
// the way to start it again.
private _running = missionNamespace getVariable [QGVAR(RUNNING), false];
private _showing = missionNamespace getVariable [QGVAR(SHOW), false];

_menus =
[
    [
        ["main", "ALiVE", _menuRsc],
        [
            [localize "STR_ALIVE_PERF" + " >",
                "",
                "",
                localize "STR_ALIVE_PERF_COMMENT",
                ["call ALiVE_fnc_perfMenuDef", "perf", 1],
                -1, true, (call ALIVE_fnc_isServerAdmin)
            ]
        ]
    ]
];

TRACE_2("Menu setup",_running,_showing);

if (_menuName == "perf") then {
    _menus set [count _menus,
        [
            ["perf", localize "STR_ALIVE_PERF", "popup"],
            [
                [localize (["STR_ALIVE_PERF_SHOW", "STR_ALIVE_PERF_HIDE"] select _showing),
                    { call ALIVE_fnc_perfShow; },
                    "",
                    localize "STR_ALIVE_PERF_SHOW_COMMENT",
                    "",
                    -1,
                    true,
                    true
                ],
                [localize "STR_ALIVE_PERF_ENABLE",
                    { ["start"] remoteExecCall ["ALIVE_fnc_perfServer", 2]; },
                    "",
                    localize "STR_ALIVE_PERF_ENABLE_COMMENT",
                    "",
                    -1,
                    !_running,
                    !_running
                ],
                [localize "STR_ALIVE_DISABLE_PERF",
                    { ["stop"] remoteExecCall ["ALIVE_fnc_perfServer", 2]; },
                    "",
                    localize "STR_ALIVE_DISABLE_PERF_COMMENT",
                    "",
                    -1,
                    _running,
                    _running
                ]
            ]
        ]
    ];
};

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
