#include "\x\alive\addons\sup_group_manager\script_component.hpp"
/*
    ALIVE_fnc_GMSetTerrainMode
    #698: Group Manager tablet terrain toggle. Swaps both group-view maps (left 11020 + right 11021)
    between the satellite class and the schematic class via the shared ALIVE_fnc_tabletSetTerrainMode
    engine. Neither map has a click handler, so no rearm is needed.

    Params: 0: _terrainOn <BOOL> (default true = satellite)
    Author: Jman
*/
params [["_terrainOn", true]];

[
    11001,                       // GMTablet display idd
    [11020, 11021],              // left + right map idcs
    "GMTablet_RscMap",           // satellite class
    "GMTablet_RscMapSchematic",  // schematic class
    "GMTerrainMode",             // uinamespace session flag
    _terrainOn
] call ALIVE_fnc_tabletSetTerrainMode;
