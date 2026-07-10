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
                class ModuleDescription : ModuleDescription {};
        };
        class ModuleDescription
        {
            description[] = {"$STR_ALIVE_MIL_ARTILLERY_DESCRIPTION"};
        };
    };
};
