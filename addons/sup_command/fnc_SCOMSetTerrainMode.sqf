#include "\x\alive\addons\sup_command\script_component.hpp"
/*
    ALIVE_fnc_SCOMSetTerrainMode
    #698: SCOM (command) tablet terrain toggle. Swaps every tablet map between the satellite class
    and the schematic class via the shared ALIVE_fnc_tabletSetTerrainMode engine, restoring the
    operation editor handlers on its recreated map control.

    Params: 0: _terrainOn <BOOL> (default true = satellite)
    Author: Jman
*/
params [["_terrainOn", true]];

[
    12001,                          // SCOMTablet display idd
    [12021,12022,12026],            // right, main, and operations/edit maps
    "SCOMTablet_RscMap",            // satellite class
    "SCOMTablet_RscMapSchematic",   // schematic class
    "SCOMTerrainMode",              // uinamespace session flag
    _terrainOn,
    {
        params ["_newMap"];
        private _idc = ctrlIDC _newMap;

        if (_idc == 12022) then {
            // Restore the main Intel map's recorded focus-select handler.
            _newMap ctrlSetEventHandler ["MouseButtonDown",uinamespace getVariable ["SCOMMainMapClick",""]];
        };

        if (_idc == 12026) then {
            private _commandState = [ALiVE_SUP_COMMAND,"commandState"] call ALiVE_fnc_SCOM;
            private _viewMode = [_commandState,"opsViewMode","GROUPS"] call ALiVE_fnc_hashGet;

            _newMap ctrlSetEventHandler ["MouseButtonDblClick",""];

            switch (_viewMode) do {
                case "GROUPS": {
                    _newMap ctrlSetEventHandler ["MouseButtonDown","['OP_EDIT_MAP_CLICK',[_this]] call ALIVE_fnc_SCOMTabletOnAction"];
                    _newMap ctrlSetEventHandler ["MouseButtonDblClick","['OP_EDIT_MAP_DOUBLE_CLICK',[_this]] call ALIVE_fnc_SCOMTabletOnAction"];
                };
                case "WAYPOINTS": {
                    _newMap ctrlSetEventHandler ["MouseButtonDown","['OP_EDIT_WAYPOINT_MAP_CLICK',[_this]] call ALIVE_fnc_SCOMTabletOnAction"];
                };
                case "OBJECTIVES": {
                    private _display = findDisplay 12001;
                    private _placingObjective = ctrlText (_display displayCtrl 12017) == "Confirm Position";
                    private _clickHandler = if (_placingObjective) then {
                        "['OP_OBJECTIVE_MAP_CLICK',[_this]] call ALIVE_fnc_SCOMTabletOnAction"
                    } else {
                        "['OP_MAP_CLICK_NULL',[_this]] call ALIVE_fnc_SCOMTabletOnAction"
                    };
                    _newMap ctrlSetEventHandler ["MouseButtonDown",_clickHandler];
                };
                default {
                    _newMap ctrlSetEventHandler ["MouseButtonDown","['OP_MAP_CLICK_NULL',[_this]] call ALIVE_fnc_SCOMTabletOnAction"];
                };
            };

            // ctrlDelete removes the original Draw EH. Reattach exactly one
            // waypoint-chain renderer to the replacement control.
            private _drawEH = _newMap ctrlAddEventHandler ["Draw",{
                [ALiVE_SUP_COMMAND,"opsDrawWaypoints",_this] call ALiVE_fnc_SCOM;
            }];
            _newMap setVariable ["SCOM_opsDrawEH",_drawEH];
        };
    }
] call ALIVE_fnc_tabletSetTerrainMode;
