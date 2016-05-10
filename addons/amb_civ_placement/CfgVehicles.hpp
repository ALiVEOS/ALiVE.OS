class CfgVehicles {
        class ModuleAliveBase;
        class ADDON : ModuleAliveBase
        {
                scope = 2;
                displayName = "$STR_ALIVE_AMBCP";
                function = "ALIVE_fnc_AMBCPInit";
                author = MODULE_AUTHOR;
				functionPriority = 80;
                isGlobal = 1;
				icon = "x\alive\addons\amb_civ_placement\icon_civ_AMBCP.paa";
				picture = "x\alive\addons\amb_civ_placement\icon_civ_AMBCP.paa";
                class Arguments
                {
                        class debug
                        {
                                displayName = "$STR_ALIVE_AMBCP_DEBUG";
                                description = "$STR_ALIVE_AMBCP_DEBUG_COMMENT";
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
                                                default = 1;
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
                                                default = 1;
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
                /*
                class ModuleDescription
                {
                    //description = "$STR_ALIVE_OPCOM_COMMENT"; // Short description, will be formatted as structured text
                    description[] = {
                            "$STR_ALIVE_AMBCP_COMMENT",
                            "",
                            "$STR_ALIVE_AMBCP_USAGE"
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
                */
        };
};
