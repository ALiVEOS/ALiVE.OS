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
                displayName = "$STR_ALIVE_GC";
                function = "ALIVE_fnc_emptyInit";
                author = MODULE_AUTHOR;
                functionPriority = 46;
                isGlobal = 2;
                icon = "x\alive\addons\sys_GC\icon_sys_GC.paa";
                picture = "x\alive\addons\sys_GC\icon_sys_GC.paa";
                class Attributes : AttributesBase
                {
                        class HDR_GENERAL : ALiVE_ModuleSubTitle { property = "ALiVE_sys_gc_HDR_GENERAL"; displayName = "GENERAL"; };
                        class debug : Combo
                        {
                                property = "ALiVE_sys_gc_debug";
                                displayName = "$STR_ALIVE_GC_DEBUG";
                                tooltip = "$STR_ALIVE_GC_DEBUG_COMMENT";
                                defaultValue = """false""";
                                class Values
                                {
                                    class Yes { name = "Yes"; value = true; };
                                    class No { name = "No"; value = false; default = 1; };
                                };
                        };
                        class ALiVE_GC_INTERVAL : Edit { property = "ALiVE_sys_gc_ALiVE_GC_INTERVAL"; displayName = "$STR_ALIVE_GC_INTERVAL"; tooltip = "$STR_ALIVE_GC_INTERVAL_COMMENT"; defaultValue = """300"""; };
                        class ALiVE_GC_THRESHHOLD : Edit { property = "ALiVE_sys_gc_ALiVE_GC_THRESHHOLD"; displayName = "$STR_ALIVE_GC_THRESHHOLD"; tooltip = "$STR_ALIVE_GC_THRESHHOLD_COMMENT"; defaultValue = """100"""; };
                        class ALiVE_GC_INDIVIDUALTYPES : Edit { property = "ALiVE_sys_gc_ALiVE_GC_INDIVIDUALTYPES"; displayName = "$STR_ALIVE_GC_INDIVIDUALTYPES"; tooltip = "$STR_ALIVE_GC_INDIVIDUALTYPES_COMMENT"; defaultValue = """"""; };
                        class ModuleDescription : ModuleDescription {};
                };
        };
};
