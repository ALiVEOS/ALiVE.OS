class CfgVehicles {
	class ModuleAliveBase;
	class ADDON: ModuleAliveBase {
		scope = 2;
		displayName = "$STR_ALIVE_TOUR";
		function = "ALIVE_fnc_tourInit";
		author = MODULE_AUTHOR;
		functionPriority = 250;
		isGlobal = 1;
		icon = "x\alive\addons\sys_tour\icon_sys_tour.paa";
		picture = "x\alive\addons\sys_tour\icon_sys_tour.paa";
		class Arguments
        {
            class debug
            {
                    displayName = "$STR_ALIVE_TOUR_DEBUG";
                    description = "$STR_ALIVE_TOUR_DEBUG_COMMENT";
                    class Values
                    {
                            class Yes
                            {
                                    name = "Yes";
                                    value = true;
                                    default = 1;
                            };
                            class No
                            {
                                    name = "No";
                                    value = false;
                            };
                    };
            };
        };
	};
};
