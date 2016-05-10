class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class ML {
                                description = "The main class";
                                file = "\x\alive\addons\mil_logistics\fnc_ML.sqf";
                                recompile = RECOMPILE;
                        };
                        class MLInit {
                                description = "The module initialisation function";
                                file = "\x\alive\addons\mil_logistics\fnc_MLInit.sqf";
                                recompile = RECOMPILE;
                        };
                        class MLGlobalRegistry {
                                description = "Handles global module registry and forcepools";
                                file = "\x\alive\addons\mil_logistics\fnc_MLGlobalRegistry.sqf";
                                recompile = RECOMPILE;
                        };
                        class MLLoadData {
                                description = "Load persistent data";
                                file = "\x\alive\addons\mil_logistics\fnc_MLLoadData.sqf";
                                recompile = RECOMPILE;
                        };
                        class MLSaveData {
                                description = "Save persistent data";
                                file = "\x\alive\addons\mil_logistics\fnc_MLSaveData.sqf";
                                recompile = RECOMPILE;
                        };
                };
        };
};
