#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(mapPinsLayout);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_mapPinsLayout

Description:
Where each adopted marker's name goes on one map control (ALiVE_fnc_mapPins has the rules). Runs
a few times a second from ALiVE_fnc_mapPinsDraw, not every frame. Everything is in screen units.
A placement is the name's offset from its marker's icon on screen, so a pan moves the names with
their markers and needs no new layout.

Parameters:
    CONTROL - the map

Returns:
    ARRAY - placements [marker, dx, dy, align, text, RGBA, leader, lx, ly]; leader is true for the
    outer ring, and [lx, ly] is then the icon edge the leader line starts from, as an offset too

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

// a label's width on screen, measured once per text (getTextWidth takes the text on its left)
if (isNil "ALiVE_mapPins_tw") then { ALiVE_mapPins_tw = createHashMap };
private _meas = {
    params ["_t"];
    private _w = ALiVE_mapPins_tw get _t;
    if (!isNil "_w") exitWith {_w};
    _w = _t getTextWidth [_font, _size];
    ALiVE_mapPins_tw set [_t, _w];
    _w
};

// none of ALiVE's markers on this map: nothing to place, so no pass over every marker
private _any = false;
{
    if (markerType _x != "") then {
        (_c ctrlMapWorldToScreen (markerPos _x)) params ["_qx", "_qy"];
        if (_qx > _cx0 && {_qx < _cx1} && {_qy > _cy0} && {_qy < _cy1}) exitWith { _any = true };
    };
} forEach ALiVE_mapPins_reg;
if (!_any) exitWith {[]};

// an icon's half width and half height on screen; each marker type's size read once
if (isNil "ALiVE_mapPins_typeSize") then { ALiVE_mapPins_typeSize = createHashMap };
private _half = {
    params ["_m"];
    private _t = markerType _m;
    private _s = ALiVE_mapPins_typeSize get _t;
    if (isNil "_s") then {
        _s = getNumber (configFile >> "CfgMarkers" >> _t >> "size");
        ALiVE_mapPins_typeSize set [_t, _s];
    };
    private _px = _s * ((markerSize _m) select 0);
    [0.5 * _px * pixelW, 0.5 * _px * pixelH]
};

// everything a name must not cover: every icon on this map, and the names Arma still draws
private _occ = [];
private _entries = [];
private _gone = [];
{
    private _m = _x;
    if (markerShape _m == "ICON" && {markerAlpha _m > 0} && {markerType _m != ""}) then {
        private _p = _c ctrlMapWorldToScreen (markerPos _m);
        _p params ["_px", "_py"];
        if (_px > _cx0 - 0.1 && {_px < _cx1 + 0.1} && {_py > _cy0 - 0.1} && {_py < _cy1 + 0.1}) then {
            // a text-only marker (Empty, EmptyIcon: the task's area title, a mission maker's label)
            // has no icon to keep clear, but its text still counts
            ([_m] call _half) params ["_hw", "_hh"];
            if (markerType _m in ["Empty", "EmptyIcon"]) then { _hw = 0; _hh = 0 };
            if (_hw > 0) then { _occ pushBack [_px - _hw, _py - _hh, _px + _hw, _py + _hh] };
            private _e = ALiVE_mapPins_reg get _m;
            if (isNil "_e") then {
                private _t = markerText _m;
                if (_t != "") then {
                    private _tw = [_t] call _meas;
                    _occ pushBack [_px + _hw, _py - _lh / 2, _px + _hw + _tw, _py + _lh / 2];
                };
            } else {
                if ((_e select 0) != "") then { _entries pushBack [_e select 1, _m, _px, _py, _hw, _hh, _e] };
            };
        };
    };
} forEach allMapMarkers;

// drop entries whose marker was deleted
{
    if (markerType _x == "") then { _gone pushBack _x };
} forEach ALiVE_mapPins_reg;
if (_gone isNotEqualTo []) then {
    { ALiVE_mapPins_reg deleteAt _x } forEach _gone;
};

_entries sort false;

private _hit = {
    params ["_r"];
    _r params ["_x0", "_y0", "_x1", "_y1"];
    if (_x0 < _cx0 || {_x1 > _cx1} || {_y0 < _cy0} || {_y1 > _cy1}) exitWith {true};
    (_occ findIf { _x0 < (_x select 2) && {_x1 > (_x select 0)} && {_y0 < (_x select 3)} && {_y1 > (_x select 1)} }) >= 0
};

private _out = [];
{
    _x params ["_prio", "_m", "_px", "_py", "_hw", "_hh", "_e"];
    _e params ["_text", "", "_col"];
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
} forEach _entries;

_out
