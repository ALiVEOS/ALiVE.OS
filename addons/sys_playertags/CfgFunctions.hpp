class cfgFunctions {
        class PREFIX {
                class COMPONENT {
												FUNC_FILEPATH(playertags,"The main class");
												FUNC_FILEPATH(playertagsInit,"The module initialisation function");
												FUNC_FILEPATH(playertagsMenuDef,"The module menu definition");
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
