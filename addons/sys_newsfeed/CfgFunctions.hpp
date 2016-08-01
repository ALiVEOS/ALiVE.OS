class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class newsFeed {
                                description = "The main class";
																file = PATHTO_FUNC(newsFeed);
                                recompile = RECOMPILE;
                        };
                        class newsFeedInit {
                                description = "The module initialisation function";
																file = PATHTO_FUNC(newsFeedInit);
                                recompile = RECOMPILE;
                        };
                        class newsFeedMenuDef {
                                description = "The module menu definition";
																file = PATHTO_FUNC(newsFeedMenuDef);
                                recompile = RECOMPILE;
                        };
                         class newsFeedMenuInit {
                                description = "The module menu definition";
                                file = "\x\alive\addons\sys_newsfeed\newsfeed\newsfeed_init.sqf";
                                recompile = RECOMPILE;
                        };
                };
        };
};
