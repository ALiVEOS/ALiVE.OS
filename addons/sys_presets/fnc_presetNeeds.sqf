#include "script_component.hpp"
SCRIPT(presetNeeds);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_presetNeeds

Description:
What a preset needs loaded before it will do what it says: the mods and the
official DLC behind its modules and its factions, one row each, with whether
each one is running right now.

Its own window rather than a corner of the preset window. The right hand column
there is already carrying the detail pane, the title, the author, the
description and a save button, and a list that can run to a dozen rows with a
reason beside each has nowhere to go in what is left. This is the same window
the place-it screen uses, so it is the same thing to learn twice.

The list is worked out from the preset, not typed into it. A preset names a
faction and the faction names its mod, so the answer is already in the preset
and asking somebody to maintain a second copy of it by hand would only let the
two disagree. It does mean the list cannot be edited, and a preset that needs a
terrain or a composition pack will not have that worked out for it, so anything
the preset states for itself is kept and shown as its own reason.

Red means the mod is named by this preset and is not loaded here. That is the
one row worth acting on, so it sorts to the top.

A row carries the mod and ONE reason. A listbox clips its text rather than
wrapping it, so three reasons ran off the right hand edge of the window with
nothing to say the line had been cut. Selecting a row spells out the rest
underneath, where the text can wrap.

Parameters:
    _preset - ARRAY - a parsed preset
    _name - STRING - optional, what to call it in the window

Returns:
    BOOL - whether the window opened

Examples:
    (begin example)
    [_preset, "NATO takes and holds an island"] call ALIVE_fnc_presetNeeds;
    (end)

See Also:
    ALIVE_fnc_presetAddons, ALIVE_fnc_presetWindow, ALIVE_fnc_presetLoad

Author:
    Jman
---------------------------------------------------------------------------- */

params [["_preset", [], [[]]], ["_name", "", [""]]];

if (!is3DEN) exitWith { false };

#define IDD_NEEDS   88120
#define IDC_NROWS   88121
#define IDC_NSAYS   88122
#define IDC_NWHY    88123
#define IDC_NPAGE   88124

disableSerialization;

// One row per mod somebody downloads, NOT per addon. RHS USAF alone ships a
// dozen addons, so counting addons reported sixteen mods where there were six.
private _rows = [_preset param [3, []], _preset param [5, []], "mods",
    _preset param [8, []]] call ALIVE_fnc_presetAddons;
private _missing = count (_rows select { !(_x select 2) });

// The editor has no mission display to hang a window off, so a window here is a
// child of the editor's own display. createDialog does nothing at all, silently.
private _parent = findDisplay 313;
if (isNull _parent) then { _parent = findDisplay 46 };
if (isNull _parent) exitWith {
    ["ALIVE_fnc_presetNeeds - there is no editor display to open the window on"] call ALiVE_fnc_dump;
    false
};

private _display = _parent createDisplay "ALiVE_PresetLibrary";
if (isNull _display) exitWith {
    ["ALIVE_fnc_presetNeeds - the window would not open"] call ALiVE_fnc_dump;
    false
};

_display setVariable ["rows", _rows];

// Named _px rather than _x on purpose: forEach binds _x, so a window laid out
// with an _x cannot have a control placed from inside a loop without silently
// putting it wherever the loop happens to be.
private _px = 0.26 * safezoneW + safezoneX;
private _py = 0.16 * safezoneH + safezoneY;
private _pw = 0.48 * safezoneW;
private _ph = 0.64 * safezoneH;

private _fnc_at = {
    params ["_ctrl", "_cx", "_cy", "_cw", "_ch"];
    _ctrl ctrlSetPosition [_px + _cx * _pw, _py + _cy * _ph, _cw * _pw, _ch * _ph];
    _ctrl ctrlCommit 0;
    _ctrl
};

