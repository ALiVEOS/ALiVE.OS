class CfgFunctions {
    class PREFIX {
        class COMPONENT {
            class xStream {
                description = "The main class";
								file = PATHTO_FUNC(xstream);
                recompile = RECOMPILE;
            };
            class xStreamInit {
                description = "The module initialisation function";
								file = PATHTO_FUNC(xStreamInit);
                recompile = RECOMPILE;
            };
            class xStreamMenuDef {
                description = "The module menu definition";
								file = PATHTO_FUNC(xStreamMenuDef);
                recompile = RECOMPILE;
            };
            class camera {
                description = "The module camera function";
								file = PATHTO_FUNC(camera);
                recompile = RECOMPILE;
            };
        };
    };
};
