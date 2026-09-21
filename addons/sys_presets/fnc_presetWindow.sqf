#include "script_component.hpp"
SCRIPT(presetWindow);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_presetWindow

Description:
The window a mission maker actually uses: everything they can place, in one list,
with a button that places it.

Presets that ship with ALiVE and presets they have collected sit in the same
list, because from where they stand the difference is uninteresting. What matters
is what the preset does, which is why the description is shown beside it rather
than hidden behind a hover.

The controls are made at run time from the game's own, rather than declared as a
screenful of config. Only the window itself is declared, which keeps the config
for this to a handful of lines and keeps the layout where it can be read.

Parameters:
    None.

Returns:
    BOOL - whether the window opened

Examples:
    (begin example)
    [] call ALIVE_fnc_presetWindow;
    (end)

See Also:
    ALIVE_fnc_presetLibrary, ALIVE_fnc_presetPlace, ALIVE_fnc_presetShare

Author:
    Jman
---------------------------------------------------------------------------- */

if (!is3DEN) exitWith { false };

#define IDD_LIBRARY 88100
#define IDC_LIST    88101
#define IDC_DETAIL  88102
#define IDC_STATUS  88103
#define IDC_NAME    88104
#define IDC_DESC    88105
#define IDC_SUBMIT  88106
#define IDC_CLIP    88107
#define IDC_AUTHOR  88108

disableSerialization;

// The editor is not a mission, so it has no mission display for createDialog to
// hang a window off: asking for one there does nothing at all, silently. A
// window in the editor is made as a child of the editor's own display instead.
// The mission display is kept as a fallback so this also works in a preview.
private _parent = findDisplay 313;
if (isNull _parent) then { _parent = findDisplay 46 };
if (isNull _parent) exitWith {
    ["ALIVE_fnc_presetWindow - there is no editor display to open the window on"] call ALiVE_fnc_dump;
    false
};

private _display = _parent createDisplay "ALiVE_PresetLibrary";
if (isNull _display) exitWith {
    ["ALIVE_fnc_presetWindow - the preset window would not open"] call ALiVE_fnc_dump;
    false
};
["ALIVE_fnc_presetWindow - open"] call ALiVE_fnc_dump;

// Where the person is looking, taken NOW, before the window covers the map.
// Asked once the window is up, the middle of the screen is the middle of the
// window, and a preset would be placed under it rather than in view.
private _lookingAt = screenToWorld [0.5, 0.5];
_display setVariable ["lookingAt", _lookingAt];

private _x = 0.22 * safezoneW + safezoneX;
private _y = 0.18 * safezoneH + safezoneY;
private _w = 0.56 * safezoneW;
private _h = 0.60 * safezoneH;

private _fnc_at = {
    params ["_ctrl", "_cx", "_cy", "_cw", "_ch"];
    _ctrl ctrlSetPosition [_x + _cx * _w, _y + _cy * _h, _cw * _w, _ch * _h];
    _ctrl ctrlCommit 0;
    _ctrl
};

// The window needs an edge. Opaque was not enough on its own: the editor's own
// background is nearly black, so a nearly black panel over it had no visible
// boundary and read as part of the editor rather than as a window.
//
// Three layers, back to front, because controls draw in the order they are made:
// a pale rectangle for the border, the panel inset a hair inside it, and a
// slightly lighter bar behind the title so the head of the window reads as one.
private _edge = _display ctrlCreate ["RscText", -1];
_edge ctrlSetBackgroundColor [0.47, 0.50, 0.43, 1];
[_edge, 0, 0, 1, 1] call _fnc_at;

private _back = _display ctrlCreate ["RscText", -1];
_back ctrlSetBackgroundColor [0.12, 0.13, 0.12, 1];
[_back, 0.004, 0.006, 0.992, 0.988] call _fnc_at;

private _head = _display ctrlCreate ["RscText", -1];
_head ctrlSetBackgroundColor [0.19, 0.21, 0.18, 1];
[_head, 0.004, 0.006, 0.992, 0.14] call _fnc_at;

