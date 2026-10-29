class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class zeusModule {
                                description = "Entry point of the plain Zeus modules";
                                file = "\x\alive\addons\sys_zeus\fnc_zeusModule.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class zeusClient {
                                description = "The Zeus side of each module: asks for any options, then sends the request";
                                file = "\x\alive\addons\sys_zeus\fnc_zeusClient.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class zeusRequest {
                                description = "Server: checks who is asking, then runs the request";
                                file = "\x\alive\addons\sys_zeus\fnc_zeusRequest.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class zeusServer {
                                description = "Server: what each module does";
                                file = "\x\alive\addons\sys_zeus\fnc_zeusServer.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class zeusFeedback {
                                description = "Shows the Zeus the outcome of a request";
                                file = "\x\alive\addons\sys_zeus\fnc_zeusFeedback.sqf";
                                ALIVE_RECOMPILE;
                        };
                };
        };
};
