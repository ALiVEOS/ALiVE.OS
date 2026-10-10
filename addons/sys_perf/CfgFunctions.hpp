class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class perfInit {
                                description = "The module initialisation function";
                                file = "\x\alive\addons\sys_perf\fnc_perfInit.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class perfMenuDef {
                                description = "The module menu definition";
                                file = "\x\alive\addons\sys_perf\fnc_perfMenuDef.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class perfDisable {
                                description = "The module disable function";
                                file = "\x\alive\addons\sys_perf\fnc_perfDisable.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class perfModuleFunction {
                                description = "The module function definition";
                                file = "\x\alive\addons\sys_perf\fnc_perfModuleFunction.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class perf_OnPlayerDisconnected {
                                description = "The module onPlayerDisconnected handler";
                                file = "\x\alive\addons\sys_perf\fnc_perf_onPlayerDisconnected.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class perfServer {
                                description = "The server performance monitor";
                                file = "\x\alive\addons\sys_perf\fnc_perfServer.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class perfMenuInit {
                                description = "Sets up the Perf menu and starts monitoring at start when asked";
                                file = "\x\alive\addons\sys_perf\fnc_perfMenuInit.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class perfShow {
                                description = "Shows or hides the admin performance readout";
                                file = "\x\alive\addons\sys_perf\fnc_perfShow.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class perfMonitor {
                            file = "\x\alive\addons\sys_perf\fnc_perfMonitor.fsm";
                            ext = ".fsm";
                        };
                };
        };
};
