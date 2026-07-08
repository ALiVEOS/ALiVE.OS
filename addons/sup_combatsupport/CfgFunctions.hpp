class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class combatSupportFncInit {
                                description = "The main class";
                                file = "\x\alive\addons\sup_combatsupport\fnc_combatSupportFncInit.sqf";
                                RECOMPILE;
                        };
                        class combatSupport {
                                description = "The main class";
                                file = "\x\alive\addons\sup_combatsupport\fnc_combatSupport.sqf";
                                RECOMPILE;
                        };
                        class combatSupportInit {
                                description = "The module initialisation function";
                                file = "\x\alive\addons\sup_combatsupport\fnc_combatSupportInit.sqf";
                                RECOMPILE;
                        };
                          class radioAction {
                                description = "The module Radio Action function";
                                file = "\x\alive\addons\sup_combatsupport\fnc_radioAction.sqf";
                                RECOMPILE;
                        };
                        class combatSupportMenuDef {
                                description = "The module menu definition";
                                file = "\x\alive\addons\sup_combatsupport\fnc_combatSupportMenuDef.sqf";
                                RECOMPILE;
                        };
                        class combatSupportAddClientMenu {
                                description = "Installs the CS client menu + actions on the local player (module init + JIP fallback)";
                                file = "\x\alive\addons\sup_combatsupport\fnc_combatSupportAddClientMenu.sqf";
                                RECOMPILE;
                        };
                        class combatSupportIsOperator {
                                description = "Returns whether the local player may operate Combat Support (all-players mode, or holds the per-side operator slot)";
                                file = "\x\alive\addons\sup_combatsupport\fnc_combatSupportIsOperator.sqf";
                                RECOMPILE;
                        };
                        class packMortar {
                                description = "Enables a group to pack a mortar";
                                file = "\x\alive\addons\sup_combatsupport\fnc_packMortar.sqf";
                                RECOMPILE;
                        };
                        class unpackMortar {
                                description = "Enables a group to unpack a mortar";
                                file = "\x\alive\addons\sup_combatsupport\fnc_unpackMortar.sqf";
                                RECOMPILE;
                        };
                          class combatSupportAdd {
                                description = "Adds Combat Support unit via script";
                                file = "\x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_supportAdd.sqf";
                                RECOMPILE;
                        };
                           class combatSupportRemove{
                                description = "Removes Combat Support unit via script";
                                file = "\x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_supportRemove.sqf";
                                RECOMPILE;
                        };
                        class resupplyWatchdog {
                                description = "Monitors support assets and dispatches LOGCOM resupply when thresholds are reached";
                                file = "\x\alive\addons\sup_combatsupport\fnc_resupplyWatchdog.sqf";
                                RECOMPILE;
                        };
                        class resupplyService {
                                description = "Performs rearm, refuel, and repair on a support asset";
                                file = "\x\alive\addons\sup_combatsupport\fnc_resupplyService.sqf";
                                RECOMPILE;
                        };
                };
        };
};

