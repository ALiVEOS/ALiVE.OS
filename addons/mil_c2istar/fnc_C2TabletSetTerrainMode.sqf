#include "\x\alive\addons\mil_c2istar\script_component.hpp"
/*
    ALIVE_fnc_C2TabletSetTerrainMode
    #698: C2ISTAR tablet terrain toggle. Swaps the tasking map (70022) between the satellite class and
    the schematic class via the shared ALIVE_fnc_tabletSetTerrainMode engine, restoring whichever
    map-click handler was live before the swap (recorded by fnc_C2ISTAR at each attach site).

    Scope: the single tasking map (C2ISTAR has no second/edit/right map surface).

    Params: 0: _terrainOn <BOOL> (default true = satellite)
    Author: Jman
*/
params [["_terrainOn", true]];

[
    70001,                          // C2Tablet display idd
    [70022],                        // tasking map idc
    "C2Tablet_RscMap",              // satellite class
    "C2Tablet_RscMapSchematic",     // schematic class
    "C2TerrainMode",                // uinamespace session flag
    _terrainOn,
    {
        params ["_newMap"];
        // #698 restore whichever tasking-map click handler was live (generate / add / add-null), or "" when the map carried none.
        _newMap ctrlSetEventHandler ["MouseButtonDown", uinamespace getVariable ["C2Tablet_taskingMapClickHandler", ""]];
    }
] call ALIVE_fnc_tabletSetTerrainMode;
