#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(edenListToggle);

/* ----------------------------------------------------------------------------
Function: fnc_edenListToggle

Description:
Makes one of ALiVE's multi-select Eden lists tick and untick a row on a plain click (#1083), so a
stray click no longer clears every other tick, and marks the ticked rows "[+] ". Called at the end of
a picker's attributeLoad with its listbox (idc 100).

The list keeps its native multi-select style, so every picker's own selection handling and save
read it exactly as before: just before a click lands (MouseButtonDown) the ticked rows are noted, and
when the click has changed the selection (LBSelChanged) the clicked row is flipped against that note
and the rest are put back. A Shift click adds the run of rows it picks to what was ticked, for
picking 10 or 15 in a row. Arrow keys still move a single selection, as before.

Parameters:
    _this select 0: CONTROL - the listbox

Author:
Jman
---------------------------------------------------------------------------- */

params [["_list", controlNull]];
if (isNull _list || {_list getVariable ["alive_toggleOn", false]}) exitWith {};
_list setVariable ["alive_toggleOn", true];

// the list's height as the player chose in Addon Options (ALiVE > Eden Editor): 4 rows as built, or 6
// or 8. The rows of the picker below the list move down and the picker grows to match; the module's
// section layout stacks the settings by their real height, so the window follows.
private _rows = missionNamespace getVariable ["ALiVE_edenPickerRows", 4];
if (_rows isEqualType 0 && {_rows > 4}) then {
    private _grp = ctrlParentControlsGroup _list;
    private _extra = (_rows - 4) * 2.4 * pixelH * pixelGrid;
    private _lp = ctrlPosition _list;
    private _below = (_lp select 1) + (_lp select 3) - (pixelH * pixelGrid * 0.1);
    {
        private _p = ctrlPosition _x;
        if (!(_x isEqualTo _list) && {(_p select 1) >= _below}) then {
            _p set [1, (_p select 1) + _extra];
            _x ctrlSetPosition _p;
            _x ctrlCommit 0;
        };
    } forEach ((allControls (ctrlParent _list)) select { (ctrlParentControlsGroup _x) isEqualTo _grp });
    _lp set [3, (_lp select 3) + _extra];
    _list ctrlSetPosition _lp;
    _list ctrlCommit 0;
    private _gp = ctrlPosition _grp;
    _gp set [3, (_gp select 3) + _extra];
    _grp ctrlSetPosition _gp;
    _grp ctrlCommit 0;
};

// Find (#1083): a picker that can refill its list by text (it sets alive_searchable and keeps its
// ticks off the list, so a row the search hides keeps its tick) gets the Find row, which sits just
// below its bottom edge until now. Typing refills the list through the picker's own populate.
private _grpF = ctrlParentControlsGroup _list;
private _find = _grpF controlsGroupCtrl 104;
if (!isNull _find && {_grpF getVariable ["alive_searchable", false]} && {!isNil {_grpF getVariable "alive_populateFn"}}) then {
    private _rowH = 5 * pixelH * pixelGrid * 0.5;
    private _gp = ctrlPosition _grpF;
    {
        private _c = _grpF controlsGroupCtrl _x;
        private _p = ctrlPosition _c;
        _p set [1, _gp select 3];
        _c ctrlSetPosition _p;
        _c ctrlShow true;
        _c ctrlCommit 0;
    } forEach [104, 105];
    _gp set [3, (_gp select 3) + _rowH];
    _grpF ctrlSetPosition _gp;
    _grpF ctrlCommit 0;
    _find setVariable ["alive_grp", _grpF];
    _find setVariable ["alive_list", _list];
    _find ctrlAddEventHandler ["KeyUp", {
        params ["_e"];
        private _g = _e getVariable "alive_grp";
        private _q = toLower (ctrlText _e);
        if (_q isEqualTo (_g getVariable ["alive_searchText", ""])) exitWith {};
        _g setVariable ["alive_searchText", _q];
        [_g] call (_g getVariable "alive_populateFn");
        private _l = _e getVariable "alive_list";
        [_l] call (_l getVariable "alive_toggleMark");
    }];
};

// a row's identity: its data, or its index when it has none
private _key = { params ["_c", "_i"]; private _d = _c lbData _i; if (_d isEqualTo "") then { "#" + str _i } else { _d } };
// "[+] " on the ticked rows, off the others
private _mark = {
    params ["_c"];
    private _sel = lbSelection _c;
    for "_i" from 0 to (lbSize _c - 1) do {
        private _t = _c lbText _i;
        // two spaces in front keep the text off the list's left edge; nothing reads the row text
        // back, the pickers save the row data
        _t = _t trim [" ", 1];
        if ((_t select [0, 4]) == "[+] ") then { _t = _t select [4] };
        _c lbSetText [_i, "  " + (["", "[+] "] select (_i in _sel)) + _t];
    };
};
_list setVariable ["alive_toggleKey", _key];
_list setVariable ["alive_toggleMark", _mark];

// what was ticked just before the click
_list ctrlAddEventHandler ["MouseButtonDown", {
    params ["_c", "_button", "", "", ["_shift", false]];
    if (_button != 0) exitWith {};
    _c setVariable ["alive_toggleShift", _shift];
    private _key = _c getVariable "alive_toggleKey";
    _c setVariable ["alive_toggleBefore", (lbSelection _c) apply { [_c, _x] call _key }];
    _c setVariable ["alive_toggleClick", true];
}];

// flip the clicked row against that, and put the rest back
_list ctrlAddEventHandler ["LBSelChanged", {
    params ["_c", "_i"];
    if (_c getVariable ["alive_toggleBusy", false]) exitWith {};
    if !(_c getVariable ["alive_toggleClick", false]) exitWith { [_c] call (_c getVariable "alive_toggleMark") };
    _c setVariable ["alive_toggleClick", false];
    if (_i < 0) exitWith {};
    private _key = _c getVariable "alive_toggleKey";
    private _before = _c getVariable ["alive_toggleBefore", []];
    private _clicked = [_c, _i] call _key;
    // Shift picks a run of rows: added to what was ticked. Otherwise the clicked row flips.
    private _want = switch (true) do {
        case (_c getVariable ["alive_toggleShift", false]): { _before + (((lbSelection _c) apply { [_c, _x] call _key }) - _before) };
        case (_clicked in _before): { _before - [_clicked] };
        default { _before + [_clicked] };
    };
    _c setVariable ["alive_toggleBusy", true];
    for "_r" from 0 to (lbSize _c - 1) do {
        private _on = ([_c, _r] call _key) in _want;
        if ((_r in (lbSelection _c)) isNotEqualTo _on) then { _c lbSetSelected [_r, _on] };
    };
    _c setVariable ["alive_toggleBusy", false];
    [_c] call (_c getVariable "alive_toggleMark");
}];

// the marks after the picker has filled the list, and again whenever a filter button refills it
[_list] spawn { params ["_c"]; uiSleep 0.1; if (!isNull _c) then { [_c] call (_c getVariable "alive_toggleMark") } };
_list ctrlAddEventHandler ["MouseEnter", { params ["_c"]; [_c] call (_c getVariable "alive_toggleMark") }];
