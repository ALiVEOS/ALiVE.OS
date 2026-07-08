#include "\x\alive\addons\sys_profile\script_component.hpp"
#include "\a3\editor_f\Data\Scripts\dikCodes.h"

SCRIPT(profileMenuDef);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_profileMenuDef
Description:
This function controls the View portion of profile.

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
    ["call ALIVE_fnc_profileMenuDef","main"]
] call CBA_fnc_flexiMenu_Add;
(end)

See Also:
- <ALIVE_fnc_IED>
- <CBA_fnc_flexiMenu_Add>

Author:
Tupolov, Wolffy
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

if (_menuName == "profile") then {
    // Live pathfinding debug-draw toggles are offered to a logged-in admin /
    // listen-host / assigned-Zeus (the same three-gate test the virtualised
    // profile debug uses). Gating on this - NOT on the server-only
    // "alive_pathfinder" global, which is nil on every remote client - keeps the
    // entries present for the admins meant to use them, independent of whether
    // pathfinding draw is currently on or even whether pathfinding is enabled.
    private _pfAdmin   = (isServer && hasInterface) || (serverCommandAvailable "#kick") || !isNull (getAssignedCuratorLogic player);
    private _pfGridOn  = missionNamespace getVariable ["ALiVE_pathfinding_drawGrid",  false];
    private _pfPathsOn = missionNamespace getVariable ["ALiVE_pathfinding_drawPaths", false];

    _menus set [count _menus,
        [
            ["profile", localize "STR_ALIVE_PROFILE_SYSTEM", "popup"],
            [
                [localize "STR_ALIVE_PROFILE_SYSTEM_DEBUG_ENABLE",
                    {ADDON setVariable ["debug","true", true]; [] call ALIVE_fnc_profileSystemDebug; },
                    "",
                    localize "STR_ALIVE_PROFILE_SYSTEM_DEBUG1_COMMENT",
                    "",
                    -1,
                    [QUOTE(ADDON)] call ALiVE_fnc_isModuleAvailable,
                    !isnil QUOTE(ADDON) && {!((ADDON getVariable ["debug","false"]) == "true")}
                ],
                [localize "STR_ALIVE_PROFILE_SYSTEM_DEBUG_DISABLE",
                    {ADDON setVariable ["debug","false", true]; [] call ALIVE_fnc_profileSystemDebug; },
                    "",
                    localize "STR_ALIVE_PROFILE_SYSTEM_DEBUG1_COMMENT",
                    "",
                    -1,
                    [QUOTE(ADDON)] call ALiVE_fnc_isModuleAvailable,
                    !isnil QUOTE(ADDON) && {((ADDON getVariable ["debug","false"]) == "true")}
                ],
                // --- Pathfinding debug-draw toggles (live, admin only) ---
                // Offered to any admin/host/Zeus (_pfAdmin); each activate/
                // deactivate pair shows depending on the current draw flag. The
                // action no-ops safely if no pathfinder exists on this machine.
                [localize "STR_ALIVE_PROFILE_SYSTEM_PATHFINDING_DRAWGRID_ENABLE",
                    {if (!isNil "alive_pathfinder") then {[alive_pathfinder,"setDrawGrid",true] call ALiVE_fnc_pathfinder;};},
                    "",
                    localize "STR_ALIVE_PROFILE_SYSTEM_PATHFINDING_DRAWGRID_COMMENT",
                    "",
                    -1,
                    _pfAdmin,
                    _pfAdmin && {!_pfGridOn}
                ],
                [localize "STR_ALIVE_PROFILE_SYSTEM_PATHFINDING_DRAWGRID_DISABLE",
                    {if (!isNil "alive_pathfinder") then {[alive_pathfinder,"setDrawGrid",false] call ALiVE_fnc_pathfinder;};},
                    "",
                    localize "STR_ALIVE_PROFILE_SYSTEM_PATHFINDING_DRAWGRID_COMMENT",
                    "",
                    -1,
                    _pfAdmin,
                    _pfAdmin && {_pfGridOn}
                ],
                [localize "STR_ALIVE_PROFILE_SYSTEM_PATHFINDING_DRAWPATHS_ENABLE",
                    {if (!isNil "alive_pathfinder") then {[alive_pathfinder,"setDrawPaths",true] call ALiVE_fnc_pathfinder;};},
                    "",
                    localize "STR_ALIVE_PROFILE_SYSTEM_PATHFINDING_DRAWPATHS_COMMENT",
                    "",
                    -1,
                    _pfAdmin,
                    _pfAdmin && {!_pfPathsOn}
                ],
                [localize "STR_ALIVE_PROFILE_SYSTEM_PATHFINDING_DRAWPATHS_DISABLE",
                    {if (!isNil "alive_pathfinder") then {[alive_pathfinder,"setDrawPaths",false] call ALiVE_fnc_pathfinder;};},
                    "",
                    localize "STR_ALIVE_PROFILE_SYSTEM_PATHFINDING_DRAWPATHS_COMMENT",
                    "",
                    -1,
                    _pfAdmin,
                    _pfAdmin && {_pfPathsOn}
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
