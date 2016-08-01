class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class adminActions {
                                description = "The main class";
																file = PATHTO_FUNC(adminActions);
                                recompile = RECOMPILE;
                        };
                        class adminActionsInit {
                                description = "The module initialisation function";
																file = PATHTO_FUNC(adminActionsInit);
                                recompile = RECOMPILE;
                        };
                        class adminActionsMenuDef {
                                description = "The module menu definition";
																file = PATHTO_FUNC(adminActionsMenuDef);
                                recompile = RECOMPILE;
                        };
                        class markUnits {
                                description = "Mark units active and profiled";
																file = PATHTO_FUNC(markUnits);
                                recompile = RECOMPILE;
                        };
                        class adminGhost {
                                description = "Set admin to ghost mode";
																file = PATHTO_FUNC(adminGhost);
                                recompile = RECOMPILE;
                        };
                        class profileSystemDebug {
                                description = "Turn on profile system debug";
																file = PATHTO_FUNC(profileSystemDebug);
                                recompile = RECOMPILE;
                        };
                        class adminCreateProfiles {
                                description = "Profile non profiled units";
																file = PATHTO_FUNC(adminCreateProfiles);
                                recompile = RECOMPILE;
                        };
                        class agentSystemDebug {
                                description = "Turn on agent system debug";
																file = PATHTO_FUNC(agentSystemDebug);
                                recompile = RECOMPILE;
                        };
                        class adminActionsTeleportUnits {
                                description = "Teleports the nearest given unit to the desired spot";
																file = PATHTO_FUNC(adminActionsTeleportUnits);
                                recompile = RECOMPILE;
                        };
                };
        };
};
