class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class GCAbandoned {
                                description = "Removes or wrecks abandoned enemy vehicle profiles";
                                file = "\x\alive\addons\sys_GC\fnc_GCAbandoned.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class vehicleAbandoned {
                                description = "Whether a land vehicle profile is abandoned";
                                file = "\x\alive\addons\sys_GC\fnc_vehicleAbandoned.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class GC {
                                description = "The main class";
                                file = "\x\alive\addons\sys_GC\fnc_GC.sqf";
                                ALIVE_RECOMPILE;
                        };
                };
        };
};
