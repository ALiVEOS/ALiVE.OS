class cfgFunctions {
        class PREFIX {
			class COMPONENT {
				class data {
					description = "Data Handler";
					file = "\x\alive\addons\sys_data\fnc_data.sqf";
					recompile = RECOMPILE;
				};
                class dataInit {
                    description = "The module initialisation function";
                    file = "\x\alive\addons\sys_data\fnc_dataInit.sqf";
					recompile = RECOMPILE;
                };
				class sendToPlugIn {
					description = "Sends data to an external plugin via arma2net";
					file = "\x\alive\addons\sys_data\fnc_sendToPlugIn.sqf";
					recompile = RECOMPILE;
				};
				class sendToPlugInAsync {
					description = "Sends data to an external plugin via arma2net using an Async function";
					file = "\x\alive\addons\sys_data\fnc_sendToPlugInAsync.sqf";
					recompile = RECOMPILE;
				};
				class getServerIP {
					description = "Gets the servers IP address via arma2net";
					file = "\x\alive\addons\sys_data\fnc_getServerIP.sqf";
					recompile = RECOMPILE;
				};
				class getServerName {
					description = "Gets the server hostname via arma2net";
					file = "\x\alive\addons\sys_data\fnc_getServerName.sqf";
					recompile = RECOMPILE;
				};
				class getServerTime {
					description = "Gets the current local time from the server via arma2net";
					file = "\x\alive\addons\sys_data\fnc_getServerTime.sqf";
					recompile = RECOMPILE;
				};
				class getGroupID {
					description = "Gets the group ID via arma2net";
					file = "\x\alive\addons\sys_data\fnc_getGroupID.sqf";
					recompile = RECOMPILE;
				};
				class getData {
					description = "Gets custom data";
					file = "\x\alive\addons\sys_data\fnc_getData.sqf";
					recompile = RECOMPILE;
				};
				class setData {
					description = "Sets custom data";
					file = "\x\alive\addons\sys_data\fnc_setData.sqf";
					recompile = RECOMPILE;
				};
				class startALiVEPLugIn {
					description = "Starts the ALiVE Plugin for arma2net";
					file = "\x\alive\addons\sys_data\fnc_startALiVEPlugIn.sqf";
					recompile = RECOMPILE;
				};
				class data_OnPlayerDisconnected {
						description = "The module onPlayerDisconnected handler";
						file = "\x\alive\addons\sys_data\fnc_data_onPlayerDisconnected.sqf";
						recompile = RECOMPILE;
				};
            };
        };
};
