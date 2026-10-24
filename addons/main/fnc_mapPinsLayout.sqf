#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(mapPinsLayout);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_mapPinsLayout

Description:
What the map label layer draws on one map control, and where (ALiVE_fnc_mapPins has the rules).
Runs a few times a second from ALiVE_fnc_mapPinsDraw, not every frame. Everything is in screen
units. A name's placement is its offset from its marker's icon on screen, so a pan moves names
with their markers and needs no new layout.

Grouping: a unit pin the layer draws (a NATO unit type on its side's frame: ask-a-soldier,
G2, an informant's marks) groups with other unit pins drawn within 0.8 of an icon width of it on
screen, the higher priority one heading the group with a count, so zooming in splits groups by
itself. Place pins (FOB, rally point, task, the tablet's picks) never group: each is something the
player looks for by itself.

Parameters:
    CONTROL - the map

Returns:
    ARRAY - [icons, labels]
      icons  [marker, texture, RGBA, px, px, glyphTexture, glyphRGBA, count]
      labels [marker, dx, dy, align, text, RGBA, leader, lx, ly]; leader is true for the outer
             ring, and [lx, ly] is then the icon edge the leader line starts from, as an offset too

Author:
Jman
---------------------------------------------------------------------------- */

params ["_c"];

private _size = missionNamespace getVariable ["ALiVE_mapPins_textSize", 0.04];
private _font = "RobotoCondensed";
// a label's height on screen for a text size, and the gap between a label and its icon
private _lh = _size * (missionNamespace getVariable ["ALiVE_mapPins_lineK", 0.75]);
private _g = _lh * 0.25;

// the map's edges on screen: ctrlPosition is relative to the controls group the map sits in (the
// GPS, the tablets), where ctrlMapWorldToScreen answers in whole-screen terms, so add each group's
// offset
(ctrlPosition _c) params ["_cx0", "_cy0", "_cw", "_ch"];
private _grp = ctrlParentControlsGroup _c;
while { !isNull _grp } do {
    (ctrlPosition _grp) params ["_gx", "_gy"];
    _cx0 = _cx0 + _gx;
    _cy0 = _cy0 + _gy;
    _grp = ctrlParentControlsGroup _grp;
};
private _cx1 = _cx0 + _cw;
private _cy1 = _cy0 + _ch;
// a small map (the GPS) has no room to move names about: each goes to the right of its marker
private _small = _cw < 0.4;
private _inView = { params ["_x0", "_y0", ["_m", 0]]; _x0 > _cx0 - _m && {_x0 < _cx1 + _m} && {_y0 > _cy0 - _m} && {_y0 < _cy1 + _m} };

// a label's width on screen, measured once per text (getTextWidth takes the text on its left); the
// cache starts again past 400 texts
if (isNil "ALiVE_mapPins_tw" || {count ALiVE_mapPins_tw > 400}) then { ALiVE_mapPins_tw = createHashMap };
private _meas = {
    params ["_t"];
    private _w = ALiVE_mapPins_tw get _t;
    if (!isNil "_w") exitWith {_w};
    _w = _t getTextWidth [_font, _size];
    ALiVE_mapPins_tw set [_t, _w];
    _w
};

// a marker type's size in config, read once
if (isNil "ALiVE_mapPins_typeSize") then { ALiVE_mapPins_typeSize = createHashMap };
private _typeSize = {
    params ["_t"];
    private _s = ALiVE_mapPins_typeSize get _t;
    if (isNil "_s") then {
        _s = getNumber (configFile >> "CfgMarkers" >> _t >> "size");
        ALiVE_mapPins_typeSize set [_t, _s];
    };
    _s
};

// what the layer draws for a marker it draws itself, by type and colour, read once:
// [texture, RGBA, glyphTexture, glyphRGBA, size in px at marker size 1, edgeTexture, edgeRGBA]. A NATO
// unit type (b_inf, o_armor, n_air, c_...) with a drawing of its own, while the player has ALiVE pins on,
// is its side's NATO frame (blue box, red diamond, green square, purple box) in the marker's colour with
// Arma's own drawing for that kind of unit in white on top; anything else is its own icon in its own
// colour (ALiVE's pins are white in config and made with colour "Default", so they come out as drawn).
if (isNil "ALiVE_mapPins_iconCache") then { ALiVE_mapPins_iconCache = createHashMap };
private _glyphs = ["inf", "recon", "motor_inf", "mech_inf", "armor", "art", "antiair", "air", "plane", "uav", "naval", "unknown"];
private _iconFor = {
    params ["_m"];
    private _t = markerType _m;
    private _col = markerColor _m;
    // the frame only while the player has ALiVE pins on, so the key carries that
    private _on = (["pinSet"] call ALiVE_fnc_mapPins) != "off";
    private _key = _t + "|" + _col + "|" + str _on;
    private _v = ALiVE_mapPins_iconCache get _key;
    if (!isNil "_v") exitWith {_v};
    private _kind = _t select [2];
    private _pre = _t select [0, 2];
    _v = if (_on && {_pre in ["b_", "o_", "n_", "c_"]} && {_kind in _glyphs}) then {
        private _disc = ["alive_pin_disc"] call _typeSize;
        private _dir = "\x\alive\addons\main\data\pins\";
        private _frame = format ["%1alive_frame_%2.paa", _dir, ["w", "e", "i", "c"] select (["b_", "o_", "n_", "c_"] find _pre)];
        [_frame, [_col, _t] call ALiVE_mapPins_rgba, format ["%1alive_glyph_%2.paa", _dir, _kind], [1, 1, 1, 1], [40, _disc] select (_disc > 0), "", []]
    } else {
        [getText (configFile >> "CfgMarkers" >> _t >> "icon"), [_col, _t] call ALiVE_mapPins_rgba, "", [], [_t] call _typeSize, "", []]
    };
    ALiVE_mapPins_iconCache set [_key, _v];
    _v
};

// everything a name must not cover: every icon on this map, and the names Arma still draws
private _occ = [];

// 1. ALiVE's own markers: those the layer draws (to group) and those Arma still draws (names only)
private _pins = [];
private _named = [];
private _gone = [];
private _any = false;
if (isNil "ALiVE_mapPins_fade") then { ALiVE_mapPins_fade = createHashMap };
private _op = ((missionNamespace getVariable ["ALiVE_prefPinOpacity", 100]) max 20 min 100) / 100;
{
    private _m = _x;
    if (markerType _m == "") then {
        _gone pushBack _m;
    } else {
        // an ALiVE pin Arma draws: its alpha is the mission's, times the player's opacity. An alpha other than
        // the one last set here is the marker's owner changing it, and becomes the new base.
        if ((markerType _m) select [0, 10] == "alive_pin_") then {
            (ALiVE_mapPins_fade getOrDefault [_m, [-1, -1]]) params ["_base", "_set"];
            private _now = markerAlpha _m;
            if (_now != _set) then { _base = _now };
            private _want = _base * _op;
            if (_now != _want) then { _m setMarkerAlphaLocal _want };
            ALiVE_mapPins_fade set [_m, [_base, _want]];
        };
        if (markerAlpha _m > 0) then {
            (_c ctrlMapWorldToScreen (markerPos _m)) params ["_px", "_py"];
            // a whole map width round the view, so a pin comes in with its group as the map pans
            if ([_px, _py, _cw] call _inView) then { _any = true };
            _y params ["", "_prio", "", "", "", ["_osz", [1, 1]], ["_icon", ""]];
            if (_icon != "") then {
                private _spec = [_m] call _iconFor;
                private _ipx = (_spec select 4) * (_osz select 0);
                // a unit pin groups only with its own side's (b_, o_, n_, c_)
                _pins pushBack [_prio, _m, _px, _py, 0.5 * _ipx * pixelW, 0.5 * _ipx * pixelH, _y, _spec, _ipx, (markerType _m) select [0, 2]];
            } else {
                private _ipx = ([markerType _m] call _typeSize) * ((markerSize _m) select 0);
                _named pushBack [_prio, _m, _px, _py, 0.5 * _ipx * pixelW, 0.5 * _ipx * pixelH, _y, 1];
                // Arma still draws this one's icon: no name may cover it
                _occ pushBack [_px - 0.5 * _ipx * pixelW, _py - 0.5 * _ipx * pixelH, _px + 0.5 * _ipx * pixelW, _py + 0.5 * _ipx * pixelH];
            };
        };
    };
} forEach ALiVE_mapPins_reg;
if (_gone isNotEqualTo []) then {
    { ALiVE_mapPins_reg deleteAt _x; ALiVE_mapPins_fade deleteAt _x } forEach _gone;
};
// none of ALiVE's markers near this map: nothing to draw, so no pass over every marker
if (!_any) exitWith {[[], []]};

// 2. the icons and names of every other marker on this map
{
    private _m = _x;
    if (!(_m in ALiVE_mapPins_reg) && {markerShape _m == "ICON"} && {markerAlpha _m > 0} && {markerType _m != ""}) then {
        (_c ctrlMapWorldToScreen (markerPos _m)) params ["_px", "_py"];
        if ([_px, _py, 0.1] call _inView) then {
            // a text-only marker (Empty, EmptyIcon: the task's area title, a mission maker's label)
            // has no icon to keep clear, but its text still counts
            private _hw = 0;
            private _hh = 0;
            if !(markerType _m in ["Empty", "EmptyIcon"]) then {
                private _ipx = ([markerType _m] call _typeSize) * ((markerSize _m) select 0);
                _hw = 0.5 * _ipx * pixelW;
                _hh = 0.5 * _ipx * pixelH;
            };
            if (_hw > 0) then { _occ pushBack [_px - _hw, _py - _hh, _px + _hw, _py + _hh] };
            private _t = markerText _m;
            if (_t != "") then {
                private _tw = [_t] call _meas;
                _occ pushBack [_px + _hw, _py - _lh / 2, _px + _hw + _tw, _py + _lh / 2];
            };
        };
    };
} forEach allMapMarkers;

// 3. group the pins the layer draws, highest priority first, in pixels on screen
_pins sort false;
private _icons = [];
private _maxPx = 0;
{ _maxPx = _maxPx max (_x select 8) } forEach _pins;
private _cell = 0.8 * (_maxPx max 1);
private _grid = createHashMap;
{
    private _k = [floor ((_x select 2) / pixelW / _cell), floor ((_x select 3) / pixelH / _cell)];
    private _l = _grid getOrDefault [_k, []];
    _l pushBack _forEachIndex;
    _grid set [_k, _l];
} forEach _pins;
private _claimed = _pins apply {false};
{
    if !(_claimed select _forEachIndex) then {
        _claimed set [_forEachIndex, true];
        _x params ["_prio", "_m", "_px", "_py", "_hw", "_hh", "_e", "_spec", "_ipx", "_side"];
        private _count = 1;
        private _unit = (_spec select 2) != "";
        if (_unit) then {
            private _gx = floor (_px / pixelW / _cell);
            private _gy = floor (_py / pixelH / _cell);
            for "_i" from -1 to 1 do {
                for "_j" from -1 to 1 do {
                    {
                        if !(_claimed select _x) then {
                            private _o = _pins select _x;
                            if (((_o select 7) select 2) != "" && {(_o select 9) == _side} && {(((_o select 2) - _px) / pixelW) ^ 2 + (((_o select 3) - _py) / pixelH) ^ 2 <= _cell ^ 2}) then {
                                _claimed set [_x, true];
                                _count = _count + 1;
                            };
                        };
                    } forEach (_grid getOrDefault [[_gx + _i, _gy + _j], []]);
                };
            };
        };
        _spec params ["_tex", "_rgba", "_gtex", "_grgba", "", ["_etex", ""], ["_ergba", []]];
        _icons pushBack [_m, _tex, _rgba, _ipx, _ipx, _gtex, _grgba, _count, _etex, _ergba];
        if ([_px, _py, 0.1] call _inView) then {
            _occ pushBack [_px - _hw, _py - _hh, _px + _hw, _py + _hh];
            // the count badge, top right of the icon (fnc_mapPinsDraw: 0.42 out, 0.55 of the pin across)
            if (_count > 1) then { _occ pushBack [_px + 0.29 * _hw, _py - 1.39 * _hh, _px + 1.39 * _hw, _py - 0.29 * _hh] };
            _named pushBack [_prio, _m, _px, _py, _hw, _hh, _e, _count];
        };
    };
} forEach _pins;

// 4. names, highest priority first
_named sort false;
private _hit = {
    params ["_r"];
    _r params ["_x0", "_y0", "_x1", "_y1"];
    if (_x0 < _cx0 || {_x1 > _cx1} || {_y0 < _cy0} || {_y1 > _cy1}) exitWith {true};
    (_occ findIf { _x0 < (_x select 2) && {_x1 > (_x select 0)} && {_y0 < (_x select 3)} && {_y1 > (_x select 1)} }) >= 0
};

private _out = [];
{
    _x params ["_prio", "_m", "_px", "_py", "_hw", "_hh", "_e", "_count"];
    _e params ["_text", "", "_col"];
    if (_text == "" || {!([_px, _py] call _inView)}) then { continue };
    private _lw = [_text] call _meas;
    // [anchor x, anchor y, align, outward x, outward y] round the icon, nearest first
    private _slots = [
        [_px + _hw + _g, _py, "right", 1, 0],
        [_px - _hw - _g, _py, "left", -1, 0],
        [_px, _py - _hh - _g - _lh / 2, "center", 0, -1],
        [_px, _py + _hh + _g + _lh / 2, "center", 0, 1],
        [_px + _hw * 0.5, _py - _hh - _lh / 2, "right", 0.7, -0.7],
        [_px + _hw * 0.5, _py + _hh + _lh / 2, "right", 0.7, 0.7],
        [_px - _hw * 0.5, _py - _hh - _lh / 2, "left", -0.7, -0.7],
        [_px - _hw * 0.5, _py + _hh + _lh / 2, "left", -0.7, 0.7]
    ];
    private _placed = [];
    if (_small) then { _placed = [_m, _hw + _g, 0, "right", _text, _col, false, 0, 0] };
    {
        private _ring = _x;
        private _d = _ring * 1.5 * _lh;
        {
            _x params ["_ax", "_ay", "_al", "_ox", "_oy"];
            _ax = _ax + _ox * _d;
            _ay = _ay + _oy * _d;
            private _r = switch (_al) do {
                case "right": { [_ax, _ay - _lh / 2, _ax + _lw, _ay + _lh / 2] };
                case "left": { [_ax - _lw, _ay - _lh / 2, _ax, _ay + _lh / 2] };
                default { [_ax - _lw / 2, _ay - _lh / 2, _ax + _lw / 2, _ay + _lh / 2] };
            };
            if !([_r] call _hit) exitWith {
                _occ pushBack _r;
                _placed = [_m, _ax - _px, _ay - _py, _al, _text, _col, _ring > 0, _ox * _hw, _oy * _hh];
            };
        } forEach _slots;
        if (_placed isNotEqualTo []) exitWith {};
    } forEach ([[0, 1], []] select _small);
    // a FOB or the like keeps its name even with nowhere free for it
    if (_placed isEqualTo [] && {_prio >= 80}) then {
        _placed = [_m, _hw + _g, 0, "right", _text, _col, false, 0, 0];
    };
    if (_placed isNotEqualTo []) then { _out pushBack _placed };
} forEach _named;

[_icons, _out]
