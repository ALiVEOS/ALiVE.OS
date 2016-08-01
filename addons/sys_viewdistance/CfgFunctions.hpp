class cfgFunctions {
    class PREFIX {
        class COMPONENT {
            class vDist {
                description = "The main class";
								file = PATHTO_FUNC(vDist);
                recompile = RECOMPILE;
            };
            class vDistInit {
                description = "The module initialisation function";
								file = PATHTO_FUNC(vDistInit);
                recompile = RECOMPILE;
            };
            class vDistMenuDef {
                description = "The module menu definition";
								file = PATHTO_FUNC(vDistMenuDef);
                recompile = RECOMPILE;
            };
            class vDistGuiInit {
                description = "The Gui";
								file = PATHTO_FUNC(vdist_init);
                recompile = RECOMPILE;
            };
        };
    };
};
