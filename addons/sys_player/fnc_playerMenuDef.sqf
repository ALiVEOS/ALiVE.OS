#include <\x\alive\addons\sys_player\script_component.hpp>
#include <\x\cba\addons\ui_helper\script_dikCodes.hpp>

SCRIPT(playerMenuDef);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_playerMenuDef
Description:
This function controls the View portion of player.

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
	["call ALIVE_fnc_playerMenuDef","main"]
] call CBA_fnc_flexiMenu_Add;
(end)

See Also:
- <ALIVE_fnc_player>
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
	]
];

if (_menuName == "playerAdmin") then {
	_menus set [count _menus,
		[
			["adminOptions", "Admin Options", "popup"],
			[
			]
		]
	];
	_menus set [count _menus,
		[

			["playerAdmin", localize "STR_ALIVE_player", "popup"],
			[
				// ADMIN MENUS
				[localize "STR_ALIVE_player_allowReset_ENABLE",
					{ MOD(sys_player) setVariable ["allowReset", true, true]; },
					"",
					localize "STR_ALIVE_player_allowReset_COMMENT",
					"",
					-1,
					!(MOD(sys_player) getVariable ["allowReset",true]),
					(call ALIVE_fnc_isServerAdmin && !( (MOD(sys_player) getVariable ["allowReset",true])))
				],
				[localize "STR_ALIVE_player_allowReset_DISABLE",
					{  MOD(sys_player) setVariable ["allowReset", false, true];},
					"",
					localize "STR_ALIVE_player_allowReset_COMMENT",
					"",
					-1,
					 (MOD(sys_player) getVariable ["allowReset", true]),
					(call ALIVE_fnc_isServerAdmin && ( (MOD(sys_player) getVariable ["allowReset", true])))
				],

				[localize "STR_ALIVE_player_allowDiffClass_ENABLE",
					{ MOD(sys_player) setVariable ["allowDiffClass", true, true]},
					"",
					localize "STR_ALIVE_player_allowDiffClass_COMMENT",
					"",
					-1,
					!( (MOD(sys_player) getVariable ["allowDiffClass", false])),
					(call ALIVE_fnc_isServerAdmin && !( (MOD(sys_player) getVariable ["allowDiffClass",false])))
				],
				[localize "STR_ALIVE_player_allowDiffClass_DISABLE",
					{ MOD(sys_player) setVariable ["allowDiffClass", false, true]; },
					"",
					localize "STR_ALIVE_player_allowDiffClass_COMMENT",
					"",
					-1,
					 (MOD(sys_player) getVariable ["allowDiffClass",false]),
					(call ALIVE_fnc_isServerAdmin && ( (MOD(sys_player) getVariable ["allowDiffClass", false])))
				],

				[localize "STR_ALIVE_player_allowManualSave_ENABLE",
					{ MOD(sys_player) setVariable ["allowManualSave", true, true]; },
					"",
					localize "STR_ALIVE_player_allowManualSave_COMMENT",
					"",
					-1,
					!( (MOD(sys_player) getVariable ["allowManualSave", false])),
					(call ALIVE_fnc_isServerAdmin && !( (MOD(sys_player) getVariable ["allowManualSave", true])))
				],
				[localize "STR_ALIVE_player_allowManualSave_DISABLE",
					{ MOD(sys_player) setVariable ["allowManualSave", false, true]; },
					"",
					localize "STR_ALIVE_player_allowManualSave_COMMENT",
					"",
					-1,
					 (MOD(sys_player) getVariable ["allowManualSave", true]),
					(call ALIVE_fnc_isServerAdmin && ( (MOD(sys_player) getVariable ["allowManualSave", true])))
				]

/*				[localize "STR_ALIVE_player_storeToDB_ENABLE",
					{ MOD(sys_player) setVariable ["storeToDB",true, true]; },
					"",
					localize "STR_ALIVE_player_storeToDB_COMMENT",
					"",
					-1,
					!( (MOD(sys_player) getVariable ["storeToDB", true])),
					(call ALIVE_fnc_isServerAdmin && !( (MOD(sys_player) getVariable ["storeToDB", true])))
				],
				[localize "STR_ALIVE_player_storeToDB_DISABLE",
					{ MOD(sys_player) setVariable ["storeToDB", false, true]; },
					"",
					localize "STR_ALIVE_player_storeToDB_COMMENT",
					"",
					-1,
					 (MOD(sys_player) getVariable ["storeToDB", true]),
					(call ALIVE_fnc_isServerAdmin && ( (MOD(sys_player) getVariable ["storeToDB", true])))
				],

				[localize "STR_ALIVE_player_autoSaveTime_SET",
					{ createDialog "ALIVE_ui_sys_player_setautoSaveTime";},
					"",
					localize "STR_ALIVE_player_autoSaveTime_COMMENT",
					"",
					-1,
					!isNil QMOD(sys_data) && {MOD(sys_data_DISABLED) && MOD(sys_player) getVariable ["storeToDB", false]},
					call ALIVE_fnc_isServerAdmin
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
