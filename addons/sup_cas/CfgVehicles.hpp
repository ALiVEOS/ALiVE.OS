class CfgVehicles {
        class ModuleAliveBase;
        class ADDON : ModuleAliveBase
        {
                scope = 2;
                displayName = "$STR_ALIVE_CAS";
                function = "ALIVE_fnc_CASInit";
                author = MODULE_AUTHOR;
                functionPriority = 162;
                isGlobal = 2;
				icon = "x\alive\addons\sup_cas\icon_sup_cas.paa";
				picture = "x\alive\addons\sup_cas\icon_sup_cas.paa";
                class Arguments
                {
                        class cas_callsign
                        {
                                displayName = "$STR_ALIVE_CAS_CALLSIGN";
                                description = "$STR_ALIVE_CAS_CALLSIGN_DESC";
                                defaultValue ="EAGLE ONE";
                        };

                        class cas_type
                        {
                                displayName = "$STR_ALIVE_CAS_TYPE";
                                description = "$STR_ALIVE_CAS_TYPE_DESC";
                                defaultValue ="B_Heli_Attack_01_F";
                        };
                        class cas_height
                        {
                                displayName = "$STR_ALIVE_CAS_HEIGHT";
                                description = "$STR_ALIVE_CAS_HEIGHT_DESC";
                                defaultValue=0;
                        };
                        class cas_code
                        {
                                displayName = "$STR_ALIVE_CAS_CODE";
                                description = "$STR_ALIVE_CAS_CODE_DESC";
                                defaultValue="";
                        };
                };
				class ModuleDescription
				{
						//description = "$STR_ALIVE_CAS_COMMENT"; // Short description, will be formatted as structured text
						description[] = {
								"$STR_ALIVE_CAS_COMMENT",
								"",
								"$STR_ALIVE_CAS_USAGE"
						};
				};
        };
};