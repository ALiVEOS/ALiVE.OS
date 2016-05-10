class CfgFunctions {
	class PREFIX {
		class COMPONENT {
			class PR {
				description = "The main class";
				file = "\x\alive\addons\sup_player_resupply\fnc_PR.sqf";
				recompile = RECOMPILE;
			};
			class PRInit {
				description = "The module initialisation function";
				file = "\x\alive\addons\sup_player_resupply\fnc_PRInit.sqf";
				recompile = RECOMPILE;
			};
			class PRMenuDef {
                description = "The module menu definition";
                file = "\x\alive\addons\sup_player_resupply\fnc_PRMenuDef.sqf";
                recompile = RECOMPILE;
            };
            class PRTabletOnAction {
                description = "The module Radio Action function";
                file = "\x\alive\addons\sup_player_resupply\fnc_PRTabletOnAction.sqf";
                recompile = RECOMPILE;
            };
            class PRTabletOnLoad {
                description = "The module tablet on load function";
                file = "\x\alive\addons\sup_player_resupply\fnc_PRTabletOnLoad.sqf";
                recompile = RECOMPILE;
            };
            class PRTabletOnUnLoad {
                description = "The module tablet on unload function";
                file = "\x\alive\addons\sup_player_resupply\fnc_PRTabletOnUnLoad.sqf";
                recompile = RECOMPILE;
            };
            class PRTabletEventToClient {
                description = "Call the tablet on the client from the server";
                file = "\x\alive\addons\sup_player_resupply\fnc_PRTabletEventToClient.sqf";
                recompile = RECOMPILE;
            };
        };
	};
};
