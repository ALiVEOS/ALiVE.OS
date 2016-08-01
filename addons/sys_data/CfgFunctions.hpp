class cfgFunctions {
        class PREFIX {
            class COMPONENT {
                class data {
                    description = "Data Handler";
										file = PATHTO_FUNC(data);
                    recompile = RECOMPILE;
                };
                class dataInit {
                    description = "The module initialisation function";
										file = PATHTO_FUNC(dataInit);
                    recompile = RECOMPILE;
                };
                class sendToPlugIn {
                    description = "Sends data to an external plugin via arma2net";
										file = PATHTO_FUNC(sendToPlugIn);
                    recompile = RECOMPILE;
                };
                class sendToPlugInAsync {
                    description = "Sends data to an external plugin via arma2net using an Async function";
										file = PATHTO_FUNC(sendToPlugInAsync);
                    recompile = RECOMPILE;
                };
                class getServerIP {
                    description = "Gets the servers IP address via arma2net";
										file = PATHTO_FUNC(getServerIP);
                    recompile = RECOMPILE;
                };
                class getServerName {
                    description = "Gets the server hostname via arma2net";
										file = PATHTO_FUNC(getServerName);
                    recompile = RECOMPILE;
                };
                class getServerTime {
                    description = "Gets the current local time from the server via arma2net";
										file = PATHTO_FUNC(getServerTime);
                    recompile = RECOMPILE;
                };
                class getGroupID {
                    description = "Gets the group ID via arma2net";
										file = PATHTO_FUNC(getGroupID);
                    recompile = RECOMPILE;
                };
                class getData {
                    description = "Gets custom data";
										file = PATHTO_FUNC(getData);
                    recompile = RECOMPILE;
                };
                class setData {
                    description = "Sets custom data";
										file = PATHTO_FUNC(setData);
                    recompile = RECOMPILE;
                };
                class startALiVEPLugIn {
                    description = "Starts the ALiVE Plugin for arma2net";
										file = PATHTO_FUNC(startALiVEPlugin);
                    recompile = RECOMPILE;
                };
                class data_OnPlayerDisconnected {
                        description = "The module onPlayerDisconnected handler";
												file = PATHTO_FUNC(data_onPlayerDisconnected);
                        recompile = RECOMPILE;
                };
            };
        };
};
