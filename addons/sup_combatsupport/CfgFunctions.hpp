class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class combatSupportFncInit {
                                description = "The main class";
																file = PATHTO_FUNC(combatSupportFncInit);
                                recompile = RECOMPILE;
                        };
                        class combatSupport {
                                description = "The main class";
																file = PATHTO_FUNC(combatSupport);
                                recompile = RECOMPILE;
                        };
                        class combatSupportInit {
                                description = "The module initialisation function";
																file = PATHTO_FUNC(combatSupportInit);
                                recompile = RECOMPILE;
                        };
                          class radioAction {
                                description = "The module Radio Action function";
																file = PATHTO_FUNC(radioAction);
                                recompile = RECOMPILE;
                        };
                        class combatSupportMenuDef {
                                description = "The module menu definition";
																file = PATHTO_FUNC(combatSupportMenuDef);
                                recompile = RECOMPILE;
                        };
                        class packMortar {
                                description = "Enables a group to pack a mortar";
																file = PATHTO_FUNC(packMortar);
                                recompile = RECOMPILE;
                        };
                        class unpackMortar {
                                description = "Enables a group to unpack a mortar";
																file = PATHTO_FUNC(unpackMortar);
                                recompile = RECOMPILE;
                        };
                          class combatSupportAdd {
                                description = "Adds Combat Support unit via script";
                                file = "\x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_supportAdd.sqf";
                                recompile = RECOMPILE;
                        };
                           class combatSupportRemove{
                                description = "Removes Combat Support unit via script";
                                file = "\x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_supportRemove.sqf";
                                recompile = RECOMPILE;
                        };
                };
        };
};
