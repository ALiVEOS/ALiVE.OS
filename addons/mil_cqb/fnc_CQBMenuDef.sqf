#include <\x\alive\addons\mil_CQB\script_component.hpp>
#include <\x\cba\addons\ui_helper\script_dikCodes.hpp>

SCRIPT(CQBMenuDef);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_profileMenuDef
Description:
This function controls the View portion of CQB.

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
	["call ALIVE_fnc_CQBMenuDef","main"]
] call CBA_fnc_flexiMenu_Add;
(end)

See Also:
- <ALIVE_fnc_IED>
- <CBA_fnc_flexiMenu_Add>

Author:
Tupolov, Wolffy

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

if (_menuName == "cqb") then {
	_menus set [count _menus,
		[
			["cqb", localize "STR_ALIVE_CQB", "popup"],
			[
                [localize "STR_ALIVE_CQB_DEBUG_ENABLE",
					{MOD(CQB) setVariable ["debug","true", true]; {[_x,"debug",true] call ALiVE_fnc_CQB} foreach (MOD(CQB) getVariable ["instances",[]]); },
					"",
					localize "STR_ALIVE_CQB_DEBUG_ENABLE_COMMENT",
					"",
					-1,
                    [QUOTE(ADDON)] call ALiVE_fnc_isModuleAvailable,
                    !isnil QUOTE(MOD(CQB)) && {!(MOD(CQB) getVariable ["debug",false])}
				],
				[localize "STR_ALIVE_CQB_DEBUG_DISABLE",
					{MOD(CQB) setVariable ["debug","false", true]; {[_x,"debug",false] call ALiVE_fnc_CQB} foreach (MOD(CQB) getVariable ["instances",[]]); },
					"",
					localize "STR_ALIVE_CQB_DEBUG_DISABLE_COMMENT",
					"",
					-1,
                    [QUOTE(ADDON)] call ALiVE_fnc_isModuleAvailable,
                    !isnil QUOTE(MOD(CQB)) && {(MOD(CQB) getVariable ["debug",false])}
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


