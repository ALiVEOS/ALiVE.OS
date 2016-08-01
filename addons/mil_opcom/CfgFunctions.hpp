class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class OPCOM {
                                description = "The main class";
																file = PATHTO_FUNC(OPCOM);
                                recompile = RECOMPILE;
                        };
                        class OPCOMInit {
                                description = "The module initialisation function";
																file = PATHTO_FUNC(OPCOMInit);
                                recompile = RECOMPILE;
                        };
                        class OPCOMpositions {
                                description = "Selects OPCOM objective positions of given state";
																file = PATHTO_FUNC(OPCOMpositions);
                                recompile = RECOMPILE;
                        };
                        class OPCOMLoadData {
                                description = "Loads OPCOM state from DB";
																file = PATHTO_FUNC(OPCOMLoadData);
                                recompile = RECOMPILE;
                        };
                        class OPCOMSaveData {
                                description = "Saves OPCOM state from DB";
																file = PATHTO_FUNC(OPCOMSaveData);
                                recompile = RECOMPILE;
                        };
                        class OPCOMjoinNearestGroup {
                                description = "Joins the given unit to the nearest group of given state (attacking/defending)";
																file = PATHTO_FUNC(OPCOMjoinNearestGroup);
                                recompile = RECOMPILE;
                        };
                        class OPCOMJoinObjective {
                                description = "Joins the given unit to a group that is attacking/defending the selected objective!";
																file = PATHTO_FUNC(OPCOMJoinObjective);
                                recompile = RECOMPILE;
                        };
                        class OPCOMToggleInstallations {
                                description = "Toggles Installation markers on / off";
																file = PATHTO_FUNC(OPCOMToggleInstallations);
                                recompile = RECOMPILE;
                        };
                        class updateSectorHostility {
                                description = "Updates the current sector of position with given value";
																file = PATHTO_FUNC(updateSectorHostility);
                                recompile = RECOMPILE;
                        };
                        class INS_helpers {
                                description = "Loads the parent function for the Insurgency helper functions";
																file = PATHTO_FUNC(INS_helpers);
                                recompile = RECOMPILE;
                        };
                        class OPCOMDropIntel {
                                description = "Drops Intel by chance";
																file = PATHTO_FUNC(OPCOMDropIntel);
                                recompile = RECOMPILE;
                        };
                };
        };
};
