class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class spotrep {
                                description = "The main class";
																file = PATHTO_FUNC(spotrep);
                                recompile = RECOMPILE;
                        };
                        class spotrepInit {
                                description = "The module initialisation function";
																file = PATHTO_FUNC(spotrepInit);
                                recompile = RECOMPILE;
                        };
                        class spotrepParams {
                                description = "spotrep parameters";
																file = PATHTO_FUNC(spotrepParams);
                                recompile = RECOMPILE;
                        };
                        class spotrepSaveData {
                                description = "spotrep save data to DB";
																file = PATHTO_FUNC(spotrepSaveData);
                                recompile = RECOMPILE;
                        };
                        class spotrepLoadData {
                                description = "spotrep load data to DB";
																file = PATHTO_FUNC(spotrepLoadData);
                                recompile = RECOMPILE;
                        };
                        class spotrepDeleteData {
                                description = "spotrep delete data from DB";
																file = PATHTO_FUNC(spotrepDeleteData);
                                recompile = RECOMPILE;
                        };
                        class spotrepOnPlayerConnected {
                                description = "Handles on player connected event";
																file = PATHTO_FUNC(spotrepOnPlayerConnected);
                                recompile = RECOMPILE;
                        };
                        class spotrepCreateDiaryRecord {
                                description = "Adds a spotrep to a diary record";
																file = PATHTO_FUNC(spotrepCreateDiaryRecord);
                                recompile = RECOMPILE;
                        };
                };
        };
};
