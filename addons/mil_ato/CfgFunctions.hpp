class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class ATO {
                                description = "The main class";
                                file = "\x\alive\addons\mil_ato\fnc_ATO.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class ATOInit {
                                description = "The module initialisation function";
                                file = "\x\alive\addons\mil_ato\fnc_ATOInit.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class ATOGlobalRegistry {
                                description = "Handles global module registry and forcepools";
                                file = "\x\alive\addons\mil_ato\fnc_ATOGlobalRegistry.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class ATOLoadData {
                                description = "Load persistent data";
                                file = "\x\alive\addons\mil_ato\fnc_ATOLoadData.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class ATOSaveData {
                                description = "Save persistent data";
                                file = "\x\alive\addons\mil_ato\fnc_ATOSaveData.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class ATOLedger {
                                description = "The airframe record set and the only campaign store they have";
                                file = "\x\alive\addons\mil_ato\fnc_ATOLedger.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class ATOSurface {
                                description = "Where an airframe may stand, and how it gets on and off the ground";
                                file = "\x\alive\addons\mil_ato\fnc_ATOSurface.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class ATOMachine {
                                description = "The airframe state table. Pure: no side effects, no object access";
                                file = "\x\alive\addons\mil_ato\fnc_ATOMachine.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class ATOObserve {
                                description = "Reads the world and reports what an airframe actually is right now";
                                file = "\x\alive\addons\mil_ato\fnc_ATOObserve.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class ATOEffect {
                                description = "Applies an effect to an airframe, idempotently";
                                file = "\x\alive\addons\mil_ato\fnc_ATOEffect.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class ATOPlace {
                                description = "Adopts airframes and puts them on the ground";
                                file = "\x\alive\addons\mil_ato\fnc_ATOPlace.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class ATOTask {
                                description = "Chooses which airframe answers a request";
                                file = "\x\alive\addons\mil_ato\fnc_ATOTask.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class ATOWatch {
                                description = "Watches the airspace and raises the component's own requests";
                                file = "\x\alive\addons\mil_ato\fnc_ATOWatch.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class ATOResupply {
                                description = "Orders and adopts replacements for lost airframes";
                                file = "\x\alive\addons\mil_ato\fnc_ATOResupply.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class ATOBase {
                                description = "Establishes the component's base and airspace";
                                file = "\x\alive\addons\mil_ato\fnc_ATOBase.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class ATOKernel {
                                description = "The kernel and the bus: owns the logic, wires the pieces, drives them";
                                file = "\x\alive\addons\mil_ato\fnc_ATOKernel.sqf";
                                ALIVE_RECOMPILE;
                        };
                };
        };
};
