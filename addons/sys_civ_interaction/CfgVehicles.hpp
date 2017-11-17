class CfgVehicles {
        class ModuleAliveBase;
        class ADDON : ModuleAliveBase {
                scope = 2;
                displayName = "$STR_ALIVE_CIVINTERACTION";
                function = "ALiVE_fnc_civInteractionInit";
                functionPriority = 1;
                isGlobal = 2;
                icon = "x\alive\addons\sys_civ_interaction\icon_sys_civ_interaction.paa";
                picture = "x\alive\addons\sys_civ_interaction\icon_sys_civ_interaction.paa";
                author = MODULE_AUTHOR;

                class Arguments {

                    class debug {
                            displayName = "$STR_ALIVE_CIVINTERACTION_DEBUG";
                            description = "$STR_ALIVE_CIVINTERACTION_DEBUG_COMMENT";
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

                };

        };
};