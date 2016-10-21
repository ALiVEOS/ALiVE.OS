class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class multispawn {
                                description = "The main class";
                                file = "\x\alive\addons\sup_multispawn\fnc_multispawn.sqf";
                                RECOMPILE;
                        };
                        class multispawnInit {
                                description = "The module initialisation function";
                                file = "\x\alive\addons\sup_multispawn\fnc_multispawnInit.sqf";
                                RECOMPILE;
                        };
                        class multispawnMenuDef {
                                description = "The module menu definition";
                                file = "\x\alive\addons\sup_multispawn\fnc_multispawnMenuDef.sqf";
                                RECOMPILE;
                        };
                        class forwardSpawn {
                                description = "The spawn function that lets you selects a group unit and spawn near it";
                                file = "\x\alive\addons\sup_multispawn\fnc_forwardSpawn.sqf";
                                RECOMPILE;
                        };
                        class establishingShotCustom {
                                description = "Camera waiting scene for insertion";
                                file = "\x\alive\addons\sup_multispawn\fnc_establishingShotCustom.sqf";
                                RECOMPILE;
                        };
                };
        };
};
