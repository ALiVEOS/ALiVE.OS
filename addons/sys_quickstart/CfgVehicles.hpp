class CfgVehicles {

        class ModuleAliveBase;

        class ALiVE: ModuleAliveBase {
                author = MODULE_AUTHOR;
                scope = 1;
                displayName = "ALiVE Quick Start";
                icon = "x\alive\addons\sys_quickstart\icon_sys_quickstart.paa";
                picture = "x\alive\addons\sys_quickstart\icon_sys_quickstart.paa";
                functionPriority = 20;
                function = "ALiVE_fnc_quickstartInit";

            class Arguments
              {
                class debug
                {
                        displayName = "$STR_ALIVE_DEBUG";
                        description = "$STR_ALIVE_DEBUG_COMMENT";
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
                // REQUIRES ALIVE
                class ALiVE_Versioning
                {
                        displayName = "$STR_ALIVE_REQUIRES_ALIVE_VERSIONING";
                        description = "$STR_ALIVE_REQUIRES_ALIVE_VERSIONING_COMMENT";
                        class Values
                        {
                                class warning
                                {
                                        name = "Warn players";
                                        value = warning;
                                        default = 1;
                                };
                                class kick
                                {
                                        name = "Kick players";
                                        value = kick;
                                };
                        };
                };

                class ALiVE_DISABLESAVE
                {
                        displayName = "$STR_ALIVE_DISABLESAVE";
                        description = "$STR_ALIVE_DISABLESAVE_COMMENT";
                        class Values
                        {
                                class Yes
                                {
                                        name = "Yes";
                                        value = true;
                                        default = 1;
                                        typeName = "BOOL";
                                };
                                class No
                                {
                                        name = "No";
                                        value = false;
                                        typeName = "BOOL";
                                };
                        };
                };
                // AI SKILL
                class AISKILL {
                        displayName = "";
                        class Values
                        {
                                class Divider
                                {
                                        name = "----- AI Skill Levels ------------------------------------------------";
                                        value = "";
                                };
                        };
                };
                class skillFactionsRecruit {
                        displayName = "$STR_ALIVE_AISKILL_RECRUIT";
                        description = "$STR_ALIVE_AISKILL_RECRUIT_COMMENT";
                        defaultValue = "CIV_F";
                };
                class skillFactionsRegular {
                        displayName = "$STR_ALIVE_AISKILL_REGULAR";
                        description = "$STR_ALIVE_AISKILL_REGULAR_COMMENT";
                        defaultValue = "IND_F,IND_G_F,BLU_G_F,OPF_G_F";
                };
                class skillFactionsVeteran {
                        displayName = "$STR_ALIVE_AISKILL_VETERAN";
                        description = "$STR_ALIVE_AISKILL_VETERAN_COMMENT";
                        defaultValue = "BLU_F,OPF_F";
                };
                class skillFactionsExpert {
                        displayName = "$STR_ALIVE_AISKILL_EXPERT";
                        description = "$STR_ALIVE_AISKILL_EXPERT_COMMENT";
                        defaultValue = "";
                };
                // CIVILIANS
                class CIVILIANS {
                        displayName = "";
                        class Values
                        {
                                class Divider
                                {
                                        name = "----- Civilians ------------------------------------------------------";
                                        value = "";
                                };
                        };
                };
                class hostilityWest
                {
                        displayName = "$STR_ALIVE_CIV_POP_HOSTILITY_WEST";
                        description = "$STR_ALIVE_CIV_POP_HOSTILITY_WEST_COMMENT";
                        class Values
                        {
                                class LOW
                                {
                                        name = "$STR_ALIVE_CIV_POP_HOSTILITY_WEST_LOW";
                                        value = "0";
                                };
                                class MEDIUM
                                {
                                        name = "$STR_ALIVE_CIV_POP_HOSTILITY_WEST_MEDIUM";
                                        value = "1";
                                };
                                class HIGH
                                {
                                        name = "$STR_ALIVE_CIV_POP_HOSTILITY_WEST_HIGH";
                                        value = "2";
                                };
                                class EXTREME
                                {
                                        name = "$STR_ALIVE_CIV_POP_HOSTILITY_WEST_EXTREME";
                                        value = "3";
                                };
                        };
                };
                class hostilityEast
                {
                      displayName = "$STR_ALIVE_CIV_POP_HOSTILITY_EAST";
                      description = "$STR_ALIVE_CIV_POP_HOSTILITY_EAST_COMMENT";
                      class Values
                      {
                              class LOW
                              {
                                      name = "$STR_ALIVE_CIV_POP_HOSTILITY_EAST_LOW";
                                      value = "0";
                              };
                              class MEDIUM
                              {
                                      name = "$STR_ALIVE_CIV_POP_HOSTILITY_EAST_MEDIUM";
                                      value = "1";
                              };
                              class HIGH
                              {
                                      name = "$STR_ALIVE_CIV_POP_HOSTILITY_EAST_HIGH";
                                      value = "2";
                              };
                              class EXTREME
                              {
                                      name = "$STR_ALIVE_CIV_POP_HOSTILITY_EAST_EXTREME";
                                      value = "3";
                              };
                      };
                };
                class hostilityIndep
                {
                      displayName = "$STR_ALIVE_CIV_POP_HOSTILITY_INDEP";
                      description = "$STR_ALIVE_CIV_POP_HOSTILITY_INDEP_COMMENT";
                      class Values
                      {
                              class LOW
                              {
                                      name = "$STR_ALIVE_CIV_POP_HOSTILITY_INDEP_LOW";
                                      value = "0";
                              };
                              class MEDIUM
                              {
                                      name = "$STR_ALIVE_CIV_POP_HOSTILITY_INDEP_MEDIUM";
                                      value = "1";
                              };
                              class HIGH
                              {
                                      name = "$STR_ALIVE_CIV_POP_HOSTILITY_INDEP_HIGH";
                                      value = "2";
                              };
                              class EXTREME
                              {
                                      name = "$STR_ALIVE_CIV_POP_HOSTILITY_INDEP_EXTREME";
                                      value = "3";
                              };
                      };
                };
                class taor
                {
                        displayName = "$STR_ALIVE_AMBCP_TAOR";
                        description = "$STR_ALIVE_AMBCP_TAOR_COMMENT";
                        defaultValue = "";
                };
                class blacklist
                {
                        displayName = "$STR_ALIVE_AMBCP_BLACKLIST";
                        description = "$STR_ALIVE_AMBCP_BLACKLIST_COMMENT";
                        defaultValue = "";
                };
                class sizeFilter
                {
                        displayName = "$STR_ALIVE_AMBCP_SIZE_FILTER";
                        description = "$STR_ALIVE_AMBCP_SIZE_FILTER_COMMENT";
                        class Values
                        {
                                class NONE
                                {
                                        name = "$STR_ALIVE_AMBCP_SIZE_FILTER_NONE";
                                        value = "160";
                                };
                                class SMALL
                                {
                                        name = "$STR_ALIVE_AMBCP_SIZE_FILTER_SMALL";
                                        value = "250";
                                        default = 1;
                                };
                                                            class MEDIUM
                                {
                                        name = "$STR_ALIVE_AMBCP_SIZE_FILTER_MEDIUM";
                                        value = "400";
                                };
                                                            class LARGE
                                {
                                        name = "$STR_ALIVE_AMBCP_SIZE_FILTER_LARGE";
                                        value = "700";
                                };
                        };
                };
                class priorityFilter
                {
                        displayName = "$STR_ALIVE_AMBCP_PRIORITY_FILTER";
                        description = "$STR_ALIVE_AMBCP_PRIORITY_FILTER_COMMENT";
                        class Values
                        {
                                class NONE
                                {
                                        name = "$STR_ALIVE_AMBCP_PRIORITY_FILTER_NONE";
                                        value = "0";
                                };
                                class LOW
                                {
                                        name = "$STR_ALIVE_AMBCP_PRIORITY_FILTER_LOW";
                                        value = "10";
                                };
                                                            class MEDIUM
                                {
                                        name = "$STR_ALIVE_AMBCP_PRIORITY_FILTER_MEDIUM";
                                        value = "30";
                                };
                                                            class HIGH
                                {
                                        name = "$STR_ALIVE_AMBCP_PRIORITY_FILTER_HIGH";
                                        value = "40";
                                };
                        };
                };
                class faction
                {
                        displayName = "$STR_ALIVE_AMBCP_FACTION";
                        description = "$STR_ALIVE_AMBCP_FACTION_COMMENT";
                        defaultValue = "CIV_F";
                };
                class placementMultiplier
                {
                        displayName = "$STR_ALIVE_AMBCP_PLACEMENT_MULTIPLIER";
                        description = "$STR_ALIVE_AMBCP_PLACEMENT_MULTIPLIER_COMMENT";
                        class Values
                        {
                                class LOW
                                {
                                        name = "$STR_ALIVE_AMBCP_PLACEMENT_MULTIPLIER_LOW";
                                        value = "0.5";
                                };
                                class MEDIUM
                                {
                                        name = "$STR_ALIVE_AMBCP_PLACEMENT_MULTIPLIER_MEDIUM";
                                        value = "1";
                                };
                                class HIGH
                                {
                                        name = "$STR_ALIVE_AMBCP_PLACEMENT_MULTIPLIER_HIGH";
                                        value = "1.5";
                                };
                                class EXTREME
                                {
                                        name = "$STR_ALIVE_AMBCP_PLACEMENT_MULTIPLIER_EXTREME";
                                        value = "2";
                                };
                        };
                };
                class ambientVehicleAmount
                {
                        displayName = "$STR_ALIVE_AMBCP_AMBIENT_VEHICLE_AMOUNT";
                        description = "$STR_ALIVE_AMBCP_AMBIENT_VEHICLE_AMOUNT_COMMENT";
                        class Values
                        {
                                class NONE
                                {
                                        name = "$STR_ALIVE_AMBCP_AMBIENT_VEHICLE_AMOUNT_NONE";
                                        value = "0";
                                };
                                class LOW
                                {
                                        name = "$STR_ALIVE_AMBCP_AMBIENT_VEHICLE_AMOUNT_LOW";
                                        value = "0.2";
                                        default = 1;
                                };
                                class MEDIUM
                                {
                                        name = "$STR_ALIVE_AMBCP_AMBIENT_VEHICLE_AMOUNT_MEDIUM";
                                        value = "0.6";
                                };
                                class HIGH
                                {
                                        name = "$STR_ALIVE_AMBCP_AMBIENT_VEHICLE_AMOUNT_HIGH";
                                        value = "1";
                                };
                        };
                };
                class ambientVehicleFaction
                {
                        displayName = "$STR_ALIVE_AMBCP_AMBIENT_VEHICLE_FACTION";
                        description = "$STR_ALIVE_AMBCP_AMBIENT_VEHICLE_FACTION_COMMENT";
                        defaultValue = "CIV_F";
                };
            };
        };

};