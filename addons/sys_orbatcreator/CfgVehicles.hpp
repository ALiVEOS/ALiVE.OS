class CfgVehicles {
        class ModuleAliveBase;
        class ADDON : ModuleAliveBase {
                scope = 2;
                displayName = "$STR_ALIVE_ORBATCREATOR";
                function = "ALiVE_fnc_orbatCreatorInit";
                functionPriority = 1;
                isGlobal = 2;
                icon = "x\alive\addons\sys_orbatcreator\icon_sys_orbatcreator.paa";
                picture = "x\alive\addons\sys_orbatcreator\icon_sys_orbatcreator.paa";
                author = MODULE_AUTHOR;

                class Arguments {

                    class debug {
                            displayName = "$STR_ALIVE_ORBATCREATOR_DEBUG";
                            description = "$STR_ALIVE_ORBATCREATOR_DEBUG_COMMENT";
                            class Values {
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
                    class background {
                            displayName = "$STR_ALIVE_ORBATCREATOR_BACKGROUND";
                            description = "$STR_ALIVE_ORBATCREATOR_BACKGROUND_COMMENT";
                            class Values {
                                    class Yes {
                                            name = "Yes";
                                            value = true;
                                            default = 1;
                                    };
                                    class No {
                                            name = "No";
                                            value = false;

                                    };
                            };
                    };
                };

        };
};