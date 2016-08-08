class cfgFunctions {
    class PREFIX {
        class COMPONENT {
            FUNC_FILEPATH(perfInit,"The module initialisation function");
            FUNC_FILEPATH(perfMenuDef,"The module menu definition");
            FUNC_FILEPATH(perfDisable,"The module disable function");
            FUNC_FILEPATH(perfModuleFunction,"The module function definition");
            FUNC_FILEPATH(perf_OnPlayerDisconnected,"The module onPlayerDisconnected handler");
            class perfMonitor {
                file = "\x\alive\addons\sys_perf\fnc_perfMonitor.fsm";
                ext = ".fsm";
            };
        };
    };
};
