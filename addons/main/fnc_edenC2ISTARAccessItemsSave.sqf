#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(edenC2ISTARAccessItemsSave);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_edenC2ISTARAccessItemsSave

Description:
    Eden attributeSave handler for ALiVE_C2ISTARAccessItemsChoice.
    Reads the listbox multi-selection, maps to category keys via
    lbData, joins as CSV. Persists via the conventional three paths
    (Eden value slot, logic setVariable, CfgVehicles expression).

Parameters:
    [_display, _varName]
    _display : DISPLAY - Eden attribute display
    _varName : STRING  - logic variable name. Defaults to "c2_item".

Returns:
    STRING - CSV of selected category keys, or "" if nothing ticked.

Author:
    Jman
---------------------------------------------------------------------------- */

private _display = controlNull;
private _varName = "c2_item";

if (typeName _this == "ARRAY") then {
    _display = _this select 0;
    if (count _this > 1 && {typeName (_this select 1) == "STRING"} && {(_this select 1) != ""}) then {
        _varName = _this select 1;
    };
} else {
    _display = _this;
};

if (isNull _display) exitWith {
    diag_log "ALIVE C2ISTARAccessItems SAVE: null display";
    ""
};

private _listCtrl = _display controlsGroupCtrl 100;
if (isNull _listCtrl) exitWith {
    diag_log "ALIVE C2ISTARAccessItems SAVE: listbox control (idc 100) not found";
    ""
};

private _rawSel = lbSelection _listCtrl;
private _selectedIdxs = if (typeName _rawSel == "ARRAY") then {
    _rawSel
} else {
    if (typeName _rawSel == "SCALAR" && {_rawSel >= 0}) then { [_rawSel] } else { [] };
};

private _selectedKeys = [];
{
    private _data = _listCtrl lbData _x;
    if (typeName _data == "STRING" && {_data != ""}) then {
        _selectedKeys pushBack _data;
    };
} forEach _selectedIdxs;

private _result = _selectedKeys joinString ",";

_display setVariable ["value", _result];
{
    _x setVariable [_varName, _result, true];
} forEach (get3DENSelected "logic");

diag_log format [
    "ALIVE C2ISTARAccessItems SAVE: varName='%1' selected=%2 -> '%3'",
    _varName,
    str _selectedKeys,
    _result
];

_result
