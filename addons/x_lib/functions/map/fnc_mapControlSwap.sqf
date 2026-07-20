#include "\x\alive\addons\x_lib\script_component.hpp"
/*
    ALIVE_fnc_mapControlSwap
    Swap a dialog map control for a different map class IN PLACE, preserving the viewport and the
    shown/enabled state. maxSatelliteAlpha (the satellite terrain layer) is creation-time only, so an
    ALiVE tablet terrain toggle recreates the control in the other class instead of changing a
    property. The new control keeps the SAME idc, so every existing "displayCtrl <idc>" call site keeps
    working. Recreating a config map at runtime also drops it out of the config map's always-on-top
    draw layer, so an overlay control created afterwards renders above it. Promoted from the Combat
    Support tablet (#698) so every ALiVE tablet can share it.

    Params:
      0: _displayId  <NUMBER>  the dialog display id
      1: _mapIdc     <NUMBER>  the map control idc
      2: _newClass   <STRING>  a ROOT config map class that carries deletable = 1
      3: _rearmCode  <CODE>    optional; run as [_newMap] call _rearmCode to re-attach handlers
      4: _targetView <ARRAY>   optional [scale, centre]; [] = preserve the current view
    Returns: the new map <CONTROL>, or controlNull on failure.

    CAVEAT (maps hidden at swap time): the view restore is deferred to the new control's first Draw, so
    a map that is ctrlShow-false when swapped restores its view only when next shown - and if the tablet
    re-applies its own view on show, it can race the still-pending restore. A tablet that hides its map
    per sub-view should pass an explicit _targetView, or zero the pending restore (setVariable
    ["ALIVE_mapRestoreTicks", 0] on the control) in its show handler.
    Author: Jman
*/
params ["_displayId", "_mapIdc", "_newClass", ["_rearmCode", {}], ["_targetView", []]];
disableSerialization;

private _display = findDisplay _displayId;
if (isNull _display) exitWith { controlNull };
private _map = _display displayCtrl _mapIdc;
if (isNull _map) exitWith { controlNull };

private _cp = ctrlPosition _map;
// Preserve shown/enabled state: a ctrlCreate'd control defaults to shown+enabled, but several
// tablets hide their map on non-map sub-views, so a blind recreate would splash a hidden map over a
// menu. The view restore is deferred to the map's Draw handler, so it simply resumes when shown.
private _shown = ctrlShown _map;
private _enabled = ctrlEnabled _map;
if (_targetView isEqualTo []) then {
    // preserve the current view. Captured with the SAME reading the restore converges to, so the
    // visible centre round-trips exactly despite that reading being offset from where the map anim
    // actually centres.
    _targetView = [ctrlMapScale _map, _map ctrlMapScreenToWorld [(_cp select 0) + (_cp select 2) / 2, (_cp select 1) + (_cp select 3) / 2]];
};

// ctrlDelete needs deletable = 1 on the class or it silently no-ops. Safe here because this is only
// ever called from a button action / onLoad, never from a handler owned by the deleted map.
ctrlDelete _map;
private _new = _display ctrlCreate [_newClass, _mapIdc];
// the root map class carries no position (that lives on the dialog instance), so restore the saved
// screen rect before any map animation runs
_new ctrlSetPosition _cp;
_new ctrlCommit 0;
_new ctrlShow _shown;
_new ctrlEnable _enabled;

(_targetView) params ["_tScale", "_tCentre"];
[_new, _tScale, _tCentre] call ALIVE_fnc_mapRestoreView;
[_new] call _rearmCode;
_new
