class CfgVehicles {
        class ModuleAliveBase;
        class ADDON : ModuleAliveBase
        {
                scope = 2;
                displayName = "$STR_ALIVE_COMBATSUPPORT";
                function = "ALIVE_fnc_CombatSupportInit";
                author = MODULE_AUTHOR;
	            functionPriority = 160;
                isGlobal = 2;
                icon = "x\alive\addons\sup_combatsupport\icon_sup_combatsupport.paa";
                picture = "x\alive\addons\sup_combatsupport\icon_sup_combatsupport.paa";
                class Arguments
                {
                        class combatsupport_item
                        {
                                displayName = "$STR_ALIVE_CS_ALLOW";
                                description = "$STR_ALIVE_CS_ALLOW_COMMENT";
                                defaultValue = "LaserDesignator";
                        };
                        class combatsupport_casrespawnlimit
                        {
                                displayName = "$STR_ALIVE_CAS_LIMIT";
                                description = "$STR_ALIVE_CAS_LIMIT_COMMENT";
                                defaultValue = "3";
                        };
                        class combatsupport_transportrespawnlimit
                        {
                                displayName = "$STR_ALIVE_TRANS_LIMIT";
                                description = "$STR_ALIVE_TRANS_LIMIT_COMMENT";
                                defaultValue = "3";
                        };
                        class combatsupport_artyrespawnlimit
                        {
                                displayName = "$STR_ALIVE_ARTY_LIMIT";
                                description = "$STR_ALIVE_ARTY_LIMIT_COMMENT";
                                defaultValue = "3";
                        };
                        class combatsupport_respawn
                        {
                                displayName = "$STR_ALIVE_CS_RESPAWN";
                                description = "$STR_ALIVE_CS_RESPAWN_COMMENT";
                                class values
                                {
                                	class RESPAWN_1
                                	{
                                		name="1 Min";
                                		value = 60;
                                		CS_RESPAWN = 60;
                                	};
                                	class RESPAWN_10
                                	{
                                		name="10 Mins";
                                		value = 600;
                                		CS_RESPAWN = 600;
                                		default = 1;
                                	};
                                	class RESPAWN_20
                                	{
                                		name="20 Mins";
                                		value = 1200;
                                		CS_RESPAWN = 1200;
                                	};
                                	class RESPAWN_30
                                	{
                                		name="30 Mins";
                                		value = 1800;
                                		CS_RESPAWN = 1800;
                                	};
                                };
                        };
                };
                class ModuleDescription
				{
					//description = "$STR_ALIVE_CS_COMMENT"; // Short description, will be formatted as structured text
					description[] = {
						"$STR_ALIVE_CS_COMMENT",
						"",
						"$STR_ALIVE_CS_USAGE"
					};
					sync[] = {"ALiVE_SUP_TRANSPORT","ALiVE_SUP_CAS","ALiVE_SUP_ARTILLERY"}; // Array of synced entities (can contain base classes)

					class ALiVE_SUP_TRANSPORT
					{
						description[] = { // Multi-line descriptions are supported
							"$STR_ALIVE_TRANSPORT_COMMENT",
							"",
							"$STR_ALIVE_TRANSPORT_USAGE"
						};
						position = 1; // Position is taken into effect
						direction = 1; // Direction is taken into effect
						optional = 1; // Synced entity is optional
						duplicate = 1; // Multiple entities of this type can be synced
					};
					class ALiVE_SUP_CAS
					{
						description[] = { // Multi-line descriptions are supported
							"$STR_ALIVE_CAS_COMMENT",
							"",
							"$STR_ALIVE_CAS_USAGE"
						};
						position = 1; // Position is taken into effect
						direction = 1; // Direction is taken into effect
						optional = 1; // Synced entity is optional
						duplicate = 1; // Multiple entities of this type can be synced
					};
                    class ALiVE_SUP_ARTILLERY
                    {
						description[] = { // Multi-line descriptions are supported
							"$STR_ALIVE_ARTILLERY_COMMENT",
							"",
							"$STR_ALIVE_ARTILLERY_USAGE"
						};
						position = 1; // Position is taken into effect
						direction = 1; // Direction is taken into effect
						optional = 1; // Synced entity is optional
						duplicate = 1; // Multiple entities of this type can be synced
                    };
				};
        };
};
