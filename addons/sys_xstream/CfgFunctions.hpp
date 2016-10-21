class CfgFunctions {
    class PREFIX {
        class COMPONENT {
            class xStream {
                description = "The main class";
                file = "\x\alive\addons\sys_xstream\fnc_xstream.sqf";
                RECOMPILE;
            };
            class xStreamInit {
                description = "The module initialisation function";
                file = "\x\alive\addons\sys_xstream\fnc_xStreamInit.sqf";
                RECOMPILE;
            };
            class xStreamMenuDef {
                description = "The module menu definition";
                file = "\x\alive\addons\sys_xstream\fnc_xStreamMenuDef.sqf";
                RECOMPILE;
            };
            class camera {
                description = "The module camera function";
                file = "\x\alive\addons\sys_xstream\fnc_camera.sqf";
                RECOMPILE;
            };
        };
    };
};