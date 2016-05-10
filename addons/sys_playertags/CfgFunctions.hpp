class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class playertags {
                                description = "The main class";
                                file = "\x\alive\addons\sys_playertags\fnc_playertags.sqf";
																recompile = RECOMPILE;
                        };
                        class playertagsInit {
                                description = "The module initialisation function";
                                file = "\x\alive\addons\sys_playertags\fnc_playertagsInit.sqf";
																recompile = RECOMPILE;
                        };
                        class playertagsMenuDef {
                                description = "The module menu definition";
                                file = "\x\alive\addons\sys_playertags\fnc_playertagsMenuDef.sqf";
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
