class CfgFunctions {
    class PREFIX {
        class COMPONENT {
            class SCOM {
                description = "The main class";
								file = PATHTO_FUNC(SCOM);
                recompile = RECOMPILE;
            };
            class SCOMInit {
                description = "The module initialisation function";
								file = PATHTO_FUNC(SCOMInit);
                recompile = RECOMPILE;
            };
            class SCOMTabletOnAction {
                description = "The module Radio Action function";
								file = PATHTO_FUNC(SCOMTabletOnAction);
                recompile = RECOMPILE;
            };
            class SCOMTabletOnLoad {
                description = "The module tablet on load function";
								file = PATHTO_FUNC(SCOMTabletOnLoad);
                recompile = RECOMPILE;
            };
            class SCOMTabletOnUnLoad {
                description = "The module tablet on unload function";
								file = PATHTO_FUNC(SCOMTabletOnUnload);
                recompile = RECOMPILE;
            };
            class SCOMTabletEventToClient {
                description = "Call the tablet on the client from the server";
								file = PATHTO_FUNC(SCOMTabletEventToClient);
                recompile = RECOMPILE;
            };
            class commandHandler {
                description = "Command Handler";
								file = PATHTO_FUNC(commandHandler);
                recompile = RECOMPILE;
            };
        };
    };
};
