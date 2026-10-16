#include "\x\alive\addons\sup_fob\script_component.hpp"
SCRIPT(fobEdenManageLoad);

/* ----------------------------------------------------------------------------
Function: fnc_fobEdenManageLoad

Description:
Eden attributeLoad for Who Can Dismantle (ALiVE_FOBManageChoice, on ALiVE_SideChoiceMulti): a
multi-select list of who on the FOB's side may dismantle it, recycle what was built there and
rename it. Any ticked row lets a player in; with none ticked only admins can.

Storage: one string, the ticked rows' tokens comma separated: SIDE, LEADER, DEPLOYER, LIST.

Parameters:
    [_display, _value]

Author:
Jman
---------------------------------------------------------------------------- */

params [["_display", controlNull], ["_value", "SIDE"]];
if (isNull _display) exitWith {};
private _list = _display controlsGroupCtrl 100;
if (isNull _list) exitWith {};
(_display controlsGroupCtrl 101) ctrlSetText localize "STR_ALIVE_FOB_MANAGE_WHO";

private _raw = if (_value isEqualType "") then { _value } else { "SIDE" };
private _picked = (toUpper _raw) splitString "[]""', ";

lbClear _list;
{
    _x params ["_token", "_key"];
    private _i = _list lbAdd localize _key;
    _list lbSetData [_i, _token];
    _list lbSetTooltip [_i, localize (_key + "_COMMENT")];
    if (_token in _picked) then { _list lbSetSelected [_i, true] };
} forEach [
    ["SIDE", "STR_ALIVE_FOB_MANAGE_SIDE"],
    ["LEADER", "STR_ALIVE_FOB_MANAGE_LEADER"],
    ["DEPLOYER", "STR_ALIVE_FOB_MANAGE_DEPLOYER"],
    ["LIST", "STR_ALIVE_FOB_MANAGE_LIST"]
];

// a plain click ticks or unticks just that row, and ticked rows read [+], as on ALiVE's other lists
[_list] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenListToggle.sqf';
