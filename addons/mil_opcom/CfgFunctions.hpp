class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class OPCOM {
                                description = "The main class";
                                file = "\x\alive\addons\mil_opcom\fnc_OPCOM.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class OPCOMInit {
                                description = "The module initialisation function";
                                file = "\x\alive\addons\mil_opcom\fnc_OPCOMInit.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class OPCOMpositions {
                                description = "Selects OPCOM objective positions of given state";
                                file = "\x\alive\addons\mil_opcom\fnc_OPCOMpositions.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class OPCOMLoadData {
                                description = "Loads OPCOM state from DB";
                                file = "\x\alive\addons\mil_opcom\fnc_OPCOMLoadData.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class OPCOMSaveData {
                                description = "Saves OPCOM state from DB";
                                file = "\x\alive\addons\mil_opcom\fnc_OPCOMSaveData.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class OPCOMjoinNearestGroup {
                                description = "Joins the given unit to the nearest group of given state (attacking/defending)";
                                file = "\x\alive\addons\mil_opcom\fnc_OPCOMjoinNearestGroup.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class OPCOMJoinObjective {
                                description = "Joins the given unit to a group that is attacking/defending the selected objective!";
                                file = "\x\alive\addons\mil_opcom\fnc_OPCOMJoinObjective.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class OPCOMToggleInstallations {
                                description = "Toggles Installation markers on / off";
                                file = "\x\alive\addons\mil_opcom\fnc_OPCOMToggleInstallations.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class OPCOMAsymmetricState {
                                description = "Returns installation and profiled force counts for asymmetric OPCOM instances";
                                file = "\x\alive\addons\mil_opcom\fnc_OPCOMAsymmetricState.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class updateSectorHostility {
                                description = "Updates the current sector of position with given value";
                                file = "\x\alive\addons\mil_opcom\fnc_updateSectorHostility.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class INS_helpers {
                                description = "Loads the parent function for the Insurgency helper functions";
                                file = "\x\alive\addons\mil_opcom\fnc_INS_helpers.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class INS_disableBuildingInstallations {
                                description = "Disables asymmetric installations registered on a building";
                                file = "\x\alive\addons\mil_opcom\fnc_INS_disableBuildingInstallations.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class OPCOMDropIntel {
                                description = "Drops Intel by chance";
                                file = "\x\alive\addons\mil_opcom\fnc_OPCOMDropIntel.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class OPCOMgetHighestPrioObjective {
                                description = "Drops Intel by chance";
                                file = "\x\alive\addons\mil_opcom\fnc_OPCOMgetHighestPrioObjective.sqf";
                                ALIVE_RECOMPILE;
                        };  
                        class OPCOMIncrementStartForceStrength {
                                description = "Increment StartForceStrength of targeted side of OPCOM_INSTANCES";
                                file = "\x\alive\addons\mil_opcom\fnc_OPCOMIncrementStartForceStrength.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class OPCOMdecrementStartForceStrength {
                                description = "decrement StartForceStrength of targeted side of OPCOM_INSTANCES";
                                file = "\x\alive\addons\mil_opcom\fnc_OPCOMdecrementStartForceStrength.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class OPCOMfriendlyDisableInstallations {
                                description = "Issue #697: friendly AI disables enemy asymmetric installations via proximity presence and/or friendly OPCOM capture of the objective";
                                file = "\x\alive\addons\mil_opcom\fnc_OPCOMfriendlyDisableInstallations.sqf";
                                ALIVE_RECOMPILE;
                        };
                                              
                };
        };
};
