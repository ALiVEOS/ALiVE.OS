class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                    class indexer {
                        description = "The main class";
                        file = "\x\alive\addons\sys_indexer\fnc_indexer.sqf";
                        recompile = RECOMPILE;
                    };
                    class indexerInit {
                        description = "The module initialisation function";
                        file = "\x\alive\addons\sys_indexer\fnc_indexerInit.sqf";
                        recompile = RECOMPILE;
                    };
                    class indexerMenuDef {
                        description = "The module menu definition";
                        file = "\x\alive\addons\sys_indexer\fnc_indexerMenuDef.sqf";
                        recompile = RECOMPILE;
                    };
                    class indexMap
                    {
                        file = "\x\alive\addons\sys_indexer\fnc_indexMap.sqf";
                        ext = ".sqf";
                        recompile = RECOMPILE;
                    };
                    class auto_staticObjects {
                        description = "ALiVE object viewer";
                        file = "\x\alive\addons\sys_indexer\fnc_auto_staticObjects.sqf";
                        recompile = RECOMPILE;
                    };
                    class autoUpdateStaticData {
                        description = "ALiVE index static data update UI";
                        file = "\x\alive\addons\sys_indexer\fnc_autoUpdateStaticData.sqf";
                        recompile = RECOMPILE;
                    };
                };
        };
};