// Three layers, back to front, because controls draw in the order they are made:
// a pale rectangle for the border, the panel inset a hair inside it, and a
// lighter bar behind the title so the head of the window reads as one.
private _edge = _display ctrlCreate ["RscText", -1];
_edge ctrlSetBackgroundColor [0.47, 0.50, 0.43, 1];
[_edge, 0, 0, 1, 1] call _fnc_at;

private _back = _display ctrlCreate ["RscText", -1];
_back ctrlSetBackgroundColor [0.12, 0.13, 0.12, 1];
[_back, 0.004, 0.006, 0.992, 0.988] call _fnc_at;

private _head = _display ctrlCreate ["RscText", -1];
_head ctrlSetBackgroundColor [0.19, 0.21, 0.18, 1];
[_head, 0.004, 0.006, 0.992, 0.145] call _fnc_at;

private _title = _display ctrlCreate ["RscText", -1];
_title ctrlSetText "What This Preset Needs";
[_title, 0.02, 0.02, 0.7, 0.06] call _fnc_at;

// The logo and the build, top right, the same as the other two windows.
// RscPictureKeepAspect so the engine fits the image without distorting it, and
// screen units rather than _fnc_at because that helper scales x and y by
// different numbers.
private _logoH = 0.085 * _ph;
private _logoW = 2.4 * _logoH;
private _rightEdge = _px + _pw - (0.025 * _pw);

private _logoClass = "RscPicture";
if (isClass (configFile >> "RscPictureKeepAspect")) then { _logoClass = "RscPictureKeepAspect" };
private _logo = _display ctrlCreate [_logoClass, -1];
_logo ctrlSetText "\x\alive\addons\main\logo_alive.paa";
_logo ctrlSetPosition [_rightEdge - _logoW, _py + (0.010 * _ph), _logoW, _logoH];
_logo ctrlCommit 0;

private _verW = 0.36 * _pw;
private _ver = _display ctrlCreate ["RscStructuredText", -1];
_ver ctrlSetStructuredText parseText format [
    "<t align='right' size='0.85' color='#9ea894'>ALiVE Version: %1</t>",
    getText (configFile >> "CfgPatches" >> "ALiVE_main" >> "version")];
_ver ctrlSetPosition [_rightEdge - _verW, _py + (0.010 * _ph) + _logoH, _verW, 0.04 * _ph];
_ver ctrlCommit 0;

private _hint = _display ctrlCreate ["RscText", -1];
// Narrower than the window, because the version text shares this row and an
// RscText clips rather than wraps.
_hint ctrlSetText (if (_name isEqualTo "") then {
    "Worked out from the modules and factions the preset carries."
} else {
    format ["%1, and what has to be running for it.", _name]
});
[_hint, 0.02, 0.08, 0.58, 0.05] call _fnc_at;

private _list = _display ctrlCreate ["RscListBox", IDC_NROWS];
// 0.54 tall, not 0.57: the line below it grew to three lines and this is where
// that room came from. Left at 0.57 the list ran to 0.73 while that line started
// at 0.71, so the line was drawn over the bottom of the list.
[_list, 0.02, 0.16, 0.96, 0.54] call _fnc_at;

// Why the selected mod is needed, in full, under the list.
//
// A row cannot carry this. A listbox clips its text rather than wrapping it, so
// a mod wanted by six modules ran past the right hand edge of the window and
// the end of the line was simply gone. Structured text here, because this one
// DOES wrap, and three lines is enough once the reasons are summarised.
private _why = _display ctrlCreate ["RscStructuredText", IDC_NWHY];
[_why, 0.02, 0.71, 0.96, 0.09] call _fnc_at;

private _says = _display ctrlCreate ["RscText", IDC_NSAYS];
_says ctrlSetText "";
[_says, 0.02, 0.81, 0.96, 0.05] call _fnc_at;

