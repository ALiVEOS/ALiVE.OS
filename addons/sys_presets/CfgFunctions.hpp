class cfgFunctions {
    class PREFIX {
        class COMPONENT {
            // The two that read nothing but config are registered here as well as
            // being compiled for the editor, so a mission or a test can call them.
            class presetDefault {
                description = "What a module setting reads when nobody has touched it";
                file = "\x\alive\addons\sys_presets\fnc_presetDefault.sqf";
                RECOMPILE;
            };
            class presetParse {
                description = "Checks a preset somebody else wrote against this build";
                file = "\x\alive\addons\sys_presets\fnc_presetParse.sqf";
                RECOMPILE;
            };
            class presetSerialize {
                description = "Writes a preset out as one line of text";
                file = "\x\alive\addons\sys_presets\fnc_presetSerialize.sqf";
                RECOMPILE;
            };
        };
    };
};
