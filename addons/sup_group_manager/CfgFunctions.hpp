class CfgFunctions {
	class PREFIX {
		class COMPONENT {
			class GM {
				description = "The main class";
				file = "\x\alive\addons\sup_group_manager\fnc_GM.sqf";
				recompile = RECOMPILE;
			};
			class GMInit {
				description = "The module initialisation function";
				file = "\x\alive\addons\sup_group_manager\fnc_GMInit.sqf";
				recompile = RECOMPILE;
			};
            class GMTabletOnAction {
                description = "The module Radio Action function";
                file = "\x\alive\addons\sup_group_manager\fnc_GMTabletOnAction.sqf";
                recompile = RECOMPILE;
            };
            class GMTabletOnLoad {
                description = "The module tablet on load function";
                file = "\x\alive\addons\sup_group_manager\fnc_GMTabletOnLoad.sqf";
                recompile = RECOMPILE;
            };
            class GMTabletOnUnLoad {
                description = "The module tablet on unload function";
                file = "\x\alive\addons\sup_group_manager\fnc_GMTabletOnUnLoad.sqf";
                recompile = RECOMPILE;
            };
            class GMTabletEventToClient {
                description = "Call the tablet on the client from the server";
                file = "\x\alive\addons\sup_group_manager\fnc_GMTabletEventToClient.sqf";
                recompile = RECOMPILE;
            };
            class groupHandler {
                description = "Group Handler";
                file = "\x\alive\addons\sup_group_manager\fnc_groupHandler.sqf";
                recompile = RECOMPILE;
            };
        };
	};
};
