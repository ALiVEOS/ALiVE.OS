class CfgFunctions {
    class ALIVE {
        class UI {
            class flexiMenu_Add {
                description = "Add a type-based menu source. Result: TBA (WIP)";
								file = "\x\alive\addons\ui\fleximenu\fnc_add.sqf";
            };
            class flexiMenu_Remove {
                description = "Remove a type-based menu source. Result: TBA (WIP)";
								file = "\x\alive\addons\ui\fleximenu\fnc_remove.sqf";
            };
            class flexiMenu_setObjectMenuSource {
                description = "Set an object's menu source (variable). Result: TBA (WIP)";
								file = "\x\alive\addons\ui\fleximenu\fnc_setObjectMenuSource.sqf";
            };
            class displayMenu {
                description = "Display various UI menus";
								file = "\x\alive\addons\ui\menu\fnc_displayMenu.sqf";
                recompile = RECOMPILE;
            };
            class RscDisplayLoadingALiVE {
                description = "Hook loading screen";
								file = PATHTO_FUNC(RscDisplayLoadingALiVE);
                recompile = RECOMPILE;
            };
            class RscDisplayMPInterruptALiVE {
                description = "Hook MP interrupt screen";
								file = PATHTO_FUNC(RscDisplayMPInterruptALiVE);
                recompile = RECOMPILE;
            };
            class copyFactionClasses {
                description = "Copy faction classes from selected objects in 3DEN to clipboard";
								file = PATHTO_FUNC(copyFactionClasses);
                recompile = RECOMPILE;
            };
        };
    };
};
