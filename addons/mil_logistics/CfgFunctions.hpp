class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class ML {
                                description = "The main class";
                                file = "\x\alive\addons\mil_logistics\fnc_ML.sqf";
                                RECOMPILE;
                        };
                        class MLInit {
                                description = "The module initialisation function";
                                file = "\x\alive\addons\mil_logistics\fnc_MLInit.sqf";
                                RECOMPILE;
                        };
                        class MLGlobalRegistry {
                                description = "Handles global module registry and forcepools";
                                file = "\x\alive\addons\mil_logistics\fnc_MLGlobalRegistry.sqf";
                                RECOMPILE;
                        };
                        class MLLoadData {
                                description = "Load persistent data";
                                file = "\x\alive\addons\mil_logistics\fnc_MLLoadData.sqf";
                                RECOMPILE;
                        };
                        class MLSaveData {
                                description = "Save persistent data";
                                file = "\x\alive\addons\mil_logistics\fnc_MLSaveData.sqf";
                                RECOMPILE;
                        };
                        class MLAttachSmokeOrStrobe {
                                description = "Attaches smoke or strobe to object depending on day time";
                                file = "\x\alive\addons\mil_logistics\fnc_MLAttachSmokeOrStrobe.sqf";
                                RECOMPILE;
                        };
                };
        };
};
