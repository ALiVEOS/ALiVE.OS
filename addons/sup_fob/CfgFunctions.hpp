class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class FOB {
                                description = "The main class: the module and the FOB registry";
                                file = "\x\alive\addons\sup_fob\fnc_FOB.sqf";
                ALIVE_RECOMPILE;
                        };
                        class FOBInit {
                                description = "The module initialisation function";
                                file = "\x\alive\addons\sup_fob\fnc_FOBInit.sqf";
                ALIVE_RECOMPILE;
                        };
                        class FOBTypesInit {
                                description = "The FOB Types module initialisation function";
                                file = "\x\alive\addons\sup_fob\fnc_FOBTypesInit.sqf";
                ALIVE_RECOMPILE;
                        };
                        class fobCap {
                                description = "How many FOBs a side may have";
                                file = "\x\alive\addons\sup_fob\fnc_fobCap.sqf";
                ALIVE_RECOMPILE;
                        };
                        class fobSupply {
                                description = "Supply balance, credit and debit for the three supply sources";
                                file = "\x\alive\addons\sup_fob\fnc_fobSupply.sqf";
                ALIVE_RECOMPILE;
                        };
                        class fobPersistence {
                                description = "Turns the registry into a saved document and back";
                                file = "\x\alive\addons\sup_fob\fnc_fobPersistence.sqf";
                ALIVE_RECOMPILE;
                        };
                        class fobSaveData {
                                description = "Saves the FOBs (autosave, server save and exit)";
                                file = "\x\alive\addons\sup_fob\fnc_fobSaveData.sqf";
                ALIVE_RECOMPILE;
                        };
                        class fobLoadData {
                                description = "Loads the saved FOBs";
                                file = "\x\alive\addons\sup_fob\fnc_fobLoadData.sqf";
                ALIVE_RECOMPILE;
                        };
                        class fobWatchdog {
                                description = "The one server loop: timers, then later alerts and capture";
                                file = "\x\alive\addons\sup_fob\fnc_fobWatchdog.sqf";
                ALIVE_RECOMPILE;
                        };
                        class fobRequest {
                                description = "The only way a client asks the server to change a FOB";
                                file = "\x\alive\addons\sup_fob\fnc_fobRequest.sqf";
                ALIVE_RECOMPILE;
                        };
                        class fobOps {
                                description = "Server transactions on a FOB";
                                file = "\x\alive\addons\sup_fob\fnc_fobOps.sqf";
                ALIVE_RECOMPILE;
                        };
                        class fobClient {
                                description = "Client half: the read-only copy of the FOB list";
                                file = "\x\alive\addons\sup_fob\fnc_fobClient.sqf";
                ALIVE_RECOMPILE;
                        };
                        class fobObjectives {
                                description = "A FOB as an objective for its own side's AI Commanders";
                                file = "\x\alive\addons\sup_fob\fnc_fobObjectives.sqf";
                ALIVE_RECOMPILE;
                        };
                        class fobMarkers {
                                description = "Client: the map markers for the player's own side's FOBs";
                                file = "\x\alive\addons\sup_fob\fnc_fobMarkers.sqf";
                ALIVE_RECOMPILE;
                        };
                        class fobActions {
                                description = "Client: Deploy FOB, FOB Status, Dismantle FOB, Build Menu and Recycle";
                                file = "\x\alive\addons\sup_fob\fnc_fobActions.sqf";
                ALIVE_RECOMPILE;
                        };
                        class fobBuildScan {
                                description = "The build catalog and its prices, worked out from config";
                                file = "\x\alive\addons\sup_fob\fnc_fobBuildScan.sqf";
                ALIVE_RECOMPILE;
                        };
                        class fobGearScan {
                                description = "The FOB Arsenal's gear and its prices, worked out from config";
                                file = "\x\alive\addons\sup_fob\fnc_fobGearScan.sqf";
                ALIVE_RECOMPILE;
                        };
                        class buildMenu {
                                description = "Client: the FOB build window";
                                file = "\x\alive\addons\sup_fob\fnc_buildMenu.sqf";
                ALIVE_RECOMPILE;
                        };
                        class fobPlacement {
                                description = "Client: placing a catalog item at a FOB";
                                file = "\x\alive\addons\sup_fob\fnc_fobPlacement.sqf";
                ALIVE_RECOMPILE;
                        };
                   };
        };
};
