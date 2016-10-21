class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class statisticsMenuDef {
                                description = "The module menu definition";
                                file = "\x\alive\addons\sys_statistics\fnc_statisticsMenuDef.sqf";
                                RECOMPILE;
                        };
                        class statisticsDisable {
                                description = "The module disable function";
                                file = "\x\alive\addons\sys_statistics\fnc_statisticsDisable.sqf";
                                RECOMPILE;
                        };
                        class statisticsModuleFunction {
                                description = "The module function definition";
                                file = "\x\alive\addons\sys_statistics\fnc_statisticsModuleFunction.sqf";
                                RECOMPILE;
                        };
                        class stats_OnPlayerDisconnected {
                                description = "The module onPlayerDisconnected handler";
                                file = "\x\alive\addons\sys_statistics\fnc_stats_onPlayerDisconnected.sqf";
                                RECOMPILE;
                        };
                        class stats_OnPlayerConnected {
                                description = "The module onPlayerConnected handler";
                                file = "\x\alive\addons\sys_statistics\fnc_stats_onPlayerConnected.sqf";
                                RECOMPILE;
                        };
                        class stats_createPlayerProfile {
                                description = "The module onPlayerConnected handler";
                                file = "\x\alive\addons\sys_statistics\fnc_stats_createPlayerProfile.sqf";
                                RECOMPILE;
                        };
                        class statisticsInit {
                                description = "The module init function";
                                file = "\x\alive\addons\sys_statistics\fnc_statisticsInit.sqf";
                                RECOMPILE;
                        };
                        class getPlayerGroup {
                                description = "Get's the player group associated with a unit";
                                file = "\x\alive\addons\sys_statistics\fnc_getPlayerGroup.sqf";
                                RECOMPILE;
                        };
                        class updateShotsFired {
                                description = "Update shots fired on server";
                                file = "\x\alive\addons\sys_statistics\fnc_updateShotsFired.sqf";
                                RECOMPILE;
                        };
                        class addHandleHeal {
                                description = "Adds a handleHeal EH to a player object on the local machine";
                                file = "\x\alive\addons\sys_statistics\fnc_addHandleHeal.sqf";
                                RECOMPILE;
                        };
                        class checkIsDiving {
                                description = "Monitors whether or not the unit is on a combat dive";
                                file = "\x\alive\addons\sys_statistics\fnc_checkIsDiving.sqf";
                                RECOMPILE;
                        };
                };
        };
};
