class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class sitrep {
                                description = "The main class";
                                file = "\x\alive\addons\sys_sitrep\fnc_sitrep.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class sitrepInit {
                                description = "The module initialisation function";
                                file = "\x\alive\addons\sys_sitrep\fnc_sitrepInit.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class sitrepParams {
                                description = "sitrep parameters";
                                file = "\x\alive\addons\sys_sitrep\fnc_sitrepParams.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class sitrepSaveData {
                                description = "sitrep save data to DB";
                                file = "\x\alive\addons\sys_sitrep\fnc_sitrepSaveData.sqf";
                                                                ALIVE_RECOMPILE;
                        };
                        class sitrepLoadData {
                                description = "sitrep load data to DB";
                                file = "\x\alive\addons\sys_sitrep\fnc_sitrepLoadData.sqf";
                                                                ALIVE_RECOMPILE;
                        };
                        class sitrepDeleteData {
                                description = "sitrep delete data from DB";
                                file = "\x\alive\addons\sys_sitrep\fnc_sitrepDeleteData.sqf";
                                                                ALIVE_RECOMPILE;
                        };
                        class sitrepOnPlayerConnected {
                                description = "Handles on player connected event";
                                file = "\x\alive\addons\sys_sitrep\fnc_sitrepOnPlayerConnected.sqf";
                                                                ALIVE_RECOMPILE;
                        };
                        class sitrepCreateDiaryRecord {
                                description = "Adds a sitrep to a diary record";
                                file = "\x\alive\addons\sys_sitrep\fnc_sitrepCreateDiaryRecord.sqf";
                                                                ALIVE_RECOMPILE;
                        };
                        class sitrepOnLoad {
                                description = "sitrep on load for dialog";
                                file = "\x\alive\addons\sys_sitrep\fnc_sitrepOnLoad.sqf";
                                                                ALIVE_RECOMPILE;
                        };
                        class sitrepButtonAction {
                                description = "sitrep button action for dialog";
                                file = "\x\alive\addons\sys_sitrep\fnc_sitrepButtonAction.sqf";
                                                                ALIVE_RECOMPILE;
                        };
                        class sitrepOnMapEvent {
                                description = "sitrep on map event for dialog";
                                file = "\x\alive\addons\sys_sitrep\fnc_sitrepOnMapEvent.sqf";
                                                                ALIVE_RECOMPILE;
                        };
                        class sitrepSetTerrainMode {
                                description = "sitrep terrain-mode toggle (#698)";
                                file = "\x\alive\addons\sys_sitrep\fnc_sitrepSetTerrainMode.sqf";
                                                                ALIVE_RECOMPILE;
                        };
                };
        };
};