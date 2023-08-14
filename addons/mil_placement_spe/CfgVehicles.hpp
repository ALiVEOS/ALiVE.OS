class CfgVehicles {
        class ModuleAliveBase;
        class ADDON : ModuleAliveBase
        {
                scope = 2;
                displayName = "$STR_ALIVE_SPEMP";
                function = "ALIVE_fnc_SPEMPInit";
                author = MODULE_AUTHOR;
                functionPriority = 100;
                isGlobal = 1;
                icon = "x\alive\addons\mil_placement_spe\icon_mil_SPEMP.paa";
                picture = "x\alive\addons\mil_placement_spe\icon_mil_SPEMP.paa";
                class Arguments
                {
                        class debug
                        {
                                displayName = "$STR_ALIVE_SPEMP_DEBUG";
                                description = "$STR_ALIVE_SPEMP_DEBUG_COMMENT";
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
                                displayName = "$STR_ALIVE_SPEMP_FACTION";
                                description = "$STR_ALIVE_SPEMP_FACTION_COMMENT";
                                defaultValue = "SPE_US_ARMY";
                        };
                        class priority
                        {
                                displayName = "$STR_ALIVE_SPEMP_PRIORITY";
                                description = "$STR_ALIVE_SPEMP_PRIORITY_COMMENT";
                                defaultValue = "50";
                        };
                        class size
                        {
                                displayName = "$STR_ALIVE_SPEMP_SIZE";
                                description = "$STR_ALIVE_SPEMP_SIZE_COMMENT";
                                defaultValue = "50";
                        };
                        class speInfantryClass
                        {
                                displayName = "$STR_ALIVE_SPEMP_CUSTOM_INFANTRY_CLASS";
                                description = "$STR_ALIVE_SPEMP_CUSTOM_INFANTRY_CLASS_COMMENT";
                                defaultValue = "";
                        };
                        class speInfantryBehaviour
                        {
                                displayName = "$STR_ALIVE_SPEMP_CUSTOM_INFANTRY_BEHAVIOUR";
                                description = "$STR_ALIVE_SPEMP_CUSTOM_INFANTRY_BEHAVIOUR_COMMENT";
                                class Values
                                {
                                        class AWARE
                                        {
                                                name = "Aware";
                                                value = "AWARE";
                                                default = 1;
                                        };
                                        class COMBAT
                                        {
                                                name = "Combat";
                                                value = "COMBAT";
                                        };
                                        class STEALTH
                                        {
                                                name = "Stealth";
                                                value = "STEALTH";
                                        };
                                        class SAFE
                                        {
                                                name = "Safe";
                                                value = "SAFE";
                                        };
                                        class CARELESS
                                        {
                                                name = "Careless";
                                                value = "CARELESS";
                                        };
      
                                };
                        };
                        class speVehicleClass
                        {
                                displayName = "$STR_ALIVE_SPEMP_CUSTOM_VEHICLE_CLASS";
                                description = "$STR_ALIVE_SPEMP_CUSTOM_VEHICLE_CLASS_COMMENT";
                                defaultValue = "";
                        };
                        class allowPlayerTasking
                        {
                            displayName = "$STR_ALIVE_SPEMP_ALLOW_PLAYER_TASK";
                            description = "$STR_ALIVE_SPEMP_ALLOW_PLAYER_TASK_COMMENT";
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
                };
                class ModuleDescription
                {
                    //description = "$STR_ALIVE_OPCOM_COMMENT"; // Short description, will be formatted as structured text
                    description[] = {
                            "$STR_ALIVE_SPEMP_COMMENT",
                            "",
                            "$STR_ALIVE_SPEMP_USAGE"
                    };
                    sync[] = {"ALiVE_mil_OPCOM","ALiVE_mil_CQB"}; // Array of synced entities (can contain base classes)

                    class ALiVE_mil_OPCOM
                    {
                        description[] = { // Multi-line descriptions are supported
                            "$STR_ALIVE_OPCOM_COMMENT",
                            "",
                            "$STR_ALIVE_OPCOM_USAGE"
                        };
                        position = 1; // Position is taken into effect
                        direction = 1; // Direction is taken into effect
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
                        position = 1; // Position is taken into effect
                        direction = 1; // Direction is taken into effect
                        optional = 1; // Synced entity is optional
                        duplicate = 1; // Multiple entities of this type can be synced
                    };
                };
        };
};
