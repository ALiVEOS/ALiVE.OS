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
                   };
        };
};
