class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class logistics {
                                description = "The main class";
                                file = "\x\alive\addons\sys_logistics\fnc_logistics.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class logisticsInit {
                                description = "The module initialisation function";
                                file = "\x\alive\addons\sys_logistics\fnc_logisticsInit.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class logisticsDisable {
                                description = "Logistics load data to DB";
                                file = "\x\alive\addons\sys_logistics\fnc_logisticsDisable.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class logisticsMenuDef {
                                description = "The module menu definition";
                                file = "\x\alive\addons\sys_logistics\fnc_logisticsMenuDef.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class getObjectWeight {
                                description = "Gets the approximate weight (sum) of the given objects";
                                file = "\x\alive\addons\sys_logistics\fnc_getObjectWeight.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class getObjectSize {
                                description = "Gets the approximate volume (sum) of the given objects";
                                file = "\x\alive\addons\sys_logistics\fnc_getObjectSize.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class availableWeight {
                                description = "Gets the available weight capacity (sum) of the given objects in kg";
                                file = "\x\alive\addons\sys_logistics\fnc_availableWeight.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class availableCargo {
                                description = "Gets the available cargo volume (sum) of the given objects in m^3";
                                file = "\x\alive\addons\sys_logistics\fnc_availableCargo.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class canCarry {
                                description = "Checks if an object can be carried by another given object";
                                file = "\x\alive\addons\sys_logistics\fnc_canCarry.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class canStow {
                                description = "Checks if an object can be stowed the given container";
                                file = "\x\alive\addons\sys_logistics\fnc_canStow.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class canTow {
                                description = "Checks if an object can be towed by the given vehicle";
                                file = "\x\alive\addons\sys_logistics\fnc_canTow.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class canLift {
                                description = "Checks if an object can be lifted by given vehicle";
                                file = "\x\alive\addons\sys_logistics\fnc_canLift.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class getObjectCargo {
                                description = "Gets the cargo list of an object";
                                file = "\x\alive\addons\sys_logistics\fnc_getObjectCargo.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class setObjectCargo {
                                description = "Sets the cargo back on an object";
                                file = "\x\alive\addons\sys_logistics\fnc_setObjectCargo.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class setObjectState {
                                description = "Sets the given state of on an object";
                                file = "\x\alive\addons\sys_logistics\fnc_setObjectState.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class getObjectState {
                                description = "Gets the given state of an object";
                                file = "\x\alive\addons\sys_logistics\fnc_getObjectState.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class getObjectFuel {
                                description = "Gets the fuel of an object";
                                file = "\x\alive\addons\sys_logistics\fnc_getObjectFuel.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class setObjectFuel {
                                description = "Sets the given fuel oo an object";
                                file = "\x\alive\addons\sys_logistics\fnc_setObjectFuel.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class getObjectDamage {
                                description = "Gets the damage of an object";
                                file = "\x\alive\addons\sys_logistics\fnc_getObjectDamage.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class setObjectDamage {
                                description = "Sets the given damage on an object";
                                file = "\x\alive\addons\sys_logistics\fnc_setObjectDamage.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class logisticsSaveData {
                                description = "Logistics save data to DB";
                                file = "\x\alive\addons\sys_logistics\fnc_logisticsSaveData.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class logisticsLoadData {
                                description = "Logistics load data to DB";
                                file = "\x\alive\addons\sys_logistics\fnc_logisticsLoadData.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class logisticsSaveDataPNS {
                                description = "Logistics save data to ProfileNameSpace";
                                file = "\x\alive\addons\sys_logistics\fnc_logisticsSaveDataPNS.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class logisticsLoadDataPNS {
                                description = "Logistics load data to ProfileNameSpace";
                                file = "\x\alive\addons\sys_logistics\fnc_logisticsLoadDataPNS.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class getObjectPointDamage {
                                description = "Get hit point damage for a given object";
                                file = "\x\alive\addons\sys_logistics\fnc_getObjectPointDamage.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class setObjectPointDamage {
                                description = "Set hit point damage for a given object";
                                file = "\x\alive\addons\sys_logistics\fnc_setObjectPointDamage.sqf";
                                ALIVE_RECOMPILE;
                        };         
                };
        };
};
