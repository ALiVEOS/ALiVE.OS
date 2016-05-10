#include <\x\alive\addons\sys_playeroptions\script_component.hpp>
#include <\x\cba\addons\ui_helper\script_dikCodes.hpp>

SCRIPT(playeroptionsMenuDef);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_playeroptionsMenuDef
Description:
This function controls the View portion of player options.

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
	["call ALIVE_fnc_playeroptionsMenuDef","main"]
] call CBA_fnc_flexiMenu_Add;
(end)

See Also:
- <ALIVE_fnc_adminActions>
- <CBA_fnc_flexiMenu_Add>

Author:
Tupolov

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
			[localize "STR_ALIVE_PLAYEROPTIONS_SHORT" + " >",
				"",
				"",
				localize "STR_ALIVE_PLAYEROPTIONS_COMMENT",
                ["call ALiVE_fnc_playeroptionsMenuDef", "playeroptions", 1],
                -1,
                1,
                !isnil QMOD(sys_playeroptions)
			]
		]
	]
];


if (_menuName == "playeroptions") then {
	_menus set [count _menus,
		[
			["playeroptions", localize "STR_ALIVE_PLAYEROPTIONS", "popup"],
			[
				[localize "STR_ALIVE_VDIST",
					{[] call ALIVE_fnc_vDistGuiInit},
					"",
					localize "STR_ALIVE_VDIST_COMMENT",
			 		"",
			 		-1,
			 		1,
			 		true
				],
				[localize "STR_ALIVE_PLAYERTAGS_DISPLAY_ENABLE",
					{ MOD(sys_playertags) setVariable ["display_enabled", true]; true call MOD(sys_playertags_TRIGGER); },
					"",
					localize "STR_ALIVE_PLAYERTAGS_DISPLAY_COMMENT",
					"",
					-1,
				 	true,
					!isnil QMOD(sys_playertags) && !(MOD(sys_playertags) getVariable ["display_enabled", false])
				],
				[localize "STR_ALIVE_PLAYERTAGS_DISPLAY_DISABLE",
					 { 	MOD(sys_playertags)  setVariable ["display_enabled", false]; false call MOD(sys_playertags_TRIGGER); },
					"",
					localize "STR_ALIVE_PLAYERTAGS_DISPLAY_COMMENT",
					"",
					-1,
				  	true,
					!isnil QMOD(sys_playertags) && ( MOD(sys_playertags) getVariable ["display_enabled", false])
				],
				[localize "STR_ALIVE_LOGISTICS_ENABLEACTIONS_COMMENT",
					{[MOD(SYS_LOGISTICS),"addActions"] call ALiVE_fnc_Logistics},
					"",
					localize "STR_ALIVE_LOGISTICS_ENABLEACTIONS_COMMENT",
					"",
					-1,
					true,
					!isnil QMOD(sys_logistics) && (isnil {player getvariable [QMOD(SYS_LOGISTICS_ACTIONS),nil]})
				],
                [localize "STR_ALIVE_LOGISTICS_DISABLEACTIONS_COMMENT",
					{[MOD(SYS_LOGISTICS),"removeActions"] call ALiVE_fnc_Logistics},
					"",
					localize "STR_ALIVE_LOGISTICS_DISABLEACTIONS_COMMENT",
					"",
					-1,
					true,
					!isnil QMOD(sys_logistics) && !(isnil {player getvariable [QMOD(SYS_LOGISTICS_ACTIONS),nil]})
				],
				[localize "STR_ALIVE_player_allowReset_ACTION",
					{ [MOD(sys_player), "resetPlayer", [player]] call ALIVE_fnc_player;},
					"",
					localize "STR_ALIVE_player_allowReset_ACTION_COMMENT",
					"",
					-1,
					!(isNil QGVAR(resetAvailable)),
					!isNil QMOD(sys_player) && MOD(sys_player) getVariable ["enablePlayerPersistence",false] && (MOD(sys_player) getVariable ["allowReset", false])
				],
				[localize "STR_ALIVE_player_allowManualSave_ACTION",
					{ [MOD(sys_player), "manualSavePlayer", [player]] call ALIVE_fnc_player },
					"",
					localize "STR_ALIVE_player_allowManualSave_ACTION_COMMENT",
					"",
					-1,
					 (MOD(sys_player) getVariable ["allowManualSave", true]),
					 !isNil QMOD(sys_player) && MOD(sys_player) getVariable ["enablePlayerPersistence",false] && (MOD(sys_player) getVariable ["allowManualSave", true])
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
