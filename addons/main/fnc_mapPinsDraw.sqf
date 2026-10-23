#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(mapPinsDraw);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_mapPinsDraw

Description:
The Draw handler ALiVE_fnc_mapPins hangs on every map control: draws the adopted markers' names
where ALiVE_fnc_mapPinsLayout put them. The layout is redone four times a second, when the zoom
changes and when a marker is adopted, renamed or released; in between each frame only turns the
stored offsets back into map positions.

Parameters:
    CONTROL - the map

Returns:
    Nothing

Author:
Jman
---------------------------------------------------------------------------- */

params ["_c"];

if (isNil "ALiVE_mapPins_reg" || {count ALiVE_mapPins_reg == 0}) exitWith {};
if !(missionNamespace getVariable ["ALiVE_prefMapLayer", true]) exitWith {};

private _scale = ctrlMapScale _c;
private _now = diag_tickTime;
private _lay = _c getVariable ["ALiVE_mapPins_lay", []];
if (_lay isEqualTo [] || {(_lay select 0) < _now} || {(_lay select 1) != _scale} || {(_lay select 2) != ALiVE_mapPins_version}) then {
    _lay = [_now + 0.25, _scale, ALiVE_mapPins_version, [_c] call ALiVE_fnc_mapPinsLayout];
    _c setVariable ["ALiVE_mapPins_lay", _lay];
};

private _size = missionNamespace getVariable ["ALiVE_mapPins_textSize", 0.04];
{
    _x params ["_m", "_dx", "_dy", "_al", "_text", "_col", "_lead", "_lx", "_ly"];
    // deleted since the last layout (a rally or task marker being remade): skip it
    if (markerType _m == "") then { continue };
    private _mp = markerPos _m;
    private _p = _c ctrlMapWorldToScreen _mp;
    private _w = _c ctrlMapScreenToWorld [(_p select 0) + _dx, (_p select 1) + _dy];
    private _a = markerAlpha _m;
    private _rgba = [_col select 0, _col select 1, _col select 2, (_col select 3) * _a];
    if (_lead) then {
        _c drawLine [_c ctrlMapScreenToWorld [(_p select 0) + _lx, (_p select 1) + _ly], _w, _rgba];
    };
    // black names read best plain; coloured ones (dark red and green included) get an outline so
    // they read on any ground
    private _shadow = [2, 0] select ((_col select [0, 3]) isEqualTo [0, 0, 0]);
    _c drawIcon ["#(argb,8,8,3)color(0,0,0,0)", _rgba, _w, 1, 1, 0, _text, _shadow, _size, "RobotoCondensed", _al];
} forEach (_lay select 3);
