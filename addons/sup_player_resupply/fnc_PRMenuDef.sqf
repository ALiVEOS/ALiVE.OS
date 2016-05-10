#include <\x\alive\addons\sup_player_resupply\script_component.hpp>
#include <\x\cba\addons\ui_helper\script_dikCodes.hpp>

SCRIPT(PRMenuDef);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_PRMenuDef
Description:
This function controls the View portion

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
	["call ALIVE_fnc_vdistMenuDef","main"]
] call CBA_fnc_flexiMenu_Add;
(end)

See Also:
- <ALIVE_fnc_PR>
- CBA_fnc_flexiMenu_Add

Author:
ARJay
Peer reviewed:
nil
---------------------------------------------------------------------------- */

private ["_menuDef","_target","_params","_menuName","_menuRsc","_menus","_backpacks","_userItems","_items","_result"];
// _this==[_target, _menuNameOrParams]

PARAMS_2(_target,_params);

_menuName = "";
_menuRsc = "popup";
_items = assignedItems player + items player;
_backpacks = Backpack player;
_userItems = [[MOD(SUP_PLAYER_RESUPPLY),"pr_item"] call ALIVE_fnc_PR,"ALIVE_Tablet"];
//Finds selected userItem-string(s) in assignedItems
_result = (({([toLower(str(_items + [_backpacks])), toLower(_x)] call CBA_fnc_find) > -1} count _userItems) > 0);

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
			[localize "STR_ALIVE_PR",
				{["OPEN",[]] call ALIVE_fnc_PRTabletOnAction},
				"",
				localize "STR_ALIVE_PR_COMMENT",
                "",
                -1,
                (MOD(Require) getVariable [format["ALIVE_MIL_LOG_AVAIL_%1", (side player)], false]),
                !([QMOD(mil_C2ISTAR)] call ALiVE_fnc_isModuleAvailable) && {_result}
			]
		]
	]
];


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
