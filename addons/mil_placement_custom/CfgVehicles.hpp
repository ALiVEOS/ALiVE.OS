class CfgVehicles {
        class ModuleAliveBase;
        class ADDON : ModuleAliveBase
        {
                scope = 2;
                displayName = "$STR_ALIVE_CMP";
                function = "ALIVE_fnc_CMPInit";
                author = MODULE_AUTHOR;
                functionPriority = 100;
                isGlobal = 1;
                icon = "x\alive\addons\mil_placement_custom\icon_mil_CMP.paa";
                picture = "x\alive\addons\mil_placement_custom\icon_mil_CMP.paa";
                class Arguments
                {
                        class debug
                        {
                                displayName = "$STR_ALIVE_CMP_DEBUG";
                                description = "$STR_ALIVE_CMP_DEBUG_COMMENT";
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
                        class faction
                        {
                                displayName = "$STR_ALIVE_CMP_FACTION";
                                description = "$STR_ALIVE_CMP_FACTION_COMMENT";
                                defaultValue = "OPF_F";
                        };
                        class priority
                        {
                                displayName = "$STR_ALIVE_CMP_PRIORITY";
                                description = "$STR_ALIVE_CMP_PRIORITY_COMMENT";
                                defaultValue = "50";
                        };
                        class size
                        {
                                displayName = "$STR_ALIVE_CMP_SIZE";
                                description = "$STR_ALIVE_CMP_SIZE_COMMENT";
                                defaultValue = "50";
                        };
                        class customInfantryCount
                        {
                                displayName = "$STR_ALIVE_CMP_CUSTOM_INFANTRY_COUNT";
                                description = "$STR_ALIVE_CMP_CUSTOM_INFANTRY_COUNT_COMMENT";
                                defaultValue = "0";
                        };
                        class customMotorisedCount
                        {
                                displayName = "$STR_ALIVE_CMP_CUSTOM_MOTORISED_COUNT";
                                description = "$STR_ALIVE_CMP_CUSTOM_MOTORISED_COUNT_COMMENT";
                                defaultValue = "0";
                        };
                        class customMechanisedCount
                        {
                                displayName = "$STR_ALIVE_CMP_CUSTOM_MECHANISED_COUNT";
                                description = "$STR_ALIVE_CMP_CUSTOM_MECHANISED_COUNT_COMMENT";
                                defaultValue = "0";
                        };
                        class customArmourCount
                        {
                                displayName = "$STR_ALIVE_CMP_CUSTOM_ARMOUR_COUNT";
                                description = "$STR_ALIVE_CMP_CUSTOM_ARMOUR_COUNT_COMMENT";
                                defaultValue = "0";
                        };
                        class customSpecOpsCount
                        {
                                displayName = "$STR_ALIVE_CMP_CUSTOM_SPECOPS_COUNT";
                                description = "$STR_ALIVE_CMP_CUSTOM_SPECOPS_COUNT_COMMENT";
                                defaultValue = "0";
                        };
                        class readinessLevel
                        {
                                displayName = "$STR_ALIVE_CMP_READINESS_LEVEL";
                                description = "$STR_ALIVE_CMP_READINESS_LEVEL_COMMENT";
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
                        class composition
                        {
                                displayName = "$STR_ALIVE_CMP_COMPOSITION";
                                description = "$STR_ALIVE_CMP_COMPOSITION_COMMENT";
                                defaultValue = "";
                        };
                        class createHQ
                        {
                                displayName = "$STR_ALIVE_MP_CREATE_HQ";
                                description = "$STR_ALIVE_MP_CREATE_HQ_COMMENT";
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
                         class placeHelis
                        {
                                displayName = "$STR_ALIVE_MP_PLACE_HELI";
                                description = "$STR_ALIVE_MP_PLACE_HELI_COMMENT";
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
                        class placeSupplies
                        {
                                displayName = "$STR_ALIVE_MP_PLACE_SUPPLIES";
                                description = "$STR_ALIVE_MP_PLACE_SUPPLIES_COMMENT";
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
                        class ambientVehicleAmount
                        {
                                displayName = "$STR_ALIVE_MP_AMBIENT_VEHICLE_AMOUNT";
                                description = "$STR_ALIVE_MP_AMBIENT_VEHICLE_AMOUNT_COMMENT";
                                class Values
                                {
                                        class NONE
                                        {
                                                name = "$STR_ALIVE_MP_AMBIENT_VEHICLE_AMOUNT_NONE";
                                                value = "0";
                                                default = 1;
                                        };
                                        class LOW
                                        {
                                                name = "$STR_ALIVE_MP_AMBIENT_VEHICLE_AMOUNT_LOW";
                                                value = "0.2";
                                        };
                                        class MEDIUM
                                        {
                                                name = "$STR_ALIVE_MP_AMBIENT_VEHICLE_AMOUNT_MEDIUM";
                                                value = "0.6";
                                        };
                                        class HIGH
                                        {
                                                name = "$STR_ALIVE_MP_AMBIENT_VEHICLE_AMOUNT_HIGH";
                                                value = "1";
                                        };
                                };
                        };
                };
                class ModuleDescription
                {
                    //description = "$STR_ALIVE_OPCOM_COMMENT"; // Short description, will be formatted as structured text
                    description[] = {
                            "$STR_ALIVE_CMP_COMMENT",
                            "",
                            "$STR_ALIVE_CMP_USAGE"
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
