class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class ATO {
                                description = "The main class";
                                file = "\x\alive\addons\mil_ato\fnc_ATO.sqf";
                                RECOMPILE;
                        };
                        class ATOInit {
                                description = "The module initialisation function";
                                file = "\x\alive\addons\mil_ato\fnc_ATOInit.sqf";
                                RECOMPILE;
                        };
                        class ATOGlobalRegistry {
                                description = "Handles global module registry and forcepools";
                                file = "\x\alive\addons\mil_ato\fnc_ATOGlobalRegistry.sqf";
                                RECOMPILE;
                        };
                        class ATOLoadData {
                                description = "Load persistent data";
                                file = "\x\alive\addons\mil_ato\fnc_ATOLoadData.sqf";
                                RECOMPILE;
                        };
                        class ATOSaveData {
                                description = "Save persistent data";
                                file = "\x\alive\addons\mil_ato\fnc_ATOSaveData.sqf";
                                RECOMPILE;
                        };
                };
        };
};
