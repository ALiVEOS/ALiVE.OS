#include <\x\alive\addons\sys_logistics\script_component.hpp>
#include <\x\cba\addons\ui_helper\script_dikCodes.hpp>

SCRIPT(logisticsMenuDef);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_logisticsMenuDef
Description:
This function controls the View portion of logistics.

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
	["call ALIVE_fnc_logisticsMenuDef","main"]
] call CBA_fnc_flexiMenu_Add;
(end)

See Also:
- <ALIVE_fnc_logistics>
- <CBA_fnc_flexiMenu_Add>

Author:
Highhead

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

_menus =
[
	[
		["main", "ALiVE", _menuRsc],
		[
			[localize "STR_ALIVE_PLAYEROPTIONS_SHORT" + " >",
				"",
				"",
				localize "STR_ALIVE_PLAYEROPTIONS_COMMENT",
                ["call ALiVE_fnc_logisticsMenuDef", "logistics", 1],
                -1,
                1,
                [QMOD(SYS_LOGISTICS)] call ALiVE_fnc_isModuleAvailable
			]
		]
	]
];

//-----------------------------------------------------------------------------

TRACE_2("Menu setup",MOD(SYS_LOGISTICS),[QMOD(SYS_LOGISTICS)] call ALiVE_fnc_isModuleAvailable);

if (_menuName == "logistics") then {
    	_menus set [count _menus,
		[
        	["logistics", localize "STR_ALIVE_PLAYEROPTIONS", "popup"],
			[
				[localize "STR_ALIVE_LOGISTICS_ENABLEACTIONS_COMMENT",
					{[MOD(SYS_LOGISTICS),"addActions"] call ALiVE_fnc_Logistics},
					"",
					localize "STR_ALIVE_LOGISTICS_ENABLEACTIONS_COMMENT",
					"",
					-1,
					true,
					(isnil {player getvariable [QGVAR(ACTIONS),nil]})
				],
                [localize "STR_ALIVE_LOGISTICS_DISABLEACTIONS_COMMENT",
					{[MOD(SYS_LOGISTICS),"removeActions"] call ALiVE_fnc_Logistics},
					"",
					localize "STR_ALIVE_LOGISTICS_DISABLEACTIONS_COMMENT",
					"",
					-1,
					true,
					!(isnil {player getvariable [QGVAR(ACTIONS),nil]})
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
