class CfgVehicles {
        class ModuleAliveBase;
        class ADDON : ModuleAliveBase
        {
                scope = 2;
                displayName = "$STR_ALIVE_ARTILLERY";
                function = "ALIVE_fnc_ARTILLERYInit";
                author = MODULE_AUTHOR;
                functionPriority = 161;
                isGlobal = 2;
				icon = "x\alive\addons\sup_cas\icon_sup_cas.paa";
				picture = "x\alive\addons\sup_cas\icon_sup_cas.paa";
                class Arguments
                {
                        class artillery_callsign
                        {
                                displayName = "$STR_ALIVE_ARTILLERY_CALLSIGN";
                                description = "$STR_ALIVE_ARTILLERY_CALLSIGN_DESC";
                                defaultValue ="FOX SEVEN";
                        };

                        class artillery_type
                        {
                                displayName = "$STR_ALIVE_ARTILLERY_TYPE";
                                description = "$STR_ALIVE_ARTILLERY_TYPE_DESC";
                                defaultValue ="B_MBT_01_arty_F";
                        };
                        class artillery_he
                        {
                                displayName = "$STR_ALIVE_ARTILLERY_HE";
                                description = "$STR_ALIVE_ARTILLERY_HE_DESC";
                                defaultValue= 30;
                        };
                        class artillery_illum
                        {
                                displayName = "$STR_ALIVE_ARTILLERY_ILLUM";
                                description = "$STR_ALIVE_ARTILLERY_ILLUM_DESC";
                                defaultValue= 30;
                        };
                         class artillery_smoke
                        {
                                displayName = "$STR_ALIVE_ARTILLERY_SMOKE";
                                description = "$STR_ALIVE_ARTILLERY_SMOKE_DESC";
                                defaultValue= 30;
                        };
                        class artillery_guided
                        {
                                displayName = "$STR_ALIVE_ARTILLERY_GUIDED";
                                description = "$STR_ALIVE_ARTILLERY_GUIDED_DESC";
                                defaultValue= 30;
                        };
                        class artillery_cluster
                        {
                                displayName = "$STR_ALIVE_ARTILLERY_CLUSTER";
                                description = "$STR_ALIVE_ARTILLERY_CLUSTER_DESC";
                                defaultValue= 30;
                        };
                        class artillery_lg
                        {
                                displayName = "$STR_ALIVE_ARTILLERY_LG";
                                description = "$STR_ALIVE_ARTILLERY_LG_DESC";
                                defaultValue= 30;
                        };
                        class artillery_mine
                        {
                                displayName = "$STR_ALIVE_ARTILLERY_MINE";
                                description = "$STR_ALIVE_ARTILLERY_MINE_DESC";
                                defaultValue= 30;
                        };
                        class artillery_atmine
                        {
                                displayName = "$STR_ALIVE_ARTILLERY_ATMINE";
                                description = "$STR_ALIVE_ARTILLERY_ATMINE_DESC";
                                defaultValue= 30;
                        };
                        class artillery_rockets
                        {
                                displayName = "$STR_ALIVE_ARTILLERY_ROCKETS";
                                description = "$STR_ALIVE_ARTILLERY_ROCKETS_DESC";
                                defaultValue= 16;
                        };

                        class artillery_code
                        {
                                displayName = "$STR_ALIVE_ARTILLERY_CODE";
                                description = "$STR_ALIVE_ARTILLERY_CODE_DESC";
                                defaultValue = "";
                        };
                };
				class ModuleDescription
				{
					//description = "$STR_ALIVE_ARTILLERY_COMMENT"; // Short description, will be formatted as structured text
					description[] = {
						"$STR_ALIVE_ARTILLERY_COMMENT",
						"",
						"$STR_ALIVE_ARTILLERY_USAGE"
					};
				};
		};
};