class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class marker {
                                description = "The main class";
                                file = "\x\alive\addons\sys_marker\fnc_marker.sqf";
                                RECOMPILE;
                        };
                        class markerInit {
                                description = "The module initialisation function";
                                file = "\x\alive\addons\sys_marker\fnc_markerInit.sqf";
                                RECOMPILE;
                        };
                        class markerParams {
                                description = "Marker parameters";
                                file = "\x\alive\addons\sys_marker\fnc_markerParams.sqf";
                                RECOMPILE;
                        };
                        class markerSaveData {
                                description = "marker save data to DB";
                                file = "\x\alive\addons\sys_marker\fnc_markerSaveData.sqf";
                                                                RECOMPILE;
                        };
                        class markerLoadData {
                                description = "marker load data to DB";
                                file = "\x\alive\addons\sys_marker\fnc_markerLoadData.sqf";
                                                                RECOMPILE;
                        };
                        class markerDeleteData {
                                description = "marker delete data from DB";
                                file = "\x\alive\addons\sys_marker\fnc_markerDeleteData.sqf";
                                                                RECOMPILE;
                        };
                        class markerOnLoad{
                                description = "Onload for Dialog";
                                file = "\x\alive\addons\sys_marker\fnc_markerOnLoad.sqf";
                                                                RECOMPILE;
                        };
                        class markerOnPlayerConnected{
                                description = "Handles on player connected event";
                                file = "\x\alive\addons\sys_marker\fnc_markerOnPlayerConnected.sqf";
                                                                RECOMPILE;
                        };
                        class markerLBSelChanged{
                                description = "LBSelChanged for Dialog";
                                file = "\x\alive\addons\sys_marker\fnc_markerLBSelChanged.sqf";
                                                                RECOMPILE;
                        };
                        class markerCheckedChanged{
                                description = "CheckedChanged for Dialog";
                                file = "\x\alive\addons\sys_marker\fnc_markerCheckedChanged.sqf";
                                                                RECOMPILE;
                        };
                        class markerButtonAction{
                                description = "Button Action for Dialog";
                                file = "\x\alive\addons\sys_marker\fnc_markerButtonAction.sqf";
                                                                RECOMPILE;
                        };
                };
        };
};