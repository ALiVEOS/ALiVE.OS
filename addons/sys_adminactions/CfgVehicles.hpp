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
                displayName = "$STR_ALIVE_ADMINACTIONS";
                function = "ALIVE_fnc_emptyInit";
                author = MODULE_AUTHOR;
                functionPriority = 42;
                isGlobal = 2;
                icon = "x\alive\addons\sys_adminactions\icon_sys_adminactions.paa";
                picture = "x\alive\addons\sys_adminactions\icon_sys_adminactions.paa";
                class Attributes : AttributesBase
                {
                        // #1044: the seven Yes/No options that sat here are gone. This module is scope 1 and
                        // could never be placed, so they were never set, and nothing read them.
                        class ModuleDescription : ModuleDescription {};
                };
                class ModuleDescription
                {
                    description[] = {"$STR_ALIVE_ADMINACTIONS_COMMENT","","$STR_ALIVE_ADMINACTIONS_USAGE"};
                };
        };
};
