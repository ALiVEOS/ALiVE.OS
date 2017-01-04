class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class weatherInit {
                                description = "The module initialisation function";
                                file = "\x\alive\addons\sys_weather\fnc_weatherInit.sqf";
                                                                RECOMPILE;
                        };
                        class weather {
                                description = "The main class";
                                file = "\x\alive\addons\sys_weather\fnc_weather.sqf";
                                                                RECOMPILE;
                        };
                        class weatherServerInit {
                                description = "The weather server initialisation function";
                                file = "\x\alive\addons\sys_weather\fnc_weatherServerInit.sqf";
                                                                RECOMPILE;
                        };
                        class weatherServer {
                                description = "The weather server function";
                                file = "\x\alive\addons\sys_weather\fnc_weatherServer.sqf";
                                                                RECOMPILE;
                        };
                        class weatherCycleServer {
                                description = "The weather cycle function";
                                file = "\x\alive\addons\sys_weather\fnc_weatherCycleServer.sqf";
                                                                RECOMPILE;
                        };
                        class weatherDebugEvent {
                                description = "The weather debug cycle function";
                                file = "\x\alive\addons\sys_weather\fnc_weatherDebugEvent.sqf";
                                                                RECOMPILE;
                        };
                        class getRealWeather {
                                description = "Gets real weather for a time and location function";
                                file = "\x\alive\addons\sys_weather\fnc_getRealWeather.sqf";
                                                                RECOMPILE;
                        };
                };
        };
};