private _title = _display ctrlCreate ["RscText", -1];
_title ctrlSetText "ALiVE Presets";
[_title, 0.02, 0.02, 0.6, 0.07] call _fnc_at;

// The logo and the build, top right of the header.
//
// RscPictureKeepAspect, not RscPicture: the engine fits the image inside the
// control without distorting it, which solves the whole problem. Working the
// aspect out here instead meant deciding the image is 2:1 and trusting that the
// screen aspect matches the UI aspect, which a person can set independently, and
// it came out stretched. ALiVE's own splash screen already uses this class for
// this logo.
//
// Still positioned in screen units rather than through _fnc_at, because that
// helper scales x by the window width and y by the window height and those are
// different numbers.
private _logoH = 0.085 * _h;
private _logoW = 2.4 * _logoH;
private _rightEdge = _x + _w - (0.025 * _w);

private _logoClass = "RscPicture";
if (isClass (configFile >> "RscPictureKeepAspect")) then { _logoClass = "RscPictureKeepAspect" };
private _logo = _display ctrlCreate [_logoClass, -1];
_logo ctrlSetText "\x\alive\addons\main\logo_alive.paa";
_logo ctrlSetPosition [_rightEdge - _logoW, _y + (0.010 * _h), _logoW, _logoH];
_logo ctrlCommit 0;

// The build under the logo, named so it reads as a version rather than as a
// number that happens to be there. Worth having on screen at all because the
// first question about a preset that will not read is which build wrote it and
// which build is reading it.
//
// Structured text, right aligned. A plain RscText starts its words at the left
// edge of its own control, so making the control wide enough for the text pushed
// the text away from the logo instead of under it. Right aligning against the
// same edge the logo uses keeps the two stacked however long the build gets.
private _verW = 0.36 * _w;
private _ver = _display ctrlCreate ["RscStructuredText", -1];
_ver ctrlSetStructuredText parseText format [
    "<t align='right' size='0.85' color='#9ea894'>ALiVE Version: %1</t>",
    getText (configFile >> "CfgPatches" >> "ALiVE_main" >> "version")];
_ver ctrlSetPosition [_rightEdge - _verW, _y + (0.010 * _h) + _logoH, _verW, 0.04 * _h];
_ver ctrlCommit 0;

private _hint = _display ctrlCreate ["RscText", -1];
// Narrower than the window on purpose. It shares its row with the version text
// on the right, and an RscText clips rather than wraps, so a full width control
// here would sit under the version and a longer sentence would be cut off.
_hint ctrlSetText "Pick one and place it, then change whatever you like.";
[_hint, 0.02, 0.09, 0.58, 0.06] call _fnc_at;

// The left column says what it is. Without this heading the column had no
// declared identity, so anything put underneath the list attached itself to the
// list by default: the save button read as an action on whatever was selected,
// which is not what it does. Naming the list fixes the cause rather than moving
// the button somewhere else.
private _listLabel = _display ctrlCreate ["RscText", -1];
_listLabel ctrlSetText "Your presets  (double click to place one)";
_listLabel ctrlSetTextColor [0.62, 0.66, 0.58, 1];
[_listLabel, 0.02, 0.155, 0.45, 0.04] call _fnc_at;

private _list = _display ctrlCreate ["RscListBox", IDC_LIST];
[_list, 0.02, 0.20, 0.45, 0.41] call _fnc_at;

private _detailLabel = _display ctrlCreate ["RscText", -1];
_detailLabel ctrlSetText "The one you have picked";
_detailLabel ctrlSetTextColor [0.62, 0.66, 0.58, 1];
[_detailLabel, 0.49, 0.155, 0.49, 0.04] call _fnc_at;

private _detail = _display ctrlCreate ["RscStructuredText", IDC_DETAIL];
[_detail, 0.49, 0.20, 0.49, 0.26] call _fnc_at;

