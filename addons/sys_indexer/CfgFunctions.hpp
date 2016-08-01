class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                    class indexer {
                        description = "The main class";
												file = PATHTO_FUNC(indexer);
                        recompile = RECOMPILE;
                    };
                    class indexerInit {
                        description = "The module initialisation function";
												file = PATHTO_FUNC(indexerInit);
                        recompile = RECOMPILE;
                    };
                    class indexerMenuDef {
                        description = "The module menu definition";
												file = PATHTO_FUNC(indexerMenuDef);
                        recompile = RECOMPILE;
                    };
                    class indexMap
                    {
												file = PATHTO_FUNC(indexMap);
                        ext = ".sqf";
                        recompile = RECOMPILE;
                    };
                    class auto_staticObjects {
                        description = "ALiVE object viewer";
												file = PATHTO_FUNC(auto_staticObjects);
                        recompile = RECOMPILE;
                    };
                    class autoUpdateStaticData {
                        description = "ALiVE index static data update UI";
												file = PATHTO_FUNC(autoUpdateStaticData);
                        recompile = RECOMPILE;
                    };
                };
        };
};
