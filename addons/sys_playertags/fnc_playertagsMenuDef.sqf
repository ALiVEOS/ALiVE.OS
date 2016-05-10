#include <\x\alive\addons\sys_playertags\script_component.hpp>
#include <\x\cba\addons\ui_helper\script_dikCodes.hpp>

SCRIPT(playertagsMenuDef);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_fnc_playertagsMenuDef
Description:
This function controls the View portion of playertags.

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
	["call ALIVE_fnc_playertagsMenuDef","main"]
] call CBA_fnc_flexiMenu_Add;
(end)

See Also:
- <ALIVE_fnc_playertags>
- <CBA_fnc_flexiMenu_Add>

Author:
Jman

Peer reviewed:
nil
---------------------------------------------------------------------------- */
private ["_menuDef", "_target", "_params", "_menuName", "_menuRsc", "_menus"];

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



_menus =
[
	[
		["main", "ALiVE", _menuRsc],
		[
			[localize "STR_ALIVE_PLAYERTAGS" + " >",
		  {
		  	if (GVAR(STYLE) == "default") then {0 cutRsc ["playertagsOverlayRsc", "PLAIN"]};
		  },

			"",
				localize "STR_ALIVE_PLAYERTAGS_COMMENT",
                  ["call ALiVE_fnc_playertagsMenuDef", "playertags", 1],
                 -1, 1, true
			]
		]
	]
];


if (_menuName == "playertags") then {
	_menus set [count _menus,
		[
			["playertags", localize "STR_ALIVE_PLAYERTAGS", "popup"],
			[
				[localize "STR_ALIVE_PLAYERTAGS_DISPLAY_ENABLE",
					{ ADDON setVariable ["display_enabled", true]; true call GVAR(TRIGGER); },
					"",
					localize "STR_ALIVE_PLAYERTAGS_DISPLAY_COMMENT",
					"",
					-1,
				  true,
					!(ADDON getVariable ["display_enabled", false])
				],

					[localize "STR_ALIVE_PLAYERTAGS_DISPLAY_DISABLE",
					 { 	ADDON setVariable ["display_enabled", false]; false call GVAR(TRIGGER); },
					"",
					localize "STR_ALIVE_PLAYERTAGS_DISPLAY_COMMENT",
					"",
					-1,
				  true,
					(ADDON getVariable ["display_enabled", false])
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
