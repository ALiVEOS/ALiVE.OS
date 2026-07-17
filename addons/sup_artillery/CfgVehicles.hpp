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
                scope = 2;
                displayName = "$STR_ALIVE_ARTILLERY";
                function = "ALIVE_fnc_ARTILLERYInit";
                author = MODULE_AUTHOR;
                functionPriority = 161;
                isGlobal = 2;
                icon = "x\alive\addons\sup_cas\icon_sup_cas.paa";
                picture = "x\alive\addons\sup_cas\icon_sup_cas.paa";
                class Attributes : AttributesBase
                {
                        class HDR_GENERAL : ALiVE_ModuleSubTitle { property = "ALiVE_sup_artillery_HDR_GENERAL"; displayName = "GENERAL"; };
                        class artillery_callsign : Edit { property = "ALiVE_sup_artillery_artillery_callsign"; displayName = "$STR_ALIVE_ARTILLERY_CALLSIGN"; tooltip = "$STR_ALIVE_ARTILLERY_CALLSIGN_DESC"; defaultValue = """FOX SEVEN"""; };
                        class artillery_type
                        {
                                property     = "ALiVE_sup_artillery_artillery_type";
                                displayName  = "$STR_ALIVE_ARTILLERY_TYPE";
                                tooltip      = "$STR_ALIVE_ARTILLERY_TYPE_DESC";
                                control      = "ALiVE_VehicleCombo_Artillery";
                                typeName     = "STRING";
                                expression   = "_this setVariable ['artillery_type', _value];";
                                defaultValue = """B_MBT_01_arty_F""";
                        };
                        class artillery_type_custom : Edit
                        {
                                property     = "ALiVE_sup_artillery_artillery_type_custom";
                                displayName  = "$STR_ALIVE_ARTILLERY_TYPE_CUSTOM";
                                tooltip      = "$STR_ALIVE_ARTILLERY_TYPE_CUSTOM_DESC";
                                typeName     = "STRING";
                                expression   = "_this setVariable ['artillery_type_custom', _value];";
                                defaultValue = """""";
                        };
                        class HDR_ROUNDS : ALiVE_ModuleSubTitle { property = "ALiVE_sup_artillery_HDR_ROUNDS"; displayName = "ROUNDS"; };
                        class artillery_he : Edit { property = "ALiVE_sup_artillery_artillery_he"; displayName = "$STR_ALIVE_ARTILLERY_HE"; tooltip = "$STR_ALIVE_ARTILLERY_HE_DESC"; defaultValue = """30"""; };
                        class artillery_illum : Edit { property = "ALiVE_sup_artillery_artillery_illum"; displayName = "$STR_ALIVE_ARTILLERY_ILLUM"; tooltip = "$STR_ALIVE_ARTILLERY_ILLUM_DESC"; defaultValue = """30"""; };
                        class artillery_smoke : Edit { property = "ALiVE_sup_artillery_artillery_smoke"; displayName = "$STR_ALIVE_ARTILLERY_SMOKE"; tooltip = "$STR_ALIVE_ARTILLERY_SMOKE_DESC"; defaultValue = """30"""; };
                        class artillery_wp : Edit { property = "ALiVE_sup_artillery_artillery_wp"; displayName = "$STR_ALIVE_ARTILLERY_WP"; tooltip = "$STR_ALIVE_ARTILLERY_WP_DESC"; defaultValue = """30"""; };
                        class artillery_guided : Edit { property = "ALiVE_sup_artillery_artillery_guided"; displayName = "$STR_ALIVE_ARTILLERY_GUIDED"; tooltip = "$STR_ALIVE_ARTILLERY_GUIDED_DESC"; defaultValue = """30"""; };
                        class artillery_cluster : Edit { property = "ALiVE_sup_artillery_artillery_cluster"; displayName = "$STR_ALIVE_ARTILLERY_CLUSTER"; tooltip = "$STR_ALIVE_ARTILLERY_CLUSTER_DESC"; defaultValue = """30"""; };
                        class artillery_lg : Edit { property = "ALiVE_sup_artillery_artillery_lg"; displayName = "$STR_ALIVE_ARTILLERY_LG"; tooltip = "$STR_ALIVE_ARTILLERY_LG_DESC"; defaultValue = """30"""; };
                        class artillery_mine : Edit { property = "ALiVE_sup_artillery_artillery_mine"; displayName = "$STR_ALIVE_ARTILLERY_MINE"; tooltip = "$STR_ALIVE_ARTILLERY_MINE_DESC"; defaultValue = """30"""; };
                        class artillery_atmine : Edit { property = "ALiVE_sup_artillery_artillery_atmine"; displayName = "$STR_ALIVE_ARTILLERY_ATMINE"; tooltip = "$STR_ALIVE_ARTILLERY_ATMINE_DESC"; defaultValue = """30"""; };
                        class artillery_rockets : Edit { property = "ALiVE_sup_artillery_artillery_rockets"; displayName = "$STR_ALIVE_ARTILLERY_ROCKETS"; tooltip = "$STR_ALIVE_ARTILLERY_ROCKETS_DESC"; defaultValue = """16"""; };
                        class artillery_code : Edit { property = "ALiVE_sup_artillery_artillery_code"; displayName = "$STR_ALIVE_ARTILLERY_CODE"; tooltip = "$STR_ALIVE_ARTILLERY_CODE_DESC"; defaultValue = """"""; };
                        class HDR_LOGISTICS : ALiVE_ModuleSubTitle { property = "ALiVE_sup_artillery_HDR_LOGISTICS"; displayName = "LOGISTICS"; };
                        class artillery_logistics : Combo
                        {
                                property = "ALiVE_sup_artillery_artillery_logistics";
                                displayName = "$STR_ALIVE_ARTILLERY_LOGISTICS";
                                tooltip = "$STR_ALIVE_ARTILLERY_LOGISTICS_DESC";
                                defaultValue = """0""";
                                class Values
                                {
                                    class No { name = "No"; value = 0; default = 1; };
                                    class Yes { name = "Yes"; value = 1; };
                                };
                        };
                        class artillery_logisticssource : Combo
                        {
                                property = "ALiVE_sup_artillery_artillery_logisticssource";
                                displayName = "$STR_ALIVE_ARTILLERY_LOGISTICSSOURCE";
                                tooltip = "$STR_ALIVE_ARTILLERY_LOGISTICSSOURCE_DESC";
                                defaultValue = """0""";
                                class Values
                                {
                                    class Static { name = "Static (LOGCOM Base)"; value = 0; default = 1; };
                                    class Dynamic { name = "Dynamic (Nearest Objective)"; value = 1; };
                                };
                        };
                        class ModuleDescription : ModuleDescription {};
                };
                class ModuleDescription
                {
                    description[] = {"$STR_ALIVE_ARTILLERY_COMMENT","","$STR_ALIVE_ARTILLERY_USAGE"};
                };
        };
};
