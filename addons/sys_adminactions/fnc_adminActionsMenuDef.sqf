#include <\x\alive\addons\sys_adminactions\script_component.hpp>
#include <\a3\editor_f\Data\Scripts\dikCodes.h>

SCRIPT(adminActionsMenuDef);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_adminActionsMenuDef

Description:
This function controls the View portion of adminActions.

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
    ["call ALIVE_fnc_adminActionsMenuDef","main"]
] call CBA_fnc_flexiMenu_Add;
(end)

See Also:
- <ALIVE_fnc_adminActions>
- <CBA_fnc_flexiMenu_Add>

Author:
Wolffy.au
shukari

//-----------------------------------------------------------------------------
// Menu example
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
---------------------------------------------------------------------------- */
params ["", "_params"];
_params params [
        ["_menuName", ""],
        ["_menuRsc", "popup"]
    ];

switch (_menuName) do {
    case "main": {
        private _isAdmin = call ALIVE_fnc_isServerAdmin || call BIS_fnc_isDebugConsoleAllowed;
        
        [
            ["main", "ALiVE", _menuRsc],
            [
                [localize "STR_ALIVE_ADMINACTIONS" + " >",
                    "",
                    "",
                    localize "STR_ALIVE_ADMINACTIONS_COMMENT",
                    ["call ALiVE_fnc_adminActionsMenuDef", ["adminActions"], 1],
                    -1,
                    1,
                    _isAdmin
                ],
                [localize "STR_ALIVE_ADMINACTIONS_OPTIONS" + " >",
                    "",
                    "",
                    localize "STR_ALIVE_ADMINACTIONS_OPTIONS_COMMENT",
                    ["call ALiVE_fnc_adminActionsMenuDef", ["adminOptions"], 1],
                    -1,
                    1,
                    _isAdmin
                ]
            ]
        ]
    };
    case "adminActions": {
        [
            ["adminActions", localize "STR_ALIVE_ADMINACTIONS", "popup"],
            [
                [localize "STR_ALIVE_ADMINACTIONS_MARK_UNITS_ENABLE",
                    {[] call ALIVE_fnc_markUnits},
                    "",
                    localize "STR_ALIVE_ADMINACTIONS_MARK_UNITS_COMMENT",
                    "",
                    -1,
                    1,
                    true
                ],
                [localize "STR_ALIVE_ADMINACTIONS_GHOST_ENABLE",
                    //{player setCaptive true},
                    {ADDON setVariable ["GHOST_enabled", true]; [player, true] call ALIVE_fnc_adminGhost;},
                    "",
                    localize "STR_ALIVE_ADMINACTIONS_GHOST_COMMENT",
                    "",
                    -1,
                    1,
                    //!captive player
                    !(ADDON getVariable ["GHOST_enabled", false])
                ],
                [localize "STR_ALIVE_ADMINACTIONS_GHOST_DISABLE",
                    {ADDON setVariable ["GHOST_enabled", false]; [player, false] call ALIVE_fnc_adminGhost;},
                    //{player setCaptive false},
                    "",
                    localize "STR_ALIVE_ADMINACTIONS_GHOST_COMMENT",
                    "",
                    -1,
                    1,
                    //captive player
                    (ADDON getVariable ["GHOST_enabled", false])
                ],
                [localize "STR_ALIVE_ADMINACTIONS_TELEPORT_ENABLE",
                    {ADDON setVariable ["teleport_enabled", true]; onMapSingleClick {(vehicle player) setPos _pos}},
                    "",
                    localize "STR_ALIVE_ADMINACTIONS_TELEPORT_COMMENT",
                    "",
                    -1,
                    1,
                    !(ADDON getVariable ["teleport_enabled", false])
                ],
                [localize "STR_ALIVE_ADMINACTIONS_TELEPORT_DISABLE",
                    {ADDON setVariable ["teleport_enabled", false]; onMapSingleClick DEFAULT_MAPCLICK;},
                    "",
                    localize "STR_ALIVE_ADMINACTIONS_TELEPORT_COMMENT",
                    "",
                    -1,
                    1,
                    (ADDON getVariable ["teleport_enabled", false])
                ],
                [localize "STR_ALIVE_ADMINACTIONS_TELEPORTUNITS",
                    {["CAManBase"] spawn ALiVE_fnc_AdminActionsTeleportUnits},
                    "",
                    localize "STR_ALIVE_ADMINACTIONS_TELEPORTUNITS_COMMENT",
                    "",
                    -1,
                    1,
                    true
                ],
                [localize "STR_ALIVE_ADMINACTIONS_CREATE_PROFILES_ENABLE",
                    {[] call ALIVE_fnc_adminCreateProfiles;},
                    "",
                    localize "STR_ALIVE_ADMINACTIONS_CREATE_PROFILES_COMMENT",
                    "",
                    -1,
                    1,
                    true
                ],
                [localize "STR_ALIVE_ADMINACTIONS_OPCOM_TOGGLEINSTALLATIONS",
                    {[] call ALIVE_fnc_OPCOMToggleInstallations;},
                    "",
                    localize "STR_ALIVE_ADMINACTIONS_OPCOM_TOGGLEINSTALLATIONS_COMMENT",
                    "",
                    -1,
                    1,
                    !isnil "ALiVE_mil_OPCOM"
                ],
                [localize "STR_ALIVE_ADMINACTIONS_CONSOLE_ENABLE",
                    {createDialog "RscDisplayDebugPublic"},
                    "",
                    localize "STR_ALIVE_ADMINACTIONS_CONSOLE_COMMENT",
                    "",
                    -1,
                    !isMultiplayer || (call BIS_fnc_admin) > 0 ||
                        {(getMissionConfigValue ["enableDebugConsole", 0]) isEqualType 0 && {(getMissionConfigValue ["enableDebugConsole", 0]) > 0}} ||
                        {(getMissionConfigValue ["enableDebugConsole", []]) isEqualType [] && {getPlayerUID player in (getMissionConfigValue ["enableDebugConsole", []])}},
                    true
                ]
            ]
        ]
    };
    case "adminOptions": {
        [
            ["adminOptions", localize "STR_ALIVE_ADMINACTIONS_OPTIONS", "popup"],
            [
                [localize "STR_ALIVE_CQB" + " >",
                    "",
                    "",
                    localize "STR_ALIVE_CQB_COMMENT",
                    ["call ALiVE_fnc_CQBMenuDef", "cqb", 1],
                    -1,
                    1,
                    !isNil QMOD(CQB)
                ],
                [localize "STR_ALIVE_IED" + " >",
                    "",
                    "",
                    localize "STR_ALIVE_IED_COMMENT",
                    ["call ALiVE_fnc_IEDMenuDef", "IED", 1],
                     -1,
                     1,
                    !isNil QMOD(mil_IED)
                ],
                [localize "STR_ALIVE_PROFILE_SYSTEM" + " >",
                    "",
                    "",
                    localize "STR_ALIVE_PROFILE_SYSTEM_COMMENT",
                    ["call ALiVE_fnc_profileMenuDef", "profile", 1],
                     -1,
                     1,
                    !isNil QMOD(sys_profile)
                ],
                [localize "STR_ALIVE_CIV_POP" + " >",
                    "",
                    "",
                    localize "STR_ALIVE_CIV_POP_COMMENT",
                    ["call ALiVE_fnc_civilianPopulationMenuDef", "civpop", 1],
                     -1,
                     1,
                    !isNil QMOD(amb_civ_population)
                ],
                [localize "STR_ALIVE_player" + " >",
                    "",
                    "",
                    localize "STR_ALIVE_player_COMMENT",
                    ["call ALiVE_fnc_playerMenuDef", "playeradmin", 1],
                     -1,
                     1,
                    !isNil QMOD(sys_player) && {MOD(sys_player) getVariable ["enablePlayerPersistence",false]}
                ],
                [localize "STR_ALIVE_STATISTICS" + " >",
                    "",
                    "",
                    localize "STR_ALIVE_STATISTICS_ENABLE_COMMENT",
                    ["call ALiVE_fnc_statisticsMenuDef", "statistics", 1],
                    -1,
                    !isNil QMOD(sys_statistics_ENABLED),
                    !isNil QMOD(statistics)
                ]/*,
                [localize "STR_ALIVE_Data" + " >",
                    "",
                    "",
                    localize "STR_ALIVE_Data_COMMENT",
                    ["call ALiVE_fnc_dataMenuDef", "data", 1],
                    -1,
                    !isNil QMOD(sys_data) && {!MOD(sys_data_DISABLED)},
                    !isNil QMOD(sys_data)
                ]*/
            ]
        ]
    };
    default {[]};
};
