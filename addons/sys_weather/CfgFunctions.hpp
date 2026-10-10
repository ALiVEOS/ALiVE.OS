class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class weatherInit {
                                description = "The module initialisation function";
                                file = "\x\alive\addons\sys_weather\fnc_weatherInit.sqf";
                                                                ALIVE_RECOMPILE;
                        };
                        class weather {
                                description = "The main class";
                                file = "\x\alive\addons\sys_weather\fnc_weather.sqf";
                                                                ALIVE_RECOMPILE;
                        };
                        class weatherServerInit {
                                description = "The weather server initialisation function";
                                file = "\x\alive\addons\sys_weather\fnc_weatherServerInit.sqf";
                                                                ALIVE_RECOMPILE;
                        };
                        class weatherServer {
                                description = "The weather server function";
                                file = "\x\alive\addons\sys_weather\fnc_weatherServer.sqf";
                                                                ALIVE_RECOMPILE;
                        };
                        class weatherCycleServer {
                                description = "The weather cycle function";
                                file = "\x\alive\addons\sys_weather\fnc_weatherCycleServer.sqf";
                                                                ALIVE_RECOMPILE;
                        };
                        class weatherDebugEvent {
                                description = "The weather debug cycle function";
                                file = "\x\alive\addons\sys_weather\fnc_weatherDebugEvent.sqf";
                                                                ALIVE_RECOMPILE;
                        };
                        class getRealWeather {
                                description = "Gets real weather for a time and location function";
                                file = "\x\alive\addons\sys_weather\fnc_getRealWeather.sqf";
                                                                ALIVE_RECOMPILE;
                        };
                        class weatherEffects {
                                description = "Weather effects";
                                file = "\x\alive\addons\sys_weather\fnc_weatherEffects.sqf";
                                                                ALIVE_RECOMPILE;
                        };
                };
        };
};