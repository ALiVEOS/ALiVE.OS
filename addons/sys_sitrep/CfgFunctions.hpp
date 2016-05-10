class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class sitrep {
                                description = "The main class";
                                file = "\x\alive\addons\sys_sitrep\fnc_sitrep.sqf";
								recompile = RECOMPILE;
                        };
                        class sitrepInit {
                                description = "The module initialisation function";
                                file = "\x\alive\addons\sys_sitrep\fnc_sitrepInit.sqf";
								recompile = RECOMPILE;
                        };
                        class sitrepParams {
                                description = "sitrep parameters";
                                file = "\x\alive\addons\sys_sitrep\fnc_sitrepParams.sqf";
								recompile = RECOMPILE;
                        };
                        class sitrepSaveData {
                                description = "sitrep save data to DB";
                                file = "\x\alive\addons\sys_sitrep\fnc_sitrepSaveData.sqf";
                                                                recompile = RECOMPILE;
                        };
                        class sitrepLoadData {
                                description = "sitrep load data to DB";
                                file = "\x\alive\addons\sys_sitrep\fnc_sitrepLoadData.sqf";
                                                                recompile = RECOMPILE;
                        };
                        class sitrepDeleteData {
                                description = "sitrep delete data from DB";
                                file = "\x\alive\addons\sys_sitrep\fnc_sitrepDeleteData.sqf";
                                                                recompile = RECOMPILE;
                        };
                        class sitrepOnPlayerConnected {
                                description = "Handles on player connected event";
                                file = "\x\alive\addons\sys_sitrep\fnc_sitrepOnPlayerConnected.sqf";
                                                                recompile = RECOMPILE;
                        };
                        class sitrepCreateDiaryRecord {
                                description = "Adds a sitrep to a diary record";
                                file = "\x\alive\addons\sys_sitrep\fnc_sitrepCreateDiaryRecord.sqf";
                                                                recompile = RECOMPILE;
                        };
                        class sitrepOnLoad {
                                description = "sitrep on load for dialog";
                                file = "\x\alive\addons\sys_sitrep\fnc_sitrepOnLoad.sqf";
                                                                recompile = RECOMPILE;
                        };
                        class sitrepButtonAction {
                                description = "sitrep button action for dialog";
                                file = "\x\alive\addons\sys_sitrep\fnc_sitrepButtonAction.sqf";
                                                                recompile = RECOMPILE;
                        };
                        class sitrepOnMapEvent {
                                description = "sitrep on map event for dialog";
                                file = "\x\alive\addons\sys_sitrep\fnc_sitrepOnMapEvent.sqf";
                                                                recompile = RECOMPILE;
                        };
                };
        };
};