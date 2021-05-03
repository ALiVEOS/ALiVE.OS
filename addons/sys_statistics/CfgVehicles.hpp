class CfgVehicles {
    class ModuleAliveBase;
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
        class Arguments {
            class Condition {
                displayName = "Condition:";
                description = "";
                defaultValue = "true";
            };
        };

        class Eventhandlers : Eventhandlers{
            init = "call ALIVE_fnc_statisticsDisable;";
        };
    };
};