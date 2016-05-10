class CfgVehicles {
        class ModuleAliveBase;
        class ADDON : ModuleAliveBase
        {
                scope = 2;
                displayName = "$STR_ALIVE_CP";
                function = "ALIVE_fnc_CPInit";
                author = MODULE_AUTHOR;
				functionPriority = 100;
                isGlobal = 1;
				icon = "x\alive\addons\civ_placement\icon_civ_CP.paa";
				picture = "x\alive\addons\civ_placement\icon_civ_CP.paa";
                class Arguments
                {
                        class debug
                        {
                                displayName = "$STR_ALIVE_CP_DEBUG";
                                description = "$STR_ALIVE_CP_DEBUG_COMMENT";
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
						class taor
                        {
                                displayName = "$STR_ALIVE_CP_TAOR";
                                description = "$STR_ALIVE_CP_TAOR_COMMENT";
                                defaultValue = "";
                        };
                        class blacklist
                        {
                                displayName = "$STR_ALIVE_CP_BLACKLIST";
                                description = "$STR_ALIVE_CP_BLACKLIST_COMMENT";
                                defaultValue = "";
                        };
                        class clusterType
                        {
                                displayName = "$STR_ALIVE_CP_CLUSTER_TYPE";
                                description = "$STR_ALIVE_CP_CLUSTER_TYPE_COMMENT";
                                class Values
                                {
                                        class ALL
                                        {
                                                name = "$STR_ALIVE_CP_CLUSTER_TYPE_ALL";
                                                value = "All";
                                                default = 1;
                                        };
                                        class HQ
                                        {
                                                name = "$STR_ALIVE_CP_CLUSTER_TYPE_HQ";
                                                value = "HQ";
                                        };
                                        class POWER
                                        {
                                                name = "$STR_ALIVE_CP_CLUSTER_TYPE_POWER";
                                                value = "Power";
                                        };
                                        class COMMS
                                        {
                                                name = "$STR_ALIVE_CP_CLUSTER_TYPE_COMMS";
                                                value = "Comms";
                                        };
                                        class FUEL
                                        {
                                                name = "$STR_ALIVE_CP_CLUSTER_TYPE_FUEL";
                                                value = "Fuel";
                                        };
                                        class MARINE
                                        {
                                                name = "$STR_ALIVE_CP_CLUSTER_TYPE_MARINE";
                                                value = "Marine";
                                        };
                                        class CONSTRUCTION
                                        {
                                                name = "$STR_ALIVE_CP_CLUSTER_TYPE_CONSTRUCTION";
                                                value = "Construction";
                                        };
                                        class SETTLEMENT
                                        {
                                                name = "$STR_ALIVE_CP_CLUSTER_TYPE_SETTLEMENT";
                                                value = "Settlement";
                                        };
                                };
                        };
						class sizeFilter
                        {
                                displayName = "$STR_ALIVE_CP_SIZE_FILTER";
                                description = "$STR_ALIVE_CP_SIZE_FILTER_COMMENT";
                                class Values
                                {
                                        class NONE
                                        {
                                                name = "$STR_ALIVE_CP_SIZE_FILTER_NONE";
                                                value = "160";
                                        };
                                        class SMALL
                                        {
                                                name = "$STR_ALIVE_CP_SIZE_FILTER_SMALL";
                                                value = "250";
                                                default = 1;
                                        };
										class MEDIUM
                                        {
                                                name = "$STR_ALIVE_CP_SIZE_FILTER_MEDIUM";
                                                value = "400";
                                        };
										class LARGE
                                        {
                                                name = "$STR_ALIVE_CP_SIZE_FILTER_LARGE";
                                                value = "700";
                                        };
                                };
                        };
						class priorityFilter
                        {
                                displayName = "$STR_ALIVE_CP_PRIORITY_FILTER";
                                description = "$STR_ALIVE_CP_PRIORITY_FILTER_COMMENT";
                                class Values
                                {
                                        class NONE
                                        {
                                                name = "$STR_ALIVE_CP_PRIORITY_FILTER_NONE";
                                                value = "0";
                                                default = 1;
                                        };
                                        class LOW
                                        {
                                                name = "$STR_ALIVE_CP_PRIORITY_FILTER_LOW";
                                                value = "10";
                                        };
										class MEDIUM
                                        {
                                                name = "$STR_ALIVE_CP_PRIORITY_FILTER_MEDIUM";
                                                value = "30";
                                        };
										class HIGH
                                        {
                                                name = "$STR_ALIVE_CP_PRIORITY_FILTER_HIGH";
                                                value = "40";
                                        };
                                };
                        };
						class withPlacement
                        {
                                displayName = "$STR_ALIVE_CP_PLACEMENT";
                                description = "$STR_ALIVE_CP_PLACEMENT_COMMENT";
                                class Values
                                {
                                         class Yes
                                        {
                                                name = "$STR_ALIVE_CP_PLACEMENT_YES";
                                                value = true;
                                                default = 1;
                                        };
                                        class No
                                        {
                                                name = "$STR_ALIVE_CP_PLACEMENT_NO";
                                                value = false;
                                        };
                                };
                        };
						class size
                        {
                                displayName = "$STR_ALIVE_CP_SIZE";
                                description = "$STR_ALIVE_CP_SIZE_COMMENT";
                                class Values
                                {
										class BNx3
                                        {
                                                name = "$STR_ALIVE_CP_SIZE_BNx3";
                                                value = 1200;
                                        };
										class BNx2
                                        {
                                                name = "$STR_ALIVE_CP_SIZE_BNx2";
                                                value = 800;
                                        };
                                        class BN
                                        {
                                                name = "$STR_ALIVE_CP_SIZE_BN";
                                                value = 400;
                                        };
										class CYx2
                                        {
                                                name = "$STR_ALIVE_CP_SIZE_CYx2";
                                                value = 200;
												default = 1;
                                        };
                                        class CY
                                        {
                                                name = "$STR_ALIVE_CP_SIZE_CY";
                                                value = 100;
                                        };
										class PLx2
                                        {
                                                name = "$STR_ALIVE_CP_SIZE_PLx2";
                                                value = 60;
                                        };
                                        class PL
                                        {
                                                name = "$STR_ALIVE_CP_SIZE_PL";
                                                value = 30;
                                        };
                                };
                        };
                        class type
                        {
                                displayName = "$STR_ALIVE_CP_TYPE";
                                description = "$STR_ALIVE_CP_TYPE_COMMENT";
                                class Values
                                {
                                        class RANDOM
                                        {
                                                name = "$STR_ALIVE_CP_TYPE_RANDOM";
                                                value = "Random";
												default = 1;
                                        };
                                        class ARMOR
                                        {
                                                name = "$STR_ALIVE_CP_TYPE_ARMOR";
                                                value = "Armored";
                                        };
                                        class MECH
                                        {
                                                name = "$STR_ALIVE_CP_TYPE_MECH";
                                                value = "Mechanized";
                                        };
                                        class MOTOR
                                        {
                                                name = "$STR_ALIVE_CP_TYPE_MOTOR";
                                                value = "Motorized";
                                        };
                                        class LIGHT
                                        {
                                                name = "$STR_ALIVE_CP_TYPE_LIGHT";
                                                value = "Infantry";
                                        };
                                        /*
                                        class AIRBORNE
                                        {
                                                name = "$STR_ALIVE_CP_TYPE_AIRBORNE";
                                                value = "Air";
                                        };
                                        */
                                        class SPECOPS
                                        {
                                                name = "$STR_ALIVE_CP_TYPE_SPECOPS";
                                                value = "Specops";
                                        };
                                };
                        };
                        class readinessLevel
                        {
                                displayName = "$STR_ALIVE_CP_READINESS_LEVEL";
                                description = "$STR_ALIVE_CP_READINESS_LEVEL_COMMENT";
                                class Values
                                {
                                        class NONE
                                        {
                                                name = "100%";
                                                value = "1";
                                                default = 1;
                                        };
                                        class HIGH
                                        {
                                                name = "75%";
                                                value = "0.75";
                                        };
										class MEDIUM
                                        {
                                                name = "50%";
                                                value = "0.5";
                                        };
										class LOW
                                        {
                                                name = "25%";
                                                value = "0.25";
                                        };
                                };
                        };
                       	class roadblocks
                        {
                                displayName = "$STR_ALIVE_CP_ROADBLOCKS";
                                description = "$STR_ALIVE_CP_ROADBLOCKS_COMMENT";
                                class Values
                                {
                                        class NONE
                                        {
                                                name = "None";
                                                value = "0";
                                                default = 1;
                                        };
                                        class All
                                        {
                                                name = "All";
                                                value = "100";
                                        };
                                        class EXTREME
                                        {
                                                name = "Extreme";
                                                value = "75";
                                        };
                                        class HIGH
                                        {
                                                name = "High";
                                                value = "50";
                                        };
										class MEDIUM
                                        {
                                                name = "Medium";
                                                value = "35";
                                        };
										class LOW
                                        {
                                                name = "low";
                                                value = "15";
                                        };
                                };
                        };
                        class placeSeaPatrols
                        {
                                displayName = "$STR_ALIVE_CP_PLACE_SEAPATROLS";
                                description = "$STR_ALIVE_CP_PLACE_SEAPATROLS_COMMENT";
                                typeName = "NUMBER";
                                class Values
                                {
                                        class NONE
                                        {
                                                name = "None";
                                                value = 0;
                                                default = 1;
                                        };
                                        class All
                                        {
                                                name = "All";
                                                value = 1;
                                        };
                                        class EXTREME
                                        {
                                                name = "Extreme";
                                                value = 0.75;
                                        };
                                        class HIGH
                                        {
                                                name = "High";
                                                value = 0.5;
                                        };
                                        class MEDIUM
                                        {
                                                name = "Medium";
                                                value = 0.33;
                                        };
                                        class LOW
                                        {
                                                name = "Low";
                                                value = 0.2;
                                        };
                                };
                        };
                        class customInfantryCount
                        {
                                displayName = "$STR_ALIVE_CP_CUSTOM_INFANTRY_COUNT";
                                description = "$STR_ALIVE_CP_CUSTOM_INFANTRY_COUNT_COMMENT";
                                defaultValue = "";
                        };
                        class customMotorisedCount
                        {
                                displayName = "$STR_ALIVE_CP_CUSTOM_MOTORISED_COUNT";
                                description = "$STR_ALIVE_CP_CUSTOM_MOTORISED_COUNT_COMMENT";
                                defaultValue = "";
                        };
                        class customMechanisedCount
                        {
                                displayName = "$STR_ALIVE_CP_CUSTOM_MECHANISED_COUNT";
                                description = "$STR_ALIVE_CP_CUSTOM_MECHANISED_COUNT_COMMENT";
                                defaultValue = "";
                        };
                        class customArmourCount
                        {
                                displayName = "$STR_ALIVE_CP_CUSTOM_ARMOUR_COUNT";
                                description = "$STR_ALIVE_CP_CUSTOM_ARMOUR_COUNT_COMMENT";
                                defaultValue = "";
                        };
                        class customSpecOpsCount
                        {
                                displayName = "$STR_ALIVE_CP_CUSTOM_SPECOPS_COUNT";
                                description = "$STR_ALIVE_CP_CUSTOM_SPECOPS_COUNT_COMMENT";
                                defaultValue = "";
                        };
                        class faction
                        {
                                displayName = "$STR_ALIVE_CP_FACTION";
                                description = "$STR_ALIVE_CP_FACTION_COMMENT";
                                defaultValue = "OPF_F";
                        };
                };
                class ModuleDescription
                {
                    //description = "$STR_ALIVE_OPCOM_COMMENT"; // Short description, will be formatted as structured text
                    description[] = {
                            "$STR_ALIVE_CP_COMMENT",
                            "",
                            "$STR_ALIVE_CP_USAGE"
                    };
                    sync[] = {"ALiVE_mil_OPCOM","ALiVE_mil_CQB"}; // Array of synced entities (can contain base classes)

                    class ALiVE_mil_OPCOM
                    {
                        description[] = { // Multi-line descriptions are supported
                            "$STR_ALIVE_OPCOM_COMMENT",
                            "",
                            "$STR_ALIVE_OPCOM_USAGE"
                        };
                        position = 0; // Position is taken into effect
                        direction = 0; // Direction is taken into effect
                        optional = 1; // Synced entity is optional
                        duplicate = 1; // Multiple entities of this type can be synced
                    };
                    class ALiVE_mil_CQB
                    {
                        description[] = { // Multi-line descriptions are supported
                            "$STR_ALIVE_CQB_COMMENT",
                            "",
                            "$STR_ALIVE_CQB_USAGE"
                        };
                        position = 0; // Position is taken into effect
                        direction = 0; // Direction is taken into effect
                        optional = 1; // Synced entity is optional
                        duplicate = 1; // Multiple entities of this type can be synced
                    };
                };
        };
};