// Reasons said as a sentence rather than listed one per item.
//
// RHS USAF is wanted by eight factions in a busy scenario, and printing "the
// rhs_faction_usarmy_d faction" eight times filled four lines with almost the
// same words and still overflowed. Counting them says more in less space, and
// the individual faction names were never the useful part: what a person wants
// to know is whether it is factions, units, or the preset saying so.
//
// Kept in uiNamespace because the selection handler below runs in its own scope
// and cannot see anything declared out here.
private _fnc_phrase = {
    params [["_reasons", [], [[]]], ["_short", false, [false]]];
    private _factions = [];
    private _modules = [];
    private _wheres = [];
    private _counts = [];
    private _stated = false;
    {
        _x params [["_kind", ""], ["_subject", ""], ["_where", ""]];
        switch (_kind) do {
            case "faction": { _factions pushBackUnique _subject };
            case "module": { _modules pushBackUnique _subject };
            case "stated": { _stated = true };
            case "class": {
                // Counted per module, so six units named in one place read as
                // one clause rather than six.
                private _at = _wheres find _where;
                if (_at < 0) then {
                    _wheres pushBack _where;
                    _counts pushBack 1;
                } else {
                    _counts set [_at, (_counts select _at) + 1];
                };
            };
        };
    } forEach _reasons;

    private _bits = [];
    if (count _factions > 0) then {
        _bits pushBack (switch (true) do {
            case (count _factions == 1): { format ["the %1 faction", _factions select 0] };
            case (count _factions == 2): { format ["the %1 and %2 factions",
                _factions select 0, _factions select 1] };
            default { format ["%1 factions, among them %2", count _factions, _factions select 0] };
        });
    };
    {
        private _n = _counts select _forEachIndex;
        _bits pushBack (if (_n == 1) then {
            format ["a unit named in %1", _x]
        } else {
            format ["%1 units named in %2", _n, _x]
        });
    } forEach _wheres;
    { _bits pushBack format ["the %1 module", _x] } forEach _modules;
    if (_stated) then { _bits pushBack "the preset saying so itself" };

    if (count _bits == 0) exitWith { "something this cannot name" };
    if (_short) exitWith {
        if (count _bits == 1) then { _bits select 0 }
        else { format ["%1; and %2 more", _bits select 0, count _bits - 1] }
    };
    if (count _bits == 1) exitWith { _bits select 0 };
    // Semicolons between clauses, not commas, and an "and" before the last one.
    // A clause like "7 factions, among them rhs_faction_usarmy_d" carries a comma
    // of its own, so joining the clauses with commas as well made the one after it
    // read as though it were still part of the faction list.
    private _last = _bits deleteAt (count _bits - 1);
    (_bits joinString "; ") + "; and " + _last
};
uiNamespace setVariable ["ALiVE_presetNeedsPhrase", _fnc_phrase];

{
    _x params ["_mod", "_reasons", "_on"];
    private _mark = if (_on) then { "[loaded]  " } else { "[missing] " };
    private _text = _mark + _mod;
    if (count _reasons > 0) then {
        private _tail = [_reasons, true] call _fnc_phrase;
        // Belt as well as braces. A mod name and one clause can still be wider
        // than the window at a small interface size, and a cut that gives no
        // sign it happened is the whole fault being fixed here.
        private _room = 110 - (count _text) - 6;
        if (_room >= 8) then {
            if (count _tail > _room) then { _tail = (_tail select [0, _room - 3]) + "..." };
            _text = _text + format ["   (%1)", _tail];
        };
    };
    private _at = _list lbAdd _text;
    if (_on) then {
        _list lbSetColor [_at, [0.72, 0.82, 0.55, 1]];
    } else {
        _list lbSetColor [_at, [0.92, 0.55, 0.45, 1]];
    };
} forEach _rows;

