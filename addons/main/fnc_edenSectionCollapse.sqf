#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(edenSectionCollapse);

/* ----------------------------------------------------------------------------
Function: fnc_edenSectionCollapse

Description:
Opens and closes the setting sections of an ALiVE module in Eden's attributes window (#1083). Each
section header (ALiVE_ModuleSubTitle) carries Eden's own category arrow; a click on the arrow or on
the header text opens or closes the settings under it, down to the next header.

Sections start closed, apart from the first, until any of the module's sections is opened or
closed. The ones left open are remembered for each placed module in the profile
(ALiVE_edenOpenSections, "<mission>|<map>|<Eden entity ID>|<header text>"), so a module opens the way
it was last left.

Module attributes have no Eden categories of their own, so the rows are moved by script: rows of a
closed section are hidden, the rows below move up, and the module's category and the categories
under it shrink and move to match. When Eden's own category arrow is used the layout is put back
once Eden has redrawn.

Modes:
    "init"   [CONTROL arrow]           - the header's arrow onLoad: hooks the header and queues a layout
    "set"    [CONTROL header, BOOL]    - opens or closes one section and remembers it
    "layout" [DISPLAY]                 - places every row of every ALiVE module category in the window

Author:
Jman
---------------------------------------------------------------------------- */

params ["_mode", "_arg"];

#define SELF '\x\alive\addons\main\fnc_edenSectionCollapse.sqf'
#define PROFILE_VAR "ALiVE_edenOpenSections"

// a header's key in the profile: the placed module (mission, map and its Eden ID, which the mission
// saves) and the header's text. With several modules edited at once the first one counts
private _keyOf = {
    params ["_hdr"];
    private _k = _hdr getVariable ["alive_secKey", ""];
    if (_k isEqualTo "") then {
        private _ent = (get3DENSelected "Logic") param [0, objNull];
        _k = format ["%1|%2|%3|%4", missionName, worldName, get3DENEntityID _ent, ctrlText (_hdr controlsGroupCtrl 301)];
        _hdr setVariable ["alive_secKey", _k];
    };
    _k
};
// the placed module's marker in the profile: there once any of its sections has been opened or closed
private _touchedKey = {
    params ["_hdr"];
    private _parts = ([_hdr] call _keyOf) splitString "|";
    format ["%1|%2|%3|*", _parts param [0, ""], _parts param [1, ""], _parts param [2, ""]]
};

// one layout per batch of events, once Eden has finished drawing
private _queue = {
    params ["_display"];
    if (isNull _display || {_display getVariable ["alive_secQueued", false]}) exitWith {};
    _display setVariable ["alive_secQueued", true];
    [_display] spawn {
        params ["_display"];
        uiSleep 0.02;
        if (isNull _display) exitWith {};
        _display setVariable ["alive_secQueued", false];
        ["layout", _display] call compile preprocessFileLineNumbers SELF;
    };
};

// a control's place when first seen, before anything was moved
private _keep = {
    params ["_c"];
    if (isNil { _c getVariable "alive_y0" }) then {
        private _p = ctrlPosition _c;
        _c setVariable ["alive_y0", _p select 1];
        _c setVariable ["alive_h0", _p select 3];
    };
};

// sets one of a control's x, y, w, h and keeps the rest: ctrlSetPositionY / ctrlSetPositionH reset the
// height to 1 in Eden's attributes window, measured
private _place = {
    params ["_c", "_i", "_v"];
    private _p = ctrlPosition _c;
    _p set [_i, _v];
    _c ctrlSetPosition _p;
};

// the direct children of a controls group, top to bottom by their first place
private _children = {
    params ["_display", "_grp", "_filter"];
    private _list = (allControls _display) select { (ctrlParentControlsGroup _x) isEqualTo _grp && _filter };
    { [_x] call _keep } forEach _list;
    private _order = [];
    { _order pushBack [_x getVariable "alive_y0", _forEachIndex] } forEach _list;
    _order sort true;
    _order apply { _list select (_x select 1) }
};

