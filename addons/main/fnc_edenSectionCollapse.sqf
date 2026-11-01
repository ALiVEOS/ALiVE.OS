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

A setting or header can carry show/hide rules in its config, read here on every layout:
    ALiVE_showWhen[]    = {{"controlType", "is", "invasion"}, ...};   all of them must hold
    ALiVE_showWhenAny[] = {{"gameMode", "is", {"outbreak", "hunt"}}};  any one is enough
A condition is {setting, test, value}. The setting is another attribute class of the same module, or
"@<module class>/<attribute class>" for the first such module in the mission. Tests: "is" and "not"
(the value or any of a list of values), ">" and "<" (numbers), "filled" and "empty" (brackets, quotes,
commas and spaces don't count), "has" (contains). Values compare as lower-case text. A condition on a
setting that is itself hidden by its rules is false, whatever the test. A rule on a section header
covers every setting under it. A header whose rows are all hidden by rules hides too. A setting with
ALiVE_showStyle = "dim" greys out instead of hiding (an override, or a value that can still be
switched on during play). Rows are matched to their settings by order (Eden makes them in config
order, checked against the row titles); if they can't be matched, no rule applies to that module.
CBA Addon Options > ALiVE > Eden Editor picks Hide (the default), Grey out or Show all.

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
        // unscheduled, so a change hook firing mid-layout can't run a second layout in between
        isNil { ["layout", _display] call compile preprocessFileLineNumbers SELF };
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

// the show/hide rules for one module's rows (see the header). Marks each row with rules alive_rowOff,
// and each header whose rows are all hidden by rules alive_hdrEmpty; hooks the settings the rules read
private _fnc_rules = {
    params ["_display", "_attrs", "_rows"];
    private _mode = missionNamespace getVariable ["ALiVE_edenRuleMode", "hide"];
    private _sel = get3DENSelected "Logic";
    private _cls = typeOf (_sel param [0, objNull]);

    // rows matched to their settings once per window: attribute class (lower case) -> [row, config]
    private _byName = _attrs getVariable "alive_ruleRows";
    if (!isNil "_byName" && {count _byName > 0} && {(values _byName) findIf { isNull (_x select 0) } >= 0}) then { _byName = nil };
    if (isNil "_byName" && {_cls != ""}) then {
        _byName = createHashMap;
        _attrs setVariable ["alive_ruleRows", _byName];
        if (_sel findIf { typeOf _x != _cls } >= 0) exitWith {};
        private _cfgs = configProperties [configFile >> "CfgVehicles" >> _cls >> "Attributes", "isClass _x && {getText (_x >> 'property') != '' || {configName _x == 'ModuleDescription'}}", true];
        if (_cfgs findIf { isArray (_x >> "ALiVE_showWhen") || {isArray (_x >> "ALiVE_showWhenAny")} } < 0) exitWith {};
        private _made = (allControls _display) select { (ctrlParentControlsGroup _x) isEqualTo _attrs && {ctrlType _x == 15} };
        if (count _made != count _cfgs) exitWith {
            diag_log format ["ALiVE Eden rules: %1 has %2 rows for %3 settings, rules off", _cls, count _made, count _cfgs];
        };
        // each row's title: the first text in it (a control's str isn't unique, so rows are numbered)
        private _title = _made apply { "" };
        { _x setVariable ["alive_ruleIx", _forEachIndex] } forEach _made;
        {
            private _i = (ctrlParentControlsGroup _x) getVariable ["alive_ruleIx", -1];
            if (_i >= 0 && {ctrlType _x in [0, 13]} && {ctrlText _x != ""} && {(_title select _i) == ""}) then { _title set [_i, ctrlText _x] };
        } forEach (allControls _display);
        private _miss = 0;
        private _named = 0;
        {
            private _dn = getText ((_cfgs select _forEachIndex) >> "displayName");
            if ((_dn select [0, 1]) == "$") then { _dn = localize (_dn select [1]) };
            _dn = _dn trim [": ", 2];
            if (_dn != "") then {
                _named = _named + 1;
                if (((_title select _forEachIndex) trim [": ", 2]) != _dn) then { _miss = _miss + 1 };
            };
        } forEach _made;
        // a picker that writes its own title can differ; more than that and the order can't be trusted
        if (_miss > (2 max (_named / 10))) exitWith {
            diag_log format ["ALiVE Eden rules: %1 rows don't match their settings (%2 of %3), rules off", _cls, _miss, _named];
        };
        // each setting with the section header above it (a header with no text is a spacer, not a section)
        private _hdrKey = "";
        {
            private _c = _cfgs select _forEachIndex;
            private _k = toLower configName _c;
            // Eden's module description at the foot belongs to no section
            if (configName _c == "ModuleDescription") then { _byName set [_k, [_x, _c, ""]]; continue };
            if (getText (_c >> "control") == "ALiVE_ModuleSubTitle" && {((getText (_c >> "displayName")) trim [" ", 0]) != ""}) then {
                _hdrKey = _k;
                _byName set [_k, [_x, _c, ""]];
            } else {
                _byName set [_k, [_x, _c, _hdrKey]];
            };
        } forEach _made;
    };
    if (isNil "_byName" || {count _byName == 0}) exitWith {};

    // a setting's value as lower-case text: what its row would save (a picker may put its own in
    // alive_ruleValue). -2 when several modules are selected, their saved values differ and the row
    // still shows no choice of its own
    private _fnc_value = {
        params ["_key"];
        (_byName get _key) params ["_row", "_cfg"];
        private _v = _row getVariable "alive_ruleValue";
        if (isNil "_v") then {
            private _ctrl = getText (_cfg >> "control");
            private _saves = missionNamespace getVariable ["ALiVE_edenRuleSaves", createHashMap];
            missionNamespace setVariable ["ALiVE_edenRuleSaves", _saves];
            private _code = _saves getOrDefault [_ctrl, {}];
            if (_code isEqualTo {}) then {
                private _txt = getText (configFile >> "Cfg3DEN" >> "Attributes" >> _ctrl >> "attributeSave");
                _code = if (_txt == "") then { {""} } else { compile _txt };
                _saves set [_ctrl, _code];
            };
            // the control's own save code reads the attribute's config as _config; it runs in a scope of
            // its own, so a variable it sets can't change this script's
            _v = [_row, _cfg, _code] call {
                params ["_ctrlRow", "_config", "_saveCode"];
                private ["_mode", "_v", "_cfg", "_row", "_key", "_sel", "_cls", "_byName", "_display", "_attrs", "_rows", "_cursor", "_gap", "_top", "_logo", "_show", "_hdrOff", "_on", "_value", "_ctrl", "_code", "_txt"];
                _ctrlRow call _saveCode
            };
        };
        if (isNil "_v") then { _v = "" };
        _v = toLower (if (_v isEqualType "") then { _v } else { str _v });
        if (_v == "" && {count _sel > 1}) then {
            private _prop = getText (_cfg >> "property");
            private _vals = _sel apply { str ((_x get3DENAttribute _prop) param [0, ""]) };
            if (count (_vals arrayIntersect _vals) > 1) then { _v = -2 };
        };
        _v
    };

    private _vis = createHashMap;
    private _fnc_visible = {};
    // one condition: {setting, test, value}
    private _fnc_cond = {
        params [["_name", "", [""]], ["_test", "is", [""]], ["_want", ""]];
        private _v = call {
            if ((_name select [0, 1]) == "@") exitWith {
                // another module's setting: the first module of that class in the mission
                ((_name select [1]) splitString "/") params [["_mc", ""], ["_ac", ""]];
                private _ent = ((all3DENEntities select 3) select { typeOf _x == _mc }) param [0, objNull];
                if (isNull _ent) exitWith { "" };
                private _r = (_ent get3DENAttribute (getText (configFile >> "CfgVehicles" >> _mc >> "Attributes" >> _ac >> "property"))) param [0, ""];
                toLower (if (_r isEqualType "") then { _r } else { str _r })
            };
            private _k = toLower _name;
            if !(_k in _byName) exitWith { -1 };
            if !([_k] call _fnc_visible) exitWith { -1 };
            [_k] call _fnc_value
        };
        // not this module's setting, or hidden by its own rules: false. Values differing across the
        // selected modules: true, so nothing that might apply is hidden
        if (_v isEqualTo -1) exitWith { false };
        if (_v isEqualTo -2) exitWith { true };
        private _wants = (if (_want isEqualType []) then { _want } else { [_want] }) apply { toLower (if (_x isEqualType "") then { _x } else { str _x }) };
        private _filled = (_v splitString ("[], '" + toString [34])) isNotEqualTo [];
        switch (toLower _test) do {
            case "is": { _v in _wants };
            case "not": { !(_v in _wants) };
            case ">": { (parseNumber _v) > (parseNumber (_wants param [0, "0"])) };
            case "<": { (parseNumber _v) < (parseNumber (_wants param [0, "0"])) };
            case "filled": { _filled };
            case "empty": { !_filled };
            case "has": { (_wants findIf { (_v find _x) >= 0 }) >= 0 };
            default { true };
        }
    };
    _fnc_visible = {
        params ["_key"];
        if (_key in _vis) exitWith { _vis get _key };
        // a loop of rules settles as shown
        _vis set [_key, true];
        (_byName get _key) params ["", "_cfg", ["_hk", ""]];
        private _all = getArray (_cfg >> "ALiVE_showWhen");
        private _any = getArray (_cfg >> "ALiVE_showWhenAny");
        private _ok = ((_all findIf { !(_x call _fnc_cond) }) < 0) && {_any isEqualTo [] || {(_any findIf { _x call _fnc_cond }) >= 0}}
            && {_hk == "" || {[_hk] call _fnc_visible}};
        _vis set [_key, _ok];
        _ok
    };

    private _fnc_ruleList = { (getArray (_this >> "ALiVE_showWhen")) + (getArray (_this >> "ALiVE_showWhenAny")) };
    private _controllers = [];
    {
        _y params ["_row", "_cfg", ["_hk", ""]];
        private _rules = _cfg call _fnc_ruleList;
        { _controllers pushBackUnique (toLower (_x param [0, ""])) } forEach _rules;
        // a row of a section whose header has rules follows them as well
        if (_rules isNotEqualTo [] || {_hk != "" && {(((_byName get _hk) select 1) call _fnc_ruleList) isNotEqualTo []}}) then {
            private _on = [_x] call _fnc_visible;
            // Grey out: the row stays, faded; Show all: the rules are ignored. A row whose own rules
            // say dim greys out in Hide too; a row hidden by its header's rules goes with the header
            private _dim = (_mode == "dim") || {(_mode == "hide") && {getText (_cfg >> "ALiVE_showStyle") == "dim"} && {_hk == "" || {[_hk] call _fnc_visible}}};
            _row setVariable ["alive_rowOff", (_mode == "hide") && {!_on} && {!_dim}];
            _row ctrlSetFade ([0, 0.6] select (_dim && {!_on}));
            _row ctrlCommit 0;
        };
    } forEach _byName;

    // a header with rows, all of them hidden by rules, hides too
    private _hdr = controlNull;
    private _seen = 0;
    private _off = 0;
    private _fnc_close = {
        if (!isNull _hdr) then { _hdr setVariable ["alive_hdrEmpty", (_seen > 0) && {_seen == _off}] };
    };
    {
        if (_x getVariable ["alive_secHdr", false]) then {
            call _fnc_close;
            _hdr = _x;
            _seen = 0;
            _off = 0;
        } else {
            // Eden's module description at the foot is no setting of the section above it
            private _info = _x controlsGroupCtrl 101;
            if (!(_x getVariable ["alive_secSpacer", false]) && {isNull _info || {ctrlType _info != 15}}) then {
                _seen = _seen + 1;
                if (_x getVariable ["alive_rowOff", false]) then { _off = _off + 1 };
            };
        };
    } forEach _rows;
    call _fnc_close;

    // a change to a setting the rules read lays the window out again
    {
        private _pair = _byName getOrDefault [_x, []];
        if (_pair isNotEqualTo []) then {
            private _row = _pair select 0;
            if !(_row getVariable ["alive_ruleHooked", false]) then {
                _row setVariable ["alive_ruleHooked", true];
                {
                    private _c = _x;
                    private _p = ctrlParentControlsGroup _c;
                    private _in = false;
                    for "_i" from 1 to 4 do {
                        if (isNull _p) exitWith {};
                        if (_p isEqualTo _row) exitWith { _in = true };
                        _p = ctrlParentControlsGroup _p;
                    };
                    if (_in) then {
                        private _fn = { ["queue", ctrlParent (_this select 0)] call compile preprocessFileLineNumbers SELF };
                        switch (ctrlType _c) do {
                            case 4;
                            case 5: { _c ctrlAddEventHandler ["LBSelChanged", _fn] };
                            case 7;
                            case 77: { _c ctrlAddEventHandler ["CheckedChanged", _fn] };
                            case 2: { _c ctrlAddEventHandler ["KeyUp", _fn]; _c ctrlAddEventHandler ["KillFocus", _fn] };
                            case 6: { _c ctrlAddEventHandler ["ToolBoxSelChanged", _fn] };
                            case 3;
                            case 43: { _c ctrlAddEventHandler ["SliderPosChanged", _fn] };
                            case 1;
                            case 16: { _c ctrlAddEventHandler ["ButtonClick", _fn] };
                        };
                    };
                } forEach (allControls _display);
            };
        };
    } forEach _controllers;
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

            [_display, _attrs, _rows] call _fnc_rules;

            private _show = true;
            private _hdrOff = false;
            {
                private _y0 = _x getVariable "alive_y0";
                private _step = (_x getVariable "alive_h0") + _gap;
                if (_x getVariable ["alive_secHdr", false]) then {
                    _hdrOff = (_x getVariable ["alive_rowOff", false]) || {_x getVariable ["alive_hdrEmpty", false]};
                    _show = (_x getVariable ["alive_secOpen", false]) && {!_hdrOff};
                };
                // Eden's module description at the foot (ModuleInfo: a scrolling group 101 holding
                // structured text 100) belongs to no section and always shows
                private _info = _x controlsGroupCtrl 101;
                if (!isNull _info && {ctrlType _info == 15} && {ctrlType (_info controlsGroupCtrl 100) == 13}) then { _show = true };
                // a setting whose rules say it doesn't apply (alive_rowOff, e.g. Zombie Side outside Outbreak)
                // hides even in an open section; a header shows unless its rules or an empty section hide it
                private _on = if (_x getVariable ["alive_secHdr", false]) then { !_hdrOff } else { _show && {!(_x getVariable ["alive_rowOff", false])} };
                if (_on) then {
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
