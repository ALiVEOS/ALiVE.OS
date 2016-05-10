class CfgVehicles {
        class ModuleAliveBase;
        class ADDON : ModuleAliveBase
        {
                scope = 1;
                displayName = "$STR_ALIVE_MI";
                function = "ALIVE_fnc_MIInit";
                author = MODULE_AUTHOR;
				functionPriority = 181;
                isGlobal = 1;
				icon = "x\alive\addons\mil_intelligence\icon_mil_MI.paa";
				picture = "x\alive\addons\mil_intelligence\icon_mil_MI.paa";
                class Arguments
                {
                        class debug
                        {
                                displayName = "$STR_ALIVE_MI_DEBUG";
                                description = "$STR_ALIVE_MI_DEBUG_COMMENT";
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
						class intelChance
                        {
                                displayName = "$STR_ALIVE_MI_INTEL_CHANCE";
                                description = "$STR_ALIVE_MI_INTEL_CHANCE_COMMENT";
                                class Values
                                {
                                        class LOW
                                        {
                                                name = "$STR_ALIVE_MI_INTEL_CHANCE_LOW";
                                                value = "0.1";
                                        };
										class MEDIUM
                                        {
                                                name = "$STR_ALIVE_MI_INTEL_CHANCE_MEDIUM";
                                                value = "0.2";
                                        };
										class HIGH
                                        {
                                                name = "$STR_ALIVE_MI_INTEL_CHANCE_HIGH";
                                                value = "0.4";
                                        };
										class TOTAL
                                        {
                                                name = "$STR_ALIVE_MI_INTEL_CHANCE_TOTAL";
                                                value = "1";
                                                default = 1;
                                        };
                                };
                        };
                        class friendlyIntel
                        {
                                displayName = "$STR_ALIVE_MI_FRIENDLY_INTEL";
                                description = "$STR_ALIVE_MI_FRIENDLY_INTEL_COMMENT";
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
                        class friendlyIntelRadius
                        {
                                displayName = "$STR_ALIVE_MI_FRIENDLY_INTEL_RADIUS";
                                description = "$STR_ALIVE_MI_FRIENDLY_INTEL_RADIUS_COMMENT";
                                defaultValue = "2000";
                        };
                };

        };
        class ADDON2 : ModuleAliveBase
        {
                scope = 1;
                displayName = "$STR_ALIVE_SD";
                function = "ALIVE_fnc_SDInit";
                author = MODULE_AUTHOR;
                functionPriority = 12;
                isGlobal = 0;
                icon = "x\alive\addons\mil_intelligence\icon_mil_SD.paa";
                picture = "x\alive\addons\mil_intelligence\icon_mil_SD.paa";
                class Arguments
                {
                    class runEvery
                    {
                            displayName = "$STR_ALIVE_SD_RUN_EVERY";
                            description = "$STR_ALIVE_SD_RUN_EVERY_COMMENT";
                            defaultValue = 2;
                            typeName = "NUMBER";
                    };
                };
        };
        class ADDON3 : ModuleAliveBase
        {
                scope = 1;
                displayName = "$STR_ALIVE_PSD";
                function = "ALIVE_fnc_PSDInit";
                author = MODULE_AUTHOR;
                functionPriority = 11;
                isGlobal = 0;
                icon = "x\alive\addons\mil_intelligence\icon_mil_SD.paa";
                picture = "x\alive\addons\mil_intelligence\icon_mil_SD.paa";
        };
};
