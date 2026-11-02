class CfgVehicles {
    class Logic;
    class Module_F : Logic
    {
        class AttributesBase { class Default; class Edit; class Combo; class ModuleDescription; };
    };
    class ModuleAliveBase : Module_F
    {
        class AttributesBase : AttributesBase { class ALiVE_ModuleSubTitle; };
        class ModuleDescription;
    };
        // Persistent Craters: shells, rockets and bombs leave craters that stay, and the big
        // ones dig the ground. Place one; nothing to sync.
        class ADDON : ModuleAliveBase
        {
                scope = 2;
                displayName = "$STR_ALIVE_CRATERS";
                function = "ALIVE_fnc_cratersInit";
                author = MODULE_AUTHOR;
                // After the AI Commanders (180) and Player FOBs (195), whose areas it keeps clear
                functionPriority = 200;
                isGlobal = 2;
                icon = "x\alive\addons\sys_craters\icon_sys_craters.paa";
                picture = "x\alive\addons\sys_craters\icon_sys_craters.paa";
                class Attributes : AttributesBase
                {
                        class HDR_GENERAL : ALiVE_ModuleSubTitle { property = "ALiVE_sys_craters_HDR_GENERAL"; displayName = "GENERAL"; };
                        class craters_debug : Combo
                        {
                                property = "ALiVE_sys_craters_craters_debug";
                                displayName = "$STR_ALIVE_CRATERS_DEBUG";
                                tooltip = "$STR_ALIVE_CRATERS_DEBUG_COMMENT";
                                defaultValue = """false""";
                                class Values
                                {
                                    class Yes { name = "$STR_ALIVE_CRATERS_YES"; value = true; };
                                    class No { name = "$STR_ALIVE_CRATERS_NO"; value = false; default = 1; };
                                };
                        };
                        class craters_min_size : Combo
                        {
                                property = "ALiVE_sys_craters_craters_min_size";
                                displayName = "$STR_ALIVE_CRATERS_MIN_SIZE";
                                tooltip = "$STR_ALIVE_CRATERS_MIN_SIZE_COMMENT";
                                defaultValue = """1""";
                                class Values
                                {
                                    class GL     { name = "$STR_ALIVE_CRATERS_MIN_SIZE_GL";     value = "0"; };
                                    class Mortar { name = "$STR_ALIVE_CRATERS_MIN_SIZE_MORTAR"; value = "1"; default = 1; };
                                    class Arty   { name = "$STR_ALIVE_CRATERS_MIN_SIZE_ARTY";   value = "2"; };
                                };
                        };
                        class craters_cap : Edit { property = "ALiVE_sys_craters_craters_cap"; displayName = "$STR_ALIVE_CRATERS_CAP"; tooltip = "$STR_ALIVE_CRATERS_CAP_COMMENT"; typeName = "STRING"; defaultValue = """150"""; };
                        class craters_dig : Combo
                        {
                                property = "ALiVE_sys_craters_craters_dig";
                                displayName = "$STR_ALIVE_CRATERS_DIG";
                                tooltip = "$STR_ALIVE_CRATERS_DIG_COMMENT";
                                defaultValue = """true""";
                                class Values
                                {
                                    class Yes { name = "$STR_ALIVE_CRATERS_YES"; value = true; default = 1; };
                                    class No { name = "$STR_ALIVE_CRATERS_NO"; value = false; };
                                };
                        };
                        class craters_depth : Edit { property = "ALiVE_sys_craters_craters_depth"; displayName = "$STR_ALIVE_CRATERS_DEPTH"; tooltip = "$STR_ALIVE_CRATERS_DEPTH_COMMENT"; typeName = "STRING"; defaultValue = """0.6"""; ALiVE_showWhen[] = {{"craters_dig", "is", "true"}}; };
                        class craters_building_distance : Edit { property = "ALiVE_sys_craters_craters_building_distance"; displayName = "$STR_ALIVE_CRATERS_BUILDING_DISTANCE"; tooltip = "$STR_ALIVE_CRATERS_BUILDING_DISTANCE_COMMENT"; typeName = "STRING"; defaultValue = """25"""; };

                        class HDR_PERSISTENCE : ALiVE_ModuleSubTitle { property = "ALiVE_sys_craters_HDR_PERSISTENCE"; displayName = "PERSISTENCE"; };
                        class craters_persistent : Combo
                        {
                                property = "ALiVE_sys_craters_craters_persistent";
                                displayName = "$STR_ALIVE_CRATERS_PERSISTENT";
                                tooltip = "$STR_ALIVE_CRATERS_PERSISTENT_COMMENT";
                                defaultValue = """true""";
                                class Values
                                {
                                    class Yes { name = "$STR_ALIVE_CRATERS_YES"; value = true; default = 1; };
                                    class No { name = "$STR_ALIVE_CRATERS_NO"; value = false; };
                                };
                        };
                        class craters_save_interval : Edit { property = "ALiVE_sys_craters_craters_save_interval"; displayName = "$STR_ALIVE_CRATERS_SAVE_INTERVAL"; tooltip = "$STR_ALIVE_CRATERS_SAVE_INTERVAL_COMMENT"; typeName = "STRING"; defaultValue = """120"""; ALiVE_showWhen[] = {{"craters_persistent", "is", "true"}}; };

                        class ModuleDescription : ModuleDescription {};
                };
                class ModuleDescription
                {
                        description[] = {"$STR_ALIVE_CRATERS_COMMENT","","$STR_ALIVE_CRATERS_USAGE"};
                };
        };
};
