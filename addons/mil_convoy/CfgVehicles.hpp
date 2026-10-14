class CfgVehicles {
    class Logic;
    class Module_F : Logic
    {
        class AttributesBase
        {
            class Edit;
            class Combo;
            class ModuleDescription;
        };
    };
    class ModuleAliveBase : Module_F
    {
        class AttributesBase : AttributesBase
        {
            class ALiVE_ModuleSubTitle;
        };
        class ModuleDescription;
    };
        class ADDON : ModuleAliveBase
        {
                scope = 1;
                displayName = "$STR_ALIVE_CONVOY";
                function = "ALIVE_fnc_convoyInit";
                author = MODULE_AUTHOR;
                functionPriority = 14;
                isGlobal = 2;
                icon = "x\alive\addons\sup_transport\icon_sup_transport.paa";
                picture = "x\alive\addons\sup_transport\icon_sup_transport.paa";
                class Attributes : AttributesBase
                {
                        class HDR_GENERAL : ALiVE_ModuleSubTitle { property = "ALiVE_mil_convoy_HDR_GENERAL"; displayName = "GENERAL"; };
                        class conv_debug_setting : Combo
                        {
                                property = "ALiVE_mil_convoy_conv_debug_setting";
                                displayName = "$STR_ALIVE_CONVOY_DEBUG";
                                tooltip = "$STR_ALIVE_CONVOY_DEBUG_COMMENT";
                                defaultValue = """false""";
                                class Values
                                {
                                    class Yes { name = "Yes"; value = true; };
                                    class No { name = "No"; value = false; default = 1; };
                                };
                        };
                        class conv_intensity_setting : Combo
                        {
                                property = "ALiVE_mil_convoy_conv_intensity_setting";
                                displayName = "$STR_ALIVE_CONVOY_INTENSITY";
                                tooltip = "$STR_ALIVE_CONVOY_INTENSITY_DESC";
                                defaultValue = """1""";
                                class Values
                                {
                                    class conv_intesity_low { name = "Low"; value = 1; default = 1; };
                                    class conv_intesity_med { name = "Medium"; value = 2; };
                                    class conv_intesity_high { name = "High"; value = 3; };
                                };
                        };
                        class conv_factions_setting : Edit
                        {
                                property = "ALiVE_mil_convoy_conv_factions_setting";
                                displayName = "$STR_ALIVE_CONVOY_FACTIONS";
                                tooltip = "$STR_ALIVE_CONVOY_FACTIONS_COMMENT";
                                defaultValue = """OPF_F""";
                        };
                        class ModuleDescription : ModuleDescription {};
                };
        };
};
