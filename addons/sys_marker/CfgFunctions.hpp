class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class marker {
                                description = "The main class";
																file = PATHTO_FUNC(marker);
                                recompile = RECOMPILE;
                        };
                        class markerInit {
                                description = "The module initialisation function";
																file = PATHTO_FUNC(markerInit);
                                recompile = RECOMPILE;
                        };
                        class markerParams {
                                description = "Marker parameters";
																file = PATHTO_FUNC(markerParams);
                                recompile = RECOMPILE;
                        };
                        class markerSaveData {
                                description = "marker save data to DB";
																file = PATHTO_FUNC(markerSaveData);
                                                                recompile = RECOMPILE;
                        };
                        class markerLoadData {
                                description = "marker load data to DB";
																file = PATHTO_FUNC(markerLoadData);
                                                                recompile = RECOMPILE;
                        };
                        class markerDeleteData {
                                description = "marker delete data from DB";
																file = PATHTO_FUNC(markerDeleteData);
                                                                recompile = RECOMPILE;
                        };
                        class markerOnLoad{
                                description = "Onload for Dialog";
																file = PATHTO_FUNC(markerOnLoad);
                                                                recompile = RECOMPILE;
                        };
                        class markerOnPlayerConnected{
                                description = "Handles on player connected event";
																file = PATHTO_FUNC(markerOnPlayerConnected);
                                                                recompile = RECOMPILE;
                        };
                        class markerLBSelChanged{
                                description = "LBSelChanged for Dialog";
																file = PATHTO_FUNC(markerLBSelChanged);
                                                                recompile = RECOMPILE;
                        };
                        class markerCheckedChanged{
                                description = "CheckedChanged for Dialog";
																file = PATHTO_FUNC(markerCheckedChanged);
                                                                recompile = RECOMPILE;
                        };
                        class markerButtonAction{
                                description = "Button Action for Dialog";
																file = PATHTO_FUNC(markerButtonAction);
                                                                recompile = RECOMPILE;
                        };
                };
        };
};
