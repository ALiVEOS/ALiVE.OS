class CfgVehicles {
        class ModuleAliveBase;
        class ADDON : ModuleAliveBase
        {
                scope = 2;
                displayName = "$STR_ALIVE_PROFILE_SYSTEM";
                function = "ALIVE_fnc_profileSystemInit";
                author = MODULE_AUTHOR;
                functionPriority = 60;
                isGlobal = 2;
                icon = "x\alive\addons\sys_profile\icon_sys_profile.paa";
                picture = "x\alive\addons\sys_profile\icon_sys_profile.paa";
                class Arguments
                {
                    class debug
                    {
                        displayName = "$STR_ALIVE_PROFILE_SYSTEM_DEBUG";
                        description = "$STR_ALIVE_PROFILE_SYSTEM_DEBUG_COMMENT";
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
                    class persistent
                    {
                        displayName = "$STR_ALIVE_PROFILE_SYSTEM_PERSISTENT";
                        description = "$STR_ALIVE_PROFILE_SYSTEM_PERSISTENT_COMMENT";
                        class Values
                        {
                            class No
                            {
                                name = "No";
                                value = false;
                                default = 1;
                            };
                            class Yes
                            {
                                name = "Yes";
                                value = true;
                            };
                        };
                    };
                    class syncronised
                    {
                        displayName = "$STR_ALIVE_PROFILE_SYSTEM_SYNC";
                        description = "$STR_ALIVE_PROFILE_SYSTEM_SYNC_COMMENT";
                        class Values
                        {
                            class Add
                            {
                                name = "$STR_ALIVE_PROFILE_SYSTEM_SYNC_ADD";
                                value = "ADD";
                                default = 1;
                            };
                            class Ignore
                            {
                                name = "$STR_ALIVE_PROFILE_SYSTEM_SYNC_IGNORE";
                                value = "IGNORE";
                            };
                        };
                    };
                    class spawnRadius
                    {
                        displayName = "$STR_ALIVE_PROFILE_SYSTEM_SPAWN_RADIUS";
                        description = "$STR_ALIVE_PROFILE_SYSTEM_SPAWN_RADIUS_COMMENT";
                        defaultvalue = "1500";
                    };
                    class spawnTypeHeliRadius
                    {
                        displayName = "$STR_ALIVE_PROFILE_SYSTEM_SPAWN_HELI_RADIUS";
                        description = "$STR_ALIVE_PROFILE_SYSTEM_SPAWN_HELI_RADIUS_COMMENT";
                        defaultvalue = "1500";
                    };
                    class spawnTypeJetRadius
                    {
                        displayName = "$STR_ALIVE_PROFILE_SYSTEM_SPAWN_JET_RADIUS";
                        description = "$STR_ALIVE_PROFILE_SYSTEM_SPAWN_JET_RADIUS_COMMENT";
                        defaultvalue = "0";
                    };
                    class spawnRadiusUAV
                    {
                        displayName = "$STR_ALIVE_PROFILE_SYSTEM_SPAWN_UAV_RADIUS";
                        description = "$STR_ALIVE_PROFILE_SYSTEM_SPAWN_UAV_RADIUS_COMMENT";
                        defaultvalue = "-1";
                    };
                    class activeLimiter
                    {
                        displayName = "$STR_ALIVE_PROFILE_SYSTEM_ACTIVE_LIMITER";
                        description = "$STR_ALIVE_PROFILE_SYSTEM_ACTIVE_LIMITER_COMMENT";
                        defaultvalue = "144";
                    };
                    class zeusSpawn
                    {
                        displayName = "$STR_ALIVE_PROFILE_SYSTEM_ZEUSSPAWN";
                        description = "$STR_ALIVE_PROFILE_SYSTEM_ZEUSSPAWN_COMMENT";
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
                    class speedModifier
                    {
                        displayName = "$STR_ALIVE_PROFILE_SYSTEM_SPEED_MODIFIER";
                        description = "$STR_ALIVE_PROFILE_SYSTEM_SPEED_MODIFIER_COMMENT";
                        typeName = "STRING";
                        class Values
                        {
                            class Low
                            {
                                name = "25%";
                                value = "0.25";
                            };
                            class Medium
                            {
                                name = "50%";
                                value = "0.50";
                            };
                            class High
                            {
                                name = "75%";
                                value = "0.75";
                            };
                            class None
                            {
                                name = "100%";
                                value = "1.00";
                                default = 1;
                            };
                            class Extreme
                            {
                                name = "125%";
                                value = "1.25";
                            };
                            class Extremer
                            {
                                name = "150%";
                                value = "1.50";
                            };
                            class Crazy
                            {
                                name = "175%";
                                value = "1.75";
                            };
                            class Insane
                            {
                                name = "200%";
                                value = "2.00";
                            };
                        };
                    };
					class virtualcombat_speedmodifier
                    {
                        displayName = "$STR_ALIVE_PROFILE_SYSTEM_VIRTUAL_COMBAT_SPEED_MODIFIER";
                        description = "$STR_ALIVE_PROFILE_SYSTEM_VIRTUAL_COMBAT_SPEED_MODIFIER_COMMENT";
						class Values
						{
							class Regular
							{
								name = "Regular";
								Value = 0.75;
								default = 1;
							};
							class Fastest
							{
								name = "Fastest";
								Value = 1.75;
							};
							class Faster
							{
								name = "Faster";
								Value = 1.25;
							};
							class Slower
							{
								name = "Slower";
								Value = 0.35;
							};
							class Slowest
							{
								name = "Slowest";
								Value = 0.1;
							};
						};
					};
                    class pathfinding
                    {
                        displayName = "$STR_ALIVE_PROFILE_SYSTEM_PATHFINDING";
                        description = "$STR_ALIVE_PROFILE_SYSTEM_PATHFINDING_COMMENT";
                        class Values
                        {
                            class No
                            {
                                name = "No";
                                value = false;
                                default = 1;
                            };
                            class Yes
                            {
                                name = "Yes";
                                value = true;
                            };
                        };
                    };
                    class pathfindingSize
                    {
                        displayName = "$STR_ALIVE_PROFILE_SYSTEM_PATHFINDING_GRID";
                        description = "$STR_ALIVE_PROFILE_SYSTEM_PATHFINDING_GRID_COMMENT";
                        class Values
                        {
                            class SmallHighRes
                            {
                                name = "10km - High - (200 x 40)";
                                value = [200,40];
                            };
                            class SmallMedRes
                            {
                                name = "10km - Med - (250 x 50)";
                                value = [250,50];
                            };
                            class SmallLowRes
                            {
                                name = "10km - Low - (300 x 60)";
                                value = [300,60];
                            };
                            class MedHighRes
                            {
                                name = "20km - High - (400 x 50)";
                                value = [400,50];
                            };
                            class MedMedRes
                            {
                                name = "20km - Med - (480 x 60)";
                                value = [480,60];
                            };
                            class MedLowRes
                            {
                                name = "20km - Low - (600 x 75)";
                                value = [600,75];
                                default = 1;
                            };
                            class HighHighRes
                            {
                                name = "30km - High - (640 x 80)";
                                value = [640,80];
                            };
                            class HighMedRes
                            {
                                name = "30km - Med - 720 x 90)";
                                value = [720,90];
                            };
                            class HighLowRes
                            {
                                name = "30km - Low - (800 x 100)";
                                value = [800,100];
                            };
                            class UltraHighHighRes
                            {
                                name = "40km - High - (800 x 100)";
                                value = [800,100];
                            };
                            class UltraHighMedRes
                            {
                                name = "40km - Med - (1000 x 125)";
                                value = [1000,125];
                            };
                            class UltraHighLowRes
                            {
                                name = "40km - Low - (1200 x 150)";
                                value = [1200,150];
                            };
                        };
                    };
                    class seaTransport
                    {
                        displayName = "$STR_ALIVE_PROFILE_SYSTEM_SEATRANSPORT";
                        description = "$STR_ALIVE_PROFILE_SYSTEM_SEATRANSPORT_COMMENT";
                        class Values
                        {
                            class No
                            {
                                name = "No";
                                value = false;
                                default = 1;
                            };
                            class Yes
                            {
                                name = "Yes";
                                value = true;
                            };
                        };
                    };
                    class smoothSpawn
                    {
                        displayName = "$STR_ALIVE_PROFILE_SYSTEM_SMOOTHSPAWN";
                        description = "$STR_ALIVE_PROFILE_SYSTEM_SMOOTHSPAWN_COMMENT";
                        defaultvalue = "0.3";
                    };
                };
        };
};