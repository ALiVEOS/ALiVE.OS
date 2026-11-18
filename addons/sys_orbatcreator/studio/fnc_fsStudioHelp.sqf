#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsStudioHelp);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsStudioHelp

Description:
The help window: a few short steps for the tab on show, what its buttons do,
and where the full guide is. The text is in the stringtable
(STR_ALIVE_FS_HELP_<TAB>_<n>), so it can be translated. It is as tall as the
text of its tab, and scrolls only when that is taller than the screen. It drags
by its title and opens where it was last put (the helpPos pref).

    - "open": opens it for the current tab (or refreshes it when it is open), as a
      panel inside the studio display;
    - "toggle": the ? button, opens it or closes it;
    - "tabShown": a tab came on show. An open window follows it; a closed one opens
      by itself the first time this player sees that tab (the helpTabs pref), unless
      they ticked "Don't show help automatically" (the helpSeen pref);
    - "dragStart" / "drag" / "dragEnd": moving it by its title, always whole on screen;
    - "noshow": the tick box, stored in the prefs;
    - "close".

Parameters:
    _op   - STRING - the event
    _args - ARRAY - the event arguments

Returns:
    Nothing

Examples:
    (begin example)
    ["open"] call ALiVE_fnc_fsStudioHelp;
    (end)

Author:
    Jman
---------------------------------------------------------------------------- */

#include "\x\alive\addons\sys_orbatcreator\fs_defines.hpp"
#include "\x\alive\addons\sys_orbatcreator\data\ui\studio\idc.hpp"

disableSerialization;

params [["_op", "open", [""]], ["_args", []]];

private _session = missionNamespace getVariable "ALiVE_FS_session";
if (isNil "_session") exitWith {};
private _studio = findDisplay FS_IDD_STUDIO;
// a panel inside the studio display (the engine stops drawing the studio under any display on top of it)
private _panel = if (isNull _studio) then { controlNull } else { _studio displayCtrl FS_IDD_HELP };
private _part = { _panel controlsGroupCtrl _this };

// lines per tab: keep in step with the stringtable
private _lines = createHashMapFromArray [["faction", 5], ["units", 7], ["vehicles", 5], ["groups", 5], ["alive", 5], ["export", 6]];

// the tabs whose help this player has had, kept in the profile
private _seenTabs = {
    private _seen = ["prefGet", ["helpTabs", []]] call ALiVE_fnc_fsDataStore;
    if (_seen isEqualType []) then { _seen } else { [] }
};

