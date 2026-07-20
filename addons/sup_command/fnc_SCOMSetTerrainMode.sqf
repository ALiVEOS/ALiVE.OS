#include "\x\alive\addons\sup_command\script_component.hpp"
/*
    ALIVE_fnc_SCOMSetTerrainMode
    #698: SCOM (command) tablet terrain toggle. Swaps the main map (12022) between the satellite class
    and the schematic class via the shared ALIVE_fnc_tabletSetTerrainMode engine, restoring whichever
    map-click handler was live before the swap (recorded by fnc_SCOM at each attach site).

    Scope: main map only (the right map and edit map are per-view and out of scope for the toggle).

    Params: 0: _terrainOn <BOOL> (default true = satellite)
    Author: Jman
*/
params [["_terrainOn", true]];

[
    12001,                          // SCOMTablet display idd
    [12022],                        // main map idc
    "SCOMTablet_RscMap",            // satellite class
    "SCOMTablet_RscMapSchematic",   // schematic class
    "SCOMTerrainMode",              // uinamespace session flag
    _terrainOn,
    {
        params ["_newMap"];
        // #698 restore the main map's recorded click handler (INTEL focus-select, or empty when disabled).
        _newMap ctrlSetEventHandler ["MouseButtonDown", uinamespace getVariable ["SCOMMainMapClick", ""]];
    }
] call ALIVE_fnc_tabletSetTerrainMode;
