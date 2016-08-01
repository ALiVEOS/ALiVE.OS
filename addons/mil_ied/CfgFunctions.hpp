class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class IED {
                                description = "The main class";
																file = PATHTO_FUNC(ied);
                                recompile = RECOMPILE;
                        };
                        class IEDInit {
                                description = "The module initialisation function";
																file = PATHTO_FUNC(iedInit);
                                recompile = RECOMPILE;
                        };
                        class IEDMenuDef {
                                description = "The module menu definition";
																file = PATHTO_FUNC(iedMenuDef);
                                recompile = RECOMPILE;
                        };
                        class createBomber {
                                description = "Create an ambient suicide bomber";
																file = PATHTO_FUNC(createBomber);
                                recompile = RECOMPILE;
                        };
                        class RemoveBomber {
                                description = "Remove a suicide bomber";
																file = PATHTO_FUNC(removeBomber);
                                recompile = RECOMPILE;
                        };
                        class RemoveIED {
                                description = "Remove an IED";
																file = PATHTO_FUNC(removeIED);
                                recompile = RECOMPILE;
                        };
                        class placeIED {
                                description = "Find a suitable location for an IED";
																file = PATHTO_FUNC(placeIED);
                                recompile = RECOMPILE;
                        };
                        class placeVBIED {
                                description = "Find a suitable location for an IED";
																file = PATHTO_FUNC(placeVBIED);
                                                                recompile = RECOMPILE;
                        };
                        class armIED {
                                description = "Arm an IED";
																file = PATHTO_FUNC(armIED);
                                recompile = RECOMPILE;
                        };
                        class createVBIED {
                                description = "Create a VB-IED";
																file = PATHTO_FUNC(createVBIED);
                                recompile = RECOMPILE;
                        };
                        class disarmIED {
                                description = "Disarm a IED";
																file = PATHTO_FUNC(disarmIED);
                                recompile = RECOMPILE;
                        };
                        class detectIED {
                                description = "Detect a IED";
																file = PATHTO_FUNC(detectIED);
                                recompile = RECOMPILE;
                        };
                        class createIED {
                                description = "Create an IED";
																file = PATHTO_FUNC(createIED);
                                recompile = RECOMPILE;
                        };
                        class addActionIED {
                                description = "Add an action to an IED";
																file = PATHTO_FUNC(addActionIED);
                                recompile = RECOMPILE;
                        };
                        class removeActionIED {
                                description = "Remove an action from an IED";
																file = PATHTO_FUNC(removeActionIED);
                                recompile = RECOMPILE;
                        };
                };
        };
};
