class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class CQB {
                                description = "The main class";
                                file = "\x\alive\addons\mil_cqb\fnc_CQB.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class CQBInit {
                                description = "The module initialisation function";
                                file = "\x\alive\addons\mil_cqb\fnc_CQBInit.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class CQBSpawnStep {
                                description = "Advances one incremental step of an unscheduled CQB house spawn";
                                file = "\x\alive\addons\mil_cqb\fnc_CQBSpawnStep.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class CQBsortStrategicHouses {
                                description = "The CQB blacklist function";
                                file = "\x\alive\addons\mil_cqb\fnc_CQBsortStrategicHouses.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class CQBSaveData {
                                description = "CQB save data to DB";
                                file = "\x\alive\addons\mil_cqb\fnc_CQBSaveData.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class CQBLoadData {
                                description = "CQB load data to DB";
                                file = "\x\alive\addons\mil_cqb\fnc_CQBLoadData.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class CQBMenuDef {
                                description = "CQB Menu Definition";
                                file = "\x\alive\addons\mil_cqb\fnc_CQBMenuDef.sqf";
                                                                ALIVE_RECOMPILE;
                        };
                        class addCQBPositions {
                                description = "Enables CQB positions within the given radius of a position";
                                file = "\x\alive\addons\mil_cqb\fnc_addCQBPositions.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class removeCQBPositions{
                                description = "Disables CQB positions within the given radius of a position";
                                file = "\x\alive\addons\mil_cqb\fnc_removeCQBPositions.sqf";
                                ALIVE_RECOMPILE;
                        };
                        class resetCQB {
                                description = "Resets CQB to run in the background without houses";
                                file = "\x\alive\addons\mil_cqb\fnc_resetCQB.sqf";
                                ALIVE_RECOMPILE;
                        };
                };
        };
};
