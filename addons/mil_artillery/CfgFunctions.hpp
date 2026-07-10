class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class MilArtillery {
                                description = "The main class";
                                file = "\x\alive\addons\mil_artillery\fnc_ARTILLERY.sqf";
                                RECOMPILE;
                        };
                        class MilArtilleryInit {
                                description = "The module initialisation function";
                                file = "\x\alive\addons\mil_artillery\fnc_ARTILLERYInit.sqf";
                                RECOMPILE;
                        };
                        class MilArtilleryFireMission {
                                description = "Executes one AI fire mission";
                                file = "\x\alive\addons\mil_artillery\fnc_ARTILLERY_fireMission.sqf";
                                RECOMPILE;
                        };
                };
        };
};
