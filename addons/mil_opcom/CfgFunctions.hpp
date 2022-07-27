class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class OPCOM {
                                description = "The main class";
                                file = "\x\alive\addons\mil_opcom\fnc_OPCOM.sqf";
                                RECOMPILE;
                        };
                        class OPCOMInit {
                                description = "The module initialisation function";
                                file = "\x\alive\addons\mil_opcom\fnc_OPCOMInit.sqf";
                                RECOMPILE;
                        };
                        class OPCOMpositions {
                                description = "Selects OPCOM objective positions of given state";
                                file = "\x\alive\addons\mil_opcom\fnc_OPCOMpositions.sqf";
                                RECOMPILE;
                        };
                        class OPCOMLoadData {
                                description = "Loads OPCOM state from DB";
                                file = "\x\alive\addons\mil_opcom\fnc_OPCOMLoadData.sqf";
                                RECOMPILE;
                        };
                        class OPCOMSaveData {
                                description = "Saves OPCOM state from DB";
                                file = "\x\alive\addons\mil_opcom\fnc_OPCOMSaveData.sqf";
                                RECOMPILE;
                        };
                        class OPCOMjoinNearestGroup {
                                description = "Joins the given unit to the nearest group of given state (attacking/defending)";
                                file = "\x\alive\addons\mil_opcom\fnc_OPCOMjoinNearestGroup.sqf";
                                RECOMPILE;
                        };
                        class OPCOMJoinObjective {
                                description = "Joins the given unit to a group that is attacking/defending the selected objective!";
                                file = "\x\alive\addons\mil_opcom\fnc_OPCOMJoinObjective.sqf";
                                RECOMPILE;
                        };
                        class OPCOMToggleInstallations {
                                description = "Toggles Installation markers on / off";
                                file = "\x\alive\addons\mil_opcom\fnc_OPCOMToggleInstallations.sqf";
                                RECOMPILE;
                        };
                        class updateSectorHostility {
                                description = "Updates the current sector of position with given value";
                                file = "\x\alive\addons\mil_opcom\fnc_updateSectorHostility.sqf";
                                RECOMPILE;
                        };
                        class INS_helpers {
                                description = "Loads the parent function for the Insurgency helper functions";
                                file = "\x\alive\addons\mil_opcom\fnc_INS_helpers.sqf";
                                RECOMPILE;
                        };
                        class OPCOMDropIntel {
                                description = "Drops Intel by chance";
                                file = "\x\alive\addons\mil_opcom\fnc_OPCOMDropIntel.sqf";
                                RECOMPILE;
                        };
                        class OPCOMgetHighestPrioObjective {
                                description = "Drops Intel by chance";
                                file = "\x\alive\addons\mil_opcom\fnc_OPCOMgetHighestPrioObjective.sqf";
                                RECOMPILE;
                        };                        
                };
        };
};
