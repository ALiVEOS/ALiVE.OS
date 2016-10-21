class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class playertags {
                                description = "The main class";
                                file = "\x\alive\addons\sys_playertags\fnc_playertags.sqf";
                                                                RECOMPILE;
                        };
                        class playertagsInit {
                                description = "The module initialisation function";
                                file = "\x\alive\addons\sys_playertags\fnc_playertagsInit.sqf";
                                                                RECOMPILE;
                        };
                        class playertagsMenuDef {
                                description = "The module menu definition";
                                file = "\x\alive\addons\sys_playertags\fnc_playertagsMenuDef.sqf";
                                                                RECOMPILE;
                        };
                                                class playertagsRecognise {
                                description = "The condition script";
                                file = "\x\alive\addons\sys_playertags\playertags_recognise.sqf";
                                                                RECOMPILE;
                        };
                                                class playertagsRecogniseHandler {
                                description = "The handler script";
                                file = "\x\alive\addons\sys_playertags\playertags_recogniseHandler.sqf";
                                                                RECOMPILE;
                        };
                                                class playertagsRecogniseOverlayCtrl {
                                description = "The overlay control";
                                file = "\x\alive\addons\sys_playertags\playertags_recogniseOverlayCtrl.sqf";
                                                                RECOMPILE;
                        };
                                                class playertagsGenerateLabelText {
                                description = "The label control";
                                file = "\x\alive\addons\sys_playertags\playertags_generateLabelText.sqf";
                                                                RECOMPILE;
                        };
                };
        };
};
