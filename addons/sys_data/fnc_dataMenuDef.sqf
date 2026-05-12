#include "\x\alive\addons\sys_data\script_component.hpp"
#include "\a3\editor_f\Data\Scripts\dikCodes.h"

SCRIPT(dataMenuDef);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_dataMenuDef

Description:
Admin-menu submenu for the ALiVE Persistent Data section. Surfaces the
existing ALiVE_fnc_ProfileNameSpaceClear and ALiVE_fnc_ProfileNameSpaceWipe
helpers (#853) so a server admin can wipe persistence without dropping
to the debug console.

Two actions, each gated behind a confirmation submenu so a single
mis-click can't trigger a destructive wipe:

  - Clear current mission's data -> dataConfirmClear -> ProfileNameSpaceClear
  - Wipe ALL ALiVE data -> dataConfirmWipe -> ProfileNameSpaceWipe

Both wipe helpers are server-only (`if !(isServer) exitwith {};` guard
in their bodies). The menu actions remoteExec to the server (target id
2) so an admin running on a client triggers the wipe correctly.

Audit: every wipe writes a diag_log line naming the admin and the
wipe scope, so RPT carries a record of the action.

Parameters:
Object - The object to attach the menu too
Array  - The menu parameters

Returns:
Array - menu definition for FlexiMenu

Author:
Jman
---------------------------------------------------------------------------- */

params ["_target", "_params"];

private _menuName = "";
private _menuRsc = "popup";

if (typeName _params == typeName []) then {
    if (count _params < 1) exitWith {["Error: Invalid params: %1, %2", _this, __FILE__] call ALiVE_fnc_dump;};
    _menuName = _params select 0;
    _menuRsc = if (count _params > 1) then {_params select 1} else {_menuRsc};
} else {
    _menuName = _params;
};

private _menus =
[
    [
        ["main", "ALiVE", _menuRsc],
        []
    ],
    [
        ["adminOptions", "Admin Options", "popup"],
        []
    ]
];

if (_menuName == "data") then {
    _menus set [count _menus,
        [
            ["data", localize "STR_ALIVE_DATA_MENU", "popup"],
            [
                [localize "STR_ALIVE_DATA_CLEAR_MISSION",
                    "",
                    "",
                    localize "STR_ALIVE_DATA_CLEAR_MISSION_COMMENT",
                    ["call ALiVE_fnc_dataMenuDef", ["dataConfirmClear"], 1],
                    -1,
                    1,
                    true
                ],
                [localize "STR_ALIVE_DATA_WIPE_ALL",
                    "",
                    "",
                    localize "STR_ALIVE_DATA_WIPE_ALL_COMMENT",
                    ["call ALiVE_fnc_dataMenuDef", ["dataConfirmWipe"], 1],
                    -1,
                    1,
                    true
                ]
            ]
        ]
    ];
};

if (_menuName == "dataConfirmClear") then {
    _menus set [count _menus,
        [
            ["dataConfirmClear", localize "STR_ALIVE_DATA_CLEAR_CONFIRM_TITLE", "popup"],
            [
                [localize "STR_ALIVE_DATA_CLEAR_CONFIRM_YES",
                    {
                        diag_log format ["[ALiVE Data] Admin %1 (UID %2) clearing current mission's profileNamespace data via admin menu.", name player, getPlayerUID player];
                        [] remoteExec ["ALiVE_fnc_ProfileNameSpaceClear", 2];
                        [localize "STR_ALIVE_DATA_CLEAR_DONE"] call CBA_fnc_notify;
                    },
                    "",
                    localize "STR_ALIVE_DATA_CLEAR_CONFIRM_YES_COMMENT",
                    "",
                    -1,
                    1,
                    true
                ],
                [localize "STR_ALIVE_DATA_CONFIRM_CANCEL",
                    "",
                    "",
                    localize "STR_ALIVE_DATA_CONFIRM_CANCEL_COMMENT",
                    ["call ALiVE_fnc_dataMenuDef", ["data"], 1],
                    -1,
                    1,
                    true
                ]
            ]
        ]
    ];
};

if (_menuName == "dataConfirmWipe") then {
    _menus set [count _menus,
        [
            ["dataConfirmWipe", localize "STR_ALIVE_DATA_WIPE_CONFIRM_TITLE", "popup"],
            [
                [localize "STR_ALIVE_DATA_WIPE_CONFIRM_YES",
                    {
                        diag_log format ["[ALiVE Data] Admin %1 (UID %2) wiping ALL ALiVE profileNamespace data via admin menu.", name player, getPlayerUID player];
                        [] remoteExec ["ALiVE_fnc_ProfileNameSpaceWipe", 2];
                        [localize "STR_ALIVE_DATA_WIPE_DONE"] call CBA_fnc_notify;
                    },
                    "",
                    localize "STR_ALIVE_DATA_WIPE_CONFIRM_YES_COMMENT",
                    "",
                    -1,
                    1,
                    true
                ],
                [localize "STR_ALIVE_DATA_CONFIRM_CANCEL",
                    "",
                    "",
                    localize "STR_ALIVE_DATA_CONFIRM_CANCEL_COMMENT",
                    ["call ALiVE_fnc_dataMenuDef", ["data"], 1],
                    -1,
                    1,
                    true
                ]
            ]
        ]
    ];
};

// Normalize CBA flexiMenu code-block actions to the string form required
// by buttonSetAction.
_menus call ALiVE_fnc_normalizeFlexiMenuActions;

private _menuDef = [];
{
    if (_x select 0 select 0 == _menuName) exitWith {_menuDef = _x};
} forEach _menus;

if (count _menuDef == 0) then {
    hintC format ["Error: Menu not found: %1\n%2\n%3", str _menuName, if (_menuName == "") then {_this}else{""}, __FILE__];
    diag_log format ["Error: Menu not found: %1, %2, %3", str _menuName, _this, __FILE__];
};

_menuDef
