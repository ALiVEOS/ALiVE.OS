class CfgVehicles {
        class ModuleAliveBase;

        class ADDON : ModuleAliveBase
        {
        		scope = 1;
				displayName = "$STR_ALIVE_patrolrep";
				function = "ALIVE_fnc_emptyInit";
				functionPriority = 152;
				isGlobal = 2;
				icon = "x\alive\addons\sys_patrolrep\icon_sys_patrolrep.paa";
				picture = "x\alive\addons\sys_patrolrep\icon_sys_patrolrep.paa";
				author = MODULE_AUTHOR;
        };

};