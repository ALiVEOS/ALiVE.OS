class CfgVehicles {
        class ModuleAliveBase;

        class ADDON : ModuleAliveBase
        {
        		scope = 1;
				displayName = "$STR_ALIVE_MARKER";
				function = "ALIVE_fnc_emptyInit";
				functionPriority = 44;
				isGlobal = 2;
				icon = "x\alive\addons\sys_marker\icon_sys_marker.paa";
				picture = "x\alive\addons\sys_marker\icon_sys_marker.paa";
				author = MODULE_AUTHOR;
        };

};