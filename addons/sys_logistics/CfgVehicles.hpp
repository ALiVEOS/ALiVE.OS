class CfgVehicles {
        class ModuleAliveBase;

        class ADDON : ModuleAliveBase
        {
        	scope = 1;
		displayName = "$STR_ALIVE_LOGISTICS";
		function = "ALIVE_fnc_emptyInit";
		functionPriority = 45;
		isGlobal = 2;
		icon = "x\alive\addons\sys_logistics\icon_sys_logistics.paa";
		picture = "x\alive\addons\sys_logistics\icon_sys_logistics.paa";
		author = MODULE_AUTHOR;
        };

        class ALiVE_SYS_LOGISTICSDISABLE : ModuleAliveBase
        {
		scope = 2;
		displayName = "$STR_ALIVE_LOGISTICSDISABLE";
		function = "ALIVE_fnc_logisticsDisable";
		functionPriority = 10;
		isGlobal = 2;
		icon = "x\alive\addons\sys_logistics\icon_sys_logistics.paa";
		picture = "x\alive\addons\sys_logistics\icon_sys_logistics.paa";
		author = MODULE_AUTHOR;

                class ModuleDescription
		{
			description[] = {
					"$STR_ALIVE_LOGISTICSDISABLE_COMMENT",
					"",
					"$STR_ALIVE_LOGISTICSDISABLE_USAGE"
			};
		};

                class Arguments
                {

                        class DEBUG
                        {
                                displayName = "$STR_ALIVE_LOGISTICS_DEBUG";
                                description = "$STR_ALIVE_LOGISTICS_DEBUG_COMMENT";
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
                        class DISABLELOG
                        {
                                displayName = "$STR_ALIVE_LOGISTICS_DISABLELOG";
                                description = "$STR_ALIVE_LOGISTICS_DISABLELOG_COMMENT";
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
                        class DISABLEPERSISTENCE
                        {
                                displayName = "$STR_ALIVE_LOGISTICS_DISABLEPERSISTENCE";
                                description = "$STR_ALIVE_LOGISTICS_DISABLEPERSISTENCE_COMMENT";
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
                        class DISABLELOAD
                        {
                                displayName = "$STR_ALIVE_LOGISTICS_DISABLELOAD";
                                description = "$STR_ALIVE_LOGISTICS_DISABLELOAD_COMMENT";
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
                        class DISABLETOW
                        {
                                displayName = "$STR_ALIVE_LOGISTICS_DISABLETOW";
                                description = "$STR_ALIVE_LOGISTICS_DISABLETOW_COMMENT";
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
                        class DISABLELIFT
                        {
                                displayName = "$STR_ALIVE_LOGISTICS_DISABLELIFT";
                                description = "$STR_ALIVE_LOGISTICS_DISABLELIFT_COMMENT";
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
                        class DISABLECARRY
                        {
                                displayName = "$STR_ALIVE_LOGISTICS_DISABLECARRY";
                                description = "$STR_ALIVE_LOGISTICS_DISABLECARRY_COMMENT";
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
                        class DISABLE3D
                        {
                                displayName = "$STR_ALIVE_LOGISTICS_DISABLE3D";
                                description = "$STR_ALIVE_LOGISTICS_DISABLE3D_COMMENT";
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
                        class BLACKLIST
                        {
                                displayName = "$STR_ALIVE_LOGISTICS_BLACKLIST";
                                description = "$STR_ALIVE_LOGISTICS_BLACKLIST_COMMENT";
                                defaultValue = "";
                        };
                };
        };
};