switch (_op) do {
    case "toggle": {
        if (isNull _panel) exitWith { ["open"] call ALiVE_fnc_fsStudioHelp };
        // hidden means Close has run and the panel goes on the next frame
        if (ctrlShown _panel) then { ["close"] call ALiVE_fnc_fsStudioHelp };
    };

    case "tabShown": {
        if (isNull _studio) exitWith {};
        if (!isNull _panel) exitWith { if (ctrlShown _panel) then { ["open"] call ALiVE_fnc_fsStudioHelp } };
        if (["prefGet", ["helpSeen", false]] call ALiVE_fnc_fsDataStore) exitWith {};
        if !((_session getOrDefault ["tab", "faction"]) in (call _seenTabs)) then { ["open"] call ALiVE_fnc_fsStudioHelp };
    };

    case "open": {
        if (isNull _studio) exitWith {};
        private _isNew = isNull _panel;
        if (isNull _panel) then {
            _panel = _studio ctrlCreate ["ALiVE_FS_HelpPanel", FS_IDD_HELP];
            // dragging: the title starts it, the studio's own mouse events move and drop it
            _session set ["helpEh", [
                _studio displayAddEventHandler ["MouseMoving", { ["drag"] call ALiVE_fnc_fsStudioHelp }],
                _studio displayAddEventHandler ["MouseButtonUp", { ["dragEnd"] call ALiVE_fnc_fsStudioHelp }]
            ]];
        };
        if (isNull _panel) exitWith {};
        private _tab = _session getOrDefault ["tab", "faction"];
        if !(_tab in _lines) then { _tab = "faction" };
        private _seen = call _seenTabs;
        if !(_tab in _seen) then { ["prefSet", ["helpTabs", _seen + [_tab]]] call ALiVE_fnc_fsDataStore };
        private _upper = toUpper _tab;
        (FS_IDC_HL_TITLE call _part) ctrlSetText format [localize "STR_ALIVE_FS_HELP_TITLE", localize ("STR_ALIVE_FS_TAB_" + _upper)];
        private _safe = { ((_this regexReplace ["&", "&amp;"]) regexReplace ["<", "&lt;"]) regexReplace [">", "&gt;"] };
        private _parts = [];
        for "_i" from 1 to (_lines get _tab) do {
            _parts pushBack format ["%1. %2", _i, (localize format ["STR_ALIVE_FS_HELP_%1_%2", _upper, _i]) call _safe];
        };
        // the preview's mouse controls are the same on every tab
        _parts pushBack ((localize "STR_ALIVE_FS_HELP_PREVIEW") call _safe);
        _parts pushBack format ["<t color='#B0B0B0'>%1</t>", (localize "STR_ALIVE_FS_HELP_DOCS") call _safe];
        private _group = FS_IDC_HL_GROUP call _part;
        private _text = _group controlsGroupCtrl FS_IDC_HL_TEXT;
        _text ctrlSetStructuredText parseText format ["<t size='1'>%1</t>", _parts joinString "<br/><br/>"];
        // The window fits the text: 1.3 cells above the body and 2.3 below it (the tick and Close), with half a
        // cell clear of the screen edges. Only a text taller than that keeps the body's scrollbar.
        private _cell = (((safezoneW / safezoneH) min 1.2) / 1.2) / 25;
        private _textH = ctrlTextHeight _text;
        private _bodyH = ((_textH + 2 * pixelH) min (safezoneH - 4.6 * _cell)) max (4 * _cell);
        _text ctrlSetPositionH (_textH max _bodyH);
        _text ctrlCommit 0;
        _group ctrlSetPositionH _bodyH;
        _group ctrlCommit 0;
        private _footY = (1.3 * _cell) + _bodyH;
        { (_x select 0 call _part) ctrlSetPositionY (_footY + (_x select 1)); (_x select 0 call _part) ctrlCommit 0 } forEach [
            [FS_IDC_HL_NOSHOW, 0.2 * _cell], [FS_IDC_HL_LABEL, 0.2 * _cell], [FS_IDC_HL_CLOSE, 1.2 * _cell]
        ];
        private _panelH = _footY + 2.3 * _cell;
        (FS_IDC_HL_BACK call _part) ctrlSetPositionH _panelH;
        (FS_IDC_HL_BACK call _part) ctrlCommit 0;
        // where the player last put it, or centred at the right; whole on screen either way
        (ctrlPosition _panel) params ["_panelX", "", "_panelW"];
        private _panelY = safezoneY + (safezoneH - _panelH) / 2;
        private _saved = ["prefGet", ["helpPos", []]] call ALiVE_fnc_fsDataStore;
        if (_saved isEqualTypeArray [0, 0]) then { _saved params ["_savedX", "_savedY"]; _panelX = _savedX; _panelY = _savedY };
        _panelX = (_panelX max safezoneX) min (safezoneX + safezoneW - _panelW);
        _panelY = (_panelY max safezoneY) min (safezoneY + safezoneH - _panelH);
        _panel ctrlSetPosition [_panelX, _panelY, _panelW, _panelH];
        _panel ctrlCommit 0;
        (FS_IDC_HL_NOSHOW call _part) cbSetChecked (["prefGet", ["helpSeen", false]] call ALiVE_fnc_fsDataStore);
        // only when it opens: a tab change keeps the keyboard where the player has it
        if (_isNew) then { ctrlSetFocus (FS_IDC_HL_CLOSE call _part) };
    };

    case "dragStart": {
        _args params [["_c", controlNull], ["_button", 0]];
        if (_button != 0 || {isNull _panel}) exitWith {};
        getMousePosition params ["_mx", "_my"];
        (ctrlPosition _panel) params ["_px", "_py"];
        _session set ["helpDrag", [_mx - _px, _my - _py]];
    };

    case "drag": {
        private _drag = _session getOrDefault ["helpDrag", []];
        if (_drag isEqualTo [] || {isNull _panel}) exitWith {};
        // let go somewhere that reported no release: the window stays where it is
        if ((inputMouse 0) == 0) exitWith { ["dragEnd"] call ALiVE_fnc_fsStudioHelp };
        getMousePosition params ["_mx", "_my"];
        (ctrlPosition _panel) params ["", "", "_w", "_h"];
        private _nx = ((_mx - (_drag select 0)) max safezoneX) min (safezoneX + safezoneW - _w);
        private _ny = ((_my - (_drag select 1)) max safezoneY) min (safezoneY + safezoneH - _h);
        _panel ctrlSetPosition [_nx, _ny, _w, _h];
        _panel ctrlCommit 0;
    };

    case "dragEnd": {
        if ((_session getOrDefault ["helpDrag", []]) isEqualTo []) exitWith {};
        _session set ["helpDrag", []];
        if (isNull _panel) exitWith {};
        (ctrlPosition _panel) params ["_px", "_py"];
        ["prefSet", ["helpPos", [_px, _py]]] call ALiVE_fnc_fsDataStore;
    };

    case "noshow": {
        _args params [["_c", controlNull], ["_state", 0]];
        ["prefSet", ["helpSeen", _state isEqualTo 1 || {_state isEqualTo true}]] call ALiVE_fnc_fsDataStore;
    };

    case "close": {
        { _studio displayRemoveEventHandler _x } forEach ([["MouseMoving", "MouseButtonUp"], _session getOrDefault ["helpEh", [-1, -1]]] call {
            params ["_names", "_ids"]; private _out = []; { if (_x >= 0) then { _out pushBack [_names select _forEachIndex, _x] } } forEach _ids; _out
        });
        _session set ["helpEh", []];
        _session set ["helpDrag", []];
        // deleted a frame later: Close is a button inside the panel, and a control is not deleted from its own event
        if (!isNull _panel) then { _panel ctrlShow false; [_panel] spawn { disableSerialization; ctrlDelete (_this select 0) } };
    };
};
