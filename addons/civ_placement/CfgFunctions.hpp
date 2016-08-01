class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class CP {
                                description = "The main class";
                                file = PATHTO_FUNC(CP);
                                recompile = RECOMPILE;
                        };
                        class CPInit {
                                description = "The module initialisation function";
                                file = PATHTO_FUNC(CPInit);
                                recompile = RECOMPILE;
                        };
            class civClusterGeneration {
                                description = "Generates static cluster output";
                                file = PATHTO_FUNC(civClusterGeneration);
                                recompile = RECOMPILE;
                        };
                        class auto_civClusterGeneration {
                                description = "Auto generates static cluster output";
                                file = PATHTO_FUNC(auto_civClusterGeneration);
                                recompile = RECOMPILE;
                        };
                        class createRoadblock {
                                description = "Create a road block";
                                file = PATHTO_FUNC(createRoadblock);
                                recompile = 1;
                        };
                };
        };
};
