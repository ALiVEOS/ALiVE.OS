#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(edenSideChoiceMultiSave);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_edenSideChoiceMultiSave

Description:
    Eden attributeSave handler for ALiVE_SideChoiceMulti. Reads the
    listbox selection (idc 100), formats the selected sides as a CSV
    string like "EAST,WEST", and stores it via three paths:
        1) Eden display "value" slot (SQM serialisation).
        2) setVariable on each selected logic (so attributeLoad finds
           it on Eden re-open).
        3) The CfgVehicles attribute's `expression` re-applies on
           mission start.

    CSV is chosen over SQF array literal so the runtime path
    (ALiVE_fnc_stringListToArray + apply toupper) in fnc_C2ISTAR.sqf
    consumes the value unchanged - back-compat with legacy missions
    that stored the value as a hand-typed CSV in the old Edit field.

    Empty-selection contract: returns "" (matches the legacy default
    that the runtime treats as "no per-OPCOM intel pumping enabled").

Parameters:
    [_display, _varName]
    _display : DISPLAY - Eden attribute display
    _varName : STRING  - logic variable name. Defaults to
                         "opcomIntelSides".

Returns:
    STRING - CSV of selected uppercase side tokens, or "" if no
             selection.

Author:
    Jman
---------------------------------------------------------------------------- */

private _display = controlNull;
private _varName = "opcomIntelSides";

if (typeName _this == "ARRAY") then {
    _display = _this select 0;
    if (count _this > 1 && {typeName (_this select 1) == "STRING"} && {(_this select 1) != ""}) then {
        _varName = _this select 1;
    };
} else {
    _display = _this;
};

if (isNull _display) exitWith {
    ["ALIVE SideChoiceMulti SAVE: null display"] call ALiVE_fnc_dump;
    ""
};

private _listCtrl = _display controlsGroupCtrl 100;
if (isNull _listCtrl) exitWith {
    ["ALIVE SideChoiceMulti SAVE: listbox control (idc 100) not found"] call ALiVE_fnc_dump;
    ""
};

// lbSelection returns ARRAY for multi-select listboxes. Normalise the
// rare degenerate case (style bit dropped → SCALAR return) so the
// forEach below always sees an array.
private _rawSel = lbSelection _listCtrl;
private _selectedIdxs = if (typeName _rawSel == "ARRAY") then {
    _rawSel
} else {
    if (typeName _rawSel == "SCALAR" && {_rawSel >= 0}) then { [_rawSel] } else { [] };
};

private _selectedTokens = [];
{
    private _data = _listCtrl lbData _x;
    if (typeName _data == "STRING" && {_data != ""}) then {
        _selectedTokens pushBack _data;
    };
} forEach _selectedIdxs;

private _result = _selectedTokens joinString ",";

// Path 1: Eden value slot for SQM serialisation.
_display setVariable ["value", _result];

// Path 2: logic variable - so attributeLoad finds it on re-open.
{
    _x setVariable [_varName, _result, true];
} forEach (get3DENSelected "logic");

// Path 3: mission-start re-apply handled by the attribute's CfgVehicles
// `expression` slot.

[
    "ALIVE SideChoiceMulti SAVE: varName='%1' selected=%2 -> '%3'",
    _varName,
    str _selectedTokens,
    _result
] call ALiVE_fnc_dump;

_result
