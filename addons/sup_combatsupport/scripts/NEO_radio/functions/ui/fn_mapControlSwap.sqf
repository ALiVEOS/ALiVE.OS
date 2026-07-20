/*
    NEO_fnc_mapControlSwap
    #698: swap a dialog map control for a different map class IN PLACE, preserving (or setting) the
    viewport. maxSatelliteAlpha (the satellite terrain layer) is creation-time only, so the terrain
    -mode toggle recreates the control instead of changing a property. The new control keeps the SAME
    idc, so every existing "displayCtrl <idc>" call site keeps working. Recreating the config map at
    runtime also drops it out of the config map's always-on-top draw layer, so an overlay control
    created afterwards (the terrain button) renders above it. Generic / tablet-agnostic so the other
    ALiVE tablets can reuse it.

    Params:
      0: _displayId  <NUMBER>  the dialog display id
      1: _mapIdc     <NUMBER>  the map control idc
      2: _newClass   <STRING>  a ROOT config map class that carries deletable = 1
      3: _rearmCode  <CODE>    optional; run as [_newMap] call _rearmCode to re-attach handlers
      4: _targetView <ARRAY>   optional [scale, centre]; [] = preserve the current view
    Returns: the new map <CONTROL>, or controlNull on failure.
    Author: Jman
*/
params ["_displayId", "_mapIdc", "_newClass", ["_rearmCode", {}], ["_targetView", []]];
disableSerialization;

private _display = findDisplay _displayId;
if (isNull _display) exitWith { controlNull };
private _map = _display displayCtrl _mapIdc;
if (isNull _map) exitWith { controlNull };

private _cp = ctrlPosition _map;
if (_targetView isEqualTo []) then {
    // preserve the current view. Captured with the SAME reading the restore converges to, so the
    // visible centre round-trips exactly despite that reading being offset from where the map anim
    // actually centres.
    _targetView = [ctrlMapScale _map, _map ctrlMapScreenToWorld [(_cp select 0) + (_cp select 2) / 2, (_cp select 1) + (_cp select 3) / 2]];
};

// ctrlDelete needs deletable = 1 on the class or it silently no-ops. Safe here because this is
// only ever called from a button action / onLoad, never from a handler owned by the deleted map.
ctrlDelete _map;
private _new = _display ctrlCreate [_newClass, _mapIdc];
// the root map class carries no position (that lives on the dialog instance), so restore the saved
// screen rect before any map animation runs
_new ctrlSetPosition _cp;
_new ctrlCommit 0;

(_targetView) params ["_tScale", "_tCentre"];
[_new, _tScale, _tCentre] call NEO_fnc_mapRestoreView;
[_new] call _rearmCode;
_new
