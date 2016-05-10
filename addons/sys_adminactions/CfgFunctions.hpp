class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class adminActions {
                                description = "The main class";
                                file = "\x\alive\addons\sys_adminactions\fnc_adminActions.sqf";
				                recompile = RECOMPILE;
                        };
                        class adminActionsInit {
                                description = "The module initialisation function";
                                file = "\x\alive\addons\sys_adminactions\fnc_adminActionsInit.sqf";
				                recompile = RECOMPILE;
                        };
                        class adminActionsMenuDef {
                                description = "The module menu definition";
                                file = "\x\alive\addons\sys_adminactions\fnc_adminActionsMenuDef.sqf";
				                recompile = RECOMPILE;
                        };
                        class markUnits {
                                description = "Mark units active and profiled";
                                file = "\x\alive\addons\sys_adminactions\fnc_markUnits.sqf";
                                recompile = RECOMPILE;
                        };
                        class adminGhost {
                                description = "Set admin to ghost mode";
                                file = "\x\alive\addons\sys_adminactions\fnc_adminGhost.sqf";
                                recompile = RECOMPILE;
                        };
                        class profileSystemDebug {
                                description = "Turn on profile system debug";
                                file = "\x\alive\addons\sys_adminactions\fnc_profileSystemDebug.sqf";
                                recompile = RECOMPILE;
                        };
                        class adminCreateProfiles {
                                description = "Profile non profiled units";
                                file = "\x\alive\addons\sys_adminactions\fnc_adminCreateProfiles.sqf";
                                recompile = RECOMPILE;
                        };
                        class agentSystemDebug {
                                description = "Turn on agent system debug";
                                file = "\x\alive\addons\sys_adminactions\fnc_agentSystemDebug.sqf";
                                recompile = RECOMPILE;
                        };
                        class adminActionsTeleportUnits {
                                description = "Teleports the nearest given unit to the desired spot";
                                file = "\x\alive\addons\sys_adminactions\fnc_adminActionsTeleportUnits.sqf";
                                recompile = RECOMPILE;
                        };
                };
        };
};
