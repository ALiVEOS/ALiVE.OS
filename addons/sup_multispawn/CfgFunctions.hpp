class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class multispawn {
                                description = "The main class";
																file = PATHTO_FUNC(multispawn);
                                recompile = RECOMPILE;
                        };
                        class multispawnInit {
                                description = "The module initialisation function";
																file = PATHTO_FUNC(multispawnInit);
                                recompile = RECOMPILE;
                        };
                        class multispawnMenuDef {
                                description = "The module menu definition";
																file = PATHTO_FUNC(multispawnMenuDef);
                                recompile = RECOMPILE;
                        };
                        class forwardSpawn {
                                description = "The spawn function that lets you selects a group unit and spawn near it";
																file = PATHTO_FUNC(forwardSpawn);
                                recompile = RECOMPILE;
                        };
                        class establishingShotCustom {
                                description = "Camera waiting scene for insertion";
																file = PATHTO_FUNC(establishingShotCustom);
                                recompile = RECOMPILE;
                        };
                };
        };
};
