class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class sitrep {
                                description = "The main class";
																file = PATHTO_FUNC(sitrep);
                                recompile = RECOMPILE;
                        };
                        class sitrepInit {
                                description = "The module initialisation function";
																file = PATHTO_FUNC(sitrepInit);
                                recompile = RECOMPILE;
                        };
                        class sitrepParams {
                                description = "sitrep parameters";
																file = PATHTO_FUNC(sitrepParams);
                                recompile = RECOMPILE;
                        };
                        class sitrepSaveData {
                                description = "sitrep save data to DB";
																file = PATHTO_FUNC(sitrepSaveData);
                                                                recompile = RECOMPILE;
                        };
                        class sitrepLoadData {
                                description = "sitrep load data to DB";
																file = PATHTO_FUNC(sitrepLoadData);
                                                                recompile = RECOMPILE;
                        };
                        class sitrepDeleteData {
                                description = "sitrep delete data from DB";
																file = PATHTO_FUNC(sitrepDeleteData);
                                                                recompile = RECOMPILE;
                        };
                        class sitrepOnPlayerConnected {
                                description = "Handles on player connected event";
																file = PATHTO_FUNC(sitrepOnPlayerConnected);
                                                                recompile = RECOMPILE;
                        };
                        class sitrepCreateDiaryRecord {
                                description = "Adds a sitrep to a diary record";
																file = PATHTO_FUNC(sitrepCreateDiaryRecord);
                                                                recompile = RECOMPILE;
                        };
                        class sitrepOnLoad {
                                description = "sitrep on load for dialog";
																file = PATHTO_FUNC(sitrepOnLoad);
                                                                recompile = RECOMPILE;
                        };
                        class sitrepButtonAction {
                                description = "sitrep button action for dialog";
																file = PATHTO_FUNC(sitrepButtonAction);
                                                                recompile = RECOMPILE;
                        };
                        class sitrepOnMapEvent {
                                description = "sitrep on map event for dialog";
																file = PATHTO_FUNC(sitrepOnMapEvent);
                                                                recompile = RECOMPILE;
                        };
                };
        };
};
