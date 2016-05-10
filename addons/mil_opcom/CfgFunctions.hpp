class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class OPCOM {
                                description = "The main class";
                                file = "\x\alive\addons\mil_opcom\fnc_OPCOM.sqf";
                                recompile = RECOMPILE;
                        };
                        class OPCOMInit {
                                description = "The module initialisation function";
                                file = "\x\alive\addons\mil_opcom\fnc_OPCOMInit.sqf";
                                recompile = RECOMPILE;
                        };
                        class OPCOMpositions {
                                description = "Selects OPCOM objective positions of given state";
                                file = "\x\alive\addons\mil_opcom\fnc_OPCOMpositions.sqf";
                                recompile = RECOMPILE;
                        };
						class OPCOMLoadData {
                                description = "Loads OPCOM state from DB";
                                file = "\x\alive\addons\mil_opcom\fnc_OPCOMLoadData.sqf";
                                recompile = RECOMPILE;
                        };
						class OPCOMSaveData {
                                description = "Saves OPCOM state from DB";
                                file = "\x\alive\addons\mil_opcom\fnc_OPCOMSaveData.sqf";
                                recompile = RECOMPILE;
                        };
                        class OPCOMjoinNearestGroup {
                                description = "Joins the given unit to the nearest group of given state (attacking/defending)";
                                file = "\x\alive\addons\mil_opcom\fnc_OPCOMjoinNearestGroup.sqf";
								recompile = RECOMPILE;
                        };
                        class OPCOMJoinObjective {
                                description = "Joins the given unit to a group that is attacking/defending the selected objective!";
                                file = "\x\alive\addons\mil_opcom\fnc_OPCOMJoinObjective.sqf";
								recompile = RECOMPILE;
                        };
                        class OPCOMToggleInstallations {
                                description = "Toggles Installation markers on / off";
                                file = "\x\alive\addons\mil_opcom\fnc_OPCOMToggleInstallations.sqf";
								recompile = RECOMPILE;
                        };                        
                        class updateSectorHostility {
                                description = "Updates the current sector of position with given value";
                                file = "\x\alive\addons\mil_opcom\fnc_updateSectorHostility.sqf";
								recompile = RECOMPILE;
                        };
                        class INS_helpers {
                                description = "Loads the parent function for the Insurgency helper functions";
                                file = "\x\alive\addons\mil_opcom\fnc_INS_helpers.sqf";
								recompile = RECOMPILE;
                        };
                        class OPCOMDropIntel {
                                description = "Drops Intel by chance";
                                file = "\x\alive\addons\mil_opcom\fnc_OPCOMDropIntel.sqf";
								recompile = RECOMPILE;
                        };                        
                };
        };
};
