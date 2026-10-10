class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class patrolrep {
                                description = "The main class";
                                file = "\x\alive\addons\sys_patrolrep\fnc_patrolrep.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class patrolrepInit {
                                description = "The module initialisation function";
                                file = "\x\alive\addons\sys_patrolrep\fnc_patrolrepInit.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class patrolrepParams {
                                description = "patrolrep parameters";
                                file = "\x\alive\addons\sys_patrolrep\fnc_patrolrepParams.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class patrolrepSaveData {
                                description = "patrolrep save data to DB";
                                file = "\x\alive\addons\sys_patrolrep\fnc_patrolrepSaveData.sqf";
                                                                ALIVE_RECOMPILE;
                        };
                        class patrolrepLoadData {
                                description = "patrolrep load data to DB";
                                file = "\x\alive\addons\sys_patrolrep\fnc_patrolrepLoadData.sqf";
                                                                ALIVE_RECOMPILE;
                        };
                        class patrolrepDeleteData {
                                description = "patrolrep delete data from DB";
                                file = "\x\alive\addons\sys_patrolrep\fnc_patrolrepDeleteData.sqf";
                                                                ALIVE_RECOMPILE;
                        };
                        class patrolrepOnPlayerConnected {
                                description = "Handles on player connected event";
                                file = "\x\alive\addons\sys_patrolrep\fnc_patrolrepOnPlayerConnected.sqf";
                                                                ALIVE_RECOMPILE;
                        };
                        class patrolrepCreateDiaryRecord {
                                description = "Adds a patrolrep to a diary record";
                                file = "\x\alive\addons\sys_patrolrep\fnc_patrolrepCreateDiaryRecord.sqf";
                                                                ALIVE_RECOMPILE;
                        };
                        class patrolrepOnLoad {
                                description = "patrolrep on load for dialog";
                                file = "\x\alive\addons\sys_patrolrep\fnc_patrolrepOnLoad.sqf";
                                                                ALIVE_RECOMPILE;
                        };
                        class patrolrepButtonAction {
                                description = "patrolrep button action for dialog";
                                file = "\x\alive\addons\sys_patrolrep\fnc_patrolrepButtonAction.sqf";
                                                                ALIVE_RECOMPILE;
                        };
                        class patrolrepOnMapEvent {
                                description = "patrolrep on map event for dialog";
                                file = "\x\alive\addons\sys_patrolrep\fnc_patrolrepOnMapEvent.sqf";
                                                                ALIVE_RECOMPILE;
                        };
                        class patrolrepSetTerrainMode {
                                description = "patrolrep terrain-mode toggle (#698)";
                                file = "\x\alive\addons\sys_patrolrep\fnc_patrolrepSetTerrainMode.sqf";
                                                                ALIVE_RECOMPILE;
                        };
                };
        };
};