// Naming and describing a preset you collected. A preset from a stranger often
// arrives with no name of its own, which is exactly when somebody wants to give
// it one, and what gets typed here goes into the preset's own text so it keeps
// the name when it is copied back out.
private _nameLabel = _display ctrlCreate ["RscText", -1];
_nameLabel ctrlSetText "Title";
[_nameLabel, 0.49, 0.475, 0.12, 0.05] call _fnc_at;

private _nameEdit = _display ctrlCreate ["RscEdit", IDC_NAME];
[_nameEdit, 0.62, 0.475, 0.36, 0.05] call _fnc_at;

// Who made it. Filled in from the profile name when a preset is collected, and
// shown here rather than buried in the text, so somebody can see what is about
// to travel with anything they paste and change or clear it first.
private _authorLabel = _display ctrlCreate ["RscText", -1];
_authorLabel ctrlSetText "Author";
[_authorLabel, 0.49, 0.535, 0.12, 0.05] call _fnc_at;

private _authorEdit = _display ctrlCreate ["RscEdit", IDC_AUTHOR];
[_authorEdit, 0.62, 0.535, 0.36, 0.05] call _fnc_at;

private _descLabel = _display ctrlCreate ["RscText", -1];
_descLabel ctrlSetText "Description";
[_descLabel, 0.49, 0.595, 0.12, 0.05] call _fnc_at;

// A description is a paragraph, not a name, so the box is several lines deep.
// The multi-line edit is asked for by name and only used if the game really has
// it: a ctrlCreate of a class that does not exist gives back nothing and takes
// the rest of the window with it. Which one was used goes in the log, so this
// never has to be guessed at again.
private _descClass = "RscEdit";
if (isClass (configFile >> "RscEditMulti")) then { _descClass = "RscEditMulti" };
["ALIVE_fnc_presetWindow - the description box is a %1", _descClass] call ALiVE_fnc_dump;

private _descEdit = _display ctrlCreate [_descClass, IDC_DESC];
[_descEdit, 0.62, 0.595, 0.36, 0.12] call _fnc_at;

// What is on the clipboard right now. Loading a preset is the one action here
// that depends on something outside the window, and until this line existed the
// only way to find out whether you had copied the right thing was to press Load
// from clipboard and read the complaint.
// The button below acts on the scenario in the editor, not on whatever is
// selected in the list above it. Sitting flush under the list it read as the
// latter, so it gets a line of its own saying what it is about and a gap between
// it and the list.
private _openLabel = _display ctrlCreate ["RscText", -1];
_openLabel ctrlSetText "The scenario you have open in the editor:";
_openLabel ctrlSetTextColor [0.62, 0.66, 0.58, 1];
[_openLabel, 0.02, 0.625, 0.45, 0.04] call _fnc_at;

private _clip = _display ctrlCreate ["RscText", IDC_CLIP];
_clip ctrlSetText "";
[_clip, 0.02, 0.730, 0.45, 0.045] call _fnc_at;

private _status = _display ctrlCreate ["RscText", IDC_STATUS];
_status ctrlSetText "";
[_status, 0.02, 0.79, 0.96, 0.06] call _fnc_at;

private _fnc_button = {
    // Defaults put it on the row along the bottom, which is where all but one of
    // them go. The odd one out sits under the list instead.
    params ["_text", "_bx", "_bw", "_code", ["_idc", -1], ["_by", 0.87], ["_bh", 0.08]];
    private _b = _display ctrlCreate ["RscButton", _idc];
    _b ctrlSetText _text;
    _b ctrlAddEventHandler ["ButtonClick", _code];
    [_b, _bx, _by, _bw, _bh] call _fnc_at;
    _b
};

// Filled by refresh, read by the buttons. Kept on the display rather than in a
// global: a control cannot be stored in the mission namespace, and the window is
// the natural owner of what it is showing.
_display setVariable ["entries", []];

