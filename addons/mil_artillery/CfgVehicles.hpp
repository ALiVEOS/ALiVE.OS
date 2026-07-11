class CfgVehicles
{
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
        scope = 2;
        displayName = "$STR_ALIVE_MIL_ARTILLERY";
        function = "ALIVE_fnc_MilArtilleryInit";
        author = MODULE_AUTHOR;
        functionPriority = 190;
        isGlobal = 1;
        icon = "x\alive\addons\mil_artillery\icon_mil_artillery.paa";
        picture = "x\alive\addons\mil_artillery\icon_mil_artillery.paa";
        class Attributes : AttributesBase
        {
                // ---- General --------------------------------------------------------
                class HDR_GENERAL : ALiVE_ModuleSubTitle { property = "ALiVE_mil_artillery_HDR_GENERAL"; displayName = "GENERAL"; };
                class debug : Combo
                {
                        property = "ALiVE_mil_artillery_debug";
                        displayName = "$STR_ALIVE_MIL_ARTILLERY_DEBUG";
                        tooltip = "$STR_ALIVE_MIL_ARTILLERY_DEBUG_COMMENT";
                        defaultValue = """false""";
                        class Values
                        {
                            class Yes { name = "Yes"; value = true; };
                            class No { name = "No"; value = false; default = 1; };
                        };
                };
                // ---- Fire Missions --------------------------------------------------
                class HDR_FIRES : ALiVE_ModuleSubTitle { property = "ALiVE_mil_artillery_HDR_FIRES"; displayName = "FIRE MISSIONS"; };
                class intensity : Combo
                {
                        property = "ALiVE_mil_artillery_intensity";
                        displayName = "$STR_ALIVE_MIL_ARTILLERY_INTENSITY";
                        tooltip = "$STR_ALIVE_MIL_ARTILLERY_INTENSITY_COMMENT";
                        defaultValue = """MEDIUM""";
                        class Values
                        {
                            class LOW { name = "$STR_ALIVE_MIL_ARTILLERY_INTENSITY_LOW"; value = "LOW"; };
                            class MEDIUM { name = "$STR_ALIVE_MIL_ARTILLERY_INTENSITY_MEDIUM"; value = "MEDIUM"; default = 1; };
                            class HIGH { name = "$STR_ALIVE_MIL_ARTILLERY_INTENSITY_HIGH"; value = "HIGH"; };
                        };
                };
                class generateTasks : Combo
                {
                        property = "ALiVE_mil_artillery_generateTasks";
                        displayName = "$STR_ALIVE_MIL_ARTILLERY_TASKS";
                        tooltip = "$STR_ALIVE_MIL_ARTILLERY_TASKS_COMMENT";
                        defaultValue = """true""";
                        class Values
                        {
                            class Yes { name = "Yes"; value = true; default = 1; };
                            class No { name = "No"; value = false; };
                        };
                };
                // ---- Fine Tuning ----------------------------------------------------
                // per-parameter overrides; "Use intensity preset" leaves the master
                // dial in charge of that parameter
                class HDR_TUNING : ALiVE_ModuleSubTitle { property = "ALiVE_mil_artillery_HDR_TUNING"; displayName = "FINE TUNING"; };
                class cadenceLevel : Combo
                {
                        property = "ALiVE_mil_artillery_cadenceLevel";
                        displayName = "$STR_ALIVE_MIL_ARTILLERY_CADENCE";
                        tooltip = "$STR_ALIVE_MIL_ARTILLERY_CADENCE_COMMENT";
                        defaultValue = """PRESET""";
                        class Values
                        {
                            class PRESET { name = "$STR_ALIVE_MIL_ARTILLERY_PRESET"; value = "PRESET"; default = 1; };
                            class LOW { name = "$STR_ALIVE_MIL_ARTILLERY_INTENSITY_LOW"; value = "LOW"; };
                            class MEDIUM { name = "$STR_ALIVE_MIL_ARTILLERY_INTENSITY_MEDIUM"; value = "MEDIUM"; };
                            class HIGH { name = "$STR_ALIVE_MIL_ARTILLERY_INTENSITY_HIGH"; value = "HIGH"; };
                        };
                };
                class spreadLevel : Combo
                {
                        property = "ALiVE_mil_artillery_spreadLevel";
                        displayName = "$STR_ALIVE_MIL_ARTILLERY_SPREAD";
                        tooltip = "$STR_ALIVE_MIL_ARTILLERY_SPREAD_COMMENT";
                        defaultValue = """PRESET""";
                        class Values
                        {
                            class PRESET { name = "$STR_ALIVE_MIL_ARTILLERY_PRESET"; value = "PRESET"; default = 1; };
                            class LOW { name = "$STR_ALIVE_MIL_ARTILLERY_INTENSITY_LOW"; value = "LOW"; };
                            class MEDIUM { name = "$STR_ALIVE_MIL_ARTILLERY_INTENSITY_MEDIUM"; value = "MEDIUM"; };
                            class HIGH { name = "$STR_ALIVE_MIL_ARTILLERY_INTENSITY_HIGH"; value = "HIGH"; };
                        };
                };
                class roundsLevel : Combo
                {
                        property = "ALiVE_mil_artillery_roundsLevel";
                        displayName = "$STR_ALIVE_MIL_ARTILLERY_ROUNDS";
                        tooltip = "$STR_ALIVE_MIL_ARTILLERY_ROUNDS_COMMENT";
                        defaultValue = """PRESET""";
                        class Values
                        {
                            class PRESET { name = "$STR_ALIVE_MIL_ARTILLERY_PRESET"; value = "PRESET"; default = 1; };
                            class LOW { name = "$STR_ALIVE_MIL_ARTILLERY_INTENSITY_LOW"; value = "LOW"; };
                            class MEDIUM { name = "$STR_ALIVE_MIL_ARTILLERY_INTENSITY_MEDIUM"; value = "MEDIUM"; };
                            class HIGH { name = "$STR_ALIVE_MIL_ARTILLERY_INTENSITY_HIGH"; value = "HIGH"; };
                        };
                };
                class ammoLevel : Combo
                {
                        property = "ALiVE_mil_artillery_ammoLevel";
                        displayName = "$STR_ALIVE_MIL_ARTILLERY_AMMO";
                        tooltip = "$STR_ALIVE_MIL_ARTILLERY_AMMO_COMMENT";
                        defaultValue = """PRESET""";
                        class Values
                        {
                            class PRESET { name = "$STR_ALIVE_MIL_ARTILLERY_PRESET"; value = "PRESET"; default = 1; };
                            class LOW { name = "$STR_ALIVE_MIL_ARTILLERY_INTENSITY_LOW"; value = "LOW"; };
                            class MEDIUM { name = "$STR_ALIVE_MIL_ARTILLERY_INTENSITY_MEDIUM"; value = "MEDIUM"; };
                            class HIGH { name = "$STR_ALIVE_MIL_ARTILLERY_INTENSITY_HIGH"; value = "HIGH"; };
                        };
                };
                class selectivityLevel : Combo
                {
                        property = "ALiVE_mil_artillery_selectivityLevel";
                        displayName = "$STR_ALIVE_MIL_ARTILLERY_SELECTIVITY";
                        tooltip = "$STR_ALIVE_MIL_ARTILLERY_SELECTIVITY_COMMENT";
                        defaultValue = """PRESET""";
                        class Values
                        {
                            class PRESET { name = "$STR_ALIVE_MIL_ARTILLERY_PRESET"; value = "PRESET"; default = 1; };
                            class LOOSE { name = "$STR_ALIVE_MIL_ARTILLERY_SEL_LOOSE"; value = "LOOSE"; };
                            class STANDARD { name = "$STR_ALIVE_MIL_ARTILLERY_SEL_STANDARD"; value = "STANDARD"; };
                            class STRICT { name = "$STR_ALIVE_MIL_ARTILLERY_SEL_STRICT"; value = "STRICT"; };
                        };
                };
                class ModuleDescription : ModuleDescription {};
        };
        class ModuleDescription
        {
            description[] = {"$STR_ALIVE_MIL_ARTILLERY_DESCRIPTION"};
        };
    };
};
