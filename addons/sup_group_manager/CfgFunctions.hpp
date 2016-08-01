class CfgFunctions {
    class PREFIX {
        class COMPONENT {
            class GM {
                description = "The main class";
								file = PATHTO_FUNC(GM);
                recompile = RECOMPILE;
            };
            class GMInit {
                description = "The module initialisation function";
								file = PATHTO_FUNC(GMInit);
                recompile = RECOMPILE;
            };
            class GMTabletOnAction {
                description = "The module Radio Action function";
								file = PATHTO_FUNC(GMTabletOnAction);
                recompile = RECOMPILE;
            };
            class GMTabletOnLoad {
                description = "The module tablet on load function";
								file = PATHTO_FUNC(GMTabletOnLoad);
                recompile = RECOMPILE;
            };
            class GMTabletOnUnLoad {
                description = "The module tablet on unload function";
								file = PATHTO_FUNC(GMTabletOnUnLoad);
                recompile = RECOMPILE;
            };
            class GMTabletEventToClient {
                description = "Call the tablet on the client from the server";
								file = PATHTO_FUNC(GMTabletEventToClient);
                recompile = RECOMPILE;
            };
            class groupHandler {
                description = "Group Handler";
								file = PATHTO_FUNC(groupHandler);
                recompile = RECOMPILE;
            };
        };
    };
};