private _fnc_refresh = {
    params ["_d", ["_keep", ""]];
    private _lb = _d displayCtrl IDC_LIST;

    // Whatever was selected stays selected. Rebuilding the list and dropping the
    // person back at the top after they renamed something is the kind of small
    // rudeness that makes a window feel broken. A rename passes its new name in,
    // because the old one no longer exists to find.
    if (_keep isEqualTo "") then {
        private _was = lbCurSel _lb;
        private _old = _d getVariable ["entries", []];
        if (_was >= 0 && {_was < count _old}) then { _keep = (_old select _was) select 0 };
    };

    private _entries = ["list"] call ALIVE_fnc_presetLibrary;
    _d setVariable ["entries", _entries];
    lbClear _lb;
    {
        _x params ["_name", "_description", "_text", "_shipped"];
        // Numbered, so a preset can be referred to by number in Discord or in a
        // report rather than by reading its whole title out.
        private _row = _lb lbAdd format ["%1. %2", _forEachIndex + 1, _name];
        _lb lbSetTooltip [_row, _description];
        if (!_shipped) then { _lb lbSetColor [_row, [0.72, 0.82, 0.55, 1]] };
    } forEach _entries;
    if (count _entries > 0) then {
        private _at = _entries findIf { (_x select 0) isEqualTo _keep };
        _lb lbSetCurSel (_at max 0);
    };
    (_d displayCtrl IDC_DETAIL) ctrlSetStructuredText parseText (
        if (count _entries == 0) then {
            "<t size='1'>Nothing here yet.<br/><br/>Copy a preset from alivemod.com or from somebody in Discord, then use Load from clipboard. It stays in your profile.</t>"
        } else { "" }
    );
};

private _fnc_show = {
    params ["_d"];
    private _entries = _d getVariable ["entries", []];
    private _sel = lbCurSel (_d displayCtrl IDC_LIST);
    if (_sel < 0 || {_sel >= count _entries}) exitWith {};
    (_entries select _sel) params ["_name", "_description", "_text", "_shipped"];
    ([_text] call ALIVE_fnc_presetParse) params ["_ok", "_preset"];
    private _what = if (_ok) then {
        private _modules = _preset select 3;
        private _settings = 0;
        { _settings = _settings + count (_x select 1) } forEach _modules;
        format ["%1 module%2, %3 setting%4 chosen", count _modules, ["s", ""] select (count _modules == 1),
            _settings, ["s", ""] select (_settings == 1)]
    } else { "this preset cannot be read by this build of ALiVE" };
    private _origin = if (_shipped) then { "Ships with ALiVE" } else { "Yours, kept in your profile" };
    // Typing over a shipped preset's name would promise something this cannot
    // keep, because the next build writes it again. Yours are yours to rename.
    (_d displayCtrl IDC_NAME) ctrlSetText _name;
    (_d displayCtrl IDC_DESC) ctrlSetText _description;
    // The author comes out of the preset itself, not out of the library's own
    // cache of names, because a preset from anywhere carries its own.
    private _author = [_preset param [2, []], 2, "", [""]] call BIS_fnc_param;
    (_d displayCtrl IDC_AUTHOR) ctrlSetText _author;
    (_d displayCtrl IDC_NAME) ctrlEnable (!_shipped);
    (_d displayCtrl IDC_DESC) ctrlEnable (!_shipped);
    (_d displayCtrl IDC_AUTHOR) ctrlEnable (!_shipped);
    (_d displayCtrl IDC_DETAIL) ctrlSetStructuredText parseText format [
        "<t size='1.1'>%1</t><br/><br/><t size='0.95'>%2</t><br/><br/><t size='0.9' color='#9aa08d'>%3<br/>%4</t>",
        _name, _description, _what, _origin];

    // The submit link is put on the button NOW, while the selection changes,
    // because a link can only be opened by a real click on a control already
    // holding it. Setting it inside the click handler would open nothing.
    //
    // The title and the description travel in the address. The PRESET does not,
    // and that is deliberate.
    //
    // Hovering a control that holds a link makes the game show the whole address,
    // which it does on purpose so a person can see where a link goes before they
    // click it. A preset in there turns that into a screen-wide band of percent
    // signs on every pass of the mouse, and no tooltip of ours can override it.
    // The address the engine shows should be one somebody can actually read.
    //
    // Nothing is lost by leaving the preset out. It goes on the clipboard on every
    // click, the page asks for it, and the box is waiting with the cursor already
    // in it: one keystroke, against an unreadable hover every time the mouse
    // passes the button.
    private _submit = _d displayCtrl IDC_SUBMIT;

    // The address carries NOTHING but the page. Hovering a control that holds a
    // link makes the game print the whole address across the screen, on purpose,
    // so a person can see where a link goes before clicking it. Anything put in
    // there ends up in that band, and a description is a paragraph.
    //
    // The page gets the title and the description out of the preset itself once it
    // is pasted, which it can do because both are inside it. So nothing is lost by
    // keeping the link bare, and the hover stays one readable line.
    _submit ctrlSetURL "https://www.alivemod.com/alive3/submit_preset.htm";

    // Submitting one of ALiVE's own presets would be sending it back to the people
    // who wrote it, so the button is off for those. No tooltip when it is off: the
    // engine still prints the address of a disabled control, and adding words of
    // our own to that only makes the band longer.
    _submit ctrlEnable (!_shipped);
    _submit ctrlSetTooltip (if (_shipped) then { "" } else {
        "Opens alivemod.com in your browser. The preset is on your clipboard too."
    });
};

