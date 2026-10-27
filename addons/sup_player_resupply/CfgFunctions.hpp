class CfgFunctions {
    class PREFIX {
        class COMPONENT {
            class PR {
                description = "The main class";
                file = "\x\alive\addons\sup_player_resupply\fnc_PR.sqf";
                ALIVE_RECOMPILE;
            };
            class PRInit {
                description = "The module initialisation function";
                file = "\x\alive\addons\sup_player_resupply\fnc_PRInit.sqf";
                ALIVE_RECOMPILE;
            };
            class PRMenuDef {
                description = "The module menu definition";
                file = "\x\alive\addons\sup_player_resupply\fnc_PRMenuDef.sqf";
                ALIVE_RECOMPILE;
            };
            class PRTabletOnAction {
                description = "The module Radio Action function";
                file = "\x\alive\addons\sup_player_resupply\fnc_PRTabletOnAction.sqf";
                ALIVE_RECOMPILE;
            };
            class PRTabletOnLoad {
                description = "The module tablet on load function";
                file = "\x\alive\addons\sup_player_resupply\fnc_PRTabletOnLoad.sqf";
                ALIVE_RECOMPILE;
            };
            class PRTabletOnUnLoad {
                description = "The module tablet on unload function";
                file = "\x\alive\addons\sup_player_resupply\fnc_PRTabletOnUnLoad.sqf";
                ALIVE_RECOMPILE;
            };
            class PRSendHome {
                description = "Send home the men Player Combat Logistics delivered into a player's group (#691)";
                file = "\x\alive\addons\sup_player_resupply\fnc_PRSendHome.sqf";
                ALIVE_RECOMPILE;
            };
            class PRTabletEventToClient {
                description = "Call the tablet on the client from the server";
                file = "\x\alive\addons\sup_player_resupply\fnc_PRTabletEventToClient.sqf";
                ALIVE_RECOMPILE;
            };
            class PRCatalogueRules {
                description = "The tablet catalogue's Only These, Never and Also lists (#1091)";
                file = "\x\alive\addons\sup_player_resupply\fnc_PRCatalogueRules.sqf";
                ALIVE_RECOMPILE;
            };
            class PRSetTerrainMode {
                description = "Player Resupply terrain-mode toggle (#698)";
                file = "\x\alive\addons\sup_player_resupply\fnc_PRSetTerrainMode.sqf";
                ALIVE_RECOMPILE;
            };
        };
    };
};
