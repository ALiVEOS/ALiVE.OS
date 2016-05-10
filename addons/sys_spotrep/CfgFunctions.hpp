class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class spotrep {
                                description = "The main class";
                                file = "\x\alive\addons\sys_spotrep\fnc_spotrep.sqf";
								recompile = RECOMPILE;
                        };
                        class spotrepInit {
                                description = "The module initialisation function";
                                file = "\x\alive\addons\sys_spotrep\fnc_spotrepInit.sqf";
								recompile = RECOMPILE;
                        };
                        class spotrepParams {
                                description = "spotrep parameters";
                                file = "\x\alive\addons\sys_spotrep\fnc_spotrepParams.sqf";
								recompile = RECOMPILE;
                        };
                        class spotrepSaveData {
                                description = "spotrep save data to DB";
                                file = "\x\alive\addons\sys_spotrep\fnc_spotrepSaveData.sqf";
                                                                recompile = RECOMPILE;
                        };
                        class spotrepLoadData {
                                description = "spotrep load data to DB";
                                file = "\x\alive\addons\sys_spotrep\fnc_spotrepLoadData.sqf";
                                                                recompile = RECOMPILE;
                        };
                        class spotrepDeleteData {
                                description = "spotrep delete data from DB";
                                file = "\x\alive\addons\sys_spotrep\fnc_spotrepDeleteData.sqf";
                                                                recompile = RECOMPILE;
                        };
                        class spotrepOnPlayerConnected {
                                description = "Handles on player connected event";
                                file = "\x\alive\addons\sys_spotrep\fnc_spotrepOnPlayerConnected.sqf";
                                                                recompile = RECOMPILE;
                        };
                        class spotrepCreateDiaryRecord {
                                description = "Adds a spotrep to a diary record";
                                file = "\x\alive\addons\sys_spotrep\fnc_spotrepCreateDiaryRecord.sqf";
                                                                recompile = RECOMPILE;
                        };
                };
        };
};