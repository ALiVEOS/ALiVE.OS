class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class IED {
                                description = "The main class";
                                file = "\x\alive\addons\mil_ied\fnc_ied.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class IEDInit {
                                description = "The module initialisation function";
                                file = "\x\alive\addons\mil_ied\fnc_iedInit.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class IEDMenuDef {
                                description = "The module menu definition";
                                file = "\x\alive\addons\mil_ied\fnc_iedMenuDef.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class createBomber {
                                description = "Create an ambient suicide bomber";
                                file = "\x\alive\addons\mil_ied\fnc_createBomber.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class RemoveBomber {
                                description = "Remove a suicide bomber";
                                file = "\x\alive\addons\mil_ied\fnc_removeBomber.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class RemoveIED {
                                description = "Remove an IED";
                                file = "\x\alive\addons\mil_ied\fnc_removeIED.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class placeIED {
                                description = "Find a suitable location for an IED";
                                file = "\x\alive\addons\mil_ied\fnc_placeIED.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class placeVBIED {
                                description = "Find a suitable location for an IED";
                                file = "\x\alive\addons\mil_ied\fnc_placeVBIED.sqf";
                                                                ALIVE_RECOMPILE;
                        };
                        class armIED {
                                description = "Arm an IED";
                                file = "\x\alive\addons\mil_ied\fnc_armIED.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class iedUnitQualifies {
                                description = "Shared engineer/EOD qualification predicate";
                                file = "\x\alive\addons\mil_ied\fnc_iedUnitQualifies.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class createVBIED {
                                description = "Create a VB-IED";
                                file = "\x\alive\addons\mil_ied\fnc_createVBIED.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class disarmIED {
                                description = "Disarm a IED";
                                file = "\x\alive\addons\mil_ied\fnc_disarmIED.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class detectIED {
                                description = "Detect a IED";
                                file = "\x\alive\addons\mil_ied\fnc_detectIED.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class createIED {
                                description = "Create an IED";
                                file = "\x\alive\addons\mil_ied\fnc_createIED.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class addActionIED {
                                description = "Add an action to an IED";
                                file = "\x\alive\addons\mil_ied\fnc_addActionIED.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class removeActionIED {
                                description = "Remove an action from an IED";
                                file = "\x\alive\addons\mil_ied\fnc_removeActionIED.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class IEDLoadData {
                                description = "Load Persisted IED's";
                                file = "\x\alive\addons\mil_ied\fnc_IEDLoadData.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class IEDSaveData {
                                description = "Save IED's to DB";
                                file = "\x\alive\addons\mil_ied\fnc_IEDSaveData.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class IEDPlacementHelpers {
                                description = "Helper functions for terrain validation and tactical IED placement";
                                file = "\x\alive\addons\mil_ied\fnc_IEDPlacementHelpers.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class detectIEDIntegrations {
                                description = "Detect loaded 3rd-party IED integrations from Cfg3rdPartyIEDs";
                                file = "\x\alive\addons\mil_ied\fnc_detectIEDIntegrations.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class IEDLocationSource {
                                description = "Population centres to place IEDs around, from the cheapest source that answers";
                                file = "\x\alive\addons\mil_ied\fnc_IEDLocationSource.sqf";
                                ALIVE_RECOMPILE;
                        };
                        // Note: fnc_edenIntegrationChoiceLoad.sqf and
                        // fnc_edenIntegrationChoiceSave.sqf are deliberately NOT registered
                        // in CfgFunctions. CfgFunctions aren't compiled until mission
                        // preInit, but those handlers need to fire at 3DEN attribute-load
                        // time (before any mission runs). Cfg3DEN.hpp references them via
                        // `compile preprocessFileLineNumbers` instead, which works in any
                        // context.
                };
        };
};
