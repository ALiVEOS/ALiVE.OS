class CfgVehicles {
        class ModuleAliveBase;
        class ADDON : ModuleAliveBase
        {
                scope = 1;
                displayName = "$STR_ALIVE_ADMINACTIONS";
                function = "ALIVE_fnc_emptyInit";
                author = MODULE_AUTHOR;
				functionPriority = 42;
                isGlobal = 2;
                icon = "x\alive\addons\sys_adminactions\icon_sys_adminactions.paa";
                picture = "x\alive\addons\sys_adminactions\icon_sys_adminactions.paa";
                class Arguments
                {
                        class ghost
                        {
                                displayName = "$STR_ALIVE_ADMINACTIONS_GHOST";
                                description = "$STR_ALIVE_ADMINACTIONS_GHOST_COMMENT";
                                class Values
                                {
                                        class Yes
                                        {
                                                name = "Yes";
                                                value = 1;
                                                default = 1;
                                        };
                                        class No
                                        {
                                                name = "No";
                                                value = 0;
                                        };
                                };
                        };
                        class teleport
                        {
                                displayName = "$STR_ALIVE_ADMINACTIONS_TELEPORT";
                                description = "$STR_ALIVE_ADMINACTIONS_TELEPORT_COMMENT";
                                class Values
                                {
                                        class Yes
                                        {
                                                name = "Yes";
                                                value = 1;
                                                default = 1;
                                        };
                                        class No
                                        {
                                                name = "No";
                                                value = 0;
                                        };
                                };
                        };
                        class mark_units
                        {
                                displayName = "$STR_ALIVE_ADMINACTIONS_MARK_UNITS";
                                description = "$STR_ALIVE_ADMINACTIONS_MARK_UNITS_COMMENT";
                                class Values
                                {
                                        class Yes
                                        {
                                                name = "Yes";
                                                value = 1;
                                                default = 1;
                                        };
                                        class No
                                        {
                                                name = "No";
                                                value = 0;
                                        };
                                };
                        };
                        class profile_debug
                        {
                                displayName = "$STR_ALIVE_ADMINACTIONS_PROFILES_DEBUG";
                                description = "$STR_ALIVE_ADMINACTIONS_PROFILES_DEBUG_COMMENT";
                                class Values
                                {
                                        class Yes
                                        {
                                                name = "Yes";
                                                value = 1;
                                                default = 1;
                                        };
                                        class No
                                        {
                                                name = "No";
                                                value = 0;
                                        };
                                };
                        };
                        class profiles_create
                        {
                                displayName = "$STR_ALIVE_ADMINACTIONS_CREATE_PROFILES";
                                description = "$STR_ALIVE_ADMINACTIONS_CREATE_PROFILES_COMMENT";
                                class Values
                                {
                                        class Yes
                                        {
                                                name = "Yes";
                                                value = 1;
                                                default = 1;
                                        };
                                        class No
                                        {
                                                name = "No";
                                                value = 0;
                                        };
                                };
                        };
                        class agent_debug
                        {
                                displayName = "$STR_ALIVE_ADMINACTIONS_AGENTS_DEBUG";
                                description = "$STR_ALIVE_ADMINACTIONS_AGENTS_DEBUG_COMMENT";
                                class Values
                                {
                                        class Yes
                                        {
                                                name = "Yes";
                                                value = 1;
                                                default = 1;
                                        };
                                        class No
                                        {
                                                name = "No";
                                                value = 0;
                                        };
                                };
                        };
                        class console
                        {
                                displayName = "$STR_ALIVE_ADMINACTIONS_CONSOLE";
                                description = "$STR_ALIVE_ADMINACTIONS_CONSOLE_COMMENT";
                                class Values
                                {
                                        class Yes
                                        {
                                                name = "Yes";
                                                value = 1;
                                                default = 1;
                                        };
                                        class No
                                        {
                                                name = "No";
                                                value = 0;
                                        };
                                };
                        };
                };
                class ModuleDescription
                {
                    //description = "$STR_ALIVE_OPCOM_COMMENT"; // Short description, will be formatted as structured text
                    description[] = {
                            "$STR_ALIVE_ADMINACTIONS_COMMENT",
                            "",
                            "$STR_ALIVE_ADMINACTIONS_USAGE"
                    };

                };

        };
};
