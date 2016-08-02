class cfgFunctions {
        class PREFIX {
                class COMPONENT {
												FUNC_FILEPATH(newsFeed,"The main class");
												FUNC_FILEPATH(newsFeedInit,"The module initialisation function");
												FUNC_FILEPATH(newsFeedMenuDef,"The module menu definition");
                         class newsFeedMenuInit {
                                description = "The module menu definition";
                                file = "\x\alive\addons\sys_newsfeed\newsfeed\newsfeed_init.sqf";
                                recompile = RECOMPILE;
                        };
                };
        };
};
