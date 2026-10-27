#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(tabletOpen);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_tabletOpen
Description:
    Opens an ALiVE tablet dialog in this player's era (ALiVE_fnc_tabletEra):
    sets its frame artwork, gives each button on a painted key a short label
    (its full wording becomes the tooltip) in the era's font and text colour
    with a press sound, lays the era's glass over the screen, and on the wide
    Modern frame stretches the screen's controls sideways to fill the wider
    screen.

    The wide Modern frame is used only where the screen is wide enough for it;
    a 4:3 or 5:4 screen gets the 1160-wide Modern frame instead.

    Everything is done in one unscheduled block with createDialog, so a dialog
    whose onLoad spawns its own layout (Combat Support) always lays out after
    the stretch, never before it.

Parameters:
    0: STRING - dialog class: C2Tablet, SCOMTablet, GMTablet, PRTablet,
       RscDisplayALIVESITREP, RscDisplayALIVEPATROLREP, NEO_resourceRadio or
       MainTablet. Any other class is just opened.

Returns:
    DISPLAY - the opened tablet, or displayNull

Examples:
    (begin example)
    ["C2Tablet"] call ALiVE_fnc_tabletOpen;
    (end)

See Also:
    ALiVE_fnc_tabletEra, ALiVE_fnc_tabletBox, ALiVE_fnc_tabletFrameBox,
    addons/main/data/ui/gui_grid.hpp
Author:
    Jman
Peer Reviewed:
    nil
---------------------------------------------------------------------------- */

params [["_class", "", [""]]];

// dialog (lower case, as createDialog ignores case) -> [idd, frame picture idc, [[key slot, button idc, short label], ...]]
// key slots: 0..3 down the left (L1..L4), 4..7 down the right (R1..R4; R3 Back, R4 Close).
// A key shows a short label (STR_ALiVE_TABLET_KEY_*) and keeps the button's own wording as its tooltip.
private _tablets = createHashMapFromArray [
    ["c2tablet",                 [70001,  70002,  [[6, 70006, "BACK"], [7, 70010, "CLOSE"]]]],
    ["scomtablet",               [12001,  12002,  [[6, 12006, "BACK"], [7, 12010, "CLOSE"]]]],
    ["gmtablet",                 [11001,  11002,  [[6, 11006, "BACK"], [7, 11010, "CLOSE"]]]],
    ["prtablet",                 [60001,  60000,  [[4, 60003, "REQUEST"], [5, 60025, "STATUS"], [6, 60029, "BACK"], [7, 60004, "CLOSE"]]]],
    ["rscdisplayalivesitrep",    [90001,  90002,  [[4, 4, "SEND"], [6, 90010, "BACK"], [7, 3, "CANCEL"]]]],
    ["rscdisplayalivepatrolrep", [90002,  90003,  [[4, 4, "SEND"], [6, 90011, "BACK"], [7, 3, "CANCEL"]]]],
    ["neo_resourceradio",        [655555, 655556, [[4, 655625, "SITREP"], [6, 655598, "BACK"], [7, 655561, "CLOSE"]]]],
    ["maintablet",               [10001,  10099,  []]]
];

private _spec = _tablets getOrDefault [toLower _class, []];
if (_spec isEqualTo []) exitWith {
    createDialog _class;
    displayNull
};
_spec params ["_idd", "_frameIdc", "_keys"];

private _era = [] call ALiVE_fnc_tabletEra;
private _wideW = 0.99864 * safezoneH * 1368 / 1160;
private _wide = _era == "modern" && {safezoneW >= _wideW};
uiNamespace setVariable ["ALiVE_tabletWide", _wide];

// per era: the one typeface every text on the tablet uses (keys included, Jman 27 Oct), key text colour,
// key press sound; Close (R4) is painted red in every era
private _look = createHashMapFromArray [
    ["modern",  ["PuristaMedium",      [0.86, 0.88, 0.84, 1], "modern"]],
    ["coldwar", ["EtelkaMonospacePro", [0.92, 0.92, 0.86, 1], "coldwar"]],
    ["vietnam", ["EtelkaMonospacePro", [0.17, 0.15, 0.10, 1], "canvas"]],
    ["ww2",     ["LucidaConsoleB",     [0.20, 0.14, 0.08, 1], "canvas"]]
];
(_look get _era) params ["_font", "_colour", "_sound"];
private _art = [_era, "modern43"] select (_era == "modern" && !_wide);
private _texture = format ["\x\alive\addons\main\data\ui\ALiVE_tablet_%1_ca.paa", _art];
private _glass = format ["\x\alive\addons\main\data\ui\ALiVE_tablet_glass_%1_ca.paa", _art];
private _press = format ["playSoundUI ['\x\alive\addons\main\data\sounds\tablet_key_%1.wss', 0.6, 1]", _sound];

