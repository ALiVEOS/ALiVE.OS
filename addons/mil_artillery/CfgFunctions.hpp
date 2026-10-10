class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class MilArtillery {
                                description = "The main class";
                                file = "\x\alive\addons\mil_artillery\fnc_ARTILLERY.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class MilArtilleryInit {
                                description = "The module initialisation function";
                                file = "\x\alive\addons\mil_artillery\fnc_ARTILLERYInit.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class MilArtilleryFireMission {
                                description = "Executes one AI fire mission";
                                file = "\x\alive\addons\mil_artillery\fnc_ARTILLERY_fireMission.sqf";
                                ALIVE_RECOMPILE;
                        };
                };
        };
};
