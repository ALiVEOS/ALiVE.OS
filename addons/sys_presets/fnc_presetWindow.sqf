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

private _back = _display ctrlCreate ["RscText", -1];
_back ctrlSetBackgroundColor [0.02, 0.03, 0.02, 0.85];
[_back, 0, 0, 1, 1] call _fnc_at;

private _title = _display ctrlCreate ["RscText", -1];
_title ctrlSetText "ALiVE Presets";
[_title, 0.02, 0.02, 0.6, 0.07] call _fnc_at;

private _hint = _display ctrlCreate ["RscText", -1];
_hint ctrlSetText "Ready-made ALiVE setups. Pick one and place it, then change whatever you like.";
[_hint, 0.02, 0.09, 0.96, 0.06] call _fnc_at;

private _list = _display ctrlCreate ["RscListBox", IDC_LIST];
[_list, 0.02, 0.16, 0.45, 0.62] call _fnc_at;

private _detail = _display ctrlCreate ["RscStructuredText", IDC_DETAIL];
[_detail, 0.49, 0.16, 0.49, 0.44] call _fnc_at;

// Naming and describing a preset you collected. A preset from a stranger often
// arrives with no name of its own, which is exactly when somebody wants to give
// it one, and what gets typed here goes into the preset's own text so it keeps
// the name when it is copied back out.
private _nameLabel = _display ctrlCreate ["RscText", -1];
_nameLabel ctrlSetText "Title";
[_nameLabel, 0.49, 0.615, 0.12, 0.05] call _fnc_at;

private _nameEdit = _display ctrlCreate ["RscEdit", IDC_NAME];
[_nameEdit, 0.60, 0.615, 0.38, 0.05] call _fnc_at;

private _descLabel = _display ctrlCreate ["RscText", -1];
_descLabel ctrlSetText "Description";
[_descLabel, 0.49, 0.675, 0.12, 0.05] call _fnc_at;

private _descEdit = _display ctrlCreate ["RscEdit", IDC_DESC];
[_descEdit, 0.60, 0.675, 0.38, 0.05] call _fnc_at;

private _status = _display ctrlCreate ["RscText", IDC_STATUS];
_status ctrlSetText "";
[_status, 0.02, 0.79, 0.96, 0.06] call _fnc_at;

private _fnc_button = {
    params ["_text", "_bx", "_bw", "_code"];
    private _b = _display ctrlCreate ["RscButton", -1];
    _b ctrlSetText _text;
    _b ctrlAddEventHandler ["ButtonClick", _code];
    [_b, _bx, 0.87, _bw, 0.08] call _fnc_at;
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
    (_d displayCtrl IDC_NAME) ctrlEnable (!_shipped);
    (_d displayCtrl IDC_DESC) ctrlEnable (!_shipped);
    (_d displayCtrl IDC_DETAIL) ctrlSetStructuredText parseText format [
        "<t size='1.1'>%1</t><br/><br/><t size='0.95'>%2</t><br/><br/><t size='0.9' color='#9aa08d'>%3<br/>%4</t>",
        _name, _description, _what, _origin];
};

(_display displayCtrl IDC_LIST) ctrlAddEventHandler ["LBSelChanged", {
    params ["_ctrl"];
    [ctrlParent _ctrl] call (uiNamespace getVariable ["ALiVE_presetWindowShow", {}]);
}];

uiNamespace setVariable ["ALiVE_presetWindowShow", _fnc_show];
uiNamespace setVariable ["ALiVE_presetWindowRefresh", _fnc_refresh];

["Place it", 0.02, 0.085, {
    params ["_ctrl"];
    private _d = ctrlParent _ctrl;
    private _entries = _d getVariable ["entries", []];
    private _sel = lbCurSel (_d displayCtrl IDC_LIST);
    if (_sel < 0 || {_sel >= count _entries}) exitWith {};
    private _text = (_entries select _sel) select 2;
    ([_text] call ALIVE_fnc_presetParse) params ["_ok", "_preset", "_problems"];
    if (!_ok) exitWith {
        (_d displayCtrl 88103) ctrlSetText (if (count _problems > 0) then { _problems select 0 } else { "That preset cannot be read." });
    };
    // The window gets out of the way and what is in the preset is shown before
    // any of it lands, the same list and the same gesture as sharing one. From
    // there the next click says where it goes, which is how anything else is
    // placed in the editor. Where somebody is looking has two answers here and
    // neither is reliable in both views, so it is asked rather than guessed.
    _d closeDisplay 1;
    ["place", _preset] call ALIVE_fnc_presetChoose;
}] call _fnc_button;

["Load from clipboard", 0.305, 0.201, {
    params ["_ctrl"];
    private _d = ctrlParent _ctrl;
    (["add", copyFromClipboard] call ALIVE_fnc_presetLibrary) params ["_ok", "_why"];
    (_d displayCtrl 88103) ctrlSetText _why;
    if (_ok) then { [_d] call (uiNamespace getVariable ["ALiVE_presetWindowRefresh", {}]) };
}] call _fnc_button;

["Delete selected", 0.759, 0.158, {
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
["Copy to clipboard", 0.115, 0.18, {
    params ["_ctrl"];
    private _d = ctrlParent _ctrl;
    private _entries = _d getVariable ["entries", []];
    private _sel = lbCurSel (_d displayCtrl IDC_LIST);
    if (_sel < 0 || {_sel >= count _entries}) exitWith {};
    (_entries select _sel) params ["_name", "_description", "_text"];
    copyToClipboard _text;
    (_d displayCtrl IDC_STATUS) ctrlSetText format ["%1 is on the clipboard, ready to paste anywhere.", _name];
}] call _fnc_button;

["Save title/description", 0.516, 0.233, {
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
    (["update", [_was, _name, _description]] call ALIVE_fnc_presetLibrary) params ["_ok", "_why"];
    (_d displayCtrl IDC_STATUS) ctrlSetText _why;
    if (_ok) then { [_d, _name] call (uiNamespace getVariable ["ALiVE_presetWindowRefresh", {}]) };
}] call _fnc_button;

["Close", 0.927, 0.053, { (ctrlParent (_this select 0)) closeDisplay 1 }] call _fnc_button;

[_display] call _fnc_refresh;
[_display] call _fnc_show;

true
