class CfgVehicles {
        class ModuleAliveBase;
        class ADDON : ModuleAliveBase
        {
                scope = 2;
                displayName = "$STR_ALIVE_CIV_POP";
                function = "ALIVE_fnc_civilianPopulationSystemInit";
                author = MODULE_AUTHOR;
                functionPriority = 70;
                isGlobal = 2;
				icon = "x\alive\addons\amb_civ_population\icon_civ_pop.paa";
				picture = "x\alive\addons\amb_civ_population\icon_civ_pop.paa";
                class Arguments
                {
                        class debug
                        {
                                displayName = "$STR_ALIVE_CIV_POP_DEBUG";
                                description = "$STR_ALIVE_CIV_POP_DEBUG_COMMENT";
                                class Values
                                {
                                        class Yes
                                        {
                                                name = "Yes";
                                                value = true;
                                        };
                                        class No
                                        {
                                                name = "No";
                                                value = false;
                                                default = 1;
                                        };
                                };
                        };
						class spawnRadius
                        {
                                displayName = "$STR_ALIVE_CIV_POP_SPAWN_RADIUS";
                                description = "$STR_ALIVE_CIV_POP_SPAWN_RADIUS_COMMENT";
								defaultvalue = "900";
                        };
                        class spawnTypeHeliRadius
                        {
                                displayName = "$STR_ALIVE_CIV_POP_SPAWN_HELI_RADIUS";
                                description = "$STR_ALIVE_CIV_POP_SPAWN_HELI_RADIUS_COMMENT";
                                defaultvalue = "900";
                        };
                        class spawnTypeJetRadius
                        {
                                displayName = "$STR_ALIVE_CIV_POP_SPAWN_JET_RADIUS";
                                description = "$STR_ALIVE_CIV_POP_SPAWN_JET_RADIUS_COMMENT";
                                defaultvalue = "0";
                        };
                        class activeLimiter
                        {
                                displayName = "$STR_ALIVE_CIV_POP_ACTIVE_LIMITER";
                                description = "$STR_ALIVE_CIV_POP_ACTIVE_LIMITER_COMMENT";
                                defaultvalue = "25";
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
                                                default = 1;
                                        };
                                        class MEDIUM
                                        {
                                                name = "$STR_ALIVE_CIV_POP_HOSTILITY_WEST_MEDIUM";
                                                value = "30";
                                        };
                                        class HIGH
                                        {
                                                name = "$STR_ALIVE_CIV_POP_HOSTILITY_WEST_HIGH";
                                                value = "60";
                                        };
                                        class EXTREME
                                        {
                                                name = "$STR_ALIVE_CIV_POP_HOSTILITY_WEST_EXTREME";
                                                value = "130";
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
                                              default = 1;
                                      };
                                      class MEDIUM
                                      {
                                              name = "$STR_ALIVE_CIV_POP_HOSTILITY_EAST_MEDIUM";
                                              value = "30";
                                      };
                                      class HIGH
                                      {
                                              name = "$STR_ALIVE_CIV_POP_HOSTILITY_EAST_HIGH";
                                              value = "60";
                                      };
                                      class EXTREME
                                      {
                                              name = "$STR_ALIVE_CIV_POP_HOSTILITY_EAST_EXTREME";
                                              value = "130";
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
                                              default = 1;
                                      };
                                      class MEDIUM
                                      {
                                              name = "$STR_ALIVE_CIV_POP_HOSTILITY_INDEP_MEDIUM";
                                              value = "30";
                                      };
                                      class HIGH
                                      {
                                              name = "$STR_ALIVE_CIV_POP_HOSTILITY_INDEP_HIGH";
                                              value = "60";
                                      };
                                      class EXTREME
                                      {
                                              name = "$STR_ALIVE_CIV_POP_HOSTILITY_INDEP_EXTREME";
                                              value = "130";
                                      };
                              };
                        };
                        class ambientCivilianRoles
                        {
                                displayName = "$STR_ALIVE_CIV_POP_CIVILIAN_ROLES";
                                description = "$STR_ALIVE_CIV_POP_CIVILIAN_ROLES_COMMENT";
                                class Values
                                {
                                        class NONE
                                        {
                                                name = "$STR_ALIVE_CIV_POP_CIVILIAN_ROLES_NONE";
                                                value = [];
                                                default = 1;
                                        };
                                        class WESTERN
                                        {
                                                name = "$STR_ALIVE_CIV_POP_CIVILIAN_ROLES_WEST";
                                                value = ["major","priest","politician"];
                                        };
                                        class EASTERN
                                        {
                                                name = "$STR_ALIVE_CIV_POP_CIVILIAN_ROLES_EAST";
                                                value = ["townelder","muezzin","politician"];
                                        };
                                };
                        };
                };

        };
};