class cfgFunctions {
    class PREFIX {
        class COMPONENT {
						FUNC_FILEPATH(vDist,"The main class");
						FUNC_FILEPATH(vDistInit,"The module initialisation function");
						FUNC_FILEPATH(vDistMenuDef,"The module menu definition");
            class vDistGuiInit {
                description = "The Gui";
                file = PATHTO_FUNC(vdist_init);
                recompile = RECOMPILE;
            };
				};
		};
};
