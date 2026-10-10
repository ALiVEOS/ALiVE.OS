class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class combatSupportFncInit {
                                description = "The main class";
                                file = "\x\alive\addons\sup_combatsupport\fnc_combatSupportFncInit.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class combatSupport {
                                description = "The main class";
                                file = "\x\alive\addons\sup_combatsupport\fnc_combatSupport.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class combatSupportInit {
                                description = "The module initialisation function";
                                file = "\x\alive\addons\sup_combatsupport\fnc_combatSupportInit.sqf";
                                ALIVE_RECOMPILE;
                        };
                          class radioAction {
                                description = "The module Radio Action function";
                                file = "\x\alive\addons\sup_combatsupport\fnc_radioAction.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class combatSupportMenuDef {
                                description = "The module menu definition";
                                file = "\x\alive\addons\sup_combatsupport\fnc_combatSupportMenuDef.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class combatSupportAddClientMenu {
                                description = "Installs the CS client menu + actions on the local player (module init + JIP fallback)";
                                file = "\x\alive\addons\sup_combatsupport\fnc_combatSupportAddClientMenu.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class combatSupportIsOperator {
                                description = "Returns whether the local player may operate Combat Support (all-players mode, or holds the per-side operator slot)";
                                file = "\x\alive\addons\sup_combatsupport\fnc_combatSupportIsOperator.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class packMortar {
                                description = "Enables a group to pack a mortar";
                                file = "\x\alive\addons\sup_combatsupport\fnc_packMortar.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class unpackMortar {
                                description = "Enables a group to unpack a mortar";
                                file = "\x\alive\addons\sup_combatsupport\fnc_unpackMortar.sqf";
                                ALIVE_RECOMPILE;
                        };
                          class combatSupportAdd {
                                description = "Adds Combat Support unit via script";
                                file = "\x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_supportAdd.sqf";
                                ALIVE_RECOMPILE;
                        };
                           class combatSupportRemove{
                                description = "Removes Combat Support unit via script";
                                file = "\x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_supportRemove.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class resupplyWatchdog {
                                description = "Monitors support assets and dispatches LOGCOM resupply when thresholds are reached";
                                file = "\x\alive\addons\sup_combatsupport\fnc_resupplyWatchdog.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class resupplyService {
                                description = "Performs rearm, refuel, and repair on a support asset";
                                file = "\x\alive\addons\sup_combatsupport\fnc_resupplyService.sqf";
                                ALIVE_RECOMPILE;
                        };
                };
        };
};

