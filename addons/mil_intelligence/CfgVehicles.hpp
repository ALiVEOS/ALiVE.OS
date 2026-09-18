class CfgVehicles {
    class Logic;
    class Module_F : Logic
    {
        class AttributesBase { class Edit; class Combo; class ModuleDescription; };
    };
    class ModuleAliveBase : Module_F
    {
        class AttributesBase : AttributesBase { class ALiVE_ModuleSubTitle; };
        class ModuleDescription;
    };
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
                class Attributes : AttributesBase
                {
                        class debug : Combo
                        {
                                property = "ALiVE_mil_intelligence_debug";
                                displayName = "$STR_ALIVE_MI_DEBUG";
                                tooltip = "$STR_ALIVE_MI_DEBUG_COMMENT";
                                defaultValue = """false""";
                                class Values
                                {
                                    class Yes { name = "Yes"; value = true; };
                                    class No { name = "No"; value = false; default = 1;};
                                };
                        };
                        class intelChance : Combo
                        {
                                property = "ALiVE_mil_intelligence_intelChance";
                                displayName = "$STR_ALIVE_MI_INTEL_CHANCE";
                                tooltip = "$STR_ALIVE_MI_INTEL_CHANCE_COMMENT";
                                defaultValue = """1""";
                                class Values
                                {
                                    class LOW { name = "$STR_ALIVE_MI_INTEL_CHANCE_LOW"; value = "0.1"; };
                                    class MEDIUM { name = "$STR_ALIVE_MI_INTEL_CHANCE_MEDIUM"; value = "0.2"; };
                                    class HIGH { name = "$STR_ALIVE_MI_INTEL_CHANCE_HIGH"; value = "0.4"; };
                                    class TOTAL { name = "$STR_ALIVE_MI_INTEL_CHANCE_TOTAL"; value = "1"; default = 1; };
                                };
                        };
                        class friendlyIntel : Combo
                        {
                                property = "ALiVE_mil_intelligence_friendlyIntel";
                                displayName = "$STR_ALIVE_MI_FRIENDLY_INTEL";
                                tooltip = "$STR_ALIVE_MI_FRIENDLY_INTEL_COMMENT";
                                defaultValue = """true""";
                                class Values
                                {
                                    class Yes { name = "Yes"; value = true; default = 1; };
                                    class No { name = "No"; value = false; };
                                };
                        };
                        class friendlyIntelRadius : Edit
                        {
                                property = "ALiVE_mil_intelligence_friendlyIntelRadius";
                                displayName = "$STR_ALIVE_MI_FRIENDLY_INTEL_RADIUS";
                                tooltip = "$STR_ALIVE_MI_FRIENDLY_INTEL_RADIUS_COMMENT";
                                defaultValue = """2000""";
                        };
                        class ModuleDescription : ModuleDescription {};
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
                class Attributes : AttributesBase
                {
                    class runEvery : Edit
                    {
                            property = "ALiVE_mil_intelligence_runEvery";
                            displayName = "$STR_ALIVE_SD_RUN_EVERY";
                            tooltip = "$STR_ALIVE_SD_RUN_EVERY_COMMENT";
                            defaultValue = """2""";
                            typeName = "NUMBER";
                    };
                    class ModuleDescription : ModuleDescription {};
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
