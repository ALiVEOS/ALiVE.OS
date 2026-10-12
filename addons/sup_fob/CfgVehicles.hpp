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
        // Player FOBs (#882, #693): forward bases players deploy, build up and keep supplied, which
        // the enemy can attack and take. Place one; it serves every side that has players.
        class ADDON : ModuleAliveBase
        {
                scope = 2;
                displayName = "$STR_ALIVE_FOB";
                function = "ALIVE_fnc_FOBInit";
                author = MODULE_AUTHOR;
                // After the AI Commanders (180) and Military Logistics (190), which it reads
                functionPriority = 195;
                isGlobal = 2;
                icon = "x\alive\addons\sup_fob\icon_sup_fob.paa";
                picture = "x\alive\addons\sup_fob\icon_sup_fob.paa";
                class Attributes : AttributesBase
                {
                        class HDR_GENERAL : ALiVE_ModuleSubTitle { property = "ALiVE_sup_fob_HDR_GENERAL"; displayName = "GENERAL"; };
                        class fob_debug : Combo
                        {
                                property = "ALiVE_sup_fob_fob_debug";
                                displayName = "$STR_ALIVE_FOB_DEBUG";
                                tooltip = "$STR_ALIVE_FOB_DEBUG_COMMENT";
                                defaultValue = """false""";
                                class Values
                                {
                                    class Yes { name = "$STR_ALIVE_FOB_YES"; value = true; };
                                    class No { name = "$STR_ALIVE_FOB_NO"; value = false; default = 1; };
                                };
                        };
                        class fob_persistent : Combo
                        {
                                property = "ALiVE_sup_fob_fob_persistent";
                                displayName = "$STR_ALIVE_FOB_PERSISTENT";
                                tooltip = "$STR_ALIVE_FOB_PERSISTENT_COMMENT";
                                defaultValue = """true""";
                                class Values
                                {
                                    class Yes { name = "$STR_ALIVE_FOB_YES"; value = true; default = 1; };
                                    class No { name = "$STR_ALIVE_FOB_NO"; value = false; };
                                };
                        };
                        class fob_build_range : Edit { property = "ALiVE_sup_fob_fob_build_range"; displayName = "$STR_ALIVE_FOB_BUILD_RANGE"; tooltip = "$STR_ALIVE_FOB_BUILD_RANGE_COMMENT"; typeName = "STRING"; defaultValue = """150"""; };
                        class fob_min_distance : Edit { property = "ALiVE_sup_fob_fob_min_distance"; displayName = "$STR_ALIVE_FOB_MIN_DISTANCE"; tooltip = "$STR_ALIVE_FOB_MIN_DISTANCE_COMMENT"; typeName = "STRING"; defaultValue = """500"""; };
                        class fob_hub_west : Edit { property = "ALiVE_sup_fob_fob_hub_west"; displayName = "$STR_ALIVE_FOB_HUB_WEST"; tooltip = "$STR_ALIVE_FOB_HUB_COMMENT"; typeName = "STRING"; defaultValue = """Land_Cargo_HQ_V1_F"""; };
                        class fob_hub_east : Edit { property = "ALiVE_sup_fob_fob_hub_east"; displayName = "$STR_ALIVE_FOB_HUB_EAST"; tooltip = "$STR_ALIVE_FOB_HUB_COMMENT"; typeName = "STRING"; defaultValue = """Land_Cargo_HQ_V3_F"""; };
                        class fob_hub_guer : Edit { property = "ALiVE_sup_fob_fob_hub_guer"; displayName = "$STR_ALIVE_FOB_HUB_GUER"; tooltip = "$STR_ALIVE_FOB_HUB_COMMENT"; typeName = "STRING"; defaultValue = """Land_Cargo_HQ_V2_F"""; };

                        class HDR_CAP : ALiVE_ModuleSubTitle { property = "ALiVE_sup_fob_HDR_CAP"; displayName = "HOW MANY FOBS"; };
                        class fob_cap_type : Combo
                        {
                                property = "ALiVE_sup_fob_fob_cap_type";
                                displayName = "$STR_ALIVE_FOB_CAP_TYPE";
                                tooltip = "$STR_ALIVE_FOB_CAP_TYPE_COMMENT";
                                defaultValue = """DYNAMIC""";
                                class Values
                                {
                                    class DYNAMIC { name = "$STR_ALIVE_FOB_CAP_DYNAMIC"; value = "DYNAMIC"; default = 1; };
                                    class FIXED { name = "$STR_ALIVE_FOB_CAP_FIXED"; value = "FIXED"; };
                                };
                        };
                        class fob_cap : Edit { property = "ALiVE_sup_fob_fob_cap"; displayName = "$STR_ALIVE_FOB_CAP"; tooltip = "$STR_ALIVE_FOB_CAP_COMMENT"; typeName = "STRING"; defaultValue = """3"""; };
                        class fob_cap_base : Edit { property = "ALiVE_sup_fob_fob_cap_base"; displayName = "$STR_ALIVE_FOB_CAP_BASE"; tooltip = "$STR_ALIVE_FOB_CAP_BASE_COMMENT"; typeName = "STRING"; defaultValue = """1"""; };
                        class fob_cap_per : Edit { property = "ALiVE_sup_fob_fob_cap_per"; displayName = "$STR_ALIVE_FOB_CAP_PER"; tooltip = "$STR_ALIVE_FOB_CAP_PER_COMMENT"; typeName = "STRING"; defaultValue = """3"""; };
                        class fob_cap_max : Edit { property = "ALiVE_sup_fob_fob_cap_max"; displayName = "$STR_ALIVE_FOB_CAP_MAX"; tooltip = "$STR_ALIVE_FOB_CAP_MAX_COMMENT"; typeName = "STRING"; defaultValue = """6"""; };

                        class HDR_SUPPLY : ALiVE_ModuleSubTitle { property = "ALiVE_sup_fob_HDR_SUPPLY"; displayName = "SUPPLY"; };
                        class fob_supply_source : Combo
                        {
                                property = "ALiVE_sup_fob_fob_supply_source";
                                displayName = "$STR_ALIVE_FOB_SUPPLY_SOURCE";
                                tooltip = "$STR_ALIVE_FOB_SUPPLY_SOURCE_COMMENT";
                                defaultValue = """FOBPOOL""";
                                class Values
                                {
                                    class FOBPOOL { name = "$STR_ALIVE_FOB_SUPPLY_FOBPOOL"; value = "FOBPOOL"; default = 1; };
                                    class FORCEPOOL { name = "$STR_ALIVE_FOB_SUPPLY_FORCEPOOL"; value = "FORCEPOOL"; };
                                    class CRATES { name = "$STR_ALIVE_FOB_SUPPLY_CRATES"; value = "CRATES"; };
                                };
                        };
                        class fob_supply_initial : Edit { property = "ALiVE_sup_fob_fob_supply_initial"; displayName = "$STR_ALIVE_FOB_SUPPLY_INITIAL"; tooltip = "$STR_ALIVE_FOB_SUPPLY_INITIAL_COMMENT"; typeName = "STRING"; defaultValue = """1000"""; };
                        class fob_supply_trickle : Edit { property = "ALiVE_sup_fob_fob_supply_trickle"; displayName = "$STR_ALIVE_FOB_SUPPLY_TRICKLE"; tooltip = "$STR_ALIVE_FOB_SUPPLY_TRICKLE_COMMENT"; typeName = "STRING"; defaultValue = """0"""; };
                        class fob_supply_cap_t1 : Edit { property = "ALiVE_sup_fob_fob_supply_cap_t1"; displayName = "$STR_ALIVE_FOB_SUPPLY_CAP_T1"; tooltip = "$STR_ALIVE_FOB_SUPPLY_CAP_COMMENT"; typeName = "STRING"; defaultValue = """2500"""; };
                        class fob_supply_cap_t2 : Edit { property = "ALiVE_sup_fob_fob_supply_cap_t2"; displayName = "$STR_ALIVE_FOB_SUPPLY_CAP_T2"; tooltip = "$STR_ALIVE_FOB_SUPPLY_CAP_COMMENT"; typeName = "STRING"; defaultValue = """4000"""; };
                        class fob_supply_cap_t3 : Edit { property = "ALiVE_sup_fob_fob_supply_cap_t3"; displayName = "$STR_ALIVE_FOB_SUPPLY_CAP_T3"; tooltip = "$STR_ALIVE_FOB_SUPPLY_CAP_COMMENT"; typeName = "STRING"; defaultValue = """5000"""; };
                        class fob_cost_scale : Edit { property = "ALiVE_sup_fob_fob_cost_scale"; displayName = "$STR_ALIVE_FOB_COST_SCALE"; tooltip = "$STR_ALIVE_FOB_COST_SCALE_COMMENT"; typeName = "STRING"; defaultValue = """1"""; };

                        class HDR_DEFENCE : ALiVE_ModuleSubTitle { property = "ALiVE_sup_fob_HDR_DEFENCE"; displayName = "ATTACK AND CAPTURE"; };
                        class fob_alert_radius : Edit { property = "ALiVE_sup_fob_fob_alert_radius"; displayName = "$STR_ALIVE_FOB_ALERT_RADIUS"; tooltip = "$STR_ALIVE_FOB_ALERT_RADIUS_COMMENT"; typeName = "STRING"; defaultValue = """400"""; };
                        class fob_capture_radius : Edit { property = "ALiVE_sup_fob_fob_capture_radius"; displayName = "$STR_ALIVE_FOB_CAPTURE_RADIUS"; tooltip = "$STR_ALIVE_FOB_CAPTURE_RADIUS_COMMENT"; typeName = "STRING"; defaultValue = """100"""; };
                        class fob_capture_time : Edit { property = "ALiVE_sup_fob_fob_capture_time"; displayName = "$STR_ALIVE_FOB_CAPTURE_TIME"; tooltip = "$STR_ALIVE_FOB_CAPTURE_TIME_COMMENT"; typeName = "STRING"; defaultValue = """180"""; };
                        class fob_repair_time : Edit { property = "ALiVE_sup_fob_fob_repair_time"; displayName = "$STR_ALIVE_FOB_REPAIR_TIME"; tooltip = "$STR_ALIVE_FOB_REPAIR_TIME_COMMENT"; typeName = "STRING"; defaultValue = """900"""; };
                        class fob_repair_cost : Edit { property = "ALiVE_sup_fob_fob_repair_cost"; displayName = "$STR_ALIVE_FOB_REPAIR_COST"; tooltip = "$STR_ALIVE_FOB_REPAIR_COST_COMMENT"; typeName = "STRING"; defaultValue = """1000"""; };

                        class HDR_PERSIST : ALiVE_ModuleSubTitle { property = "ALiVE_sup_fob_HDR_PERSIST"; displayName = "SAVING"; };
                        class fob_save_interval : Edit { property = "ALiVE_sup_fob_fob_save_interval"; displayName = "$STR_ALIVE_FOB_SAVE_INTERVAL"; tooltip = "$STR_ALIVE_FOB_SAVE_INTERVAL_COMMENT"; typeName = "STRING"; defaultValue = """60"""; };

                        class ModuleDescription : ModuleDescription {};
                };
                class ModuleDescription
                {
                        description[] = {"$STR_ALIVE_FOB_COMMENT","","$STR_ALIVE_FOB_USAGE"};
                };
        };
};
