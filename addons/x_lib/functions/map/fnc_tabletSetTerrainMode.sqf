#include "\x\alive\addons\x_lib\script_component.hpp"
/*
    ALIVE_fnc_tabletSetTerrainMode
    Shared terrain-mode setter for ALiVE tablet maps. Swaps one or more of a tablet's map controls
    between a satellite base class and its schematic sibling (maxSatelliteAlpha = 0), and persists the
    mode in a uinamespace session flag. Wraps ALIVE_fnc_mapControlSwap (which recreates each map in the
    target class and restores its view). One call per tablet; multi-map tablets pass all their live map
    idcs. Replaces the per-tablet setter that would otherwise be duplicated in every module.

    Params:
      0: _displayId      <NUMBER>  the dialog display id
      1: _mapIdcs        <ARRAY>   map control idc(s) to swap (single-map tablets pass [idc])
      2: _satClass       <STRING>  the satellite (maxSatelliteAlpha > 0) map class
      3: _schematicClass <STRING>  the schematic (maxSatelliteAlpha = 0) map class
      4: _flagName       <STRING>  uinamespace key for the session terrain-mode flag
      5: _terrainOn      <BOOL>    true = satellite, false = schematic (default true)
      6: _rearmCode      <CODE>    optional; [_newMap] call _rearmCode per swapped map to re-attach handlers
      7: _targetView     <ARRAY>   optional [scale, centre]; [] = preserve each map's current view
    Returns: <BOOL> true.
    Author: Jman
*/
params ["_displayId", "_mapIdcs", "_satClass", "_schematicClass", "_flagName", ["_terrainOn", true], ["_rearmCode", {}], ["_targetView", []]];

private _class = [_schematicClass, _satClass] select _terrainOn;
private _ok = true;
{
    private _new = [_displayId, _x, _class, _rearmCode, _targetView] call ALIVE_fnc_mapControlSwap;
    if (isNull _new) then { _ok = false };
} forEach _mapIdcs;

// only persist the mode if the swap actually happened, so the flag never lies about the visible map
if (_ok) then { uinamespace setVariable [_flagName, _terrainOn] };
_ok
