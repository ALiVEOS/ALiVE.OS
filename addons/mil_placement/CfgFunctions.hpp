class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class MP {
                                description = "The main class";
																file = PATHTO_FUNC(MP);
                                recompile = RECOMPILE;
                        };
                        class MPInit {
                                description = "The module initialisation function";
																file = PATHTO_FUNC(MPInit);
                                recompile = RECOMPILE;
                        };
            class milClusterGeneration {
                                description = "Generates static cluster output";
																file = PATHTO_FUNC(milClusterGeneration);
                                recompile = RECOMPILE;
                        };
                        class auto_milClusterGeneration {
                                description = "Auto generates static cluster output";
																file = PATHTO_FUNC(auto_milClusterGeneration);
                                recompile = RECOMPILE;
                        };
                };
        };
};
