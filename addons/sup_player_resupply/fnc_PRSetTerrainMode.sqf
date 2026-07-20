#include "\x\alive\addons\sup_player_resupply\script_component.hpp"
/*
    ALIVE_fnc_PRSetTerrainMode
    #698: Player Resupply terrain toggle. Swaps the tablet map between the satellite class and the
    schematic class via the shared ALIVE_fnc_tabletSetTerrainMode engine, re-attaching the map-click
    handler after the swap.

    Params: 0: _terrainOn <BOOL> (default true = satellite)
    Author: Jman
*/
params [["_terrainOn", true]];

[
    60001,                       // PRTablet display idd
    [60002],                     // map idc
    "PRTablet_RscMap",           // satellite class
    "PRTablet_RscMapSchematic",  // schematic class
    "PRTerrainMode",             // uinamespace session flag
    _terrainOn,
    {
        params ["_newMap"];
        // #698 restore whichever map-click mode was live before the swap: MAP_CLICK in the request
        // view (placement on), MAP_CLICK_NULL in the status view (placement off). Recorded by fnc_PR
        // wherever it attaches the map handler, so the toggle never wrongly re-enables placement.
        private _mode = uinamespace getVariable ["PRMapClickMode", "MAP_CLICK"];
        _newMap ctrlSetEventHandler ["MouseButtonDown", format ["['%1',[_this]] call ALIVE_fnc_PRTabletOnAction", _mode]];
    }
] call ALIVE_fnc_tabletSetTerrainMode;
