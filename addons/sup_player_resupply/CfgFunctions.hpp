class CfgFunctions {
    class PREFIX {
        class COMPONENT {
            class PR {
                description = "The main class";
								file = PATHTO_FUNC(PR);
                recompile = RECOMPILE;
            };
            class PRInit {
                description = "The module initialisation function";
								file = PATHTO_FUNC(PRInit);
                recompile = RECOMPILE;
            };
            class PRMenuDef {
                description = "The module menu definition";
								file = PATHTO_FUNC(PRMenuDef);
                recompile = RECOMPILE;
            };
            class PRTabletOnAction {
                description = "The module Radio Action function";
								file = PATHTO_FUNC(PRTabletOnAction);
                recompile = RECOMPILE;
            };
            class PRTabletOnLoad {
                description = "The module tablet on load function";
								file = PATHTO_FUNC(PRTabletOnLoad);
                recompile = RECOMPILE;
            };
            class PRTabletOnUnLoad {
                description = "The module tablet on unload function";
								file = PATHTO_FUNC(PRTabletOnUnLoad);
                recompile = RECOMPILE;
            };
            class PRTabletEventToClient {
                description = "Call the tablet on the client from the server";
								file = PATHTO_FUNC(PRTabletEventToClient);
                recompile = RECOMPILE;
            };
        };
    };
};
