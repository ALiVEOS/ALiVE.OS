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
                        class activeLimiter
                        {
                                displayName = "$STR_ALIVE_PROFILE_SYSTEM_ACTIVE_LIMITER";
                                description = "$STR_ALIVE_PROFILE_SYSTEM_ACTIVE_LIMITER_COMMENT";
                                defaultvalue = "144";
                        };
                        class speedModifier
                        {
                                displayName = "$STR_ALIVE_PROFILE_SYSTEM_SPEED_MODIFIER";
                                description = "$STR_ALIVE_PROFILE_SYSTEM_SPEED_MODIFIER_COMMENT";
                                typeName = "NUMBER";
                                class Values
                                {
                                        class None
                                        {
                                                name = "None";
                                                value = 1;
                                                default = 1;
                                        };
                                        class Low
                                        {
                                                name = "25%";
                                                value = 0.25;
                                        };
                                        class Med
                                        {
                                                name = "50%";
                                                value = 0.5;
                                        };
                                        class High
                                        {
                                                name = "75%";
                                                value = 0.75;
                                        };
                                        class Extreme
                                        {
                                                name = "125%";
                                                value = 1.25;
                                        };
                                };
                        };
                };

        };
};