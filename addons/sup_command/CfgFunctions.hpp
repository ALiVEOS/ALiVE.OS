class CfgFunctions {
	class PREFIX {
		class COMPONENT {
			class SCOM {
				description = "The main class";
				file = "\x\alive\addons\sup_command\fnc_SCOM.sqf";
				recompile = RECOMPILE;
			};
			class SCOMInit {
				description = "The module initialisation function";
				file = "\x\alive\addons\sup_command\fnc_SCOMInit.sqf";
				recompile = RECOMPILE;
			};
            class SCOMTabletOnAction {
                description = "The module Radio Action function";
                file = "\x\alive\addons\sup_command\fnc_SCOMTabletOnAction.sqf";
                recompile = RECOMPILE;
            };
            class SCOMTabletOnLoad {
                description = "The module tablet on load function";
                file = "\x\alive\addons\sup_command\fnc_SCOMTabletOnLoad.sqf";
                recompile = RECOMPILE;
            };
            class SCOMTabletOnUnLoad {
                description = "The module tablet on unload function";
                file = "\x\alive\addons\sup_command\fnc_SCOMTabletOnUnLoad.sqf";
                recompile = RECOMPILE;
            };
            class SCOMTabletEventToClient {
                description = "Call the tablet on the client from the server";
                file = "\x\alive\addons\sup_command\fnc_SCOMTabletEventToClient.sqf";
                recompile = RECOMPILE;
            };
            class commandHandler {
                description = "Command Handler";
                file = "\x\alive\addons\sup_command\fnc_commandHandler.sqf";
                recompile = RECOMPILE;
            };
        };
	};
};
