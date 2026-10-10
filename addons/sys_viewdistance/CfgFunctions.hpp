class cfgFunctions {
    class PREFIX {
        class COMPONENT {
            class vDist {
                description = "The main class";
                file = "\x\alive\addons\sys_viewdistance\fnc_vDist.sqf";
                ALIVE_RECOMPILE;
            };
            class vDistInit {
                description = "The module initialisation function";
                file = "\x\alive\addons\sys_viewdistance\fnc_vDistInit.sqf";
                ALIVE_RECOMPILE;
            };
            class vDistMenuDef {
                description = "The module menu definition";
                file = "\x\alive\addons\sys_viewdistance\fnc_vDistMenuDef.sqf";
                ALIVE_RECOMPILE;
            };
            class vDistGuiInit {
                description = "The Gui";
                file = "\x\alive\addons\sys_viewdistance\fnc_vdist_init.sqf";
                ALIVE_RECOMPILE;
            };
        };
    };
};
