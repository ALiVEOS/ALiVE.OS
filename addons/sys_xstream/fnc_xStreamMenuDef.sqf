#include <\x\alive\addons\sys_xstream\script_component.hpp>
#include <\x\cba\addons\ui_helper\script_dikCodes.hpp>

SCRIPT(xstreamMenuDef);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_xstreamMenuDef
Description:
This function controls the View portion of xstream.

Parameters:
Object - The object to attach the menu too
Array - The menu parameters

Returns:
Array - Returns the menu definitions for FlexiMenu

Examples:
(begin example)
// initialise main menu
[
	"xstream",
	[221,[false,false,false]],
	-9500,
	["call ALIVE_fnc_xstreamMenuDef","main"]
] call CBA_fnc_flexiMenu_Add;
(end)

See Also:
- <ALIVE_fnc_xstream>
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

diag_log ">>>>>>>>>>>>>>>>>>>>>>>MENU<<<<<<<<<<<<<<<<<<<<<<<<<<";
diag_log format [">>>>>%1<<<<<<<",_this];
TRACE_1("sys_xstream",_this);

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
			[localize "STR_ALIVE_XSTREAM" + " >",
				"",
				"",
				localize "STR_ALIVE_xstream_COMMENT",
	       		 ["call ALiVE_fnc_xstreamMenuDef", "xstream", 1],
	        		-1, 1, true
			]
		]
	]
];

TRACE_4("Menu setup",MOD(sys_xstream),MOD(sys_xstream) getVariable "clientID",MOD(sys_xstream) getVariable "enablecamera",MOD(sys_xstream) getVariable "enableTwitch");

if (_menuName == "xstream") then {
	_menus set [count _menus,
		[
			["xstream", localize "STR_ALIVE_XSTREAM", "popup"],
			[
				// ADMIN MENUS
				[localize "STR_ALIVE_XSTREAM_enableTwitch_ENABLE",
					{ MOD(sys_xstream) setVariable ["enableTwitch", true, true]; },
					"",
					localize "STR_ALIVE_XSTREAM_enableTwitch_COMMENT",
					"",
					-1,
					!(MOD(sys_xstream) getVariable ["enableTwitch",true]),
					(call ALIVE_fnc_isServerAdmin && !( (MOD(sys_xstream) getVariable ["enableTwitch",true])))
				],
				[localize "STR_ALIVE_XSTREAM_enableTwitch_DISABLE",
					{  MOD(sys_xstream) setVariable ["enableTwitch", false, true];},
					"",
					localize "STR_ALIVE_XSTREAM_enableTwitch_COMMENT",
					"",
					-1,
					 (MOD(sys_xstream) getVariable ["enableTwitch", true]),
					(call ALIVE_fnc_isServerAdmin && ( (MOD(sys_xstream) getVariable ["enableTwitch", true])))
				],

				[localize "STR_ALIVE_XSTREAM_enableLiveMap_ENABLE",
					{ MOD(sys_xstream) setVariable ["enableLiveMap", true, true]},
					"",
					localize "STR_ALIVE_XSTREAM_enableLiveMap_COMMENT",
					"",
					-1,
					!( (MOD(sys_xstream) getVariable ["enableLiveMap", false])),
					(call ALIVE_fnc_isServerAdmin && !( (MOD(sys_xstream) getVariable ["enableLiveMap",false])))
				],
				[localize "STR_ALIVE_XSTREAM_enableLiveMap_DISABLE",
					{ MOD(sys_xstream) setVariable ["enableLiveMap", false, true]; },
					"",
					localize "STR_ALIVE_XSTREAM_enableLiveMap_COMMENT",
					"",
					-1,
					 (MOD(sys_xstream) getVariable ["enableLiveMap",false]),
					(call ALIVE_fnc_isServerAdmin && ( (MOD(sys_xstream) getVariable ["enableLiveMap", false])))
				],

				[localize "STR_ALIVE_XSTREAM_enableCamera_ENABLE",
					{ MOD(sys_xstream) setVariable ["enableCamera", true, true]; },
					"",
					localize "STR_ALIVE_XSTREAM_enableCamera_COMMENT",
					"",
					-1,
					!( (MOD(sys_xstream) getVariable ["enableCamera", false])),
					(call ALIVE_fnc_isServerAdmin && !( (MOD(sys_xstream) getVariable ["enableCamera", true])))
				],
				[localize "STR_ALIVE_XSTREAM_enableCamera_DISABLE",
					{ MOD(sys_xstream) setVariable ["enableCamera", false, true]; },
					"",
					localize "STR_ALIVE_XSTREAM_enableCamera_COMMENT",
					"",
					-1,
					 (MOD(sys_xstream) getVariable ["enableCamera", true]),
					(call ALIVE_fnc_isServerAdmin && ( (MOD(sys_xstream) getVariable ["enableCamera", true])))
				],

				// PLAYER MENUS
				[localize "STR_ALIVE_XSTREAM_startCamera",
					{ [MOD(sys_xstream), "startCamera", [name player]] call ALIVE_fnc_xstream;},
					"",
					"",
					"",
					-1,
					(name player) in (MOD(sys_xstream) getVariable ["clientID", [name player]]), // player is in client IDs
					(MOD(sys_xstream) getVariable ["enableCamera", true]) && !(GVAR(cameraStarted))
				],
				[localize "STR_ALIVE_XSTREAM_stopCamera",
					{ [MOD(sys_xstream), "stopCamera", [name player]] call ALIVE_fnc_xstream },
					"",
					"",
					"",
					-1,
					 (name player) in (MOD(sys_xstream) getVariable ["clientID", [name player]]),
					 (MOD(sys_xstream) getVariable ["enableCamera", true]) && (GVAR(cameraStarted))
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
