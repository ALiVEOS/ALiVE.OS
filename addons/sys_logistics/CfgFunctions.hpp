class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class logistics {
                                description = "The main class";
                                file = "\x\alive\addons\sys_logistics\fnc_logistics.sqf";
                                RECOMPILE;
                        };
                        class logisticsInit {
                                description = "The module initialisation function";
                                file = "\x\alive\addons\sys_logistics\fnc_logisticsInit.sqf";
                                RECOMPILE;
                        };
                        class logisticsDisable {
                                description = "Logistics load data to DB";
                                file = "\x\alive\addons\sys_logistics\fnc_logisticsDisable.sqf";
                                RECOMPILE;
                        };
                        class logisticsMenuDef {
                                description = "The module menu definition";
                                file = "\x\alive\addons\sys_logistics\fnc_logisticsMenuDef.sqf";
                                RECOMPILE;
                        };
                        class getObjectWeight {
                                description = "Gets the approximate weight (sum) of the given objects";
                                file = "\x\alive\addons\sys_logistics\fnc_getObjectWeight.sqf";
                                RECOMPILE;
                        };
                        class getObjectSize {
                                description = "Gets the approximate volume (sum) of the given objects";
                                file = "\x\alive\addons\sys_logistics\fnc_getObjectSize.sqf";
                                RECOMPILE;
                        };
                        class availableWeight {
                                description = "Gets the available weight capacity (sum) of the given objects in kg";
                                file = "\x\alive\addons\sys_logistics\fnc_availableWeight.sqf";
                                RECOMPILE;
                        };
                        class availableCargo {
                                description = "Gets the available cargo volume (sum) of the given objects in m^3";
                                file = "\x\alive\addons\sys_logistics\fnc_availableCargo.sqf";
                                RECOMPILE;
                        };
                        class canCarry {
                                description = "Checks if an object can be carried by another given object";
                                file = "\x\alive\addons\sys_logistics\fnc_canCarry.sqf";
                                RECOMPILE;
                        };
                        class canStow {
                                description = "Checks if an object can be stowed the given container";
                                file = "\x\alive\addons\sys_logistics\fnc_canStow.sqf";
                                RECOMPILE;
                        };
                        class canTow {
                                description = "Checks if an object can be towed by the given vehicle";
                                file = "\x\alive\addons\sys_logistics\fnc_canTow.sqf";
                                RECOMPILE;
                        };
                        class canLift {
                                description = "Checks if an object can be lifted by given vehicle";
                                file = "\x\alive\addons\sys_logistics\fnc_canLift.sqf";
                                RECOMPILE;
                        };
                        class getObjectCargo {
                                description = "Gets the cargo list of an object";
                                file = "\x\alive\addons\sys_logistics\fnc_getObjectCargo.sqf";
                                RECOMPILE;
                        };
                        class setObjectCargo {
                                description = "Sets the cargo back on an object";
                                file = "\x\alive\addons\sys_logistics\fnc_setObjectCargo.sqf";
                                RECOMPILE;
                        };
                        class setObjectState {
                                description = "Sets the given state of on an object";
                                file = "\x\alive\addons\sys_logistics\fnc_setObjectState.sqf";
                                RECOMPILE;
                        };
                        class getObjectState {
                                description = "Gets the given state of an object";
                                file = "\x\alive\addons\sys_logistics\fnc_getObjectState.sqf";
                                RECOMPILE;
                        };
                        class getObjectFuel {
                                description = "Gets the fuel of an object";
                                file = "\x\alive\addons\sys_logistics\fnc_getObjectFuel.sqf";
                                RECOMPILE;
                        };
                        class setObjectFuel {
                                description = "Sets the given fuel oo an object";
                                file = "\x\alive\addons\sys_logistics\fnc_setObjectFuel.sqf";
                                RECOMPILE;
                        };
                        class getObjectDamage {
                                description = "Gets the damage of an object";
                                file = "\x\alive\addons\sys_logistics\fnc_getObjectDamage.sqf";
                                RECOMPILE;
                        };
                        class setObjectDamage {
                                description = "Sets the given damage on an object";
                                file = "\x\alive\addons\sys_logistics\fnc_setObjectDamage.sqf";
                                RECOMPILE;
                        };
                        class logisticsSaveData {
                                description = "Logistics save data to DB";
                                file = "\x\alive\addons\sys_logistics\fnc_logisticsSaveData.sqf";
                                RECOMPILE;
                        };
                        class logisticsLoadData {
                                description = "Logistics load data to DB";
                                file = "\x\alive\addons\sys_logistics\fnc_logisticsLoadData.sqf";
                                RECOMPILE;
                        };
                        class logisticsSaveDataPNS {
                                description = "Logistics save data to ProfileNameSpace";
                                file = "\x\alive\addons\sys_logistics\fnc_logisticsSaveDataPNS.sqf";
                                RECOMPILE;
                        };
                        class logisticsLoadDataPNS {
                                description = "Logistics load data to ProfileNameSpace";
                                file = "\x\alive\addons\sys_logistics\fnc_logisticsLoadDataPNS.sqf";
                                RECOMPILE;
                        };
                        class getObjectPointDamage {
                                description = "Get hit point damage for a given object";
                                file = "\x\alive\addons\sys_logistics\fnc_getObjectPointDamage.sqf";
                                RECOMPILE;
                        };
                        class setObjectPointDamage {
                                description = "Set hit point damage for a given object";
                                file = "\x\alive\addons\sys_logistics\fnc_setObjectPointDamage.sqf";
                                RECOMPILE;
                        };         
                };
        };
};
