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
            class enableInteraction
            {
                displayName = "Enable Interaction";
                description = "Enable advanced interaction with civilians";
                class values
                {
                    class Yes {
                        name = "Yes";
                        value = true;
                    };

                    class No {
                        name = "No";
                        value = false;
                        default = 1;
                    };
                };
            };
            class limitInteraction
            {
                    displayName = "Limit Interaction";
                    description = "To limit civilian interaction to specific classes or playes, Specify the classnames or player IDs here. i.e. ['B_Officer_F','123456789']";
                    defaultvalue = "";
            };
            class insurgentFaction
            {
                    displayName = "Insurgent Faction";
                    description = "Specify the faction that civilians will inform on to players during interactions.";
                    defaultvalue = "";
            };
            class ambientCrowdSpawn
            {
                    displayName = "$STR_ALIVE_CIV_POP_CROWD_SPAWN_RADIUS";
                    description = "$STR_ALIVE_CIV_POP_CROWD_SPAWN_RADIUS_COMMENT";
                    defaultvalue = "50";
            };
            class ambientCrowdDensity
            {
                    displayName = "$STR_ALIVE_CIV_POP_CROWD_DENSITY";
                    description = "$STR_ALIVE_CIV_POP_CROWD_DENSITY_COMMENT";
                    defaultvalue = "3";
            };
            class ambientCrowdLimit
            {
                    displayName = "$STR_ALIVE_CIV_POP_CROWD_ACTIVE_LIMITER";
                    description = "$STR_ALIVE_CIV_POP_CROWD_ACTIVE_LIMITER_COMMENT";
                    defaultvalue = "50";
            };
            class ambientCrowdFaction
            {
                    displayName = "$STR_ALIVE_CIV_POP_CROWD_FACTION";
                    description = "$STR_ALIVE_CIV_POP_CROWD_FACTION_COMMENT";
                    defaultvalue = "";
            };
            class humanitarianHostilityChance
            {
                displayName = "$STR_ALIVE_CIV_POP_HOSTILITY_CHANCE";
                description = "$STR_ALIVE_CIV_POP_HOSTILITY_CHANCE_COMMENT";
                class Values
                  {
                          class LOW
                          {
                                  name = "Low Chance";
                                  value = "20";
                                  default = 1;
                          };
                          class MEDIUM
                          {
                                  name = "Medium Chance";
                                  value = "40";
                          };
                          class HIGH
                          {
                                  name = "High Chance";
                                  value = "60";
                          };
                          class EXTREME
                          {
                                  name = "Extreme Chance";
                                  value = "80";
                          };
                  };
            };
            class maxAllowAid
            {
                displayName = "$STR_ALIVE_CIV_POP_MAX_ALLOWED_AID";
                description = "$STR_ALIVE_CIV_POP_MAX_ALLOWED_AID_COMMENT";
                defaultvalue = "3";
            };
            class disableACEX
            {
                displayName = "$STR_ALIVE_CIV_POP_ACEX_COMPAT";
                description = "$STR_ALIVE_CIV_POP_ACEX_COMPAT_COMMENT";
                typeName = "BOOL";
                defaultValue = 0;
            };  
        };

    };

    class Item_Base_F;
    class ALiVE_Waterbottle_Item: Item_Base_F
    {
        scope = 2;
        scopeCurator = 2;
        displayName = "ALiVE Water Bottle (Full)";
        author = "ALiVE Mod";
        vehicleClass = "Items";
        class TransportItems {
                class ALiVE_Waterbottle {
                        name = "ALiVE_Waterbottle";
                        count = 1;
                }; 
        };
    };
    class ALiVE_Humrat_Item: Item_Base_F
    {
        scope = 2;
        scopeCurator = 2;
        displayName = "ALiVE Rice Pack";
        author = "ALiVE Mod";
        vehicleClass = "Items";
        class TransportItems {
                class ALiVE_Humrat {
                        name = "ALiVE_Humrat";
                        count = 1;
                }; 
        };
    };

    class NATO_Box_Base;
    class ALiVE_Humanitarian_Crates: NATO_Box_Base
    {
        scope = 2;
        accuracy = 1;
        displayName = "ALiVE Humanitarian Crate";
        transportMaxItems = 2000;
        maximumload = 2000;
        model = "\A3\weapons_F\AmmoBoxes\WpnsBox_large_F";
        editorPreview = "\A3\EditorPreviews_F\Data\CfgVehicles\Box_NATO_WpsSpecial_F.jpg";
        class TransportItems {
                MACRO_ADDITEM(ALiVE_Waterbottle,100);
                MACRO_ADDITEM(ALiVE_Humrat,100);
        };
    };
};