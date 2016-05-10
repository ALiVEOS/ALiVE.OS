class CfgVehicles {
        class ModuleAliveBase;

        class ADDON : ModuleAliveBase
        {
        		scope = 1;
				displayName = "$STR_ALIVE_spotrep";
				function = "ALIVE_fnc_emptyInit";
				functionPriority = 43;
				isGlobal = 2;
				icon = "x\alive\addons\sys_spotrep\icon_sys_spotrep.paa";
				picture = "x\alive\addons\sys_spotrep\icon_sys_spotrep.paa";
				author = MODULE_AUTHOR;
        };

};