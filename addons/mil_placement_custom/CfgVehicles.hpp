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
                                class Values
                                {
                                        class CompNo
                                        {
                                                name = "No";
                                                value = false;
                                                default = 1;
                                        };

                                        // autogen start

                                        class smallHQOutpost1
                                        {
                                        name = "$STR_ALIVE_COMPOSITION_smallHQOutpost1";
                                        value = "smallHQOutpost1";
                                        };
                                        class largeMedicalHQ1
                                        {
                                        name = "$STR_ALIVE_COMPOSITION_largeMedicalHQ1";
                                        value = "largeMedicalHQ1";
                                        };
                                        class smallConvoyCamp1
                                        {
                                        name = "$STR_ALIVE_COMPOSITION_smallConvoyCamp1";
                                        value = "smallConvoyCamp1";
                                        };
                                        class smallMilitaryCamp1
                                        {
                                        name = "$STR_ALIVE_COMPOSITION_smallMilitaryCamp1";
                                        value = "smallMilitaryCamp1";
                                        };
                                        class smallMortarCamp1
                                        {
                                        name = "$STR_ALIVE_COMPOSITION_smallMortarCamp1";
                                        value = "smallMortarCamp1";
                                        };
                                        class mediumAACamp1
                                        {
                                        name = "$STR_ALIVE_COMPOSITION_mediumAACamp1";
                                        value = "mediumAACamp1";
                                        };
                                        class mediumMilitaryCamp1
                                        {
                                        name = "$STR_ALIVE_COMPOSITION_mediumMilitaryCamp1";
                                        value = "mediumMilitaryCamp1";
                                        };
                                        class mediumMGCamp1
                                        {
                                        name = "$STR_ALIVE_COMPOSITION_mediumMGCamp1";
                                        value = "mediumMGCamp1";
                                        };
                                        class mediumMGCamp2
                                        {
                                        name = "$STR_ALIVE_COMPOSITION_mediumMGCamp2";
                                        value = "mediumMGCamp2";
                                        };
                                        class mediumMGCamp3
                                        {
                                        name = "$STR_ALIVE_COMPOSITION_mediumMGCamp3";
                                        value = "mediumMGCamp3";
                                        };
                                        class mediumAirstation1
                                        {
                                        name = "$STR_ALIVE_COMPOSITION_mediumAirstation1";
                                        value = "mediumAirstation1";
                                        };
                                        class communicationCamp1
                                        {
                                        name = "$STR_ALIVE_COMPOSITION_communicationCamp1";
                                        value = "communicationCamp1";
                                        };
                                        class smallFuelStation1
                                        {
                                        name = "$STR_ALIVE_COMPOSITION_smallFuelStation1";
                                        value = "smallFuelStation1";
                                        };
                                        class mediumFuelSilo1
                                        {
                                        name = "$STR_ALIVE_COMPOSITION_mediumFuelSilo1";
                                        value = "mediumFuelSilo1";
                                        };
                                        class bagFenceKit1
                                        {
                                        name = "$STR_ALIVE_COMPOSITION_bagFenceKit1";
                                        value = "bagFenceKit1";
                                        };
                                        class hbarrierKit1
                                        {
                                        name = "$STR_ALIVE_COMPOSITION_hbarrierKit1";
                                        value = "hbarrierKit1";
                                        };
                                        class hbarrierKit2
                                        {
                                        name = "$STR_ALIVE_COMPOSITION_hbarrierKit2";
                                        value = "hbarrierKit2";
                                        };
                                        class hbarrierWallKit1
                                        {
                                        name = "$STR_ALIVE_COMPOSITION_hbarrierWallKit1";
                                        value = "hbarrierWallKit1";
                                        };
                                        class hbarrierWallKit2
                                        {
                                        name = "$STR_ALIVE_COMPOSITION_hbarrierWallKit2";
                                        value = "hbarrierWallKit2";
                                        };
                                        class smallOspreyCrashsite1
                                        {
                                        name = "$STR_ALIVE_COMPOSITION_smallOspreyCrashsite1";
                                        value = "smallOspreyCrashsite1";
                                        };
                                        class smallAH99Crashsite1
                                        {
                                        name = "$STR_ALIVE_COMPOSITION_smallAH99Crashsite1";
                                        value = "smallAH99Crashsite1";
                                        };
                                        class mediumc192Crash1
                                        {
                                        name = "$STR_ALIVE_COMPOSITION_mediumc192Crash1";
                                        value = "mediumc192Crash1";
                                        };
                                        class largeMilitaryOutpost1
                                        {
                                        name = "$STR_ALIVE_COMPOSITION_largeMilitaryOutpost1";
                                        value = "largeMilitaryOutpost1";
                                        };
                                        class mediumMilitaryOutpost1
                                        {
                                        name = "$STR_ALIVE_COMPOSITION_mediumMilitaryOutpost1";
                                        value = "mediumMilitaryOutpost1";
                                        };
                                        class hugeSupplyOutpost1
                                        {
                                        name = "$STR_ALIVE_COMPOSITION_hugeSupplyOutpost1";
                                        value = "hugeSupplyOutpost1";
                                        };
                                        class hugeMilitaryOutpost1
                                        {
                                        name = "$STR_ALIVE_COMPOSITION_hugeMilitaryOutpost1";
                                        value = "hugeMilitaryOutpost1";
                                        };
                                        class smallATNest1
                                        {
                                        name = "$STR_ALIVE_COMPOSITION_smallATNest1";
                                        value = "smallATNest1";
                                        };
                                        class smallMGNest1
                                        {
                                        name = "$STR_ALIVE_COMPOSITION_smallMGNest1";
                                        value = "smallMGNest1";
                                        };
                                        class smallCheckpoint1
                                        {
                                        name = "$STR_ALIVE_COMPOSITION_smallCheckpoint1";
                                        value = "smallCheckpoint1";
                                        };
                                        class smallRoadblock1
                                        {
                                        name = "$STR_ALIVE_COMPOSITION_smallRoadblock1";
                                        value = "smallRoadblock1";
                                        };
                                        class mediumCheckpoint1
                                        {
                                        name = "$STR_ALIVE_COMPOSITION_mediumCheckpoint1";
                                        value = "mediumCheckpoint1";
                                        };
                                        class largeGarbageCamp1
                                        {
                                        name = "$STR_ALIVE_COMPOSITION_largeGarbageCamp1";
                                        value = "largeGarbageCamp1";
                                        };


                                        // autogen end

                                        class CompA
                                        {
                                                name = "$STR_ALIVE_CMP_COMPOSITION_BIS_A";
                                                value = "OutpostA";
                                        };
                                        class CompB
                                        {
                                                name = "$STR_ALIVE_CMP_COMPOSITION_BIS_B";
                                                value = "OutpostB";
                                        };
                                        class CompC
                                        {
                                                name = "$STR_ALIVE_CMP_COMPOSITION_BIS_C";
                                                value = "OutpostC";
                                        };
                                        class CompD
                                        {
                                                name = "$STR_ALIVE_CMP_COMPOSITION_BIS_D";
                                                value = "OutpostD";
                                        };
                                        class CompE
                                        {
                                                name = "$STR_ALIVE_CMP_COMPOSITION_BIS_E";
                                                value = "OutpostE";
                                        };
                                        class CompF
                                        {
                                                name = "$STR_ALIVE_CMP_COMPOSITION_BIS_F";
                                                value = "OutpostF";
                                        };
                                };
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
