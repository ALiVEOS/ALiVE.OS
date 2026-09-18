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
                displayName = "$STR_ALIVE_CREWINFO";
                function = "ALIVE_fnc_emptyInit";
                author = MODULE_AUTHOR;
                functionPriority = 203;
                isGlobal = 1;
                isPersistent = 1;
                icon = "\x\alive\addons\sys_crewinfo\icon_sys_crewinfo.paa";
                picture = "\x\alive\addons\sys_crewinfo\icon_sys_crewinfo.paa";
                class Attributes : AttributesBase
                {
                        class crewinfo_debug_setting : Combo
                        {
                                property = "ALiVE_sys_crewinfo_crewinfo_debug_setting";
                                displayName = "$STR_ALIVE_CREWINFO_DEBUG";
                                tooltip = "$STR_ALIVE_CREWINFO_DEBUG_COMMENT";
                                defaultValue = """false""";
                                class Values
                                {
                                    class No { name = "No"; value = false; default = 1;};
                                    class Yes { name = "Yes"; value = true; };
                                };
                        };
                        class crewinfo_ui_setting : Combo
                        {
                                property = "ALiVE_sys_crewinfo_crewinfo_ui_setting";
                                displayName = "$STR_ALIVE_CREWINFO_UI";
                                tooltip = "$STR_ALIVE_CREWINFO_UI_COMMENT";
                                defaultValue = """1""";
                                class Values
                                {
                                    class uiRight { name = "Right"; value = 1; default = 1; };
                                    class uiLeft { name = "Left"; value = 2; };
                                };
                        };
                        class ModuleDescription : ModuleDescription {};
                };
        };
};
