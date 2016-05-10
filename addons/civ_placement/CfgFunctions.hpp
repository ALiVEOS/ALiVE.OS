class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class CP {
                                description = "The main class";
                                file = "\x\alive\addons\civ_placement\fnc_CP.sqf";
                                recompile = RECOMPILE;
                        };
                        class CPInit {
                                description = "The module initialisation function";
                                file = "\x\alive\addons\civ_placement\fnc_CPInit.sqf";
                                recompile = RECOMPILE;
                        };
			class civClusterGeneration {
                                description = "Generates static cluster output";
                                file = "\x\alive\addons\civ_placement\fnc_civClusterGeneration.sqf";
                                recompile = RECOMPILE;
                        };
                        class auto_civClusterGeneration {
                                description = "Auto generates static cluster output";
                                file = "\x\alive\addons\civ_placement\fnc_auto_civClusterGeneration.sqf";
                                recompile = RECOMPILE;
                        };
                        class createRoadblock {
                                description = "Create a road block";
                                file = "\x\alive\addons\civ_placement\fnc_createRoadblock.sqf";
                                recompile = 1;
                        };
                };
        };
};
