#include "script_component.hpp"
SCRIPT(presetChoose);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_presetChoose

Description:
Asks which parts of the scenario to share, by showing them: every ALiVE module
and every area, one row each, ticked or not.

Sharing everything is still the quick path and still what the right click entry
does. This is for the times when a scenario holds more than the one setup worth
passing on, which is most scenarios that have been worked on for a while.

Two modules are shown ticked and cannot be unticked: ALiVE Required and the
Virtual AI System. A preset without them places cleanly and then does nothing at
all, with nothing anywhere to say why, and that is not a choice worth offering.

The rows are a list rather than a column of checkbox controls, because a
scenario can hold thirty modules and a list scrolls where a column of controls
would have to be paged by hand. Double clicking a row turns it on or off; the tick
is drawn in the row's own text so it needs no textures that might not resolve
on somebody else's install.

Parameters:
    None.

Returns:
    BOOL - whether the window opened

Examples:
    (begin example)
    [] call ALIVE_fnc_presetChoose;
    (end)

See Also:
    ALIVE_fnc_presetShare, ALIVE_fnc_presetCollect, ALIVE_fnc_presetMarkers

Author:
    Jman
---------------------------------------------------------------------------- */

params [["_mode", "share", [""]], ["_preset", [], [[]]]];

if (!is3DEN) exitWith { false };

private _placing = (toLower _mode) isEqualTo "place";

#define IDD_CHOOSE  88110
#define IDC_ROWS    88111
#define IDC_SAYS    88112

disableSerialization;

// The editor has no mission display to hang a window off, so a window here is a
// child of the editor's own display. createDialog does nothing at all, silently.
private _parent = findDisplay 313;
if (isNull _parent) then { _parent = findDisplay 46 };
if (isNull _parent) exitWith {
    ["ALIVE_fnc_presetChoose - there is no editor display to open the window on"] call ALiVE_fnc_dump;
    false
};

private _display = _parent createDisplay "ALiVE_PresetLibrary";
if (isNull _display) exitWith {
    ["ALIVE_fnc_presetChoose - the window would not open"] call ALiVE_fnc_dump;
    false
};

// A row is [kind, value, label, ticked, locked]. Sharing reads the scenario;
// placing reads the preset. The same list, the same gesture, the same rules
// about what cannot be turned off, so there is one thing to learn rather than
// two.
private _rows = [];
private _fnc_label = {
    params ["_class"];
    private _name = getText (configFile >> "CfgVehicles" >> _class >> "displayName");
    if (_name isEqualTo "") then { _name = _class };
    _name
};
private _fnc_locked = { (toLower _this) in ["alive_require", "alive_sys_profile"] };

if (_placing) then {
    {
        private _class = _x select 0;
        private _settings = _x select 1;
        _rows pushBack ["module", _forEachIndex, format ["%1  (%2 setting%3)",
            [_class] call _fnc_label, count _settings, ["s", ""] select (count _settings == 1)],
            true, _class call _fnc_locked];
    } forEach (_preset param [3, []]);

    {
        private _size = _x param [4, [0, 0]];
        _rows pushBack ["area", _forEachIndex, format ["%1  (%2 x %3 m)", _x param [0, ""],
            _size param [0, 0], _size param [1, 0]], true, false];
    } forEach (_preset param [7, []]);
} else {
    private _modules = [];
    {
        if (_x isEqualType []) then {
            {
                if (_x isEqualType objNull && {!isNull _x} && {(typeOf _x) isKindOf "ModuleAliveBase"}) then {
                    _modules pushBackUnique _x;
                };
            } forEach _x;
        };
    } forEach all3DENEntities;
    _modules = [_modules, [], { get3DENEntityID _x }, "ASCEND"] call BIS_fnc_sortBy;

    {
        private _class = typeOf _x;
        _rows pushBack ["module", _x, [_class] call _fnc_label, true, _class call _fnc_locked];
    } forEach _modules;

    {
        private _row = ["read", _x] call ALIVE_fnc_presetMarkers;
        if (count _row >= 10) then {
            private _size = _row select 4;
            _rows pushBack ["area", _x, format ["%1  (%2 x %3 m)", _row select 0,
                _size param [0, 0], _size param [1, 0]], true, false];
        };
    } forEach (["find"] call ALIVE_fnc_presetMarkers);
};

