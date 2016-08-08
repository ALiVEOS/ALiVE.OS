class cfgFunctions {
    class PREFIX {
        class COMPONENT {
            FUNC_FILEPATH(CP,"The main class");
            FUNC_FILEPATH(CPInit,"The module initialisation function");
            FUNC_FILEPATH(civClusterGeneration,"Generates static cluster output");
            FUNC_FILEPATH(auto_civClusterGeneration,"Auto generates static cluster output");
            class createRoadblock {
                description = "Create a road block";
                file = PATHTO_FUNC(createRoadblock);
                recompile = 1;
            };
        };
    };
};
