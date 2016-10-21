class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                    class indexer {
                        description = "The main class";
                        file = "\x\alive\addons\sys_indexer\fnc_indexer.sqf";
                        RECOMPILE;
                    };
                    class indexerInit {
                        description = "The module initialisation function";
                        file = "\x\alive\addons\sys_indexer\fnc_indexerInit.sqf";
                        RECOMPILE;
                    };
                    class indexerMenuDef {
                        description = "The module menu definition";
                        file = "\x\alive\addons\sys_indexer\fnc_indexerMenuDef.sqf";
                        RECOMPILE;
                    };
                    class indexMap
                    {
                        file = "\x\alive\addons\sys_indexer\fnc_indexMap.sqf";
                        ext = ".sqf";
                        RECOMPILE;
                    };
                    class auto_staticObjects {
                        description = "ALiVE object viewer";
                        file = "\x\alive\addons\sys_indexer\fnc_auto_staticObjects.sqf";
                        RECOMPILE;
                    };
                    class autoUpdateStaticData {
                        description = "ALiVE index static data update UI";
                        file = "\x\alive\addons\sys_indexer\fnc_autoUpdateStaticData.sqf";
                        RECOMPILE;
                    };
                };
        };
};

