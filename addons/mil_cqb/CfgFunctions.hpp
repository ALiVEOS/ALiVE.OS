class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class CQB {
                                description = "The main class";
																file = PATHTO_FUNC(CQB);
                                recompile = RECOMPILE;
                        };
                        class CQBInit {
                                description = "The module initialisation function";
																file = PATHTO_FUNC(CQBInit);
                                recompile = RECOMPILE;
                        };
                        class CQBsortStrategicHouses {
                                description = "The CQB blacklist function";
																file = PATHTO_FUNC(CQBsortStrategicHouses);
                                recompile = RECOMPILE;
                        };
                        class CQBSaveData {
                                description = "CQB save data to DB";
																file = PATHTO_FUNC(CQBSaveData);
                                recompile = RECOMPILE;
                        };
                        class CQBLoadData {
                                description = "CQB load data to DB";
																file = PATHTO_FUNC(CQBLoadData);
                                recompile = RECOMPILE;
                        };
                        class CQBMenuDef {
                                description = "CQB Menu Definition";
																file = PATHTO_FUNC(CQBMenuDef);
                                recompile = RECOMPILE;
                        };
                        class addCQBPositions {
                                description = "Enables CQB positions within the given radius of a position";
																file = PATHTO_FUNC(addCQBPositions);
                                recompile = RECOMPILE;
                        };
                        class removeCQBPositions{
                                description = "Disables CQB positions within the given radius of a position";
																file = PATHTO_FUNC(removeCQBPositions);
                                recompile = RECOMPILE;
                        };
                        class resetCQB {
                                description = "Resets CQB to run in the background without houses";
																file = PATHTO_FUNC(resetCQB);
                                recompile = RECOMPILE;
                        };
                };
        };
};
