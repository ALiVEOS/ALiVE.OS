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
            // Hidden: nothing reads Enable Debug, and the tour has no debug output for it to switch
            // on. Kept, not removed, so a mission's saved value still loads.
            class debug { property = "ALiVE_sys_tour_debug"; control = "ALiVE_HiddenAttribute"; defaultValue = """false"""; expression = "_this setVariable ['debug', _value, true];"; typeName = "STRING"; displayName = ""; };
            class ModuleDescription : ModuleDescription {};
        };
    };
};
