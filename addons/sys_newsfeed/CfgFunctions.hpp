class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class newsFeed {
                                description = "The main class";
                                file = "\x\alive\addons\sys_newsfeed\fnc_newsFeed.sqf";
				recompile = RECOMPILE;
                        };
                        class newsFeedInit {
                                description = "The module initialisation function";
                                file = "\x\alive\addons\sys_newsfeed\fnc_newsFeedInit.sqf";
				recompile = RECOMPILE;
                        };
                        class newsFeedMenuDef {
                                description = "The module menu definition";
                                file = "\x\alive\addons\sys_newsfeed\fnc_newsFeedMenuDef.sqf";
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

