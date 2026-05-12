#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(edenItemChoiceMultiSave);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_edenItemChoiceMultiSave

Description:
Eden-attribute `attributeSave` handler for the ALiVE_ItemChoiceMulti
control family. Reads the multi-select listbox (IDC 100), maps each
selected index to its lbData (item classname), and returns an SQF
array literal like `["ACE_Canteen","ACE_WaterBottle"]`.

Empty-selection contract: returns "[]" (canonical empty-array literal)
rather than "" -- lets the consumer's parser distinguish "user
explicitly chose no items" from "control was never opened".

Parameters:
    [_display, _varName]
    _display : DISPLAY - Eden attribute display. ListBox control IDC 100.
    _varName : STRING  - logic variable name. Required.

Returns:
    STRING - SQF array literal of selected classnames, or "[]" if none.

Author:
Jman
---------------------------------------------------------------------------- */

private _display = controlNull;
private _varName = "customItems";
if (typeName _this == "ARRAY") then {
    _display = _this select 0;
    if (count _this > 1 && {typeName (_this select 1) == "STRING"} && {(_this select 1) != ""}) then {
        _varName = _this select 1;
    };
} else {
    _display = _this;
};

private _ctrl = (_display controlsGroupCtrl 100);
if (isNull _ctrl) exitWith {
    diag_log "ALIVE ItemChoiceMulti SAVE: listbox control (IDC 100) not found";
    "[]"
};

private _selectedIdxs = lbSelection _ctrl;
private _selectedItems = [];
{
    private _data = _ctrl lbData _x;
    if (typeName _data == "STRING" && {_data != ""}) then {
        _selectedItems pushBack _data;
    };
} forEach _selectedIdxs;

private _result = if (count _selectedItems == 0) then {
    "[]"
} else {
    private _quoted = _selectedItems apply { format ["""%1""", _x] };
    format ["[%1]", _quoted joinString ","]
};

// Eden "value" slot -- for SQM serialisation
_display setVariable ["value", _result];

// Per-logic variable -- for attributeLoad to find on re-open
{
    _x setVariable [_varName, _result, true];
} forEach (get3DENSelected "logic");

diag_log format [
    "ALIVE ItemChoiceMulti SAVE: varName='%1' selected=%2 (%3 items) -> '%4'",
    _varName, _selectedItems, count _selectedItems, _result
];

_result
