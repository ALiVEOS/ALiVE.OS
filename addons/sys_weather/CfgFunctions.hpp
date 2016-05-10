class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class weatherInit {
                                description = "The module initialisation function";
                                file = "\x\alive\addons\sys_weather\fnc_weatherInit.sqf";
																recompile = RECOMPILE;
                        }; 
                        class weather {
                                description = "The main class";
                                file = "\x\alive\addons\sys_weather\fnc_weather.sqf";
																recompile = RECOMPILE;
                        };
                        class weatherServerInit {
                                description = "The weather server initialisation function";
                                file = "\x\alive\addons\sys_weather\fnc_weatherServerInit.sqf";
																recompile = RECOMPILE;
                        }; 
                        class weatherServer {
                                description = "The weather server function";
                                file = "\x\alive\addons\sys_weather\fnc_weatherServer.sqf";
																recompile = RECOMPILE;
                        }; 
                        class weatherCycleServer {
                                description = "The weather cycle function";
                                file = "\x\alive\addons\sys_weather\fnc_weatherCycleServer.sqf";
																recompile = RECOMPILE;
                        }; 
                        class weatherDebugEvent {
                                description = "The weather debug cycle function";
                                file = "\x\alive\addons\sys_weather\fnc_weatherDebugEvent.sqf";
																recompile = RECOMPILE;
                        }; 
                        
                        class getWeather {
                                description = "Gets real weather for a time and location function";
                                file = "\x\alive\addons\sys_weather\fnc_getWeather.sqf";
																recompile = RECOMPILE;
                        };        
                        
                };
        };
};