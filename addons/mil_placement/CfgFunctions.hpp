class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class MP {
                                description = "The main class";
                                file = "\x\alive\addons\mil_placement\fnc_MP.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class MPInit {
                                description = "The module initialisation function";
                                file = "\x\alive\addons\mil_placement\fnc_MPInit.sqf";
                                ALIVE_RECOMPILE;
                        };
            class milClusterGeneration {
                                description = "Generates static cluster output";
                                file = "\x\alive\addons\mil_placement\fnc_milClusterGeneration.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class auto_milClusterGeneration {
                                description = "Auto generates static cluster output";
                                file = "\x\alive\addons\mil_placement\fnc_auto_milClusterGeneration.sqf";
                                ALIVE_RECOMPILE;
                        };
                };
        };
};
