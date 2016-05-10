class CfgVehicles {
        class ModuleAliveBase;
        class ADDON : ModuleAliveBase
        {
                scope = 2;
                displayName = "$STR_ALIVE_multispawn";
                function = "ALIVE_fnc_multispawnInit";
                author = MODULE_AUTHOR;
                functionPriority = 210;
                isGlobal = 2;
				icon = "x\alive\addons\sup_multispawn\icon_sup_multispawn.paa";
				picture = "x\alive\addons\sup_multispawn\icon_sup_multispawn.paa";
                class Arguments
                {
                        class debug
                        {
                                displayName = "$STR_ALIVE_multispawn_DEBUG";
                                description = "$STR_ALIVE_multispawn_DEBUG_COMMENT";
                                class Values
                                {
                                        class Yes
                                        {
                                                name = "Yes";
                                                value = true;
                                        };
                                        class No
                                        {
                                                name = "No";
                                                value = false;
                                                default = 1;
                                        };
                                };
                        };

                        class spawntype
                        {
                                displayName = "$STR_ALIVE_multispawn_TYPE";
                                description = "$STR_ALIVE_multispawn_TYPE_COMMENT";
                                class Values
                                {
                                        class forwardspawn
                                        {
                                                name = "Spawn on squad";
                                                value = "forwardspawn";
                                                default = 1;
                                        };

                                        class insertion
                                        {
                                                name = "Insertion";
                                                value = "insertion";
                                        };

                                        class vehicle
                                        {
                                                name = "Spawn in vehicle";
                                                value = "vehicle";
                                        };

                                        class building
                                        {
                                                name = "Spawn in building";
                                                value = "building";
                                        };
                                        
                                        class none
                                        {
                                                name = "None";
                                                value = "none";
                                        };
                                };
                        };

                        class timeout
                        {
                                displayName = "$STR_ALIVE_MULTISPAWN_TIMEOUT";
                                description = "$STR_ALIVE_MULTISPAWN_TIMEOUT_COMMENT";
                                defaultValue = 60;
                        };

                        class spawningnearenemiesallowed
                        {
                                displayName = "$STR_ALIVE_multispawn_SPAWNINGNEARENEMIESALLOWED";
                                description = "$STR_ALIVE_multispawn_SPAWNINGNEARENEMIESALLOWED_COMMENT";
                                class Values
                                {
                                        class Yes
                                        {
                                                name = "No";
                                                value = false;
                                                default = 1;
                                        };
                                        class No
                                        {
                                                name = "Yes";
                                                value = true;
                                        };
                                };
                        };
                        class respawnWithGear
                        {
                                displayName = "$STR_ALIVE_multispawn_RESPAWNWITHGEAR";
                                description = "$STR_ALIVE_multispawn_RESPAWNWITHGEAR_COMMENT";
                                class Values
                                {
                                        class Yes
                                        {
                                                name = "Yes";
                                                value = true;
                                                default = 1;
                                        };
                                        class No
                                        {
                                                name = "No";
                                                value = false;
                                        };
                                };
                        };
                };
                class ModuleDescription
				{
					description[] = {
							"$STR_ALIVE_MULTISPAWN_COMMENT",
							"",
							"$STR_ALIVE_MULTISPAWN_USAGE"
					};
				};

        };
};
