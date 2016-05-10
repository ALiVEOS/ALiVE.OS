class CfgVehicles {
        class ModuleAliveBase;

        class ADDON : ModuleAliveBase
        {
        		scope = 1;
				displayName = "$STR_ALIVE_sitrep";
				function = "ALIVE_fnc_emptyInit";
				functionPriority = 151;
				isGlobal = 2;
				icon = "x\alive\addons\sys_sitrep\icon_sys_sitrep.paa";
				picture = "x\alive\addons\sys_sitrep\icon_sys_sitrep.paa";
				author = MODULE_AUTHOR;
        };

};