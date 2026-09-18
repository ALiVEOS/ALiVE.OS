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
    class ADDON: ModuleAliveBase {
        scope = 2;
        displayName = "$STR_ALIVE_TOUR";
        function = "ALIVE_fnc_tourInit";
        author = MODULE_AUTHOR;
        functionPriority = 250;
        isGlobal = 1;
        icon = "x\alive\addons\sys_tour\icon_sys_tour.paa";
        picture = "x\alive\addons\sys_tour\icon_sys_tour.paa";
        class Attributes : AttributesBase
        {
            class debug : Combo
            {
                    property = "ALiVE_sys_tour_debug";
                    displayName = "$STR_ALIVE_TOUR_DEBUG";
                    tooltip = "$STR_ALIVE_TOUR_DEBUG_COMMENT";
                    defaultValue = """false""";
                    class Values
                    {
                        class Yes { name = "Yes"; value = true; };
                        class No { name = "No"; value = false; default = 1;};
                    };
            };
            class ModuleDescription : ModuleDescription {};
        };
    };
};
