class cfgFunctions {
        class PREFIX {
            class COMPONENT {
                class data {
                    description = "Data Handler";
                    file = "\x\alive\addons\sys_data\fnc_data.sqf";
                    RECOMPILE;
                };
                class dataInit {
                    description = "The module initialisation function";
                    file = "\x\alive\addons\sys_data\fnc_dataInit.sqf";
                    RECOMPILE;
                };
                class sendToPlugIn {
                    description = "Sends data to an external plugin via arma2net";
                    file = "\x\alive\addons\sys_data\fnc_sendToPlugIn.sqf";
                    RECOMPILE;
                };
                class sendToPlugInAsync {
                    description = "Sends data to an external plugin via arma2net using an Async function";
                    file = "\x\alive\addons\sys_data\fnc_sendToPlugInAsync.sqf";
                    RECOMPILE;
                };
                class getServerIP {
                    description = "Gets the servers IP address via arma2net";
                    file = "\x\alive\addons\sys_data\fnc_getServerIP.sqf";
                    RECOMPILE;
                };
                class getServerName {
                    description = "Gets the server hostname via arma2net";
                    file = "\x\alive\addons\sys_data\fnc_getServerName.sqf";
                    RECOMPILE;
                };
                class getServerTime {
                    description = "Gets the current local time from the server via arma2net";
                    file = "\x\alive\addons\sys_data\fnc_getServerTime.sqf";
                    RECOMPILE;
                };
                class getGroupID {
                    description = "Gets the group ID via arma2net";
                    file = "\x\alive\addons\sys_data\fnc_getGroupID.sqf";
                    RECOMPILE;
                };
                class getData {
                    description = "Gets custom data";
                    file = "\x\alive\addons\sys_data\fnc_getData.sqf";
                    RECOMPILE;
                };
                class setData {
                    description = "Sets custom data";
                    file = "\x\alive\addons\sys_data\fnc_setData.sqf";
                    RECOMPILE;
                };
                class startALiVEPLugIn {
                    description = "Starts the ALiVE Plugin for arma2net";
                    file = "\x\alive\addons\sys_data\fnc_startALiVEPlugIn.sqf";
                    RECOMPILE;
                };
                class data_OnPlayerDisconnected {
                        description = "The module onPlayerDisconnected handler";
                        file = "\x\alive\addons\sys_data\fnc_data_onPlayerDisconnected.sqf";
                        RECOMPILE;
                };
            };
        };
};