switch (_mode) do {

    case "init": {
        private _arrow = _arg;
        private _hdr = ctrlParentControlsGroup _arrow;
        if (isNull _hdr || {_hdr getVariable ["alive_secHdr", false]}) exitWith {};
        _hdr setVariable ["alive_secHdr", true];
        // closed until the first layout reads the profile; set first so the echo below saves nothing
        _hdr setVariable ["alive_secOpen", false];
        _arrow cbSetChecked false;

        _arrow ctrlAddEventHandler ["CheckedChanged", {
            params ["_ctrl", "_checked"];
            ["set", [ctrlParentControlsGroup _ctrl, _checked isEqualTo 1]] call compile preprocessFileLineNumbers SELF;
        }];
        private _hit = _hdr controlsGroupCtrl 302;
        _hit ctrlAddEventHandler ["ButtonClick", {
            params ["_ctrl"];
            private _hdr = ctrlParentControlsGroup _ctrl;
            ["set", [_hdr, !(_hdr getVariable ["alive_secOpen", false])]] call compile preprocessFileLineNumbers SELF;
        }];
        _hit ctrlAddEventHandler ["MouseEnter", { ((ctrlParentControlsGroup (_this select 0)) controlsGroupCtrl 301) ctrlSetTextColor [1,1,1,1] }];
        _hit ctrlAddEventHandler ["MouseExit", {
            private _hdr = ctrlParentControlsGroup (_this select 0);
            (_hdr controlsGroupCtrl 301) ctrlSetTextColor [1,1,1,[0.55, 0.9] select (_hdr getVariable ["alive_secOpen", false])];
        }];

        [ctrlParent _arrow] call _queue;
    };

    case "set": {
        _arg params ["_hdr", "_open"];
        // cbSetChecked below can raise CheckedChanged again with the same state; that echo stops here
        if (isNull _hdr || {(_hdr getVariable ["alive_secOpen", -1]) isEqualTo _open}) exitWith {};
        _hdr setVariable ["alive_secOpen", _open];
        (_hdr controlsGroupCtrl 303) cbSetChecked _open;
        (_hdr controlsGroupCtrl 301) ctrlSetTextColor [1,1,1,[0.55, 0.9] select _open];

        private _key = [_hdr] call _keyOf;
        private _list = +(profileNamespace getVariable [PROFILE_VAR, []]);
        private _touched = [_hdr] call _touchedKey;
        _list = _list - [_key, _touched];
        if (_open) then { _list pushBack _key };
        _list pushBack _touched;
        // one section open at a time: opening one closes the module's other open sections, unless
        // the player chose to leave them open (CBA Addon Options > ALiVE > Eden Editor)
        if (_open && {missionNamespace getVariable ["ALiVE_edenSectionsCloseOthers", true]}) then {
            {
                if (!(_x isEqualTo _hdr) && {_x getVariable ["alive_secOpen", false]}) then {
                    _x setVariable ["alive_secOpen", false];
                    (_x controlsGroupCtrl 303) cbSetChecked false;
                    (_x controlsGroupCtrl 301) ctrlSetTextColor [1,1,1,0.55];
                    _list = _list - [[_x] call _keyOf];
                };
            } forEach ((allControls (ctrlParent _hdr)) select { _x getVariable ["alive_secHdr", false] });
        };
        if (count _list > 2000) then { _list deleteRange [0, count _list - 2000] };
        profileNamespace setVariable [PROFILE_VAR, _list];
        saveProfileNamespace;

        [ctrlParent _hdr] call _queue;
    };

    case "layout": {
        private _display = _arg;
        // a header with no text is a spacer some modules use to leave a gap inside a section
        // (displayName " "): an ordinary row of the section above it, with no arrow and no click
        {
            if (_x getVariable ["alive_secHdr", false] && {((ctrlText (_x controlsGroupCtrl 301)) trim [" ", 0]) isEqualTo ""}) then {
                _x setVariable ["alive_secHdr", false];
                _x setVariable ["alive_secSpacer", true];
                (_x controlsGroupCtrl 302) ctrlShow false;
                (_x controlsGroupCtrl 303) ctrlShow false;
                (_x controlsGroupCtrl 304) ctrlShow false;
                (_x controlsGroupCtrl 305) ctrlShow false;
                (_x controlsGroupCtrl 306) ctrlShow false;
            };
        } forEach (allControls _display);
        private _hdrs = (allControls _display) select { _x getVariable ["alive_secHdr", false] };
        if (_hdrs isEqualTo []) exitWith {};

        // first layout: open what the profile says was left open. A module none of whose sections has
        // been opened or closed yet opens as the player chose in Addon Options (ALiVE > Eden Editor):
        // its first section (the default), all of them, or none
        private _remembered = profileNamespace getVariable [PROFILE_VAR, []];
        private _firstMode = missionNamespace getVariable ["ALiVE_edenSectionsFirstOpen", "first"];
        private _firstHdr = controlNull;
        {
            if (isNull _firstHdr || {((ctrlPosition _x) select 1) < ((ctrlPosition _firstHdr) select 1)}) then { _firstHdr = _x };
        } forEach _hdrs;
        {
            if !(_x getVariable ["alive_secLoaded", false]) then {
                _x setVariable ["alive_secLoaded", true];
                private _open = (([_x] call _keyOf) in _remembered)
                    || {!(([_x] call _touchedKey) in _remembered) && {(_firstMode == "all") || {(_firstMode == "first") && {_x isEqualTo _firstHdr}}}};
                _x setVariable ["alive_secOpen", _open];
                (_x controlsGroupCtrl 303) cbSetChecked _open;
                (_x controlsGroupCtrl 301) ctrlSetTextColor [1,1,1,[0.55, 0.9] select _open];
            };
        } forEach _hdrs;



        {
            private _attrs = _x;
            // the setting rows are controls groups; the logo below sits beside them and isn't one
            private _rows = [_display, _attrs, {ctrlType _x == 15}] call _children;
            if (_rows isEqualTo []) then { continue };
            private _top = (_rows select 0) getVariable "alive_y0";
            // the ALiVE logo above the module's settings, made once per window, unless the player
            // turned it off in Addon Options (ALiVE > Eden Editor)
            private _showLogo = missionNamespace getVariable ["ALiVE_edenShowLogo", true];
            private _logo = _attrs getVariable ["alive_secLogo", controlNull];
            if (_showLogo && {isNull _logo}) then {
                _logo = _display ctrlCreate ["ctrlStaticPictureKeepAspect", -1, _attrs];
                _logo ctrlSetText "\x\alive\addons\ui\logo_alive_white_crop.paa";
                _logo ctrlSetTextColor [1, 1, 1, 0.6];
                // the logo at the left, lined up with the section headers' text; it is four times as
                // wide as it is tall
                private _lh = 8 * (pixelH * pixelGrid * 0.50);
                _logo ctrlSetPosition [3 * (pixelW * pixelGrid * 0.50), _top + 3 * (pixelH * pixelGrid * 0.50), 4 * _lh * pixelW / pixelH, _lh];
                _logo ctrlCommit 0;
                _attrs setVariable ["alive_secLogo", _logo];
                // the module's own icon at the left of the logo row, as Eden's asset list shows it
                private _ent = (get3DENSelected "Logic") param [0, objNull];
                private _icon = getText (configFile >> "CfgVehicles" >> typeOf _ent >> "icon");
                // an icon given by name rather than path is looked up the way Eden does
                if (_icon != "" && {!("." in _icon)}) then { _icon = getText (configFile >> "CfgVehicleIcons" >> _icon) };
                // ALiVE's module icons are drawn dark; each has a light copy beside it (<icon>_light.paa)
                // that shows on Eden's dark background
                if (_icon != "") then {
                    if ((_icon select [0, 1]) != (toString [92])) then { _icon = (toString [92]) + _icon };
                    private _light = (_icon select [0, count _icon - 4]) + "_light.paa";
                    if (fileExists _light) then { _icon = _light };
                };
                private _lp = ctrlPosition _logo;
                // the icon is square, as tall as the logo
                private _iw = (_lp select 3) * pixelW / pixelH;
                // the right side of the logo row, level with the end of the section header bands (a
                // setting row is 130 grid units wide from its own left edge)
                private _right = ((ctrlPosition (_rows select 0)) select 0) + 130 * (pixelW * pixelGrid * 0.50);
                if (_icon != "") then {
                    private _pic = _display ctrlCreate ["ctrlStaticPictureKeepAspect", -1, _attrs];
                    _pic ctrlSetText _icon;
                    _pic ctrlSetTextColor [1, 1, 1, 0.8];
                    _pic ctrlSetPosition [_right - _iw, _lp select 1, _iw, _lp select 3];
                    _pic ctrlCommit 0;
                    _right = _right - _iw - 3 * (pixelW * pixelGrid * 0.50);
                };
                // a help button just left of the module's icon that opens the module's page on the
                // docs site; none for a module with no page. The address goes on the button now: a
                // link only opens from a click on a control already holding it (fnc_presetNeeds)
                private _url = [typeOf _ent] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenDocsPage.sqf';
                if (_url != "") then {
                    private _help = _display ctrlCreate ["ctrlButtonToolbar", -1, _attrs];
                    // the circled question mark of the map's Unknown marker
                    _help ctrlSetText "\a3\ui_f\data\map\markers\military\unknown_ca.paa";
                    _help ctrlSetTextColor [1, 1, 1, 0.8];
                    _help ctrlSetTooltip (if (isLocalized "STR_ALIVE_EDEN_DOCS") then { localize "STR_ALIVE_EDEN_DOCS" } else { "Open the online docs for this module" });
                    _help ctrlSetURL _url;
                    // a little smaller than the icon, centred on its row and nudged down 3 pixels to line up with it
                    private _hh = 0.75 * (_lp select 3);
                    private _hw = _hh * pixelW / pixelH;
                    _help ctrlSetPosition [_right - _hw - ((_iw - _hw) / 2), (_lp select 1) + ((_lp select 3) - _hh) / 2 + 3 * pixelH, _hw, _hh];
                    _help ctrlCommit 0;
                };
            };
            // the logo with 3 grid units of space above and below it
            private _cursor = if (isNull _logo) then { _top } else { _top + ((ctrlPosition _logo) select 3) + 6 * (pixelH * pixelGrid * 0.50) };
            // Eden's gap between two settings, the smallest seen; each row then takes its own
            // height plus that gap, so a picker that shrank itself (fnc_edenPickerCutRows) leaves no hole
            private _gap = 1e9;
            for "_i" from 0 to (count _rows - 2) do {
                private _a = _rows select _i;
                _gap = _gap min ((((_rows select (_i + 1)) getVariable "alive_y0") - ((_a getVariable "alive_y0") + (_a getVariable "alive_h0"))) max 0);
            };
            if (_gap > 1) then { _gap = 0 };
            private _show = true;
            {
                private _y0 = _x getVariable "alive_y0";
                private _step = (_x getVariable "alive_h0") + _gap;
                if (_x getVariable ["alive_secHdr", false]) then { _show = _x getVariable ["alive_secOpen", false] };
                // Eden's module description at the foot (ModuleInfo: a scrolling group 101 holding
                // structured text 100) belongs to no section and always shows
                private _info = _x controlsGroupCtrl 101;
                if (!isNull _info && {ctrlType _info == 15} && {ctrlType (_info controlsGroupCtrl 100) == 13}) then { _show = true };
                if (_show || {_x getVariable ["alive_secHdr", false]}) then {
                    if (_x getVariable ["alive_secHidden", false]) then {
                        _x setVariable ["alive_secHidden", false];
                        _x ctrlShow true;
                        // showing a controls group shows everything in it: hide again what was hidden
                        { _x ctrlShow false } forEach (_x getVariable ["alive_secInnerHidden", []]);
                    };
                    [_x, 1, _cursor] call _place;
                    _x ctrlCommit 0;
                    _cursor = _cursor + _step;
                } else {
                    if !(_x getVariable ["alive_secHidden", false]) then {
                        private _row = _x;
                        _row setVariable ["alive_secInnerHidden", (allControls _display) select { (ctrlParentControlsGroup _x) isEqualTo _row && {!ctrlShown _x} }];
                        _row setVariable ["alive_secHidden", true];
                        _row ctrlShow false;
                        // moved up to the top, height kept: a hidden row left lower down still counts toward how far
                        // the settings can scroll, and they scrolled inside the window. Its height is never set to
                        // nothing: a row given its height back that way showed its space but drew none of its
                        // settings (Jman 15 Oct 2026)
                        [_row, 1, _top] call _place;
                        _row ctrlCommit 0;
                    };
                };
            } forEach _rows;

            // the module's category and its rows group fit the rows now shown, unless Eden has the
            // category folded with its own arrow (then Eden owns its size). Eden's own categories keep
            // Eden's layout: any below this one only move by the change in its height.
            private _cat = ctrlParentControlsGroup _attrs;
            if (!isNull _cat) then {
                private _minimize = (allControls _display) select { (ctrlParentControlsGroup _x) isEqualTo _cat && {ctrlType _x == 77} };
                private _folded = (_minimize isNotEqualTo []) && {!(cbChecked (_minimize select 0))};
                if (!_folded) then {
                    [_attrs, 3, _cursor] call _place;
                    _attrs ctrlCommit 0;
                    private _catPos = ctrlPosition _cat;
                    private _newH = ((ctrlPosition _attrs) select 1) + _cursor + pixelH;
                    private _delta = _newH - (_catPos select 3);
                    [_cat, 3, _newH] call _place;
                    _cat ctrlCommit 0;
                    if (abs _delta > 0.0001) then {
                        private _root = ctrlParentControlsGroup _cat;
                        {
                            if ((ctrlParentControlsGroup _x) isEqualTo _root && {!(_x isEqualTo _cat)} && {((ctrlPosition _x) select 1) > (_catPos select 1)}) then {
                                [_x, 1, ((ctrlPosition _x) select 1) + _delta] call _place;
                                _x ctrlCommit 0;
                            };
                        } forEach (allControls _display);
                    };
                };
            };
        } forEach ((_hdrs apply { ctrlParentControlsGroup _x }) arrayIntersect (_hdrs apply { ctrlParentControlsGroup _x }));

        // Eden redraws the categories below one that is folded or opened with its own arrow, which can
        // put back an ALiVE category's old height; fit it again afterwards. Eden's layout is left alone
        {
            if (ctrlType _x == 77 && {(ctrlParentControlsGroup (ctrlParentControlsGroup _x)) isEqualTo (_display displayCtrl 201)} && {!(_x getVariable ["alive_secHooked", false])}) then {
                _x setVariable ["alive_secHooked", true];
                _x ctrlAddEventHandler ["CheckedChanged", {
                    ["queue", ctrlParent (_this select 0)] call compile preprocessFileLineNumbers SELF;
                }];
            };
        } forEach (allControls _display);

    };

    case "queue": {
        [_arg] call _queue;
    };
};
