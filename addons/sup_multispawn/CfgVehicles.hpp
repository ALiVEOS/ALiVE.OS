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
                displayName = "$STR_ALIVE_multispawn";
                function = "ALIVE_fnc_multispawnInit";
                author = MODULE_AUTHOR;
                functionPriority = 210;
                isGlobal = 2;
                icon = "x\alive\addons\sup_multispawn\icon_sup_multispawn.paa";
                picture = "x\alive\addons\sup_multispawn\icon_sup_multispawn.paa";
                class Attributes : AttributesBase
                {
                        class debug : Combo
                        {
                                property = "ALiVE_sup_multispawn_debug";
                                displayName = "$STR_ALIVE_multispawn_DEBUG";
                                tooltip = "$STR_ALIVE_multispawn_DEBUG_COMMENT";
                                defaultValue = """false""";
                                class Values
                                {
                                    class Yes { name = "Yes"; value = true; };
                                    class No { name = "No"; value = false; default = 1; };
                                };
                        };
                        class spawntype : Combo
                        {
                                property = "ALiVE_sup_multispawn_spawntype";
                                displayName = "$STR_ALIVE_multispawn_TYPE";
                                tooltip = "$STR_ALIVE_multispawn_TYPE_COMMENT";
                                defaultValue = """forwardspawn""";
                                class Values
                                {
                                    class forwardspawn { name = "Spawn on squad"; value = "forwardspawn"; default = 1; };
                                    class insertion { name = "Insertion"; value = "insertion"; };
                                    class vehicle { name = "Spawn in vehicle"; value = "vehicle"; };
                                    class building { name = "Spawn in building"; value = "building"; };
                                    class none { name = "None"; value = "none"; };
                                };
                        };
                        class timeout : Edit { property = "ALiVE_sup_multispawn_timeout"; displayName = "$STR_ALIVE_MULTISPAWN_TIMEOUT"; tooltip = "$STR_ALIVE_MULTISPAWN_TIMEOUT_COMMENT"; defaultValue = """60"""; };
                        class spawningnearenemiesallowed : Combo
                        {
                                property = "ALiVE_sup_multispawn_spawningnearenemiesallowed";
                                displayName = "$STR_ALIVE_multispawn_SPAWNINGNEARENEMIESALLOWED";
                                tooltip = "$STR_ALIVE_multispawn_SPAWNINGNEARENEMIESALLOWED_COMMENT";
                                defaultValue = """false""";
                                class Values
                                {
                                    class Yes { name = "Yes"; value = false; default = 1; };
                                    class No { name = "No"; value = true; };
                                };
                        };
                        class respawnWithGear : Combo
                        {
                                property = "ALiVE_sup_multispawn_respawnWithGear";
                                displayName = "$STR_ALIVE_multispawn_RESPAWNWITHGEAR";
                                tooltip = "$STR_ALIVE_multispawn_RESPAWNWITHGEAR_COMMENT";
                                defaultValue = """true""";
                                class Values
                                {
                                    class Yes { name = "Yes"; value = true; default = 1; };
                                    class No { name = "No"; value = false; };
                                };
                        };
                        class ModuleDescription : ModuleDescription {};
                };
                class ModuleDescription
                {
                    description[] = {"$STR_ALIVE_MULTISPAWN_COMMENT","","$STR_ALIVE_MULTISPAWN_USAGE"};
                };
        };
};
