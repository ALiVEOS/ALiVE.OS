/*
    NEO_fnc_radioSetTerrainMode
    #698: Combat Support tablet - set "terrain" (satellite) mode by swapping the map control between
    the satellite variant (NEO_RscMap) and the schematic variant (NEO_RscMapSchematic). Wraps the
    generic NEO_fnc_mapControlSwap with the CS tablet's display/map idc and its one tablet-specific
    handler (map-click target placement), persists the choice for the session, and lifts the terrain
    button back on top of the freshly recreated map. Called on the toggle click (preserve view) and
    on dialog open (with the saved view).

    Params: 0: _terrainOn <BOOL> (default true = satellite on)
            1: _targetView <ARRAY> optional [scale, centre] to restore; [] = keep the current view
    Returns: <BOOL> true on a successful swap.
    Author: Jman
*/
params [["_terrainOn", true], ["_targetView", []]];

private _class = ["NEO_RscMapSchematic", "NEO_RscMap"] select _terrainOn;
private _new = [655555, 655560, _class, {
    params ["_newMap"];
    // Re-attach the map-click target placement only if the pre-swap control had it. The three
    // *UnitLbSelChanged handlers attach MouseButtonDown under STATUS gates (a ready battery with
    // ordnance / a non-KILLED unit) and fn_radioLbSelChanged clears it on a support-type change;
    // NEO_radioMapClickArmed mirrors that exact state, so re-arm from the flag not mere selection.
    if (uinamespace getVariable ["NEO_radioMapClickArmed", false]) then {
        _newMap ctrlSetEventHandler ["MouseButtonDown", "_this call NEO_fnc_radioMapEvent"];
    };
}, _targetView] call NEO_fnc_mapControlSwap;

if (isNull _new) exitWith { false };

uinamespace setVariable ["NEO_radioTerrainMode", _terrainOn];
true