(_display displayCtrl IDC_LIST) ctrlAddEventHandler ["LBSelChanged", {
    params ["_ctrl"];
    [ctrlParent _ctrl] call (uiNamespace getVariable ["ALiVE_presetWindowShow", {}]);
}];

uiNamespace setVariable ["ALiVE_presetWindowShow", _fnc_show];
uiNamespace setVariable ["ALiVE_presetWindowRefresh", _fnc_refresh];

// Going on to place the selected preset. Held in one place because two things
// start it: the button, and a double click on the row itself, which is what
// anybody who has used a list before will try first.
private _fnc_goPlace = {
    params ["_d"];
    private _entries = _d getVariable ["entries", []];
    private _sel = lbCurSel (_d displayCtrl IDC_LIST);
    if (_sel < 0 || {_sel >= count _entries}) exitWith {};
    private _text = (_entries select _sel) select 2;
    ([_text] call ALIVE_fnc_presetParse) params ["_ok", "_preset", "_problems"];
    if (!_ok) exitWith {
        (_d displayCtrl IDC_STATUS) ctrlSetText (if (count _problems > 0) then { _problems select 0 } else { "That preset cannot be read." });
    };
    // The window gets out of the way and what is in the preset is shown before
    // any of it lands, the same list and the same gesture as sharing one. From
    // there the next click says where it goes, which is how anything else is
    // placed in the editor. Where somebody is looking has two answers here and
    // neither is reliable in both views, so it is asked rather than guessed.
    _d closeDisplay 1;
    ["place", _preset] call ALIVE_fnc_presetChoose;
};
uiNamespace setVariable ["ALiVE_presetWindowGoPlace", _fnc_goPlace];

(_display displayCtrl IDC_LIST) ctrlAddEventHandler ["LBDblClick", {
    params ["_ctrl"];
    [ctrlParent _ctrl] call (uiNamespace getVariable ["ALiVE_presetWindowGoPlace", {}]);
}];

["Place it", 0.020, 0.085, {
    params ["_ctrl"];
    [ctrlParent _ctrl] call (uiNamespace getVariable ["ALiVE_presetWindowGoPlace", {}]);
}] call _fnc_button;

["Load from clipboard", 0.447, 0.201, {
    params ["_ctrl"];
    private _d = ctrlParent _ctrl;
    (["add", copyFromClipboard] call ALIVE_fnc_presetLibrary) params ["_ok", "_why"];
    (_d displayCtrl 88103) ctrlSetText _why;
    if (_ok) then { [_d] call (uiNamespace getVariable ["ALiVE_presetWindowRefresh", {}]) };
}] call _fnc_button;