private _display = displayNull;
isNil {
    createDialog _class;
    _display = findDisplay _idd;
    if (isNull _display) exitWith {};

    ([_wide] call ALiVE_fnc_tabletFrameBox) params ["_fx", "_fy", "_fw", "_fh"];
    private _designW = [1160, 1368] select _wide;
    private _px = _fw / _designW;     // one design px, across
    private _py = _fh / 834;          // and down

    // the artwork carries a 40 px margin all round for the tablet's shadow
    private _frame = _display displayCtrl _frameIdc;
    _frame ctrlSetText _texture;
    _frame ctrlSetPosition [_fx - 40 * _px, _fy - 40 * _py, _fw + 80 * _px, _fh + 80 * _py];
    _frame ctrlCommit 0;

    private _keyIdcs = _keys apply { _x select 1 };

    if (_wide) then {
        // screen controls: stretched about the screen centre by the wide screen's extra width
        private _c = safezoneX + safezoneW / 2;
        private _k = 1148 / 940;
        {
            if (isNull ctrlParentControlsGroup _x && {!(ctrlIDC _x in _keyIdcs)} && {ctrlIDC _x != _frameIdc}) then {
                (ctrlPosition _x) params ["_x0", "_y0", "_w0", "_h0"];
                _x ctrlSetPosition [_c + (_x0 - _c) * _k, _y0, _w0 * _k, _h0];
                _x ctrlCommit 0;
            };
        } forEach (allControls _display);
    };

    // where each era paints its keys: inset from the frame's side and width, design px (the artwork's own tiles)
    (createHashMapFromArray [["modern", [16, 70]], ["coldwar", [16, 70]], ["vietnam", [26, 64]], ["ww2", [27, 62]]]
        get _era) params ["_keyIn", "_keyWd"];
    private _keyW = _keyWd * _px;
    private _fontH = 0.28 * (1.271710 * _fh / 25);
    // the one text size on the screen: 0.4 of a grid row in Purista, the typewriter faces scaled to match
    private _textH = 0.4 * (1.271710 * _fh / 25) * ([1, 0.82] select (_font != "PuristaMedium"));
    // one character's width across the screen, for a label's fit: about 0.6 of the font height in these
    // fonts, turned from screen height units into screen width units
    private _charW = 0.6 * _fontH * (safezoneW / safezoneH) / (getResolution select 4);
    private _labelled = [];
    {
        _x params ["_slot", "_idc", "_label"];
        private _ctrl = _display displayCtrl _idc;
        if (isNull _ctrl) then { continue };

        (ctrlPosition _ctrl) params ["", "_ky", "", "_kh"];
        _ctrl ctrlSetPosition [_fx + ([_keyIn, _designW - _keyIn - _keyWd] select (_slot > 3)) * _px, _ky, _keyW, _kh];
        _ctrl ctrlCommit 0;

        _ctrl ctrlSetTooltip (ctrlText _ctrl);
        private _text = toUpper localize format ["STR_ALiVE_TABLET_KEY_%1", _label];
        _ctrl ctrlSetText _text;
        _ctrl ctrlSetFont _font;
        _ctrl setVariable ["ALiVE_tabletFont", true];
        _ctrl ctrlSetTextColor ([_colour, [0.96, 0.90, 0.88, 1]] select (_slot == 7));
        _ctrl ctrlAddEventHandler ["ButtonDown", _press];

        // shrink a label that would not fit across the key
        private _textW = count _text * _charW;
        _ctrl ctrlSetFontHeight ([_fontH, (_fontH * _keyW * 0.8 / _textW) max (_fontH * 0.6)] select (_textW > _keyW * 0.8));
        _labelled pushBack [_ctrl, _text];
    } forEach _keys;

    // While the tablet is open, every frame:
    // - the keys keep their short label: the tablets set Back's wording again on every page ("Back", "Back to
    //   groups"), and whatever they set moves into the tooltip;
    // - every other button reads in capitals (pages set their own wording as they change);
    // - every text takes the era's typeface and one size, the same on every tablet (Jman 27 Oct), controls a
    //   page creates later included (once each). The typewriter faces run wider and taller than Purista, so
    //   they are set smaller to look the same size;
    // String == in SQF ignores case, so code comparing a button's wording still matches.
    addMissionEventHandler ["EachFrame", {
        _thisArgs params ["_display", "_labelled", "_font", "_textH", "_minW", "_pad", "_longW"];
        if (isNull _display) exitWith { removeMissionEventHandler ["EachFrame", _thisEventHandler] };
        private _keyCtrls = _labelled apply { _x select 0 };
        // Long bars (over 400 design px) are cut to their wording, keeping their left edge. Bars that share a column (same left edge and
        // width in the layout) all take the width of the longest wording among them, at least 260 design px, so a
        // stack of bars lines up (Jman 27 Oct). New bars a page adds are measured with the rest of their column.
        private _fresh = (allControls _display) select {
            ctrlType _x in [1, 16] && {!(_x in _keyCtrls)} && {!(_x getVariable ["ALiVE_tabletSized", false])}
        };
        if (_fresh isNotEqualTo []) then {
            private _cols = createHashMap;
            {
                private _col = _x getVariable ["ALiVE_tabletColumn", ""];
                if (_col isEqualTo "") then {
                    (ctrlPosition _x) params ["_bx", "", "_bw"];
                    _col = format ["%1|%2", _bx toFixed 4, _bw toFixed 4];
                    _x setVariable ["ALiVE_tabletColumn", _col];
                    _x setVariable ["ALiVE_tabletLayoutW", _bw];
                };
                (_cols getOrDefaultCall [_col, { [] }, true]) pushBack _x;
            } forEach ((allControls _display) select { ctrlType _x in [1, 16] && {!(_x in _keyCtrls)} });
            {
                private _bars = _y;
                private _bw = (_bars select 0) getVariable ["ALiVE_tabletLayoutW", 0];
                private _need = _minW;
                { _need = _need max ((count ctrlText _x) * 0.62 * _textH * (safezoneW / safezoneH) / (getResolution select 4) + _pad) } forEach _bars;
                // a bar already narrower than a long one keeps its layout width (pairs and rows of buttons)
                private _nw = [_need min _bw, _bw] select (_bw <= _longW);
                {
                    _x setVariable ["ALiVE_tabletSized", true];
                    (ctrlPosition _x) params ["_bx", "_by", "", "_bh"];
                    _x ctrlSetPosition [_bx, _by, _nw, _bh];
                    _x ctrlCommit 0;
                } forEach _bars;
            } forEach _cols;
        };
        {
            if !(_x getVariable ["ALiVE_tabletFont", false]) then {
                _x setVariable ["ALiVE_tabletFont", true];
                if (ctrlType _x != 101) then {
                    _x ctrlSetFont _font;
                    _x ctrlSetFontHeight _textH;
                };
            };
            if (ctrlType _x in [1, 16] && {!(_x in _keyCtrls)}) then {
                private _now = ctrlText _x;
                private _up = toUpper _now;
                if (_now isNotEqualTo _up) then { _x ctrlSetText _up };
            };
        } forEach (allControls _display);
        {
            _x params ["_ctrl", "_text"];
            private _now = ctrlText _ctrl;
            if (_now isNotEqualTo _text) then {
                _ctrl ctrlSetTooltip _now;
                _ctrl ctrlSetText _text;
            };
        } forEach _labelled;
    }, [_display, _labelled, _font, _textH, 260 * _px, 24 * _px, 400 * _px]];

    // glass over the screen, on top of everything and deaf to the mouse: glare on Modern, a CRT on
    // Cold War, acetate sheen on the map cases (whose dark window sits 10 px inside the paper)
    private _inset = [[0, 0], [10, 8]] select (_era in ["vietnam", "ww2"]);
    _inset params ["_ix", "_iy"];
    private _glassCtrl = _display ctrlCreate ["RscPicture", -1];
    _glassCtrl ctrlSetText _glass;
    _glassCtrl ctrlSetPosition [_fx + (100 + _ix) * _px, _fy + (56 + _iy) * _py, (_designW - 200 - 2 * _ix) * _px, (730 - 2 * _iy) * _py];
    _glassCtrl ctrlEnable false;
    _glassCtrl ctrlCommit 0;

    _display setVariable ["ALiVE_tabletEra", _era];
};

_display
