class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class patrolrep {
                                description = "The main class";
																file = PATHTO_FUNC(patrolrep);
                                recompile = RECOMPILE;
                        };
                        class patrolrepInit {
                                description = "The module initialisation function";
																file = PATHTO_FUNC(patrolrepInit);
                                recompile = RECOMPILE;
                        };
                        class patrolrepParams {
                                description = "patrolrep parameters";
																file = PATHTO_FUNC(patrolrepParams);
                                recompile = RECOMPILE;
                        };
                        class patrolrepSaveData {
                                description = "patrolrep save data to DB";
																file = PATHTO_FUNC(patrolrepSaveData);
                                                                recompile = RECOMPILE;
                        };
                        class patrolrepLoadData {
                                description = "patrolrep load data to DB";
																file = PATHTO_FUNC(patrolrepLoadData);
                                                                recompile = RECOMPILE;
                        };
                        class patrolrepDeleteData {
                                description = "patrolrep delete data from DB";
																file = PATHTO_FUNC(patrolrepDeleteData);
                                                                recompile = RECOMPILE;
                        };
                        class patrolrepOnPlayerConnected {
                                description = "Handles on player connected event";
																file = PATHTO_FUNC(patrolrepOnPlayerConnected);
                                                                recompile = RECOMPILE;
                        };
                        class patrolrepCreateDiaryRecord {
                                description = "Adds a patrolrep to a diary record";
																file = PATHTO_FUNC(patrolrepCreateDiaryRecord);
                                                                recompile = RECOMPILE;
                        };
                        class patrolrepOnLoad {
                                description = "patrolrep on load for dialog";
																file = PATHTO_FUNC(patrolrepOnLoad);
                                                                recompile = RECOMPILE;
                        };
                        class patrolrepButtonAction {
                                description = "patrolrep button action for dialog";
																file = PATHTO_FUNC(patrolrepButtonAction);
                                                                recompile = RECOMPILE;
                        };
                        class patrolrepOnMapEvent {
                                description = "patrolrep on map event for dialog";
																file = PATHTO_FUNC(patrolrepOnMapEvent);
                                                                recompile = RECOMPILE;
                        };
                };
        };
};
