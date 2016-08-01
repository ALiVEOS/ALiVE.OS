class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class statisticsMenuDef {
                                description = "The module menu definition";
																file = PATHTO_FUNC(statisticsMenuDef);
                                recompile = RECOMPILE;
                        };
                        class statisticsDisable {
                                description = "The module disable function";
																file = PATHTO_FUNC(statisticsDisable);
                                recompile = RECOMPILE;
                        };
                        class statisticsModuleFunction {
                                description = "The module function definition";
																file = PATHTO_FUNC(statisticsModuleFunction);
                                recompile = RECOMPILE;
                        };
                        class stats_OnPlayerDisconnected {
                                description = "The module onPlayerDisconnected handler";
																file = PATHTO_FUNC(stats_onPlayerDisconnected);
                                recompile = RECOMPILE;
                        };
                        class stats_OnPlayerConnected {
                                description = "The module onPlayerConnected handler";
																file = PATHTO_FUNC(stats_onPlayerConnected);
                                recompile = RECOMPILE;
                        };
                        class stats_createPlayerProfile {
                                description = "The module onPlayerConnected handler";
																file = PATHTO_FUNC(stats_createPlayerProfile);
                                recompile = RECOMPILE;
                        };
                        class statisticsInit {
                                description = "The module init function";
																file = PATHTO_FUNC(statisticsInit);
                                recompile = RECOMPILE;
                        };
                        class getPlayerGroup {
                                description = "Get's the player group associated with a unit";
																file = PATHTO_FUNC(getPlayerGroup);
                                recompile = RECOMPILE;
                        };
                        class updateShotsFired {
                                description = "Update shots fired on server";
																file = PATHTO_FUNC(updateShotsFired);
                                recompile = RECOMPILE;
                        };
                        class addHandleHeal {
                                description = "Adds a handleHeal EH to a player object on the local machine";
																file = PATHTO_FUNC(addHandleHeal);
                                recompile = RECOMPILE;
                        };
                        class checkIsDiving {
                                description = "Monitors whether or not the unit is on a combat dive";
																file = PATHTO_FUNC(checkIsDiving);
                                recompile = RECOMPILE;
                        };
                };
        };
};
