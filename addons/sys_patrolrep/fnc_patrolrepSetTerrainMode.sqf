#include "\x\alive\addons\sys_patrolrep\script_component.hpp"
/*
    ALIVE_fnc_patrolrepSetTerrainMode
    #698: PATROLREP terrain toggle. Swaps the report map between the satellite class and the schematic
    class via the shared ALIVE_fnc_tabletSetTerrainMode engine, re-attaching the map-click (patrol
    start/end marker) handler after the swap.

    Params: 0: _terrainOn <BOOL> (default true = satellite)
    Author: Jman
*/
params [["_terrainOn", true]];

[
    90002,                          // display idd
    [PATROLREP_MAP],                // map idc(s)
    "patrolrep_RscMap",             // satellite class
    "patrolrep_RscMapSchematic",    // schematic class
    "patrolrepTerrainMode",         // uinamespace session flag
    _terrainOn,
    {
        params ["_newMap"];
        _newMap ctrlSetEventHandler ["MouseButtonDown", "_this call ALiVE_fnc_patrolrepOnMapEvent"];
    }
] call ALiVE_fnc_tabletSetTerrainMode;
