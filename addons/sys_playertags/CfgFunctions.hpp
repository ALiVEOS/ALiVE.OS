class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class playertags {
                                description = "The main class";
                                file = "\x\alive\addons\sys_playertags\fnc_playertags.sqf";
                                                                ALIVE_RECOMPILE;
                        };
                        class playertagsInit {
                                description = "The module initialisation function";
                                file = "\x\alive\addons\sys_playertags\fnc_playertagsInit.sqf";
                                                                ALIVE_RECOMPILE;
                        };
                        class playertagsMenuDef {
                                description = "The module menu definition";
                                file = "\x\alive\addons\sys_playertags\fnc_playertagsMenuDef.sqf";
                                                                ALIVE_RECOMPILE;
                        };
                                                class playertagsRecognise {
                                description = "The condition script";
                                file = "\x\alive\addons\sys_playertags\playertags_recognise.sqf";
                                                                ALIVE_RECOMPILE;
                        };
                                                class playertagsRecogniseHandler {
                                description = "The handler script";
                                file = "\x\alive\addons\sys_playertags\playertags_recogniseHandler.sqf";
                                                                ALIVE_RECOMPILE;
                        };
                                                class playertagsRecogniseOverlayCtrl {
                                description = "The overlay control";
                                file = "\x\alive\addons\sys_playertags\playertags_recogniseOverlayCtrl.sqf";
                                                                ALIVE_RECOMPILE;
                        };
                                                class playertagsGenerateLabelText {
                                description = "The label control";
                                file = "\x\alive\addons\sys_playertags\playertags_generateLabelText.sqf";
                                                                ALIVE_RECOMPILE;
                        };
                };
        };
};
