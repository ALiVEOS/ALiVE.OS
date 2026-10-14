#include "\x\alive\addons\mil_opcom\script_component.hpp"
SCRIPT(insTypesEdenChoiceLoad);

/* ----------------------------------------------------------------------------
Function: fnc_insTypesEdenChoiceLoad

Description:
Eden attributeLoad for the AI Commander's Installation Types (#1081): a ticked list of what an
Asymmetric commander may set up or carry out. ALiVE's filtered multi-select with its filter rows and
typed field hidden, as the list is fixed. Saved as the ticked keys separated by commas
(fnc_hvtEdenChoiceSave), all of them by default.

Parameters:
    [_display, stored value]

Author:
Jman
---------------------------------------------------------------------------- */

params [["_display", controlNull], ["_value", ""]];
if (isNull _display) exitWith {};
private _list = _display controlsGroupCtrl 100;
if (isNull _list) exitWith {};

(_display controlsGroupCtrl 101) ctrlSetText localize "STR_ALIVE_OPCOM_INSTYPES";
// a fixed list: no filters and no typed field
// a fixed list: no filter rows and no typed field, and the picker closes up the space they took
[_display, [1200, 1201, 1210, 1211, 102, 103], [[5, 5], [31, 5]]] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenPickerCutRows.sqf';

private _rows = [
    ["factory", "Factories (IED or drug lab)"],
    ["depot", "Weapons depots"],
    ["recruit", "Recruitment HQs"],
    ["ied", "Roadside IEDs"],
    ["suicide", "Suicide bombers"],
    ["sabotage", "Sabotage"],
    ["ambush", "Ambushes"],
    ["roadblocks", "Roadblocks"]
];
private _raw = if (_value isEqualType "") then { toLower _value } else { "" };
private _sel = _raw splitString ", ";
_display setVariable ["alive_selectedClasses", _sel];

lbClear _list;
{
    _x params ["_key", "_label"];
    private _i = _list lbAdd _label;
    _list lbSetData [_i, _key];
    if (_key in _sel) then { _list lbSetSelected [_i, true] };
} forEach _rows;

// keep the saved ticks in step with the list
_list setVariable ["alive_disp", _display];
_list ctrlAddEventHandler ["LBSelChanged", {
    params ["_ctrl"];
    private _disp = _ctrl getVariable "alive_disp";
    if (isNull _disp) exitWith {};
    _disp setVariable ["alive_selectedClasses", (lbSelection _ctrl) apply { _ctrl lbData _x }];
}];

// a plain click ticks or unticks just that row, and ticked rows read [+] (#1083)
[_display controlsGroupCtrl 100] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenListToggle.sqf';
