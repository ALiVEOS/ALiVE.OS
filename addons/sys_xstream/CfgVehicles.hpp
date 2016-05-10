class CfgVehicles {
	class ModuleAliveBase;
	class ADDON: ModuleAliveBase {
		author = "Tupolov";
		// Editor visibility; 2 will show it in the menu, 1 will hide it.
		scope = 1;
		// Name displayed in the menu
		displayName = "$STR_ALIVE_XSTREAM";
		// Map icon. Delete this entry to use the default icon
		icon = "x\alive\addons\sys_xstream\icon_sys_xstream.paa";
		// Name of function triggered once conditions are met
		function = "ALIVE_fnc_xStreamInit";
		// Execution priority, modules with lower number are executed first. 0 is used when the attribute is undefined
		functionPriority = 240;
		// 1 for remote execution on all clients, 0 for server only execution, 2 for persistent execution (i.e. will be called on every JIPped client). Use with caution, can lead to desync
		isGlobal = 2;
		// 1 for module waiting until all synced triggers are activated
		isTriggerActivated = 0;

		picture = "x\alive\addons\sys_xstream\icon_sys_xstream.paa";

		// Module description. Must inherit from base class, otherwise pre-defined entities won't be available
		class ModuleDescription
		{
			// Short description, will be formatted as structured text
			description = "$STR_ALIVE_XSTREAM_COMMENT";
		};

		// Module arguments
		class Arguments {
			// Module specific arguments
			class debug {
				// Argument label
				displayName = "$STR_ALIVE_XSTREAM_DEBUG";
				// Tooltip description
				description = "$STR_ALIVE_XSTREAM_COMMENT";
				// Value type, can be "NUMBER", "STRING" or "BOOL"
				typeName = "BOOL";
				class Values {
					class Yes {
						name = "Yes";
						value = 1;
						default = 1;
					};
					class No {
						name = "No";
						value = 0;
					};
				};
			};

			class enabletwitch {
				// Argument label
				displayName = "$STR_ALIVE_XSTREAM_enabletwitch";
				// Tooltip description
				description = "$STR_ALIVE_XSTREAM_enabletwitch_COMMENT";
				// Value type, can be "NUMBER", "STRING" or "BOOL"
				typeName = "BOOL";
				class Values {
					class Yes {
						name = "Yes";
						value = 1;
						default = 1;
					};
					class No {
						name = "No";
						value = 0;
					};
				};
			};

			class enableLiveMap {
				// Argument label
				displayName = "$STR_ALIVE_XSTREAM_enableLiveMap";
				// Tooltip description
				description = "$STR_ALIVE_XSTREAM_enableLiveMap_COMMENT";
				// Value type, can be "NUMBER", "STRING" or "BOOL"
				typeName = "BOOL";
				class Values {
					class Yes {
						name = "Yes";
						value = 1;
						default = 1;
					};
					class No {
						name = "No";
						value = 0;
					};
				};
			};

			class enableCamera {
				// Argument label
				displayName = "$STR_ALIVE_XSTREAM_enableCamera";
				// Tooltip description
				description = "$STR_ALIVE_XSTREAM_enableCamera_COMMENT";
				// Value type, can be "NUMBER", "STRING" or "BOOL"
				typeName = "BOOL";
				class Values {
					class Yes {
						name = "Yes";
						value = 1;
						default = 1;
					};
					class No {
						name = "No";
						value = 0;
					};
				};
			};

			class acreChannel {
				// Argument label
				displayName = "$STR_ALIVE_XSTREAM_acreChannel";
				// Tooltip description
				description = "$STR_ALIVE_XSTREAM_acreChannel_COMMENT";
				// Value type, can be "NUMBER", "STRING" or "BOOL"
				defaultValue = "";
			};

			class cameraShake {
				// Argument label
				displayName = "$STR_ALIVE_XSTREAM_CAMERASHAKE";
				// Tooltip description
				description = "$STR_ALIVE_XSTREAM_CAMERASHAKE_COMMENT";
				// Value type, can be "NUMBER", "STRING" or "BOOL"
				typeName = "BOOL";
				class Values {
					class Yes {
						name = "Yes";
						value = 1;
						default = 1;
					};
					class No {
						name = "No";
						value = 0;
					};
				};
			};

			class satellite {
				// Argument label
				displayName = "$STR_ALIVE_XSTREAM_satellite";
				// Tooltip description
				description = "$STR_ALIVE_XSTREAM_satellite_COMMENT";
				// Value type, can be "NUMBER", "STRING" or "BOOL"
				typeName = "BOOL";
				class Values {
					class Yes {
						name = "Yes";
						value = 1;
						default = 1;
					};
					class No {
						name = "No";
						value = 0;
					};
				};
			};

			class aerial {
				// Argument label
				displayName = "$STR_ALIVE_XSTREAM_aerial";
				// Tooltip description
				description = "$STR_ALIVE_XSTREAM_aerial_COMMENT";
				// Value type, can be "NUMBER", "STRING" or "BOOL"
				typeName = "BOOL";
				class Values {
					class Yes {
						name = "Yes";
						value = 1;
						default = 1;
					};
					class No {
						name = "No";
						value = 0;
					};
				};
			};

			class vehicle {
				// Argument label
				displayName = "$STR_ALIVE_XSTREAM_vehicle";
				// Tooltip description
				description = "$STR_ALIVE_XSTREAM_vehicle_COMMENT";
				// Value type, can be "NUMBER", "STRING" or "BOOL"
				typeName = "BOOL";
				class Values {
					class Yes {
						name = "Yes";
						value = 1;
						default = 1;
					};
					class No {
						name = "No";
						value = 0;
					};
				};
			};

			class thirdPerson {
				// Argument label
				displayName = "$STR_ALIVE_XSTREAM_thirdPerson";
				// Tooltip description
				description = "$STR_ALIVE_XSTREAM_thirdPerson_COMMENT";
				// Value type, can be "NUMBER", "STRING" or "BOOL"
				typeName = "BOOL";
				class Values {
					class Yes {
						name = "Yes";
						value = 1;
						default = 1;
					};
					class No {
						name = "No";
						value = 0;
					};
				};
			};

			class cameraManOnly {
				// Argument label
				displayName = "$STR_ALIVE_XSTREAM_cameraManOnly";
				// Tooltip description
				description = "$STR_ALIVE_XSTREAM_cameraManOnly_COMMENT";
				// Value type, can be "NUMBER", "STRING" or "BOOL"
				typeName = "BOOL";
				class Values {
					class Yes {
						name = "Yes";
						value = 1;
						default = 1;
					};
					class No {
						name = "No";
						value = 0;
					};
				};
			};

			class clientID {
				displayName = "$STR_ALIVE_XSTREAM_CLIENTID";
				description = "$STR_ALIVE_XSTREAM_CLIENTID_COMMENT";
				defaultValue = "";
			};

		};
	};
};

