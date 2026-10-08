class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class perfInit {
                                description = "The module initialisation function";
                                file = "\x\alive\addons\sys_perf\fnc_perfInit.sqf";
                                RECOMPILE;
                        };
                        class perfMenuDef {
                                description = "The module menu definition";
                                file = "\x\alive\addons\sys_perf\fnc_perfMenuDef.sqf";
                                RECOMPILE;
                        };
                        class perfDisable {
                                description = "The module disable function";
                                file = "\x\alive\addons\sys_perf\fnc_perfDisable.sqf";
                                RECOMPILE;
                        };
                        class perfModuleFunction {
                                description = "The module function definition";
                                file = "\x\alive\addons\sys_perf\fnc_perfModuleFunction.sqf";
                                RECOMPILE;
                        };
                        class perf_OnPlayerDisconnected {
                                description = "The module onPlayerDisconnected handler";
                                file = "\x\alive\addons\sys_perf\fnc_perf_onPlayerDisconnected.sqf";
                                RECOMPILE;
                        };
                        class perfServer {
                                description = "The server performance monitor";
                                file = "\x\alive\addons\sys_perf\fnc_perfServer.sqf";
                                RECOMPILE;
                        };
                        class perfMenuInit {
                                description = "Sets up the Perf menu and starts monitoring at start when asked";
                                file = "\x\alive\addons\sys_perf\fnc_perfMenuInit.sqf";
                                RECOMPILE;
                        };
                        class perfShow {
                                description = "Shows or hides the admin performance readout";
                                file = "\x\alive\addons\sys_perf\fnc_perfShow.sqf";
                                RECOMPILE;
                        };
                        class perfMonitor {
                            file = "\x\alive\addons\sys_perf\fnc_perfMonitor.fsm";
                            ext = ".fsm";
                        };
                };
        };
};
