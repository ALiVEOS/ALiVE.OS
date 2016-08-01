class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class crewinfo {
                                description = "The main class";
																file = PATHTO_FUNC(crewinfo);
                                                                recompile = RECOMPILE;
                        };
                        class crewinfoInit {
                                description = "The module initialisation function";
																file = PATHTO_FUNC(crewinfoInit);
                                                                recompile = RECOMPILE;
                        };
                                              class crewinfoClient {
                               description = "The module script";
																file = PATHTO_FUNC(crewinfoClient);
                                                                recompile = RECOMPILE;
                        };
                };
        };
};
