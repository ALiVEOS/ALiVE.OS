class cfgFunctions {
    class PREFIX {
        class COMPONENT {
            class classPickerModule {
                description = "The main class";
                file = "\x\alive\addons\sys_classpicker\fnc_classPickerModule.sqf";
                RECOMPILE;
            };
            class classPickerModuleInit {
                description = "The module initialisation function";
                file = "\x\alive\addons\sys_classpicker\fnc_classPickerModuleInit.sqf";
                RECOMPILE;
            };
            class classPickerMenuDef {
                description = "Class picker entries for the ALiVE menu";
                file = "\x\alive\addons\sys_classpicker\fnc_classPickerMenuDef.sqf";
                RECOMPILE;
            };
        };
    };
};
