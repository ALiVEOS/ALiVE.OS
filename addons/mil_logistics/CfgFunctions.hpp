class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class ML {
                                description = "The main class";
																file = PATHTO_FUNC(ML);
                                recompile = RECOMPILE;
                        };
                        class MLInit {
                                description = "The module initialisation function";
																file = PATHTO_FUNC(MLInit);
                                recompile = RECOMPILE;
                        };
                        class MLGlobalRegistry {
                                description = "Handles global module registry and forcepools";
																file = PATHTO_FUNC(MLGlobalRegistry);
                                recompile = RECOMPILE;
                        };
                        class MLLoadData {
                                description = "Load persistent data";
																file = PATHTO_FUNC(MLLoadData);
                                recompile = RECOMPILE;
                        };
                        class MLSaveData {
                                description = "Save persistent data";
																file = PATHTO_FUNC(MLSaveData);
                                recompile = RECOMPILE;
                        };
                };
        };
};
