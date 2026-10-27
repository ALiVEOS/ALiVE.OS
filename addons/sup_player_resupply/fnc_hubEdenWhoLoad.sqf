#include "\x\alive\addons\sup_player_resupply\script_component.hpp"
SCRIPT(hubEdenWhoLoad);

/* ----------------------------------------------------------------------------
Function: fnc_hubEdenWhoLoad

Description:
Eden attributeLoad for the Logistics Hub's Who Can Collect (ALiVE_HubCollectChoice, on
ALiVE_SideChoiceMulti): a multi-select list of who on the hub's side may collect a requisition
there. Any ticked row lets a player in; with none ticked only admins can.

Storage: one string, the ticked rows' tokens comma separated: SIDE, LEADER, ITEM, LIST.

Parameters:
    [_display, _value, _titleKey, _default]

Author:
Jman
---------------------------------------------------------------------------- */

params [["_display", controlNull], ["_value", "SIDE"], ["_titleKey", "STR_ALIVE_HUB_COLLECT_WHO"], ["_default", "SIDE"]];
if (isNull _display) exitWith {};
private _list = _display controlsGroupCtrl 100;
if (isNull _list) exitWith {};
(_display controlsGroupCtrl 101) ctrlSetText localize _titleKey;

private _raw = if (_value isEqualType "") then { _value } else { _default };
private _picked = (toUpper _raw) splitString "[]""', ";

lbClear _list;
{
    _x params ["_token", "_key"];
    private _i = _list lbAdd localize _key;
    _list lbSetData [_i, _token];
    _list lbSetTooltip [_i, localize (_key + "_COMMENT")];
    if (_token in _picked) then { _list lbSetSelected [_i, true] };
} forEach [
    ["SIDE", "STR_ALIVE_HUB_WHO_SIDE"],
    ["LEADER", "STR_ALIVE_HUB_WHO_LEADER"],
    ["ITEM", "STR_ALIVE_HUB_WHO_ITEM"],
    ["LIST", "STR_ALIVE_HUB_WHO_LIST"]
];

// a plain click ticks or unticks just that row, and ticked rows read [+], as on ALiVE's other lists
[_list] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenListToggle.sqf';
