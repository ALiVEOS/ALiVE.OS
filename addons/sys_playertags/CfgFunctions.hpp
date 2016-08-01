class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class playertags {
                                description = "The main class";
																file = PATHTO_FUNC(playertags);
                                                                recompile = RECOMPILE;
                        };
                        class playertagsInit {
                                description = "The module initialisation function";
																file = PATHTO_FUNC(playertagsInit);
                                                                recompile = RECOMPILE;
                        };
                        class playertagsMenuDef {
                                description = "The module menu definition";
																file = PATHTO_FUNC(playertagsMenuDef);
                                                                recompile = RECOMPILE;
                        };
                                                class playertagsRecognise {
                                description = "The condition script";
                                file = "\x\alive\addons\sys_playertags\playertags_recognise.sqf";
                                                                recompile = RECOMPILE;
                        };
                                                class playertagsRecogniseHandler {
                                description = "The handler script";
                                file = "\x\alive\addons\sys_playertags\playertags_recogniseHandler.sqf";
                                                                recompile = RECOMPILE;
                        };
                                                class playertagsRecogniseOverlayCtrl {
                                description = "The overlay control";
                                file = "\x\alive\addons\sys_playertags\playertags_recogniseOverlayCtrl.sqf";
                                                                recompile = RECOMPILE;
                        };
                                                class playertagsGenerateLabelText {
                                description = "The label control";
                                file = "\x\alive\addons\sys_playertags\playertags_generateLabelText.sqf";
                                                                recompile = RECOMPILE;
                        };
                };
        };
};
