class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class CP {
                                description = "The main class";
                                file = "\x\alive\addons\civ_placement\fnc_CP.sqf";
                                RECOMPILE;
                        };
                        class CPInit {
                                description = "The module initialisation function";
                                file = "\x\alive\addons\civ_placement\fnc_CPInit.sqf";
                                RECOMPILE;
                        };
            class civClusterGeneration {
                                description = "Generates static cluster output";
                                file = "\x\alive\addons\civ_placement\fnc_civClusterGeneration.sqf";
                                RECOMPILE;
                        };
                        class auto_civClusterGeneration {
                                description = "Auto generates static cluster output";
                                file = "\x\alive\addons\civ_placement\fnc_auto_civClusterGeneration.sqf";
                                RECOMPILE;
                        };
                        class createRoadblock {
                                description = "Create a road block";
                                file = "\x\alive\addons\civ_placement\fnc_createRoadblock.sqf";
                                recompile = 1;
                        };
                        class RB_captureWatchdog {
                                description = "Per-roadblock capture watchdog: 5s PFH that flips ownership when defenders die and attackers hold for 30s";
                                file = "\x\alive\addons\civ_placement\fnc_RB_captureWatchdog.sqf";
                                recompile = 1;
                        };
                        class RB_recapture {
                                description = "Re-garrison a captured roadblock under a new faction; mutates anchor state";
                                file = "\x\alive\addons\civ_placement\fnc_RB_recapture.sqf";
                                recompile = 1;
                        };
                };
        };
};
