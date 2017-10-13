class cfgFunctions {
    class PREFIX {
        class COMPONENT {
            class buttonAbort {
                description = "Calls any scripts required when the user disconnects";
                file = "\x\alive\addons\main\fnc_buttonAbort.sqf";
                RECOMPILE;
            };
            class aliveInit {
                description = "ALiVE init function";
                file = "\x\alive\addons\main\fnc_aliveInit.sqf";
                RECOMPILE;
            };
            class Nuke {
                description = "Fires a Nuke at given position";
                file = "\x\alive\addons\main\fnc_Nuke.sqf";
                RECOMPILE;
            };
            class isModuleSynced {
                description = "Checks if modules are synced";
                file = "\x\alive\addons\main\fnc_isModuleSynced.sqf";
                RECOMPILE;
            };
            class isModuleAvailable {
                description = "Checks if modules are available";
                file = "\x\alive\addons\main\fnc_isModuleAvailable.sqf";
                RECOMPILE;
            };
            class versioning {
                description = "Warns or kicks players on version mismatch";
                file = "\x\alive\addons\main\fnc_versioning.sqf";
                RECOMPILE;
            };
            class isModuleInitialised {
                description = "Checks if given modules are initialised";
                file = "\x\alive\addons\main\fnc_isModuleInitialised.sqf";
                RECOMPILE;
            };
            class pauseModule {
                description = "Pauses given module(s)";
                file = "\x\alive\addons\main\fnc_pauseModule.sqf";
                RECOMPILE;
            };
            class unPauseModule {
                description = "activates given module(s) after pausing";
                file = "\x\alive\addons\main\fnc_unPauseModule.sqf";
                RECOMPILE;
            };
            class pauseModulesAuto {
                description = "Adds EHs to pause all main modules if no players are on server";
                file = "\x\alive\addons\main\fnc_pauseModulesAuto.sqf";
                RECOMPILE;
            };
            class ZEUSinit {
                description = "Initialises Zeus for ALiVE";
                file = "\x\alive\addons\main\fnc_ZEUSinit.sqf";
                RECOMPILE;
            };
            class mainTablet {
                description = "ALiVE Main Tablet";
                file = "\x\alive\addons\main\fnc_mainTablet.sqf";
                RECOMPILE;
            };
            class AI_Distributor {
                description = "Distributes AI to all headless clients";
                file = "\x\alive\addons\main\fnc_AI_Distributor.sqf";
                RECOMPILE;
            };
            class staticDataHandler {
                description = "Serializes loading of staticData";
                file = "\x\alive\addons\main\fnc_staticDataHandler.sqf";
                RECOMPILE;
            };
        };
    };
};
