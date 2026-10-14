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
        // Ground transport (#690): a crewed truck, armoured car or APC ordered from the
        // Combat Support tablet. Sync to the Combat Support module.
        class ADDON : ModuleAliveBase
        {
                scope = 2;
                displayName = "$STR_ALIVE_GROUND";
                function = "ALIVE_fnc_GROUNDInit";
                author = MODULE_AUTHOR;
                functionPriority = 163;
                isGlobal = 2;
                icon = "x\alive\addons\sup_ground\icon_sup_ground.paa";
                picture = "x\alive\addons\sup_ground\icon_sup_ground.paa";
                class Attributes : AttributesBase
                {
                        class HDR_GENERAL : ALiVE_ModuleSubTitle { property = "ALiVE_sup_ground_HDR_GENERAL"; displayName = "GENERAL"; };
                        class ground_callsign : Edit { property = "ALiVE_sup_ground_ground_callsign"; displayName = "$STR_ALIVE_GROUND_CALLSIGN"; tooltip = "$STR_ALIVE_GROUND_CALLSIGN_DESC"; defaultValue = """MULE ONE"""; };
                        class ground_type
                        {
                                property     = "ALiVE_sup_ground_ground_type";
                                displayName  = "$STR_ALIVE_GROUND_TYPE";
                                tooltip      = "$STR_ALIVE_GROUND_TYPE_DESC";
                                control      = "ALiVE_VehicleCombo_Ground";
                                typeName     = "STRING";
                                expression   = "_this setVariable ['ground_type', _value];";
                                defaultValue = """B_Truck_01_covered_F""";
                        };
                        class ground_type_custom : Edit
                        {
                                property     = "ALiVE_sup_ground_ground_type_custom";
                                displayName  = "$STR_ALIVE_GROUND_TYPE_CUSTOM";
                                tooltip      = "$STR_ALIVE_GROUND_TYPE_CUSTOM_DESC";
                                typeName     = "STRING";
                                expression   = "_this setVariable ['ground_type_custom', _value];";
                                defaultValue = """""";
                        };
                        class ground_code : Edit { property = "ALiVE_sup_ground_ground_code"; displayName = "$STR_ALIVE_GROUND_CODE"; tooltip = "$STR_ALIVE_GROUND_CODE_DESC"; defaultValue = """"""; };
                        class ground_respawn_time : Edit { property = "ALiVE_sup_ground_ground_respawn_time"; displayName = "$STR_ALIVE_CS_ASSET_RESPAWN_TIME"; tooltip = "$STR_ALIVE_CS_ASSET_RESPAWN_TIME_COMMENT"; defaultValue = """"""; };
                        class ground_respawn_limit : Edit { property = "ALiVE_sup_ground_ground_respawn_limit"; displayName = "$STR_ALIVE_CS_ASSET_RESPAWN_LIMIT"; tooltip = "$STR_ALIVE_CS_ASSET_RESPAWN_LIMIT_COMMENT"; defaultValue = """"""; };
                        class HDR_ROAD : ALiVE_ModuleSubTitle { property = "ALiVE_sup_ground_HDR_ROAD"; displayName = "ROAD CHECK"; };
                        class ground_mine_check : Combo
                        {
                                property = "ALiVE_sup_ground_ground_mine_check";
                                displayName = "$STR_ALIVE_GROUND_MINE_CHECK";
                                tooltip = "$STR_ALIVE_GROUND_MINE_CHECK_DESC";
                                defaultValue = """1""";
                                class Values
                                {
                                    class No { name = "$STR_ALIVE_GROUND_NO"; value = 0; };
                                    class Yes { name = "$STR_ALIVE_GROUND_YES"; value = 1; default = 1; };
                                };
                        };
                        class ground_disarm_chance : Edit { property = "ALiVE_sup_ground_ground_disarm_chance"; displayName = "$STR_ALIVE_GROUND_DISARM_CHANCE"; tooltip = "$STR_ALIVE_GROUND_DISARM_CHANCE_DESC"; defaultValue = """70"""; };
                        class HDR_LOGISTICS : ALiVE_ModuleSubTitle { property = "ALiVE_sup_ground_HDR_LOGISTICS"; displayName = "LOGISTICS"; };
                        class ground_logistics : Combo
                        {
                                property = "ALiVE_sup_ground_ground_logistics";
                                displayName = "$STR_ALIVE_GROUND_LOGISTICS";
                                tooltip = "$STR_ALIVE_GROUND_LOGISTICS_DESC";
                                defaultValue = """0""";
                                class Values
                                {
                                    class No { name = "$STR_ALIVE_GROUND_NO"; value = 0; default = 1; };
                                    class Yes { name = "$STR_ALIVE_GROUND_YES"; value = 1; };
                                };
                        };
                        class ground_logisticssource : Combo
                        {
                                property = "ALiVE_sup_ground_ground_logisticssource";
                                displayName = "$STR_ALIVE_GROUND_LOGISTICSSOURCE";
                                tooltip = "$STR_ALIVE_GROUND_LOGISTICSSOURCE_DESC";
                                defaultValue = """0""";
                                class Values
                                {
                                    class Static { name = "$STR_ALIVE_GROUND_SOURCE_STATIC"; value = 0; default = 1; };
                                    class Dynamic { name = "$STR_ALIVE_GROUND_SOURCE_DYNAMIC"; value = 1; };
                                };
                        };
                        class ModuleDescription : ModuleDescription {};
                };
                class ModuleDescription
                {
                        description[] = {"$STR_ALIVE_GROUND_COMMENT","","$STR_ALIVE_GROUND_USAGE"};
                };
        };
};
