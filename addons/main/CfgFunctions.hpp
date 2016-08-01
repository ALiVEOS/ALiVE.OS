class cfgFunctions {
    class PREFIX {
        class COMPONENT {
            class buttonAbort {
                description = "Calls any scripts required when the user disconnects";
                file = PATHTO_FUNC(buttonAbort);
                recompile = RECOMPILE;
            };
            class aliveInit {
                description = "ALiVE init function";
                file = PATHTO_FUNC(aliveInit);
                recompile = RECOMPILE;
            };
            class Nuke {
                description = "Fires a Nuke at given position";
                file = PATHTO_FUNC(Nuke);
                recompile = RECOMPILE;
            };
            class isModuleSynced {
                description = "Checks if modules are synced";
                file = PATHTO_FUNC(isModuleSynced);
                recompile = RECOMPILE;
            };
            class isModuleAvailable {
                description = "Checks if modules are available";
                file = PATHTO_FUNC(isModuleAvailable);
                recompile = RECOMPILE;
            };
            class versioning {
                description = "Warns or kicks players on version mismatch";
                file = PATHTO_FUNC(versioning);
                recompile = RECOMPILE;
            };
            class isModuleInitialised {
                description = "Checks if given modules are initialised";
                file = PATHTO_FUNC(isModuleInitialised);
                recompile = RECOMPILE;
            };
            class pauseModule {
                description = "Pauses given module(s)";
                file = PATHTO_FUNC(pauseModule);
                recompile = RECOMPILE;
            };
            class unPauseModule {
                description = "activates given module(s) after pausing";
                file = PATHTO_FUNC(unPauseModule);
                recompile = RECOMPILE;
            };
            class pauseModulesAuto {
                description = "Adds EHs to pause all main modules if no players are on server";
                file = PATHTO_FUNC(pauseModulesAuto);
                recompile = RECOMPILE;
            };
            class ZEUSinit {
                description = "Initialises Zeus for ALiVE";
                file = PATHTO_FUNC(ZEUSinit);
                recompile = RECOMPILE;
            };
            class mainTablet {
                description = "ALiVE Main Tablet";
                file = PATHTO_FUNC(mainTablet);
                recompile = RECOMPILE;
            };
            class AI_Distributor {
                description = "Distributes AI to all headless clients";
                file = PATHTO_FUNC(AI_Distributor);
                recompile = RECOMPILE;
            };
        };
    };
};
