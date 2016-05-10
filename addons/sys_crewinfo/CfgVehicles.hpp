class CfgVehicles {
        class ModuleAliveBase;
        class ADDON : ModuleAliveBase
        {
                scope = 1;
                displayName = "$STR_ALIVE_CREWINFO";
                function = "ALIVE_fnc_emptyInit";
                author = MODULE_AUTHOR;
                functionPriority = 203;
                isGlobal = 1;
                isPersistent = 1;
                icon = "\x\alive\addons\sys_crewinfo\icon_sys_crewinfo.paa";
                picture = "\x\alive\addons\sys_crewinfo\icon_sys_crewinfo.paa";

			         	class Arguments
			          {
			                        class crewinfo_debug_setting
			                        {
			                                displayName = "$STR_ALIVE_CREWINFO_DEBUG";
			                                description = "$STR_ALIVE_CREWINFO_DEBUG_COMMENT";
			                                class Values
			                                {

			                                        class No
			                                        {
			                                                name = "No";
			                                                value = false;
			                                        };
			                                        class Yes
			                                        {
			                                                name = "Yes";
			                                                value = true;
			                                                default = 1;

			                                        };
			                                };
			                        };
			                        class crewinfo_ui_setting
			                        {
			                                displayName = "$STR_ALIVE_CREWINFO_UI";
			                                description = "$STR_ALIVE_CREWINFO_UI_COMMENT";
			                                class Values
			                                {
			                                        class uiRight
			                                        {
			                                                name = "Right";
			                                                value = 1;
			                                                default = 1;
			                                        };
			                                        class uiLeft
			                                        {
			                                                name = "Left";
			                                                value = 2;
			                                        };

			                                };
			                        };
			          };

			  };
};
