class CfgVehicles {
        class ModuleAliveBase;
        class ADDON : ModuleAliveBase
        {
                scope = 1;
                displayName = "$STR_ALIVE_NEWSFEED";
				function = "ALIVE_fnc_emptyInit";
                functionPriority = 41;
                isGlobal = 1;
                isPersistent = 1;
                icon = "x\alive\addons\sys_newsfeed\icon_sys_newsfeed.paa";
                picture = "x\alive\addons\sys_newsfeed\icon_sys_newsfeed.paa";
                 class Arguments
                {
                        class Enabled
                        {
                                displayName = "$STR_ALIVE_NEWSFEED_ALLOW";
                                description = "$STR_ALIVE_NEWSFEED_ALLOW_COMMENT";
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
                          class Condition
                        {
                                displayName = "Condition:";
                                description = "";
                                defaultValue = "true";
                        };
                };

        };
};

