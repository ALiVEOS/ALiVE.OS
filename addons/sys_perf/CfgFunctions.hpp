class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class perfInit {
                                description = "The module initialisation function";
																file = PATHTO_FUNC(perfInit);
                                recompile = RECOMPILE;
                        };
                        class perfMenuDef {
                                description = "The module menu definition";
																file = PATHTO_FUNC(perfMenuDef);
                                recompile = RECOMPILE;
                        };
                        class perfDisable {
                                description = "The module disable function";
																file = PATHTO_FUNC(perfDisable);
                                recompile = RECOMPILE;
                        };
                        class perfModuleFunction {
                                description = "The module function definition";
																file = PATHTO_FUNC(perfModuleFunction);
                                recompile = RECOMPILE;
                        };
                        class perf_OnPlayerDisconnected {
                                description = "The module onPlayerDisconnected handler";
																file = PATHTO_FUNC(perf_onPlayerDisconnected);
                                recompile = RECOMPILE;
                        };
                        class perfMonitor {
                            file = "\x\alive\addons\sys_perf\fnc_perfMonitor.fsm";
                            ext = ".fsm";
                        };
                };
        };
};