["Delete selected", 0.656, 0.158, {
    params ["_ctrl"];
    private _d = ctrlParent _ctrl;
    private _entries = _d getVariable ["entries", []];
    private _sel = lbCurSel (_d displayCtrl 88101);
    if (_sel < 0 || {_sel >= count _entries}) exitWith {};
    (_entries select _sel) params ["_name", "", "", "_shipped"];
    if (_shipped) exitWith {
        (_d displayCtrl 88103) ctrlSetText "That one ships with ALiVE, so it cannot be deleted.";
    };
    if (["remove", _name] call ALIVE_fnc_presetLibrary) then {
        (_d displayCtrl 88103) ctrlSetText format ["Deleted ""%1"".", _name];
        [_d] call (uiNamespace getVariable ["ALiVE_presetWindowRefresh", {}]);
    };
}] call _fnc_button;

// Closed by its own display rather than by closeDialog, which only knows about
// a dialog hung off a mission.
// Copying a preset back out is how it reaches Discord, a friend, or the submit
// page. The library is where somebody's collection lives, so it is where they
// will look to pass one on.
["Copy to clipboard", 0.113, 0.180, {
    params ["_ctrl"];
    private _d = ctrlParent _ctrl;
    private _entries = _d getVariable ["entries", []];
    private _sel = lbCurSel (_d displayCtrl IDC_LIST);
    if (_sel < 0 || {_sel >= count _entries}) exitWith {};
    (_entries select _sel) params ["_name", "_description", "_text"];
    copyToClipboard _text;
    (_d displayCtrl IDC_STATUS) ctrlSetText format ["%1 is on the clipboard, ready to paste anywhere.", _name];
}] call _fnc_button;

["Save title/description", 0.49, 0.49, {
    params ["_ctrl"];
    private _d = ctrlParent _ctrl;
    private _entries = _d getVariable ["entries", []];
    private _sel = lbCurSel (_d displayCtrl IDC_LIST);
    if (_sel < 0 || {_sel >= count _entries}) exitWith {};
    (_entries select _sel) params ["_was", "_wasDescription", "_text", "_shipped"];
    if (_shipped) exitWith {
        (_d displayCtrl IDC_STATUS) ctrlSetText "That one ships with ALiVE, so its name stays as it is.";
    };
    private _name = ctrlText (_d displayCtrl IDC_NAME);
    private _description = ctrlText (_d displayCtrl IDC_DESC);
    private _author = ctrlText (_d displayCtrl IDC_AUTHOR);
    (["update", [_was, _name, _description, _author]] call ALIVE_fnc_presetLibrary) params ["_ok", "_why"];
    (_d displayCtrl IDC_STATUS) ctrlSetText _why;
    if (_ok) then { [_d, _name] call (uiNamespace getVariable ["ALiVE_presetWindowRefresh", {}]) };
}, -1, 0.735, 0.05] call _fnc_button;

// On the row with the other actions, beside Copy to clipboard, because both are
// ways of getting the selected preset OUT of here.
//
// There was no room for it there until Save title/description moved up under the
// fields it saves, which is where it belonged anyway. Before that this button sat
// beside those fields and read as a second Save for them.
//
// A plain button carrying a link is all this takes: measured 2026-09-19, a button
// holds a 16,000 character link and opens it in the system browser, and only a
// real click will do it. The link is hung on the button whenever the selection
// changes, so by the time it is clicked it is already loaded; the handler below
// only deals with the clipboard.
["Submit online", 0.301, 0.138, {
    params ["_ctrl"];
    private _d = ctrlParent _ctrl;
    private _entries = _d getVariable ["entries", []];
    private _sel = lbCurSel (_d displayCtrl 88101);
    if (_sel < 0 || {_sel >= count _entries}) exitWith {};
    (_entries select _sel) params ["_name", "", "_text"];
    // On the clipboard every time, whether the link carried the preset or not.
    // The page opening empty is the one case where somebody needs it, and working
    // out which case they are in is not their job.
    copyToClipboard _text;
}, IDC_SUBMIT] call _fnc_button;

