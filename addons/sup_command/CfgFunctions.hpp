class CfgFunctions {
    class PREFIX {
        class COMPONENT {
            class SCOM {
                description = "The main class";
                file = "\x\alive\addons\sup_command\fnc_SCOM.sqf";
                ALIVE_RECOMPILE;
            };
            class SCOMInit {
                description = "The module initialisation function";
                file = "\x\alive\addons\sup_command\fnc_SCOMInit.sqf";
                ALIVE_RECOMPILE;
            };
            class SCOMTabletOnAction {
                description = "The module Radio Action function";
                file = "\x\alive\addons\sup_command\fnc_SCOMTabletOnAction.sqf";
                ALIVE_RECOMPILE;
            };
            class SCOMTabletOnLoad {
                description = "The module tablet on load function";
                file = "\x\alive\addons\sup_command\fnc_SCOMTabletOnLoad.sqf";
                ALIVE_RECOMPILE;
            };
            class SCOMTabletOnUnLoad {
                description = "The module tablet on unload function";
                file = "\x\alive\addons\sup_command\fnc_SCOMTabletOnUnLoad.sqf";
                ALIVE_RECOMPILE;
            };
            class SCOMTabletEventToClient {
                description = "Call the tablet on the client from the server";
                file = "\x\alive\addons\sup_command\fnc_SCOMTabletEventToClient.sqf";
                ALIVE_RECOMPILE;
            };
            class commandHandler {
                description = "Command Handler";
                file = "\x\alive\addons\sup_command\fnc_commandHandler.sqf";
                ALIVE_RECOMPILE;
            };
            class SCOMTabletEventToServer {
                description = "Transfers event from client instance to server module";
                file = "\x\alive\addons\sup_command\fnc_SCOMTabletEventToServer.sqf";
                ALIVE_RECOMPILE;
            };
            class SCOMSetTerrainMode {
                description = "SCOM tablet terrain-mode toggle (#698)";
                file = "\x\alive\addons\sup_command\fnc_SCOMSetTerrainMode.sqf";
                ALIVE_RECOMPILE;
            };
            class SCOMCmdrObjectiveOrder {
                description = "Objectives for a side's AI commander from outside the game, server only";
                file = "\x\alive\addons\sup_command\fnc_SCOMCmdrObjectiveOrder.sqf";
                ALIVE_RECOMPILE;
            };
            class SCOMCmdrPictureOrder {
                description = "The Commander's Picture orders (Go now, Look again, Strike) from outside the game, server only";
                file = "\x\alive\addons\sup_command\fnc_SCOMCmdrPictureOrder.sqf";
                ALIVE_RECOMPILE;
            };
            class SCOMCmdrControlOrder {
                description = "The AI Commander's controls (Go, stance, pause) from outside the game, server only";
                file = "\x\alive\addons\sup_command\fnc_SCOMCmdrControlOrder.sqf";
                ALIVE_RECOMPILE;
            };
            class SCOMGroupOrder {
                description = "Orders for one AI group (move, stop, lock, unlock, attack, man a static, patrol, stance, hand back, order list) from outside the game, server only";
                file = "\x\alive\addons\sup_command\fnc_SCOMGroupOrder.sqf";
                ALIVE_RECOMPILE;
            };
            class SCOMGroupOrderRun {
                description = "Carries out the War Room's order lists for the groups it holds, server only";
                file = "\x\alive\addons\sup_command\fnc_SCOMGroupOrderRun.sqf";
                preInit = 1;
                ALIVE_RECOMPILE;
            };
        };
    };
};
