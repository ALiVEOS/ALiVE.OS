class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class AMBCP {
                                description = "The main class";
                                file = "\x\alive\addons\amb_civ_placement\fnc_AMBCP.sqf";
                                RECOMPILE;
                        };
                        class AMBCPInit {
                                description = "The module initialisation function";
                                file = "\x\alive\addons\amb_civ_placement\fnc_AMBCPInit.sqf";
                                RECOMPILE;
                        };
                        class AMBCPSpawnAnimalGroups {
                                description = "Spawn the supplied ambient animal groups";
                                file = "\x\alive\addons\amb_civ_placement\fnc_AMBCPSpawnAnimalGroups.sqf";
                                RECOMPILE;
                        };
                        class AMBCPDespawnAnimalGroups {
                                description = "Despawn the supplied ambient animal groups";
                                file = "\x\alive\addons\amb_civ_placement\fnc_AMBCPDespawnAnimalGroups.sqf";
                                RECOMPILE;
                        };
                };
        };
};