if (count _rows == 0) exitWith {
    _display closeDisplay 1;
    [if (_placing) then { "There is nothing in that preset to place." }
     else { "This scenario has no ALiVE modules to share." }, 1, 8] call BIS_fnc_3DENNotification;
    false
};

_display setVariable ["rows", _rows];
_display setVariable ["placing", _placing];
_display setVariable ["preset", _preset];

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

private _back = _display ctrlCreate ["RscText", -1];
_back ctrlSetBackgroundColor [0.02, 0.03, 0.02, 0.85];
[_back, 0, 0, 1, 1] call _fnc_at;

private _title = _display ctrlCreate ["RscText", -1];
_title ctrlSetText (if (_placing) then { "Place a Preset" } else { "Share as Preset" });
[_title, 0.02, 0.02, 0.7, 0.06] call _fnc_at;

private _hint = _display ctrlCreate ["RscText", -1];
_hint ctrlSetText (if (_placing) then {
    "Double click a row to place it or leave it out. Leave an area out and the settings naming it go too."
} else {
    "Double click a row to include it or leave it out. Areas bring the settings that name them."
});
[_hint, 0.02, 0.08, 0.96, 0.05] call _fnc_at;

private _list = _display ctrlCreate ["RscListBox", IDC_ROWS];
[_list, 0.02, 0.14, 0.96, 0.66] call _fnc_at;

private _says = _display ctrlCreate ["RscText", IDC_SAYS];
_says ctrlSetText "";
[_says, 0.02, 0.81, 0.96, 0.05] call _fnc_at;

private _fnc_draw = {
    params ["_d"];
    private _lb = _d displayCtrl IDC_ROWS;
    private _rows = _d getVariable ["rows", []];
    private _was = lbCurSel _lb;
    lbClear _lb;
    private _on = 0;
    private _areas = 0;
    {
        _x params ["_kind", "_value", "_label", "_ticked", "_locked"];
        private _tick = if (_ticked) then { "[x] " } else { "[  ] " };
        private _tail = if (_locked) then { "   (always included)" } else { "" };
        private _at = _lb lbAdd (_tick + _label + _tail);
        if (_ticked) then { _on = _on + 1 };
        if (_ticked && {_kind isEqualTo "area"}) then { _areas = _areas + 1 };
        // Areas in their own colour, so the two kinds read apart at a glance in
        // what can be a long list.
        if (_kind isEqualTo "area") then { _lb lbSetColor [_at, [0.72, 0.82, 0.55, 1]] };
        if (_locked) then { _lb lbSetColor [_at, [0.6, 0.6, 0.6, 1]] };
    } forEach _rows;
    if (_was >= 0 && {_was < count _rows}) then { _lb lbSetCurSel _was };
    (_d displayCtrl IDC_SAYS) ctrlSetText format ["%1 of %2 included, %3 of them areas.",
        _on, count _rows, _areas];
};

uiNamespace setVariable ["ALiVE_presetChooseDraw", _fnc_draw];

(_display displayCtrl IDC_ROWS) ctrlAddEventHandler ["LBDblClick", {
    params ["_ctrl", "_index"];
    private _d = ctrlParent _ctrl;
    private _rows = _d getVariable ["rows", []];
    if (_index < 0 || {_index >= count _rows}) exitWith {};
    private _row = _rows select _index;
    if (_row select 4) exitWith {
        (_d displayCtrl 88112) ctrlSetText format ["%1 always travels with a preset.", _row select 2];
    };
    _row set [3, !(_row select 3)];
    _rows set [_index, _row];
    _d setVariable ["rows", _rows];
    [_d] call (uiNamespace getVariable ["ALiVE_presetChooseDraw", {}]);
}];

private _fnc_button = {
    params ["_text", "_bx", "_bw", "_code"];
    private _b = _display ctrlCreate ["RscButton", -1];
    _b ctrlSetText _text;
    _b ctrlAddEventHandler ["ButtonClick", _code];
    [_b, _bx, 0.88, _bw, 0.08] call _fnc_at;
    _b
};

