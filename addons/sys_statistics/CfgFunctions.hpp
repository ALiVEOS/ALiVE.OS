class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class statisticsMenuDef {
                                description = "The module menu definition";
                                file = "\x\alive\addons\sys_statistics\fnc_statisticsMenuDef.sqf";
								recompile = RECOMPILE;
                        };
						class statisticsDisable {
								description = "The module disable function";
								file = "\x\alive\addons\sys_statistics\fnc_statisticsDisable.sqf";
								recompile = RECOMPILE;
						};
						class statisticsModuleFunction {
								description = "The module function definition";
								file = "\x\alive\addons\sys_statistics\fnc_statisticsModuleFunction.sqf";
								recompile = RECOMPILE;
						};
						class stats_OnPlayerDisconnected {
								description = "The module onPlayerDisconnected handler";
								file = "\x\alive\addons\sys_statistics\fnc_stats_onPlayerDisconnected.sqf";
								recompile = RECOMPILE;
						};
						class stats_OnPlayerConnected {
								description = "The module onPlayerConnected handler";
								file = "\x\alive\addons\sys_statistics\fnc_stats_onPlayerConnected.sqf";
								recompile = RECOMPILE;
						};
						class stats_createPlayerProfile {
								description = "The module onPlayerConnected handler";
								file = "\x\alive\addons\sys_statistics\fnc_stats_createPlayerProfile.sqf";
								recompile = RECOMPILE;
						};
						class statisticsInit {
                                description = "The module init function";
                                file = "\x\alive\addons\sys_statistics\fnc_statisticsInit.sqf";
								recompile = RECOMPILE;
                        };
                        class getPlayerGroup {
                                description = "Get's the player group associated with a unit";
                                file = "\x\alive\addons\sys_statistics\fnc_getPlayerGroup.sqf";
								recompile = RECOMPILE;
                        };
                        class updateShotsFired {
                                description = "Update shots fired on server";
                                file = "\x\alive\addons\sys_statistics\fnc_updateShotsFired.sqf";
								recompile = RECOMPILE;
                        };
                        class addHandleHeal {
                                description = "Adds a handleHeal EH to a player object on the local machine";
                                file = "\x\alive\addons\sys_statistics\fnc_addHandleHeal.sqf";
								recompile = RECOMPILE;
                        };
                        class checkIsDiving {
                                description = "Monitors whether or not the unit is on a combat dive";
                                file = "\x\alive\addons\sys_statistics\fnc_checkIsDiving.sqf";
								recompile = RECOMPILE;
                        };
				};
        };
};
