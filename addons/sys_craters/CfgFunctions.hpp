class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class craters {
                                description = "The main class";
                                file = "\x\alive\addons\sys_craters\fnc_craters.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class cratersInit {
                                description = "The module initialisation function";
                                file = "\x\alive\addons\sys_craters\fnc_cratersInit.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class cratersWatch {
                                description = "Watches for shells, rockets and bombs going off, on every machine";
                                file = "\x\alive\addons\sys_craters\fnc_cratersWatch.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class cratersReport {
                                description = "Takes a hit on the server and decides what crater it leaves";
                                file = "\x\alive\addons\sys_craters\fnc_cratersReport.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class cratersTerrain {
                                description = "Digs and fills craters in the ground and places their marks";
                                file = "\x\alive\addons\sys_craters\fnc_cratersTerrain.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class cratersPersistence {
                                description = "Saves the craters and loads them back";
                                file = "\x\alive\addons\sys_craters\fnc_cratersPersistence.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class cratersSaveData {
                                description = "Saves the craters now";
                                file = "\x\alive\addons\sys_craters\fnc_cratersSaveData.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class cratersLoadData {
                                description = "Loads the saved craters";
                                file = "\x\alive\addons\sys_craters\fnc_cratersLoadData.sqf";
                                ALIVE_RECOMPILE;
                        };
                };
        };
};
