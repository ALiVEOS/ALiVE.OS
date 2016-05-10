class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class convoy {
                                description = "The main class";
                                file = "\x\alive\addons\mil_convoy\fnc_convoy.sqf";
				recompile = RECOMPILE;
                        };
                        class CONVOYInit {
                                description = "The module initialisation function";
                                file = "\x\alive\addons\mil_convoy\fnc_CONVOYInit.sqf";
				recompile = RECOMPILE;
                        };
                        class addVehicle {
                                description = "Add vehicles";
                                file = "\x\alive\addons\mil_convoy\fnc_addVehicle.sqf";
                recompile = RECOMPILE;
                        };
                         class inTrigger {
                                description = "Random Group by Type";
                                file = "\x\alive\addons\mil_convoy\fnc_inTrigger.sqf";
								recompile = RECOMPILE;
                        };
						class findLocations {
                                description = "Find Locations";
                                file = "\x\alive\addons\mil_convoy\fnc_findLocations.sqf";
								recompile = RECOMPILE;
                        };
                        class startConvoy {
                                description = "Random Group by Type";
                                file = "\x\alive\addons\mil_convoy\fnc_startConvoy.sqf";
								recompile = RECOMPILE;
                        };
                   };     
        };
};
