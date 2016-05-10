class CfgVehicles {
        class ModuleAliveBase;
        class ADDON : ModuleAliveBase
        {
                scope = 1;
                displayName = "$STR_ALIVE_GC";
                function = "ALIVE_fnc_emptyInit";
                author = MODULE_AUTHOR;
				functionPriority = 46;
                isGlobal = 2;
				icon = "x\alive\addons\sys_GC\icon_sys_GC.paa";
				picture = "x\alive\addons\sys_GC\icon_sys_GC.paa";
                class Arguments
                {
                        class debug
                        {
                                displayName = "$STR_ALIVE_GC_DEBUG";
                                description = "$STR_ALIVE_GC_DEBUG_COMMENT";
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
                        class ALiVE_GC_INTERVAL
                        {
                                displayName = "$STR_ALIVE_GC_INTERVAL";
                                description = "$STR_ALIVE_GC_INTERVAL_COMMENT";
                                defaultValue = 300;
                        };
                        class ALiVE_GC_THRESHHOLD
                        {
                                displayName = "$STR_ALIVE_GC_THRESHHOLD";
                                description = "$STR_ALIVE_GC_THRESHHOLD_COMMENT";
                                defaultValue = 100;
                        };
                        class ALiVE_GC_INDIVIDUALTYPES
                        {
                                displayName = "$STR_ALIVE_GC_INDIVIDUALTYPES";
                                description = "$STR_ALIVE_GC_INDIVIDUALTYPES_COMMENT";
                                defaultValue = "";
                        };
                 };

        };
};
