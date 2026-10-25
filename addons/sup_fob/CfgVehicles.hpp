class CfgVehicles {
    class Logic;
    class Module_F : Logic
    {
        class AttributesBase { class Default; class Edit; class Combo; class ModuleDescription; };
    };
    class ModuleAliveBase : Module_F
    {
        class AttributesBase : AttributesBase { class ALiVE_ModuleSubTitle; class ALiVE_EditMultilineSQF; };
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
                        class fob_interface : Combo
                        {
                                property = "ALiVE_sup_fob_fob_interface";
                                displayName = "$STR_ALIVE_FOB_INTERFACE";
                                tooltip = "$STR_ALIVE_FOB_INTERFACE_COMMENT";
                                defaultValue = """AUTO""";
                                class Values
                                {
                                    class AUTO   { name = "$STR_ALIVE_FOB_INTERFACE_AUTO";   value = "AUTO"; default = 1; };
                                    class SCROLL { name = "$STR_ALIVE_FOB_INTERFACE_SCROLL"; value = "SCROLL"; };
                                    class ACE    { name = "$STR_ALIVE_FOB_INTERFACE_ACE";    value = "ACE"; };
                                    class BOTH   { name = "$STR_ALIVE_FOB_INTERFACE_BOTH";   value = "BOTH"; };
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
                        class fob_hubs { property = "ALiVE_sup_fob_fob_hubs"; displayName = "$STR_ALIVE_FOB_HUBS"; tooltip = "$STR_ALIVE_FOB_HUBS_COMMENT"; control = "ALiVE_FOBHubChoice"; typeName = "STRING"; expression = "_this setVariable ['fob_hubs', _value, true];"; defaultValue = """Land_Cargo_HQ_V1_F|Land_Cargo_HQ_V3_F|Land_Cargo_HQ_V2_F"""; };

                        class HDR_MANAGE : ALiVE_ModuleSubTitle { property = "ALiVE_sup_fob_HDR_MANAGE"; displayName = "WHO CAN DISMANTLE"; };
                        class fob_manage_who { property = "ALiVE_sup_fob_fob_manage_who"; displayName = "$STR_ALIVE_FOB_MANAGE_WHO"; tooltip = "$STR_ALIVE_FOB_MANAGE_WHO_COMMENT"; control = "ALiVE_FOBManageChoice"; typeName = "STRING"; expression = "_this setVariable ['fob_manage_who', _value, true];"; defaultValue = """SIDE"""; };
                        class fob_manage_list : Edit { property = "ALiVE_sup_fob_fob_manage_list"; displayName = "$STR_ALIVE_FOB_MANAGE_LIST_EDIT"; tooltip = "$STR_ALIVE_FOB_MANAGE_LIST_EDIT_COMMENT"; typeName = "STRING"; defaultValue = """"""; };

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
                        class fob_buildlist : Default { property = "ALiVE_sup_fob_fob_buildlist"; displayName = "$STR_ALIVE_FOB_BUILDLIST"; tooltip = "$STR_ALIVE_FOB_BUILDLIST_COMMENT"; control = "ALiVE_FOBBuildListLink"; typeName = "STRING"; defaultValue = "''"; };
                        class fob_only : Edit { property = "ALiVE_sup_fob_fob_only"; displayName = "$STR_ALIVE_FOB_ONLY"; tooltip = "$STR_ALIVE_FOB_ONLY_COMMENT"; typeName = "STRING"; defaultValue = """"""; };
                        class fob_blacklist : Edit { property = "ALiVE_sup_fob_fob_blacklist"; displayName = "$STR_ALIVE_FOB_BLACKLIST"; tooltip = "$STR_ALIVE_FOB_BLACKLIST_COMMENT"; typeName = "STRING"; defaultValue = """"""; };
                        class fob_kit_class : Edit { property = "ALiVE_sup_fob_fob_kit_class"; displayName = "$STR_ALIVE_FOB_KIT_CLASS"; tooltip = "$STR_ALIVE_FOB_KIT_CLASS_COMMENT"; typeName = "STRING"; defaultValue = """"""; };
                        class fob_crate_class : Edit { property = "ALiVE_sup_fob_fob_crate_class"; displayName = "$STR_ALIVE_FOB_CRATE_CLASS"; tooltip = "$STR_ALIVE_FOB_CRATE_CLASS_COMMENT"; typeName = "STRING"; defaultValue = """"""; };
                        class fob_whitelist : Edit { property = "ALiVE_sup_fob_fob_whitelist"; displayName = "$STR_ALIVE_FOB_WHITELIST"; tooltip = "$STR_ALIVE_FOB_WHITELIST_COMMENT"; typeName = "STRING"; defaultValue = """"""; };

                        class fob_resupply_threshold : Edit { property = "ALiVE_sup_fob_fob_resupply_threshold"; displayName = "$STR_ALIVE_FOB_RESUPPLY_THRESHOLD"; tooltip = "$STR_ALIVE_FOB_RESUPPLY_THRESHOLD_COMMENT"; typeName = "STRING"; defaultValue = """25"""; };
                        class fob_crate_amount : Edit { property = "ALiVE_sup_fob_fob_crate_amount"; displayName = "$STR_ALIVE_FOB_CRATE_AMOUNT"; tooltip = "$STR_ALIVE_FOB_CRATE_AMOUNT_COMMENT"; typeName = "STRING"; defaultValue = """1000"""; };
                        class fob_kit_cost : Edit { property = "ALiVE_sup_fob_fob_kit_cost"; displayName = "$STR_ALIVE_FOB_KIT_COST"; tooltip = "$STR_ALIVE_FOB_KIT_COST_COMMENT"; typeName = "STRING"; defaultValue = """500"""; };
                        class fob_tier2_cost : Edit { property = "ALiVE_sup_fob_fob_tier2_cost"; displayName = "$STR_ALIVE_FOB_TIER2_COST"; tooltip = "$STR_ALIVE_FOB_TIER_COST_COMMENT"; typeName = "STRING"; defaultValue = """1500"""; };
                        class fob_tier3_cost : Edit { property = "ALiVE_sup_fob_fob_tier3_cost"; displayName = "$STR_ALIVE_FOB_TIER3_COST"; tooltip = "$STR_ALIVE_FOB_TIER_COST_COMMENT"; typeName = "STRING"; defaultValue = """3000"""; };
                        class fob_garrison_cost : Edit { property = "ALiVE_sup_fob_fob_garrison_cost"; displayName = "$STR_ALIVE_FOB_GARRISON_COST"; tooltip = "$STR_ALIVE_FOB_GARRISON_COST_COMMENT"; typeName = "STRING"; defaultValue = """500"""; };
                        class fob_garrison_groups { property = "ALiVE_sup_fob_fob_garrison_groups"; displayName = "$STR_ALIVE_FOB_GARRISON_GROUPS"; tooltip = "$STR_ALIVE_FOB_GARRISON_GROUPS_COMMENT"; control = "ALiVE_FOBGroupChoice"; typeName = "STRING"; expression = "_this setVariable ['fob_garrison_groups', _value, true];"; defaultValue = """||"""; };
                        class fob_respawn : Combo
                        {
                                property = "ALiVE_sup_fob_fob_respawn";
                                displayName = "$STR_ALIVE_FOB_RESPAWN";
                                tooltip = "$STR_ALIVE_FOB_RESPAWN_COMMENT";
                                defaultValue = """3""";
                                class Values
                                {
                                    class Off { name = "$STR_ALIVE_FOB_RESPAWN_OFF"; value = "0"; };
                                    class T1  { name = "$STR_ALIVE_FOB_RESPAWN_T1"; value = "1"; };
                                    class T2  { name = "$STR_ALIVE_FOB_RESPAWN_T2"; value = "2"; };
                                    class T3  { name = "$STR_ALIVE_FOB_RESPAWN_T3"; value = "3"; default = 1; };
                                };
                        };

                        class HDR_ARSENAL : ALiVE_ModuleSubTitle { property = "ALiVE_sup_fob_HDR_ARSENAL"; displayName = "ARSENAL"; };
                        class fob_arsenal : Combo
                        {
                                property = "ALiVE_sup_fob_fob_arsenal";
                                displayName = "$STR_ALIVE_FOB_ARSENAL";
                                tooltip = "$STR_ALIVE_FOB_ARSENAL_COMMENT";
                                defaultValue = """false""";
                                class Values
                                {
                                    class Yes { name = "$STR_ALIVE_FOB_YES"; value = true; };
                                    class No { name = "$STR_ALIVE_FOB_NO"; value = false; default = 1; };
                                };
                        };
                        class fob_arsenal_explosives : Combo
                        {
                                property = "ALiVE_sup_fob_fob_arsenal_explosives";
                                displayName = "$STR_ALIVE_FOB_ARSENAL_EXPLOSIVES";
                                tooltip = "$STR_ALIVE_FOB_ARSENAL_EXPLOSIVES_COMMENT";
                                defaultValue = """false""";
                                class Values
                                {
                                    class Yes { name = "$STR_ALIVE_FOB_YES"; value = true; };
                                    class No { name = "$STR_ALIVE_FOB_NO"; value = false; default = 1; };
                                };
                        };

                        class HDR_DEFENCE : ALiVE_ModuleSubTitle { property = "ALiVE_sup_fob_HDR_DEFENCE"; displayName = "ATTACK AND CAPTURE"; };
                        class fob_enemy_targeting : Combo
                        {
                                property = "ALiVE_sup_fob_fob_enemy_targeting";
                                displayName = "$STR_ALIVE_FOB_ENEMY_TARGETING";
                                tooltip = "$STR_ALIVE_FOB_ENEMY_TARGETING_COMMENT";
                                defaultValue = """CONTACT""";
                                class Values
                                {
                                    class Contact { name = "$STR_ALIVE_FOB_TARGETING_CONTACT"; value = "CONTACT"; default = 1; };
                                    class Immediate { name = "$STR_ALIVE_FOB_TARGETING_IMMEDIATE"; value = "IMMEDIATE"; };
                                    class Off { name = "$STR_ALIVE_FOB_TARGETING_OFF"; value = "OFF"; };
                                };
                        };
                        class fob_discovery_radius : Edit { property = "ALiVE_sup_fob_fob_discovery_radius"; displayName = "$STR_ALIVE_FOB_DISCOVERY_RADIUS"; tooltip = "$STR_ALIVE_FOB_DISCOVERY_RADIUS_COMMENT"; typeName = "STRING"; defaultValue = """500"""; };
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
        // FOB Types (NeisAEL on Discord, 20 Oct): synced to Player FOBs, a kit can become one of
        // these types. Player FOBs reads it at start (ALiVE_fnc_FOB "typesParse").
        class ALiVE_sup_fob_types : ModuleAliveBase
        {
                scope = 2;
                displayName = "$STR_ALIVE_FOB_TYPES";
                function = "ALIVE_fnc_FOBTypesInit";
                author = MODULE_AUTHOR;
                // before Player FOBs (195), which reads it
                functionPriority = 194;
                isGlobal = 2;
                icon = "x\alive\addons\sup_fob\icon_sup_fob_types.paa";
                picture = "x\alive\addons\sup_fob\icon_sup_fob_types.paa";
                class Attributes : AttributesBase
                {
                        class HDR_TYPES : ALiVE_ModuleSubTitle { property = "ALiVE_sup_fob_types_HDR_TYPES"; displayName = "FOB TYPES"; };
                        class fob_types_link : Default { property = "ALiVE_sup_fob_types_fob_types_link"; displayName = "$STR_ALIVE_FOB_TYPES"; tooltip = "$STR_ALIVE_FOB_TYPES_OPEN_COMMENT"; control = "ALiVE_FOBTypesLink"; typeName = "STRING"; defaultValue = "''"; };
                        class fob_types : ALiVE_EditMultilineSQF
                        {
                                property = "ALiVE_sup_fob_types_fob_types";
                                displayName = "$STR_ALIVE_FOB_TYPES_LIST";
                                tooltip = "$STR_ALIVE_FOB_TYPES_LIST_COMMENT";
                                defaultValue = """""";
                        };
                        class fob_types_general : Combo
                        {
                                property = "ALiVE_sup_fob_types_fob_types_general";
                                displayName = "$STR_ALIVE_FOB_TYPES_GENERAL";
                                tooltip = "$STR_ALIVE_FOB_TYPES_GENERAL_COMMENT";
                                defaultValue = """true""";
                                class Values
                                {
                                    class Yes { name = "$STR_ALIVE_FOB_YES"; value = true; default = 1; };
                                    class No { name = "$STR_ALIVE_FOB_NO"; value = false; };
                                };
                        };
                        class ModuleDescription : ModuleDescription {};
                };
                class ModuleDescription
                {
                        description[] = {"$STR_ALIVE_FOB_TYPES_COMMENT","","$STR_ALIVE_FOB_TYPES_USAGE"};
                        sync[] = {"ALiVE_sup_fob"};
                };
        };
        // A FOB kit and a supply crate players can order from the Player Resupply tablet, or a
        // mission maker can place. The server makes them a kit or crate (fobOps kitInit) when it
        // created them itself; a copy a player's machine makes stays a plain box.
        class Box_NATO_Support_F;
        class ALiVE_FOB_Kit : Box_NATO_Support_F
        {
                scope = 2;
                scopeCurator = 2;
                displayName = "$STR_ALIVE_FOB_KIT_NAME";
                author = "ALiVE Mod Team";
                class TransportMagazines {};
                class TransportWeapons {};
                class TransportItems {};
                class TransportBackpacks {};
        };
        class B_supplyCrate_F;
        class ALiVE_FOB_SupplyCrate : B_supplyCrate_F
        {
                scope = 2;
                scopeCurator = 2;
                displayName = "$STR_ALIVE_FOB_SUPPLYCRATE_NAME";
                author = "ALiVE Mod Team";
                class TransportMagazines {};
                class TransportWeapons {};
                class TransportItems {};
                class TransportBackpacks {};
        };
        // The FOB Arsenal (Player FOBs' Arsenal setting): built at a FOB like any supply object, never
        // placed in Eden or Zeus, and empty; its gear is offered only while a player has it open
        class ALiVE_FOB_Arsenal : B_supplyCrate_F
        {
                scope = 1;
                scopeCurator = 0;
                displayName = "$STR_ALIVE_FOB_ARSENAL_NAME";
                author = "ALiVE Mod Team";
                // no inventory of its own: a box gear could be dropped into is a way round paying
                maximumLoad = 0;
                class TransportMagazines {};
                class TransportWeapons {};
                class TransportItems {};
                class TransportBackpacks {};
        };
};
