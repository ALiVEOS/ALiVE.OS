#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(mapPinsDraw);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_mapPinsDraw

Description:
The Draw handler ALiVE_fnc_mapPins hangs on every map control: draws the icons the layer draws
itself (each group's head with a count badge) and the adopted markers' names where
ALiVE_fnc_mapPinsLayout put them. The layout is redone four times a second, when a marker is
adopted, renamed or released, and while zooming at most every 0.08 s; in between each frame draws
the last one, reading each marker's position and alpha as it is now.

Parameters:
    CONTROL - the map

Returns:
    Nothing

Author:
Jman
---------------------------------------------------------------------------- */

params ["_c"];

// markers given a pin by ALiVE_fnc_mapPins "pin": a global one comes back in its stock look whenever the
// server changes it (an installation fading out resends it every second), so its pin goes back on before
// this frame draws; one deleted, or made again under the same name as something else, is dropped
if (!isNil "ALiVE_mapPins_skins" && {count ALiVE_mapPins_skins > 0}) then {
    private _gone = [];
    {
        if (markerType _x != (_y select 3)) then {
            if (markerShape _x == "" || {markerType _x != (_y select 0)}) then {
                _gone pushBack _x;
            } else {
                _x setMarkerTypeLocal (_y select 3);
                _x setMarkerColorLocal (_y select 4);
            };
        };
    } forEach ALiVE_mapPins_skins;
    { ALiVE_mapPins_skins deleteAt _x } forEach _gone;
};

if (isNil "ALiVE_mapPins_reg" || {count ALiVE_mapPins_reg == 0}) exitWith {};
if !(missionNamespace getVariable ["ALiVE_prefMapLayer", true]) exitWith {};

private _op = ((missionNamespace getVariable ["ALiVE_prefPinOpacity", 100]) max 20 min 100) / 100;
private _fade = missionNamespace getVariable ["ALiVE_mapPins_fade", createHashMap];
// a group's count: a dark number on a small white disc
private _badge = "\x\alive\addons\main\data\pins\alive_pin_badge.paa";
private _digit = [0.11, 0.1, 0.1];
private _scale = ctrlMapScale _c;
private _now = diag_tickTime;
private _lay = _c getVariable ["ALiVE_mapPins_lay", []];
if (_lay isEqualTo []
    || {(_lay select 0) < _now}
    || {(_now - (_lay select 4)) > 0.08 && {(_lay select 1) != _scale || {(_lay select 2) != ALiVE_mapPins_version}}}) then {
    _lay = [_now + 0.25, _scale, ALiVE_mapPins_version, [_c] call ALiVE_fnc_mapPinsLayout, _now];
    _c setVariable ["ALiVE_mapPins_lay", _lay];
};
(_lay select 3) params [["_icons", []], ["_labels", []]];

// icons: the pin, a unit's drawing over its side's frame, and a group's count on a small disc
{
    _x params ["_m", "_tex", "_rgba", "_w", "_h", "_gtex", "_grgba", "_count", ["_etex", ""], ["_ergba", []]];
    if (markerType _m == "") then { continue };
    private _mp = markerPos _m;
    private _a = (markerAlpha _m) * _op;
    // Arma's own icon turns with its marker (a spot report's heading); the disc and its drawing stay upright
    _c drawIcon [_tex, [_rgba select 0, _rgba select 1, _rgba select 2, (_rgba select 3) * _a], _mp, _w, _h, [0, markerDir _m] select (_gtex == ""), "", 0];
    if (_etex != "") then {
        _c drawIcon [_etex, [_ergba select 0, _ergba select 1, _ergba select 2, (_ergba select 3) * _a], _mp, _w, _h, 0, "", 0];
    };
    if (_gtex != "") then {
        _c drawIcon [_gtex, [_grgba select 0, _grgba select 1, _grgba select 2, (_grgba select 3) * _a], _mp, _w, _h, 0, "", 0];
    };
    if (_count > 1) then {
        private _p = _c ctrlMapWorldToScreen _mp;
        private _b = _c ctrlMapScreenToWorld [(_p select 0) + 0.42 * _w * pixelW, (_p select 1) - 0.42 * _h * pixelH];
        _c drawIcon [_badge, [1, 1, 1, _a], _b, 0.55 * _w, 0.55 * _h, 0, "", 0];
        // the number sized to its disc: the badge is 0.55 of the pin, the digit about 0.7 of the badge
        _c drawIcon ["#(argb,8,8,3)color(0,0,0,0)", [_digit select 0, _digit select 1, _digit select 2, _a], _b, 1, 1, 0, str _count, 0, 0.385 * _h * pixelH, "RobotoCondensedBold", "center"];
    };
} forEach _icons;

private _size = missionNamespace getVariable ["ALiVE_mapPins_textSize", 0.04];
{
    _x params ["_m", "_dx", "_dy", "_al", "_text", "_col", "_lead", "_lx", "_ly"];
    // deleted since the last layout (a rally or task marker being remade): skip it
    if (markerType _m == "") then { continue };
    private _mp = markerPos _m;
    private _p = _c ctrlMapWorldToScreen _mp;
    private _w = _c ctrlMapScreenToWorld [(_p select 0) + _dx, (_p select 1) + _dy];
    private _a = (_fade getOrDefault [_m, [markerAlpha _m]]) select 0;
    private _rgba = [_col select 0, _col select 1, _col select 2, (_col select 3) * _a];
    if (_lead) then {
        _c drawLine [_c ctrlMapScreenToWorld [(_p select 0) + _lx, (_p select 1) + _ly], _w, _rgba];
    };
    // plain text, no outline (Jman 23 Oct: the dark edge round the names was too heavy on the map)
    _c drawIcon ["#(argb,8,8,3)color(0,0,0,0)", _rgba, _w, 1, 1, 0, _text, 0, _size, "RobotoCondensed", _al];
} forEach _labels;
