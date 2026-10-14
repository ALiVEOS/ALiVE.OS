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
    class ModuleAliveBase2: ModuleAliveBase {
        class EventHandlers;
    };
    class ADDON : ModuleAliveBase2 {
        scope = 1;
        displayName = "$STR_ALIVE_DISABLE_STATISTICS";
        isGlobal = 2;
        functionPriority = 32;
        icon = "x\alive\addons\sys_statistics\icon_sys_statistics.paa";
        picture = "x\alive\addons\sys_statistics\icon_sys_statistics.paa";
        class Attributes : AttributesBase
        {
            class HDR_GENERAL : ALiVE_ModuleSubTitle { property = "ALiVE_sys_statistics_HDR_GENERAL"; displayName = "GENERAL"; };
            class Condition : Edit
            {
                    property = "ALiVE_sys_statistics_Condition";
                    displayName = "Condition:";
                    tooltip = "";
                    defaultValue = """true""";
            };
            class ModuleDescription : ModuleDescription {};
        };
        class Eventhandlers : Eventhandlers{
            init = "call ALIVE_fnc_statisticsDisable;";
        };
    };
};
