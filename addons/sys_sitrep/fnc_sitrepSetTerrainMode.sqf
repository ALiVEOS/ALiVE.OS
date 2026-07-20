#include "\x\alive\addons\sys_sitrep\script_component.hpp"
/*
    ALIVE_fnc_sitrepSetTerrainMode
    #698: SITREP terrain toggle. Swaps the report map between the satellite class and the schematic
    class via the shared ALIVE_fnc_tabletSetTerrainMode engine, re-attaching the map-click handler
    after the swap.

    Params: 0: _terrainOn <BOOL> (default true = satellite)
    Author: Jman
*/
params [["_terrainOn", true]];

[
    90001,                      // display idd
    [SITREP_MAP],               // map idc(s)
    "SITREP_RscMap",            // satellite class
    "SITREP_RscMapSchematic",   // schematic class
    "SITREP_TerrainMode",       // uinamespace session flag
    _terrainOn,
    {
        params ["_newMap"];
        _newMap ctrlSetEventHandler ["MouseButtonDown", "_this call ALiVE_fnc_sitrepOnMapEvent"];
    }
] call ALiVE_fnc_tabletSetTerrainMode;
