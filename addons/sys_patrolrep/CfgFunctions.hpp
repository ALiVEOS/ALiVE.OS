class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class patrolrep {
                                description = "The main class";
                                file = "\x\alive\addons\sys_patrolrep\fnc_patrolrep.sqf";
                                RECOMPILE;
                        };
                        class patrolrepInit {
                                description = "The module initialisation function";
                                file = "\x\alive\addons\sys_patrolrep\fnc_patrolrepInit.sqf";
                                RECOMPILE;
                        };
                        class patrolrepParams {
                                description = "patrolrep parameters";
                                file = "\x\alive\addons\sys_patrolrep\fnc_patrolrepParams.sqf";
                                RECOMPILE;
                        };
                        class patrolrepSaveData {
                                description = "patrolrep save data to DB";
                                file = "\x\alive\addons\sys_patrolrep\fnc_patrolrepSaveData.sqf";
                                                                RECOMPILE;
                        };
                        class patrolrepLoadData {
                                description = "patrolrep load data to DB";
                                file = "\x\alive\addons\sys_patrolrep\fnc_patrolrepLoadData.sqf";
                                                                RECOMPILE;
                        };
                        class patrolrepDeleteData {
                                description = "patrolrep delete data from DB";
                                file = "\x\alive\addons\sys_patrolrep\fnc_patrolrepDeleteData.sqf";
                                                                RECOMPILE;
                        };
                        class patrolrepOnPlayerConnected {
                                description = "Handles on player connected event";
                                file = "\x\alive\addons\sys_patrolrep\fnc_patrolrepOnPlayerConnected.sqf";
                                                                RECOMPILE;
                        };
                        class patrolrepCreateDiaryRecord {
                                description = "Adds a patrolrep to a diary record";
                                file = "\x\alive\addons\sys_patrolrep\fnc_patrolrepCreateDiaryRecord.sqf";
                                                                RECOMPILE;
                        };
                        class patrolrepOnLoad {
                                description = "patrolrep on load for dialog";
                                file = "\x\alive\addons\sys_patrolrep\fnc_patrolrepOnLoad.sqf";
                                                                RECOMPILE;
                        };
                        class patrolrepButtonAction {
                                description = "patrolrep button action for dialog";
                                file = "\x\alive\addons\sys_patrolrep\fnc_patrolrepButtonAction.sqf";
                                                                RECOMPILE;
                        };
                        class patrolrepOnMapEvent {
                                description = "patrolrep on map event for dialog";
                                file = "\x\alive\addons\sys_patrolrep\fnc_patrolrepOnMapEvent.sqf";
                                                                RECOMPILE;
                        };
                };
        };
};