// Straight from the scenario into your own list, with no trip through the
// clipboard.
//
// The long way round still exists and is still the one to use when only part of a
// scenario is worth sharing: right click, Share as Preset, tick what goes in,
// copy, then Load from clipboard. But somebody who just wants to keep what is in
// front of them had to do all three of those, and the middle one only existed to
// carry the text from one ALiVE window to another.
//
// Takes the whole scenario and keeps the layout, which is what collecting with
// nothing chosen means.
["Save it as a preset", 0.02, 0.45, {
    params ["_ctrl"];
    private _d = ctrlParent _ctrl;

    ([] call ALIVE_fnc_presetCollect) params ["_preset", "_report"];
    if (count _preset == 0) exitWith {
        (_d displayCtrl 88103) ctrlSetText "This scenario has no ALiVE modules to save.";
    };

    private _text = _preset call ALIVE_fnc_presetSerialize;
    if (_text isEqualTo "") exitWith {
        (_d displayCtrl 88103) ctrlSetText "That scenario could not be written out as a preset.";
    };

    // Through the library's own add, so it is named, de-duplicated and saved to
    // the profile by the same code a pasted preset goes through. Two ways in, one
    // way of storing it.
    (["add", _text] call ALIVE_fnc_presetLibrary) params ["_ok", "_why"];

    // Said the same way sharing says it. A setting left out is the one thing about
    // this that is not obvious from the result, so it does not go unmentioned just
    // because this path is the quick one.
    _report params ["", "", "", ["_dropped", []], "", ["_missing", []]];
    private _said = _why;
    if (_ok && {count _dropped > 0}) then {
        _said = _said + format [" Left out: %1.", _dropped joinString ", "];
    };
    if (_ok && {count _missing > 0}) then {
        _said = _said + format [" These areas are not in it, so the settings naming them went too: %1.",
            _missing joinString ", "];
    };
    (_d displayCtrl 88103) ctrlSetText _said;

    if (_ok) then {
        [_d] call (uiNamespace getVariable ["ALiVE_presetWindowRefresh", {}]);
    };
}, -1, 0.670, 0.05] call _fnc_button;

["Close", 0.927, 0.053, { (ctrlParent (_this select 0)) closeDisplay 1 }] call _fnc_button;

[_display] call _fnc_refresh;
[_display] call _fnc_show;

// Watching the clipboard, because nothing tells you when it changes. A person
// copies a preset out of Discord with this window already open, and the window
// has no way to know unless it looks.
//
// It looks once a second, and only READS a string and compares it. Reading the
// clipboard is cheap; working out what a preset is, is not, so the expensive half
// runs only when the text is different from last time. A 14,000 character preset
// parsed every second would be a poor way to spend a frame.
[_display] spawn {
    params ["_d"];
    private _was = "nothing yet";
    while { !isNull _d } do {
        private _now = copyFromClipboard;
        if !(_now isEqualTo _was) then {
            _was = _now;
            private _line = if (_now isEqualTo "") then {
                "Clipboard: empty"
            } else {
                ([_now] call ALIVE_fnc_presetParse) params ["_ok", "_preset"];
                if (!_ok) then {
                    "Clipboard: no preset"
                } else {
                    private _meta = _preset param [2, []];
                    private _name = [_meta, 0, "", [""]] call BIS_fnc_param;
                    if (_name isEqualTo "") then { _name = "an untitled preset" };
                    private _areas = count (_preset param [7, []]);
                    format ["Clipboard: %1, %2 module%3%4", _name,
                        count (_preset param [3, []]),
                        ["s", ""] select (count (_preset param [3, []]) == 1),
                        if (_areas > 0) then {
                            format [", %1 area%2", _areas, ["s", ""] select (_areas == 1)]
                        } else { "" }]
                };
            };
            if (!isNull _d) then { (_d displayCtrl 88107) ctrlSetText _line };
        };
        // uiSleep, not sleep. The editor is not running a mission, so mission time
        // does not move and a sleep here would wait for a clock that never ticks.
        uiSleep 1;
    };
};

true
