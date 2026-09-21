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
                displayName = "$STR_ALIVE_VDIST";
                function = "ALIVE_fnc_emptyInit";
                author = MODULE_AUTHOR;
                isGlobal = 1;
                isPersistent = 1;
                functionPriority = 201;
                icon = "x\alive\addons\sys_viewdistance\icon_sys_viewdistance.paa";
                picture = "x\alive\addons\sys_viewdistance\icon_sys_viewdistance.paa";
                class Attributes : AttributesBase
                {
                        class minVD : Edit { property = "ALiVE_sys_viewdistance_minVD"; displayName = "$STR_ALIVE_VDIST_MIN"; tooltip = "$STR_ALIVE_VDIST_MIN_COMMENT"; defaultValue = """500"""; };
                        class maxVD : Edit { property = "ALiVE_sys_viewdistance_maxVD"; displayName = "$STR_ALIVE_VDIST_MAX"; tooltip = "$STR_ALIVE_VDIST_MAX_COMMENT"; defaultValue = """20000"""; };
                        class minTG : Edit { property = "ALiVE_sys_viewdistance_minTG"; displayName = "$STR_ALIVE_TGRID_MIN"; tooltip = "$STR_ALIVE_TGRID_MIN_COMMENT"; defaultValue = """1"""; };
                        class maxTG : Edit { property = "ALiVE_sys_viewdistance_maxTG"; displayName = "$STR_ALIVE_TGRID_MAX"; tooltip = "$STR_ALIVE_TGRID_MAX_COMMENT"; defaultValue = """5"""; };
                        class ModuleDescription : ModuleDescription {};
                };
        };
};
