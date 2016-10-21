class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class playeroptions {
                                description = "The main class";
                                file = "\x\alive\addons\sys_playeroptions\fnc_playeroptions.sqf";
                                RECOMPILE;
                        };
                        class playeroptionsInit {
                                description = "The module initialisation function";
                                file = "\x\alive\addons\sys_playeroptions\fnc_playeroptionsInit.sqf";
                                RECOMPILE;
                        };
                        class playeroptionsMenuDef {
                                description = "The menu definition function";
                                file = "\x\alive\addons\sys_playeroptions\fnc_playeroptionsMenuDef.sqf";
                                                                RECOMPILE;
                        };
                };
        };
};