class cfgFunctions {
        class PREFIX {
                class COMPONENT {
												FUNC_FILEPATH(combatSupportFncInit,"The main class");
												FUNC_FILEPATH(combatSupport,"The main class");
												FUNC_FILEPATH(combatSupportInit,"The module initialisation function");
												FUNC_FILEPATH(radioAction,"The module Radio Action function");
												FUNC_FILEPATH(combatSupportMenuDef,"The module menu definition");
												FUNC_FILEPATH(packMortar,"Enables a group to pack a mortar");
												FUNC_FILEPATH(unpackMortar,"Enables a group to unpack a mortar");
                        class combatSupportAdd {
                          description = "Adds Combat Support unit via script";
                          file = "\x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_supportAdd.sqf";
                          recompile = RECOMPILE;
                        };
                        class combatSupportRemove {
                          description = "Removes Combat Support unit via script";
                          file = "\x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_supportRemove.sqf";
                          recompile = RECOMPILE;
                        };
                };
        };
};