// Selecting a row spells out every reason that row is there. Knowing a mod is
// wanted by six things is no use without knowing which six.
_list ctrlAddEventHandler ["LBSelChanged", {
    params ["_ctrl", "_index"];
    private _d = ctrlParent _ctrl;
    private _rows = _d getVariable ["rows", []];
    if (_index < 0 || {_index >= count _rows}) exitWith {};
    (_rows select _index) params ["_mod", "_reasons", "", "_link"];
    (_d displayCtrl IDC_NWHY) ctrlSetStructuredText parseText format [
        "<t size='0.9' color='#9ea894'>%1 is needed by %2</t>",
        _mod,
        [_reasons] call (uiNamespace getVariable ["ALiVE_presetNeedsPhrase", { "" }])];

    // The address goes on the button NOW, while the selection changes, because a
    // link only opens from a real click on a control that is already holding it.
    // Setting it inside the click would open nothing.
    private _page = _d displayCtrl IDC_NPAGE;
    _page ctrlSetURL _link;
    // Nothing to link to for a mod outside the Workshop, and nothing at all for
    // one that is not loaded, since its Steam id was never in this game to read.
    _page ctrlEnable !(_link isEqualTo "");
}];

_says ctrlSetText (switch (true) do {
    case (count _rows == 0): {
        "Nothing beyond Arma and ALiVE. This preset will place as it is."
    };
    case (_missing == 0): {
        format ["%1 mod%2 needed, and all of them are running here.",
            count _rows, ["s", ""] select (count _rows == 1)]
    };
    default {
        format ["%1 mod%2 needed. %3 not loaded here, so parts of this preset will place and then find nothing.",
            count _rows, ["s", ""] select (count _rows == 1),
            if (_missing == 1) then { "One is" } else { format ["%1 are", _missing] }]
    };
});

private _fnc_button = {
    params ["_text", "_bx", "_bw", "_code", ["_idc", -1]];
    private _b = _display ctrlCreate ["RscButton", _idc];
    _b ctrlSetText _text;
    _b ctrlAddEventHandler ["ButtonClick", _code];
    [_b, _bx, 0.88, _bw, 0.08] call _fnc_at;
    _b
};

// The list is what somebody pastes under a preset when they hand it on, so
// getting it out has to be easier than reading it off the screen and typing it.
["Copy the list", 0.68, 0.18, {
    params ["_ctrl"];
    private _d = ctrlParent _ctrl;
    private _rows = _d getVariable ["rows", []];
    if (count _rows == 0) exitWith {
        (_d displayCtrl IDC_NSAYS) ctrlSetText "There is nothing to copy: this preset needs no mods.";
    };
    copyToClipboard ((_rows apply { _x select 0 }) joinString ", ");
    (_d displayCtrl IDC_NSAYS) ctrlSetText format ["%1 mod name%2 on the clipboard.",
        count _rows, ["s", ""] select (count _rows == 1)];
}] call _fnc_button;

// A click straight to where the mod is downloaded, for the row that is selected.
// Its address is hung on the button whenever the selection changes, see above.
["Workshop page", 0.26, 0.14, {
    // Opening the page is the engine's job, from the address already on this
    // control. Nothing to do here but say what happened.
    params ["_ctrl"];
    ((ctrlParent _ctrl) displayCtrl IDC_NSAYS) ctrlSetText "Opening the mod page in your browser.";
}, IDC_NPAGE] call _fnc_button;

["Back to your presets", 0.02, 0.20, {
    (ctrlParent (_this select 0)) closeDisplay 1;
    [] call ALIVE_fnc_presetWindow;
}] call _fnc_button;

["Close", 0.88, 0.10, { (ctrlParent (_this select 0)) closeDisplay 1 }] call _fnc_button;

// The first row's reasons up front, so the line under the list is not blank on
// opening. Set after the handler exists, because this is what fires it.
if (count _rows > 0) then { _list lbSetCurSel 0 };

["ALIVE_fnc_presetNeeds - %1 mod(s) needed, %2 not loaded", count _rows, _missing] call ALiVE_fnc_dump;
true
