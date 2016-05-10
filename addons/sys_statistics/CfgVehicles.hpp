class CfgVehicles {
        class ModuleAliveBase;
        class ADDON : ModuleAliveBase
        {
                scope = 1;
                displayName = "$STR_ALIVE_DISABLE_STATISTICS";
                isGlobal = 2;
                functionPriority = 32;

		icon = "x\alive\addons\sys_statistics\icon_sys_statistics.paa";
		picture = "x\alive\addons\sys_statistics\icon_sys_statistics.paa";
                class Arguments
                {
                        class Condition
                        {
                                displayName = "Condition:";
                                description = "";
                                defaultValue = "true";
                        };
                };

				class Eventhandlers
				{
					init = "call ALIVE_fnc_statisticsDisable;";
				};

        };
};
