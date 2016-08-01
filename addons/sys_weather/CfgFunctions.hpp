class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class weatherInit {
                                description = "The module initialisation function";
																file = PATHTO_FUNC(weatherInit);
                                                                recompile = RECOMPILE;
                        };
                        class weather {
                                description = "The main class";
																file = PATHTO_FUNC(weather);
                                                                recompile = RECOMPILE;
                        };
                        class weatherServerInit {
                                description = "The weather server initialisation function";
																file = PATHTO_FUNC(weatherServerInit);
                                                                recompile = RECOMPILE;
                        };
                        class weatherServer {
                                description = "The weather server function";
																file = PATHTO_FUNC(weatherServer);
                                                                recompile = RECOMPILE;
                        };
                        class weatherCycleServer {
                                description = "The weather cycle function";
																file = PATHTO_FUNC(weatherCycleServer);
                                                                recompile = RECOMPILE;
                        };
                        class weatherDebugEvent {
                                description = "The weather debug cycle function";
																file = PATHTO_FUNC(weatherDebugEvent);
                                                                recompile = RECOMPILE;
                        };

                        class getWeather {
                                description = "Gets real weather for a time and location function";
																file = PATHTO_FUNC(getWeather);
                                                                recompile = RECOMPILE;
                        };

                };
        };
};
