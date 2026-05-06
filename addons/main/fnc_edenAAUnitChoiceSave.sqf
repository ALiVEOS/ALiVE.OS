#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(edenAAUnitChoiceSave);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_edenAAUnitChoiceSave

Description:
    Eden attributeSave handler for ALiVE_AAUnitChoiceMulti. Reads the
    cumulative selection set from the controlsGroup namespace, syncs
    with current listbox state (in-flight click capture), appends
    free-text Override Edit entries, returns CSV-serialised classnames.

    Empty selection returns "" - the runtime resolver treats empty as
    "use ALIVE_factionDefaultAA fallback".

Parameters:
    [_display, _varName]
    _display : DISPLAY - controlsGroup display
    _varName : STRING  - logic variable name (default "aaClasses")

Returns:
    STRING - CSV of selected classnames, or "" when nothing selected.

Author:
    Jman
---------------------------------------------------------------------------- */

private _display = controlNull;
private _varName = "aaClasses";

if (typeName _this == "ARRAY") then {
    if (count _this > 0) then { _display = _this select 0; };
    if (count _this > 1 && {typeName (_this select 1) == "STRING"} && {(_this select 1) != ""}) then {
        _varName = _this select 1;
    };
} else {
    _display = _this;
};

private _sel = _display getVariable ["alive_selectedClasses", []];

// Sync with current listbox state (catches in-flight click before
// LBSelChanged has fired)
private _list = _display controlsGroupCtrl 100;
if (!isNull _list) then {
    private _selIdx = lbSelection _list;
    for "_i" from 0 to (lbSize _list - 1) do {
        private _class = _list lbData _i;
        if (typeName _class == "STRING" && {_class != ""}) then {
            if (_i in _selIdx) then {
                _sel pushBackUnique _class;
            } else {
                _sel = _sel - [_class];
            };
        };
    };
};

// Append Override Edit entries (CSV-split, trimmed)
private _editCtrl = _display controlsGroupCtrl 102;
if (!isNull _editCtrl) then {
    private _txt = ctrlText _editCtrl;
    if (typeName _txt == "STRING" && {_txt != ""}) then {
        {
            private _t = _x;
            while {count _t > 0 && {(_t select [0, 1]) == " "}} do { _t = _t select [1] };
            while {count _t > 0 && {(_t select [count _t - 1, 1]) == " "}} do { _t = _t select [0, count _t - 1] };
            if (_t != "") then { _sel pushBackUnique _t };
        } forEach ([_txt, ","] call CBA_fnc_split);
    };
};

private _result = _sel joinString ",";

_display setVariable ["value", _result];

// Per-logic setVariable so other handlers / runtime can read immediately
{
    _x setVariable [_varName, _result, true];
} forEach (get3DENSelected "logic");

diag_log format [
    "ALIVE AAUnitChoice SAVE: varName='%1' selected=%2 -> '%3'",
    _varName, count _sel, _result
];

_result
