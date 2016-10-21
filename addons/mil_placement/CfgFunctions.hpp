class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class MP {
                                description = "The main class";
                                file = "\x\alive\addons\mil_placement\fnc_MP.sqf";
                                RECOMPILE;
                        };
                        class MPInit {
                                description = "The module initialisation function";
                                file = "\x\alive\addons\mil_placement\fnc_MPInit.sqf";
                                RECOMPILE;
                        };
            class milClusterGeneration {
                                description = "Generates static cluster output";
                                file = "\x\alive\addons\mil_placement\fnc_milClusterGeneration.sqf";
                                RECOMPILE;
                        };
                        class auto_milClusterGeneration {
                                description = "Auto generates static cluster output";
                                file = "\x\alive\addons\mil_placement\fnc_auto_milClusterGeneration.sqf";
                                RECOMPILE;
                        };
                };
        };
};
