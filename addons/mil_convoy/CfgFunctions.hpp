class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class convoy {
                                description = "The main class";
                                file = "\x\alive\addons\mil_convoy\fnc_convoy.sqf";
                ALIVE_RECOMPILE;
                        };
                        class CONVOYInit {
                                description = "The module initialisation function";
                                file = "\x\alive\addons\mil_convoy\fnc_CONVOYInit.sqf";
                ALIVE_RECOMPILE;
                        };
                        class addVehicle {
                                description = "Add vehicles";
                                file = "\x\alive\addons\mil_convoy\fnc_addVehicle.sqf";
                ALIVE_RECOMPILE;
                        };
                         class inTrigger {
                                description = "Random Group by Type";
                                file = "\x\alive\addons\mil_convoy\fnc_inTrigger.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class findLocations {
                                description = "Find Locations";
                                file = "\x\alive\addons\mil_convoy\fnc_findLocations.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class startConvoy {
                                description = "Random Group by Type";
                                file = "\x\alive\addons\mil_convoy\fnc_startConvoy.sqf";
                                ALIVE_RECOMPILE;
                        };
                   };
        };
};
