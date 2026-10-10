class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class multispawn {
                                description = "The main class";
                                file = "\x\alive\addons\sup_multispawn\fnc_multispawn.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class multispawnInit {
                                description = "The module initialisation function";
                                file = "\x\alive\addons\sup_multispawn\fnc_multispawnInit.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class multispawnMenuDef {
                                description = "The module menu definition";
                                file = "\x\alive\addons\sup_multispawn\fnc_multispawnMenuDef.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class forwardSpawn {
                                description = "The spawn function that lets you selects a group unit and spawn near it";
                                file = "\x\alive\addons\sup_multispawn\fnc_forwardSpawn.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class establishingShotCustom {
                                description = "Camera waiting scene for insertion";
                                file = "\x\alive\addons\sup_multispawn\fnc_establishingShotCustom.sqf";
                                ALIVE_RECOMPILE;
                        };
                };
        };
};
