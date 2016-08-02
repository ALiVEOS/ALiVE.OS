class cfgFunctions {
        class PREFIX {
                class COMPONENT {
										FUNC_FILEPATH(indexer,"The main class");
										FUNC_FILEPATH(indexerInit,"The module initialisation function");
										FUNC_FILEPATH(indexerMenuDef,"The module menu definition");
                    class indexMap {
												file = PATHTO_FUNC(indexMap);
                        ext = ".sqf";
                        recompile = RECOMPILE;
                    };
                    FUNC_FILEPATH(auto_staticObjects,"ALiVE object viewer");
                    FUNC_FILEPATH(autoUpdateStaticData,"ALiVE index static data update UI")
                };
        };
};
