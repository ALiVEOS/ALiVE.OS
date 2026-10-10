class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class spotrep {
                                description = "The main class";
                                file = "\x\alive\addons\sys_spotrep\fnc_spotrep.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class spotrepInit {
                                description = "The module initialisation function";
                                file = "\x\alive\addons\sys_spotrep\fnc_spotrepInit.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class spotrepParams {
                                description = "spotrep parameters";
                                file = "\x\alive\addons\sys_spotrep\fnc_spotrepParams.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class spotrepSaveData {
                                description = "spotrep save data to DB";
                                file = "\x\alive\addons\sys_spotrep\fnc_spotrepSaveData.sqf";
                                                                ALIVE_RECOMPILE;
                        };
                        class spotrepLoadData {
                                description = "spotrep load data to DB";
                                file = "\x\alive\addons\sys_spotrep\fnc_spotrepLoadData.sqf";
                                                                ALIVE_RECOMPILE;
                        };
                        class spotrepDeleteData {
                                description = "spotrep delete data from DB";
                                file = "\x\alive\addons\sys_spotrep\fnc_spotrepDeleteData.sqf";
                                                                ALIVE_RECOMPILE;
                        };
                        class spotrepOnPlayerConnected {
                                description = "Handles on player connected event";
                                file = "\x\alive\addons\sys_spotrep\fnc_spotrepOnPlayerConnected.sqf";
                                                                ALIVE_RECOMPILE;
                        };
                        class spotrepCreateDiaryRecord {
                                description = "Adds a spotrep to a diary record";
                                file = "\x\alive\addons\sys_spotrep\fnc_spotrepCreateDiaryRecord.sqf";
                                                                ALIVE_RECOMPILE;
                        };
                };
        };
};