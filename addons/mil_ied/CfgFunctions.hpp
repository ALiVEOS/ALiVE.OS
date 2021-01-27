class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class IED {
                                description = "The main class";
                                file = "\x\alive\addons\mil_ied\fnc_ied.sqf";
                                RECOMPILE;
                        };
                        class IEDInit {
                                description = "The module initialisation function";
                                file = "\x\alive\addons\mil_ied\fnc_iedInit.sqf";
                                RECOMPILE;
                        };
                        class IEDMenuDef {
                                description = "The module menu definition";
                                file = "\x\alive\addons\mil_ied\fnc_iedMenuDef.sqf";
                                RECOMPILE;
                        };
                        class createBomber {
                                description = "Create an ambient suicide bomber";
                                file = "\x\alive\addons\mil_ied\fnc_createBomber.sqf";
                                RECOMPILE;
                        };
                        class RemoveBomber {
                                description = "Remove a suicide bomber";
                                file = "\x\alive\addons\mil_ied\fnc_removeBomber.sqf";
                                RECOMPILE;
                        };
                        class RemoveIED {
                                description = "Remove an IED";
                                file = "\x\alive\addons\mil_ied\fnc_removeIED.sqf";
                                RECOMPILE;
                        };
                        class placeIED {
                                description = "Find a suitable location for an IED";
                                file = "\x\alive\addons\mil_ied\fnc_placeIED.sqf";
                                RECOMPILE;
                        };
                        class placeVBIED {
                                description = "Find a suitable location for an IED";
                                file = "\x\alive\addons\mil_ied\fnc_placeVBIED.sqf";
                                                                RECOMPILE;
                        };
                        class armIED {
                                description = "Arm an IED";
                                file = "\x\alive\addons\mil_ied\fnc_armIED.sqf";
                                RECOMPILE;
                        };
                        class createVBIED {
                                description = "Create a VB-IED";
                                file = "\x\alive\addons\mil_ied\fnc_createVBIED.sqf";
                                RECOMPILE;
                        };
                        class disarmIED {
                                description = "Disarm a IED";
                                file = "\x\alive\addons\mil_ied\fnc_disarmIED.sqf";
                                RECOMPILE;
                        };
                        class detectIED {
                                description = "Detect a IED";
                                file = "\x\alive\addons\mil_ied\fnc_detectIED.sqf";
                                RECOMPILE;
                        };
                        class createIED {
                                description = "Create an IED";
                                file = "\x\alive\addons\mil_ied\fnc_createIED.sqf";
                                RECOMPILE;
                        };
                        class addActionIED {
                                description = "Add an action to an IED";
                                file = "\x\alive\addons\mil_ied\fnc_addActionIED.sqf";
                                RECOMPILE;
                        };
                        class removeActionIED {
                                description = "Remove an action from an IED";
                                file = "\x\alive\addons\mil_ied\fnc_removeActionIED.sqf";
                                RECOMPILE;
                        };
                        class IEDLoadData {
                                description = "Load Persisted IED's";
                                file = "\x\alive\addons\mil_ied\fnc_IEDLoadData.sqf";
                                RECOMPILE;
                        };
                        class IEDSaveData {
                                description = "Save IED's to DB";
                                file = "\x\alive\addons\mil_ied\fnc_IEDSaveData.sqf";
                                RECOMPILE;
                        };
                };
        };
};