private _fnc_setAll = {
    params ["_ctrl", "_state"];
    private _d = ctrlParent _ctrl;
    private _rows = _d getVariable ["rows", []];
    {
        // A locked row stays on whatever "none" is asked for.
        if !(_x select 4) then { _x set [3, _state] };
    } forEach _rows;
    _d setVariable ["rows", _rows];
    [_d] call (uiNamespace getVariable ["ALiVE_presetChooseDraw", {}]);
};
uiNamespace setVariable ["ALiVE_presetChooseSetAll", _fnc_setAll];

// "Place these", not "Place it": the button that opened this window is already
// called Place it, and two buttons with one name across two windows is the kind
// of thing that has to be explained in writing afterwards.
[if (_placing) then { "Place these" } else { "Copy the preset" }, 0.02, 0.22, {
    params ["_ctrl"];
    private _d = ctrlParent _ctrl;
    private _rows = _d getVariable ["rows", []];
    private _pickModules = [];
    private _pickMarkers = [];
    {
        _x params ["_kind", "_value", "", "_ticked"];
        if (_ticked) then {
            if (_kind isEqualTo "module") then { _pickModules pushBack _value } else { _pickMarkers pushBack _value };
        };
    } forEach _rows;

    if (count _pickModules == 0) exitWith {
        // A preset with no modules is refused when it is read back, so there is
        // no point writing one. Said here rather than letting it fail later.
        (_d displayCtrl 88112) ctrlSetText "Include at least one module: a preset with none can do nothing.";
    };

    if !(_d getVariable ["placing", false]) exitWith {
        _d closeDisplay 1;
        [[_pickModules, _pickMarkers]] call ALIVE_fnc_presetShare;
    };

    // Placing part of a preset means writing a smaller preset and placing that,
    // rather than teaching the placer to skip things. A preset that has been cut
    // down has to still make sense on its own: sync lines renumbered to the
    // modules that remain, and any setting naming an area that was left behind
    // taken out with it, because a name pointing at nothing reads as configured
    // and behaves as broken.
    private _preset = _d getVariable ["preset", []];
    private _wasModules = _preset param [3, []];
    private _wasMarkers = _preset param [7, []];

    private _keptMarkers = [];
    private _keptNames = [];
    {
        _keptMarkers pushBack (_wasMarkers select _x);
        _keptNames pushBack (toLower ((_wasMarkers select _x) param [0, ""]));
    } forEach _pickMarkers;

    private _modules = [];
    {
        (_wasModules select _x) params ["_class", "_settings"];
        private _keep = [];
        {
            private _prop = _x select 0;
            private _value = _x select 1;
            private _setting = ["setting", [_class, _prop]] call ALIVE_fnc_presetMarkers;
            private _ok = true;
            if !(_setting isEqualTo "") then {
                {
                    if !((toLower _x) in _keptNames) exitWith { _ok = false };
                } forEach (["names", [_setting, _value]] call ALIVE_fnc_presetMarkers);
            };
            if (_ok) then { _keep pushBack [_prop, _value] };
        } forEach _settings;
        _modules pushBack [_class, _keep];
    } forEach _pickModules;

    private _links = [];
    {
        _x params ["_a", "_b"];
        private _from = _pickModules find _a;
        private _to = _pickModules find _b;
        if (_from >= 0 && {_to >= 0}) then { _links pushBack [_from, _to] };
    } forEach (_preset param [4, []]);

    private _meta = _preset param [2, ["", "", "", "", "", ""]];
    private _cut = if (count _keptMarkers == 0) then {
        ["ALIVEPRESET", 1, _meta, _modules, _links, _preset param [5, []], _preset param [6, []]]
    } else {
        ["ALIVEPRESET", 2, _meta, _modules, _links, _preset param [5, []], _preset param [6, []], _keptMarkers]
    };

    _d closeDisplay 1;
    [_cut] call ALIVE_fnc_presetPlaceClick;
}] call _fnc_button;

["All", 0.26, 0.10, {
    [_this select 0, true] call (uiNamespace getVariable ["ALiVE_presetChooseSetAll", {}]);
}] call _fnc_button;

["None", 0.37, 0.10, {
    [_this select 0, false] call (uiNamespace getVariable ["ALiVE_presetChooseSetAll", {}]);
}] call _fnc_button;

["Close", 0.88, 0.10, { (ctrlParent (_this select 0)) closeDisplay 1 }] call _fnc_button;

[_display] call _fnc_draw;

["ALIVE_fnc_presetChoose - open with %1 row(s)", count _rows] call ALiVE_fnc_dump;
true
