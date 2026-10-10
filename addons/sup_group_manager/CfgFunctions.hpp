class CfgFunctions {
    class PREFIX {
        class COMPONENT {
            class GM {
                description = "The main class";
                file = "\x\alive\addons\sup_group_manager\fnc_GM.sqf";
                ALIVE_RECOMPILE;
            };
            class GMInit {
                description = "The module initialisation function";
                file = "\x\alive\addons\sup_group_manager\fnc_GMInit.sqf";
                ALIVE_RECOMPILE;
            };
            class GMTabletOnAction {
                description = "The module Radio Action function";
                file = "\x\alive\addons\sup_group_manager\fnc_GMTabletOnAction.sqf";
                ALIVE_RECOMPILE;
            };
            class GMTabletOnLoad {
                description = "The module tablet on load function";
                file = "\x\alive\addons\sup_group_manager\fnc_GMTabletOnLoad.sqf";
                ALIVE_RECOMPILE;
            };
            class GMTabletOnUnLoad {
                description = "The module tablet on unload function";
                file = "\x\alive\addons\sup_group_manager\fnc_GMTabletOnUnLoad.sqf";
                ALIVE_RECOMPILE;
            };
            class GMTabletEventToClient {
                description = "Call the tablet on the client from the server";
                file = "\x\alive\addons\sup_group_manager\fnc_GMTabletEventToClient.sqf";
                ALIVE_RECOMPILE;
            };
            class groupHandler {
                description = "Group Handler";
                file = "\x\alive\addons\sup_group_manager\fnc_groupHandler.sqf";
                ALIVE_RECOMPILE;
            };
            class GMSetTerrainMode {
                description = "Group Manager tablet terrain-mode toggle (#698)";
                file = "\x\alive\addons\sup_group_manager\fnc_GMSetTerrainMode.sqf";
                ALIVE_RECOMPILE;
            };
        };
    };
};
