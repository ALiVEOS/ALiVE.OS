class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class convoy {
                                description = "The main class";
                                file = "\x\alive\addons\mil_convoy\fnc_convoy.sqf";
                RECOMPILE;
                        };
                        class CONVOYInit {
                                description = "The module initialisation function";
                                file = "\x\alive\addons\mil_convoy\fnc_CONVOYInit.sqf";
                RECOMPILE;
                        };
                        class addVehicle {
                                description = "Add vehicles";
                                file = "\x\alive\addons\mil_convoy\fnc_addVehicle.sqf";
                RECOMPILE;
                        };
                         class inTrigger {
                                description = "Random Group by Type";
                                file = "\x\alive\addons\mil_convoy\fnc_inTrigger.sqf";
                                RECOMPILE;
                        };
                        class findLocations {
                                description = "Find Locations";
                                file = "\x\alive\addons\mil_convoy\fnc_findLocations.sqf";
                                RECOMPILE;
                        };
                        class startConvoy {
                                description = "Random Group by Type";
                                file = "\x\alive\addons\mil_convoy\fnc_startConvoy.sqf";
                                RECOMPILE;
                        };
                   };
        };
};
