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
                displayName = "$STR_ALIVE_NEWSFEED";
                function = "ALIVE_fnc_emptyInit";
                functionPriority = 41;
                isGlobal = 1;
                isPersistent = 1;
                icon = "x\alive\addons\sys_newsfeed\icon_sys_newsfeed.paa";
                picture = "x\alive\addons\sys_newsfeed\icon_sys_newsfeed.paa";
                class Attributes : AttributesBase
                {
                        class HDR_GENERAL : ALiVE_ModuleSubTitle { property = "ALiVE_sys_newsfeed_HDR_GENERAL"; displayName = "GENERAL"; };
                        class Enabled : Combo
                        {
                                property = "ALiVE_sys_newsfeed_Enabled";
                                displayName = "$STR_ALIVE_NEWSFEED_ALLOW";
                                tooltip = "$STR_ALIVE_NEWSFEED_ALLOW_COMMENT";
                                defaultValue = """1""";
                                class Values
                                {
                                    class Yes { name = "Yes"; value = 1; default = 1; };
                                    class No { name = "No"; value = 0; };
                                };
                        };
                        class Condition : Edit
                        {
                                property = "ALiVE_sys_newsfeed_Condition";
                                displayName = "Condition:";
                                tooltip = "";
                                defaultValue = """true""";
                        };
                        class ModuleDescription : ModuleDescription {};
                };
        };
};
