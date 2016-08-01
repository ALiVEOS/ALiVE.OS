class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class logistics {
                                description = "The main class";
																file = PATHTO_FUNC(logistics);
                                recompile = RECOMPILE;
                        };
                        class logisticsInit {
                                description = "The module initialisation function";
																file = PATHTO_FUNC(logisticsInit);
                                recompile = RECOMPILE;
                        };
                        class logisticsDisable {
                                description = "Logistics load data to DB";
																file = PATHTO_FUNC(logisticsDisable);
                                recompile = RECOMPILE;
                        };
                        class logisticsMenuDef {
                                description = "The module menu definition";
																file = PATHTO_FUNC(logisticsMenuDef);
                                recompile = RECOMPILE;
                        };
                        class getObjectWeight {
                                description = "Gets the approximate weight (sum) of the given objects";
																file = PATHTO_FUNC(getObjectWeight);
                                recompile = RECOMPILE;
                        };
                        class getObjectSize {
                                description = "Gets the approximate volume (sum) of the given objects";
																file = PATHTO_FUNC(getObjectSize);
                                recompile = RECOMPILE;
                        };
                        class availableWeight {
                                description = "Gets the available weight capacity (sum) of the given objects in kg";
																file = PATHTO_FUNC(availableWeight);
                                recompile = RECOMPILE;
                        };
                        class availableCargo {
                                description = "Gets the available cargo volume (sum) of the given objects in m^3";
																file = PATHTO_FUNC(availableCargo);
                                recompile = RECOMPILE;
                        };
                        class canCarry {
                                description = "Checks if an object can be carried by another given object";
																file = PATHTO_FUNC(canCarry);
                                recompile = RECOMPILE;
                        };
                        class canStow {
                                description = "Checks if an object can be stowed the given container";
																file = PATHTO_FUNC(canStow);
                                recompile = RECOMPILE;
                        };
                        class canTow {
                                description = "Checks if an object can be towed by the given vehicle";
																file = PATHTO_FUNC(canTow);
                                recompile = RECOMPILE;
                        };
                        class canLift {
                                description = "Checks if an object can be lifted by given vehicle";
																file = PATHTO_FUNC(canLift);
                                recompile = RECOMPILE;
                        };
                        class getObjectCargo {
                                description = "Gets the cargo list of an object";
																file = PATHTO_FUNC(getObjectCargo);
                                recompile = RECOMPILE;
                        };
                        class setObjectCargo {
                                description = "Sets the cargo back on an object";
																file = PATHTO_FUNC(setObjectCargo);
                                recompile = RECOMPILE;
                        };
                        class setObjectState {
                                description = "Sets the given state of on an object";
																file = PATHTO_FUNC(setObjectState);
                                recompile = RECOMPILE;
                        };
                        class getObjectState {
                                description = "Gets the given state of an object";
																file = PATHTO_FUNC(getObjectState);
                                recompile = RECOMPILE;
                        };
                        class getObjectFuel {
                                description = "Gets the fuel of an object";
																file = PATHTO_FUNC(getObjectFuel);
                                recompile = RECOMPILE;
                        };
                        class setObjectFuel {
                                description = "Sets the given fuel oo an object";
																file = PATHTO_FUNC(setObjectFuel);
                                recompile = RECOMPILE;
                        };
                        class getObjectDamage {
                                description = "Gets the damage of an object";
																file = PATHTO_FUNC(getObjectDamage);
                                recompile = RECOMPILE;
                        };
                        class setObjectDamage {
                                description = "Sets the given damage on an object";
																file = PATHTO_FUNC(setObjectDamage);
                                recompile = RECOMPILE;
                        };
                        class logisticsSaveData {
                                description = "Logistics save data to DB";
																file = PATHTO_FUNC(logisticsSaveData);
                                recompile = RECOMPILE;
                        };
                        class logisticsLoadData {
                                description = "Logistics load data to DB";
																file = PATHTO_FUNC(logisticsLoadData);
                                recompile = RECOMPILE;
                        };
                };
        };
};
