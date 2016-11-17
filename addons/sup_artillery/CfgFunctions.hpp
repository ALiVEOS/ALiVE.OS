class cfgFunctions {
    class PREFIX {
        class COMPONENT {
            class ARTILLERY {
                description = "The main class";
                file = "\x\alive\addons\sup_artillery\fnc_artillery.sqf";
                RECOMPILE;
            };
            class artilleryInit {
                description = "The module initialisation function";
                file = "\x\alive\addons\sup_artillery\fnc_artilleryInit.sqf";
                RECOMPILE;
            };
            class artillerySpawn {
                description = "Spawns artillery assets";
                file = "\x\alive\addons\sup_artillery\fnc_artillerySpawn.sqf";
                RECOMPILE;
            };
        };
    };
};
