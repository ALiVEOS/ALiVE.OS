class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class crewinfo {
                                description = "The main class";
                                file = "\x\alive\addons\sys_crewinfo\fnc_crewinfo.sqf";
																recompile = RECOMPILE;
                        };
                        class crewinfoInit {
                                description = "The module initialisation function";
                                file = "\x\alive\addons\sys_crewinfo\fnc_crewinfoInit.sqf";
																recompile = RECOMPILE;
                        };  
 											 class crewinfoClient {
                               description = "The module script";
                                file = "\x\alive\addons\sys_crewinfo\fnc_crewinfoClient.sqf";
																recompile = RECOMPILE;
                        };  
                };
        };
};