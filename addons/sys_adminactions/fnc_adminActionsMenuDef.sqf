#include <\x\alive\addons\sys_adminactions\script_component.hpp>
#include <\x\cba\addons\ui_helper\script_dikCodes.hpp>

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
			[localize "STR_ALIVE_ADMINACTIONS" + " >",
				"",
				"",
				localize "STR_ALIVE_ADMINACTIONS_COMMENT",
                ["call ALiVE_fnc_adminActionsMenuDef", "adminActions", 1],
                -1,
                1,
                call ALIVE_fnc_isServerAdmin
			],
			[localize "STR_ALIVE_ADMINACTIONS_OPTIONS" + " >",
				"",
				"",
				localize "STR_ALIVE_ADMINACTIONS_OPTIONS_COMMENT",
                ["call ALiVE_fnc_adminActionsMenuDef", "adminOptions", 1],
                -1,
                1,
                call ALIVE_fnc_isServerAdmin
			]
		]
	]
];

TRACE_4("Menu setup",ADDON,ADDON getVariable "ghost",ADDON getVariable "teleport",ADDON getVariable "mark_units");

if (_menuName == "adminActions") then {
	_menus set [count _menus,
		[
			["adminActions", localize "STR_ALIVE_ADMINACTIONS", "popup"],
			[
				[localize "STR_ALIVE_ADMINACTIONS_MARK_UNITS_ENABLE",
					{ [] call ALIVE_fnc_markUnits },
					"",
					localize "STR_ALIVE_ADMINACTIONS_MARK_UNITS_COMMENT",
					"",
					-1,
					1,
					true
				],
				[localize "STR_ALIVE_ADMINACTIONS_GHOST_ENABLE",
					//{ player setCaptive true },
					{ ADDON setVariable ["GHOST_enabled", true]; [player,true] call ALIVE_fnc_adminGhost; },
					"",
					localize "STR_ALIVE_ADMINACTIONS_GHOST_COMMENT",
					"",
					-1,
					1,
					//!captive player
					!(ADDON getVariable ["GHOST_enabled", false])
				],
				[localize "STR_ALIVE_ADMINACTIONS_GHOST_DISABLE",
				    { ADDON setVariable ["GHOST_enabled", false]; [player,false] call ALIVE_fnc_adminGhost; },
					//{ player setCaptive false },
					"",
					localize "STR_ALIVE_ADMINACTIONS_GHOST_COMMENT",
					"",
					-1,
					1,
					//captive player
					(ADDON getVariable ["GHOST_enabled", false])
				],

				[localize "STR_ALIVE_ADMINACTIONS_TELEPORT_ENABLE",
					{ ADDON setVariable ["teleport_enabled", true]; onMapSingleClick {vehicle player setPos _pos;} },
					"",
					localize "STR_ALIVE_ADMINACTIONS_TELEPORT_COMMENT",
					"",
					-1,
					1,
					!(ADDON getVariable ["teleport_enabled", false])
				],
				[localize "STR_ALIVE_ADMINACTIONS_TELEPORT_DISABLE",
					{ ADDON setVariable ["teleport_enabled", false]; onMapSingleClick DEFAULT_MAPCLICK; },
					"",
					localize "STR_ALIVE_ADMINACTIONS_TELEPORT_COMMENT",
					"",
					-1,
					1,
					(ADDON getVariable ["teleport_enabled", false])
				],

                [localize "STR_ALIVE_ADMINACTIONS_TELEPORTUNITS",
					{ ["CAManBase"] spawn ALiVE_fnc_AdminActionsTeleportUnits },
					"",
					localize "STR_ALIVE_ADMINACTIONS_TELEPORTUNITS_COMMENT",
					"",
					-1,
					1,
					true
				],
				[localize "STR_ALIVE_ADMINACTIONS_CREATE_PROFILES_ENABLE",
                    { [] call ALIVE_fnc_adminCreateProfiles; },
                    "",
                    localize "STR_ALIVE_ADMINACTIONS_CREATE_PROFILES_COMMENT",
                    "",
                    -1,
                    1,
                    true
                ],
                [localize "STR_ALIVE_ADMINACTIONS_OPCOM_TOGGLEINSTALLATIONS",
                    { [] call ALIVE_fnc_OPCOMToggleInstallations; },
                    "",
                    localize "STR_ALIVE_ADMINACTIONS_OPCOM_TOGGLEINSTALLATIONS_COMMENT",
                    "",
                    -1,
                    1,
                    !isnil "ALiVE_mil_OPCOM"
                ],

				[localize "STR_ALIVE_ADMINACTIONS_CONSOLE_ENABLE",
					{ createDialog "RscDisplayDebugPublic" },
					"",
					localize "STR_ALIVE_ADMINACTIONS_CONSOLE_COMMENT",
					"",
					-1,
					1,
					true
				]
			]
		]
	];
};

if (_menuName == "adminOptions") then {
	_menus set [count _menus,
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
	                !isNil QMOD(CQB) && call ALIVE_fnc_isServerAdmin
				],
				[localize "STR_ALIVE_IED" + " >",
					"",
					"",
					localize "STR_ALIVE_IED_COMMENT",
	                ["call ALiVE_fnc_IEDMenuDef", "IED", 1],
	                 -1,
	                 1,
	                !isNil QMOD(mil_IED) && call ALIVE_fnc_isServerAdmin
				],
				[localize "STR_ALIVE_PROFILE_SYSTEM" + " >",
					"",
					"",
					localize "STR_ALIVE_PROFILE_SYSTEM_COMMENT",
	                ["call ALiVE_fnc_profileMenuDef", "profile", 1],
	                 -1,
	                 1,
	                !isNil QMOD(sys_profile) && call ALIVE_fnc_isServerAdmin
				],
				[localize "STR_ALIVE_CIV_POP" + " >",
					"",
					"",
					localize "STR_ALIVE_CIV_POP_COMMENT",
	                ["call ALiVE_fnc_civilianPopulationMenuDef", "civpop", 1],
	                 -1,
	                 1,
	                !isNil QMOD(amb_civ_population) && call ALIVE_fnc_isServerAdmin
				],
				[localize "STR_ALIVE_player" + " >",
					"",
					"",
					localize "STR_ALIVE_player_COMMENT",
	                ["call ALiVE_fnc_playerMenuDef", "playeradmin", 1],
	                 -1,
	                 1,
	                !isNil QMOD(sys_player) && {MOD(sys_player) getVariable ["enablePlayerPersistence",false]} && {call ALIVE_fnc_isServerAdmin}
				],
				[localize "STR_ALIVE_STATISTICS" + " >",
					"",
					"",
					localize "STR_ALIVE_STATISTICS_ENABLE_COMMENT",
	                ["call ALiVE_fnc_statisticsMenuDef", "statistics", 1],
	                -1,
	                !isNil QMOD(sys_statistics_ENABLED),
	                !isNil QMOD(statistics) && call ALIVE_fnc_isServerAdmin
				]/*,
				[localize "STR_ALIVE_Data" + " >",
					"",
					"",
					localize "STR_ALIVE_Data_COMMENT",
	                ["call ALiVE_fnc_dataMenuDef", "data", 1],
	                -1,
	                !isNil QMOD(sys_data) && {!MOD(sys_data_DISABLED)},
	                !isNil QMOD(sys_data) && call ALIVE_fnc_isServerAdmin
				]*/
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
