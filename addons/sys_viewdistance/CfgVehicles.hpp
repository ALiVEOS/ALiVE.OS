class CfgVehicles {
        class ModuleAliveBase;
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
                class Arguments
                {
                        class maxVD
                        {
                                displayName = "$STR_ALIVE_VDIST_MAX";
                                description = "$STR_ALIVE_VDIST_MAX_COMMENT";
                                defaultvalue = "20000";
                        };
                        class minVD
                        {
                                displayName = "$STR_ALIVE_VDIST_MIN";
                                description = "$STR_ALIVE_VDIST_MIN_COMMENT";
                                defaultvalue = "500";
                        };
                        class maxTG
                        {
                                displayName = "$STR_ALIVE_TGRID_MAX";
                                description = "$STR_ALIVE_TGRID_MAX_COMMENT";
                                defaultvalue = "5";
                        };
                        class minTG
                        {
                                displayName = "$STR_ALIVE_TGRID_MIN";
                                description = "$STR_ALIVE_TGRID_MIN_COMMENT";
                                defaultvalue = "1";
                        };
                };

        };
};
