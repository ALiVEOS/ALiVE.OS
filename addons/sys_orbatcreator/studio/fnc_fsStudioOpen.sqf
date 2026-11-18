#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsStudioOpen);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsStudioOpen

Description:
Creates the studio display (idd 14000) on an existing session and restores the
tab and the selection from the session (the tab's refresh reads the selection).
Repaints the last status line and the faction name.

Controls whose handler function is not loaded yet are switched off, so a click
on them does nothing instead of throwing a script error:
    - the preview mouse area is hidden without ALiVE_fnc_fsStudioCamera;
    - every control of a tab is disabled without that tab's function;
    - Edit loadout and Undo last Arsenal are disabled without ALiVE_fnc_fsStudioArsenal.

Never suspends. Leaves when there is no session; returns the live display when
the studio is already open.

Parameters:
    None

Returns:
    DISPLAY - the studio display, or displayNull

Examples:
    (begin example)
    [] call ALiVE_fnc_fsStudioOpen;
    (end)

See Also:
    ALiVE_fnc_fsStudioReopen, ALiVE_fnc_fsStudioTab, ALiVE_fnc_fsStudioStatus

Author:
    Jman
---------------------------------------------------------------------------- */

#include "\x\alive\addons\sys_orbatcreator\fs_defines.hpp"
#include "\x\alive\addons\sys_orbatcreator\data\ui\studio\idc.hpp"

if (!hasInterface) exitWith { displayNull };

disableSerialization;

private _session = missionNamespace getVariable "ALiVE_FS_session";
if (isNil "_session") exitWith { displayNull };

private _live = findDisplay FS_IDD_STUDIO;
if (!isNull _live) exitWith { _live };

createDialog "ALiVE_FS_Studio";
private _display = findDisplay FS_IDD_STUDIO;
if (isNull _display) exitWith {
    ["ORBAT Creator studio: the display ALiVE_FS_Studio did not open"] call ALiVE_fnc_dump;
    displayNull
};
_session set ["display", _display];

// the header picture at its own shape: 8:1, so its width is 8 heights on screen (pixelW / pixelH turns a
// height into the same width); a narrow screen gets a lower header rather than one into the ? and Exit buttons
private _square = pixelW / pixelH;
private _logo = _display displayCtrl FS_IDC_LOGO;
(ctrlPosition _logo) params ["_lx", "_ly", "_lmax", "_lh"];
private _lw = 8 * _lh * _square;
// the artwork takes the left 6.515 of its 8 heights; the clear rest may lie under the buttons
private _art = _lw * 6.515 / 8;
if (_art > _lmax) then { _lh = _lh * _lmax / _art; _lw = _lw * _lmax / _art };
_logo ctrlSetPosition [_lx, _ly, _lw, _lh];
// the picture drawn nearest its size on screen: the interface shrinks a big texture without smoothing, so the
// tag's small letters break up. The smallest height at least as tall as the header, or the one below it when
// that is over 1.7 times the header
private _px = _lh / pixelH;
private _sizes = [32, 64, 128, 256];
private _i = _sizes findIf { _x >= _px };
if (_i < 0) then { _i = 3 };
if (_i > 0 && {(_sizes select _i) > 1.7 * _px}) then { _i = _i - 1 };
private _t = _sizes select _i;
_logo ctrlSetText format ["\x\alive\addons\sys_orbatcreator\data\images\fs_header%1_ca.paa", _t];
[format ["ORBAT Creator studio: header %1 px tall, picture %2 px", round _px, _t]] call ALiVE_fnc_dump;
_logo ctrlCommit 0;

// the six tab buttons laid out from their words: each as wide as its word on screen plus a margin, the row's
// spare width shared out evenly. When the words are too wide for the row together (a translation), their
// text is made smaller until they fit
private _gw = ((safezoneW / safezoneH) min 1.2) / 40;
private _textH = ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.85;
private _tabButtons = [FS_IDC_TAB_FACTION, FS_IDC_TAB_UNITS, FS_IDC_TAB_VEHICLES, FS_IDC_TAB_GROUPS, FS_IDC_TAB_ALIVE, FS_IDC_TAB_EXPORT] apply { _display displayCtrl _x };
private _tabWords = ["FACTION", "UNITS", "VEHICLES", "GROUPS", "ALIVE", "EXPORT"] apply { localize ("STR_ALIVE_FS_TAB_" + _x) };
private _ruler = _display ctrlCreate ["RscText", -1];
_ruler ctrlSetPosition [-10, -10, 10, 0.1];
_ruler ctrlShow false;
_ruler ctrlCommit 0;
_ruler ctrlSetFont "PuristaMedium";
_ruler ctrlSetFontHeight _textH;
private _widths = _tabWords apply { _ruler ctrlSetText _x; ctrlTextWidth _ruler };
ctrlDelete _ruler;
private _row = 16 * _gw;
private _gap = 0.1 * _gw;
private _margin = 0.45 * _gw;
private _sum = 0;
{ _sum = _sum + _x } forEach _widths;
private _room = _row - 5 * _gap - 6 * _margin;
private _scale = if (_sum > _room && {_sum > 0}) then { _room / _sum } else { 1 };
private _spare = ((_room - _sum * _scale) / 6) max 0;
private _tx = safezoneX + 0.5 * _gw;
{
    private _w = (_widths select _forEachIndex) * _scale + _margin + _spare;
    (ctrlPosition _x) params ["", "_ty", "", "_th"];
    _x ctrlSetPosition [_tx, _ty, _w, _th];
    if (_scale < 1) then { _x ctrlSetFontHeight (_textH * _scale) };
    _x ctrlCommit 0;
    _tx = _tx + _w + _gap;
} forEach _tabButtons;
[format ["ORBAT Creator studio: tab words %1 of %2 cells, text scale %3", ((_sum / _gw) toFixed 2), ((_room / _gw) toFixed 2), (_scale toFixed 2)]] call ALiVE_fnc_dump;

// true when _ctrl sits anywhere inside the controls group _group
private _inside = {
    params ["_ctrl", "_group"];
    private _parent = ctrlParentControlsGroup _ctrl;
    private _found = false;
    while { !isNull _parent && {!_found} } do {
        if (_parent isEqualTo _group) then { _found = true } else { _parent = ctrlParentControlsGroup _parent };
    };
    _found
};

if (isNil "ALiVE_fnc_fsStudioCamera") then { (_display displayCtrl FS_IDC_MOUSE) ctrlShow false };

private _all = allControls _display;
{
    _x params ["_idc", "_function"];
    if (isNil _function) then {
        private _group = _display displayCtrl _idc;
        { if ([_x, _group] call _inside) then { _x ctrlEnable false } } forEach _all;
    };
} forEach [
    [FS_IDC_GRP_FACTION,  "ALiVE_fnc_fsStudioTabFaction"],
    [FS_IDC_GRP_UNITS,    "ALiVE_fnc_fsStudioTabUnits"],
    [FS_IDC_GRP_VEHICLES, "ALiVE_fnc_fsStudioTabVehicles"],
    [FS_IDC_GRP_GROUPS,   "ALiVE_fnc_fsStudioTabGroups"],
    [FS_IDC_GRP_EXPORT,   "ALiVE_fnc_fsStudioTabExport"]
];

if (isNil "ALiVE_fnc_fsStudioArsenal") then {
    { (_display displayCtrl _x) ctrlEnable false } forEach [FS_IDC_U_LOADOUT, FS_IDC_U_UNDO];
};

[_session getOrDefault ["tab", "faction"]] call ALiVE_fnc_fsStudioTab;
[-1] call ALiVE_fnc_fsStudioStatus;

_display
