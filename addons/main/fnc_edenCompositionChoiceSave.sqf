#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(edenCompositionChoiceSave);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_edenCompositionChoiceSave

Description:
    Eden-attribute `attributeSave` handler for the ALiVE_CompositionChoice
    control. Reads the cumulative selection set (preserved across filter
    changes by the LOAD handler's LBSelChanged EH) plus the override Edit
    free-text classes, deduplicates, joins into a comma-separated string
    and returns that as the value Eden serialises onto the logic.

    Reads `_selectedClasses` from the controlsGroup namespace (set by the
    LOAD handler) rather than `lbSelection _list`, because lbSelection
    only knows about currently-visible rows after filtering. A class
    ticked under one filter view (e.g. Side=WEST) and then filtered out
    of view (e.g. Side cycled to EAST) would otherwise be lost on save.

    Storage format matches the load handler:
        Class1,Class2,Class3
    Empty selection + empty override -> "" (caller treats as no-spawn).

Parameters:
    [_display, _varName]
    _display : DISPLAY - Eden attribute display (controlsGroup control)
    _varName : STRING  - logic-variable name (used for diag log only)

Returns:
    STRING - comma-separated class names

Author:
    Jman
---------------------------------------------------------------------------- */

private _display = controlNull;
private _varName = "";

if (typeName _this == "ARRAY") then {
    if (count _this > 0) then { _display = _this select 0; };
    if (count _this > 1 && {typeName (_this select 1) == "STRING"}) then { _varName = _this select 1; };
} else {
    _display = _this;
};

if (isNull _display) exitWith {
    ["ALIVE CompositionChoice SAVE: null display"] call ALiVE_fnc_dump;
    ""
};

private _classes = [];

// Read the cumulative selection set stored by the LOAD handler. Survives
// filter changes - lbSelection on the listbox alone would lose selections
// from previously-visible views.
private _selectedClasses = _display getVariable ["alive_selectedClasses", []];
{
    if (typeName _x == "STRING" && {_x != ""}) then {
        _classes pushBackUnique _x;
    };
} forEach _selectedClasses;

// Override Edit: free-text comma-separated. Trim whitespace per entry.
private _editCtrl = _display controlsGroupCtrl 102;
if (!isNull _editCtrl) then {
    private _overrideText = ctrlText _editCtrl;
    if (_overrideText != "") then {
        {
            private _t = _x;
            while {count _t > 0 && {(_t select [0, 1]) == " "}} do { _t = _t select [1] };
            while {count _t > 0 && {(_t select [count _t - 1, 1]) == " "}} do { _t = _t select [0, count _t - 1] };
            if (_t != "") then { _classes pushBackUnique _t };
        } forEach ([_overrideText, ","] call CBA_fnc_split);
    };
};

// Prepend the current filter state (read from the controlsGroup namespace,
// where the cycle handlers wrote it) so the user's filter view persists
// across mission save/reload, not just across Eden dialog open/close.
// Format: [F:sideIdx,sizeIdx,categoryIdx,sourceIdx]Class1,Class2,...
// Legacy missions saved without the prefix get default filters (all "All")
// when the LOAD handler parses them.
private _sideIdx     = _display getVariable ["alive_sideIdx",     0];
private _sizeIdx     = _display getVariable ["alive_sizeIdx",     0];
private _categoryIdx = _display getVariable ["alive_categoryIdx", 0];
private _sourceIdx   = _display getVariable ["alive_sourceIdx",   0];
private _filterPrefix = format ["[F:%1,%2,%3,%4]", _sideIdx, _sizeIdx, _categoryIdx, _sourceIdx];

private _result = _filterPrefix + (_classes joinString ",");

["ALIVE CompositionChoice SAVE: varName=%1 filters=%2 selectedClasses=%3 overrideAdded=%4 result='%5'", _varName, _filterPrefix, count _selectedClasses, count _classes - count _selectedClasses, _result] call ALiVE_fnc_dump;

_result
