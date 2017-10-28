class CfgFunctions {
    class ALIVE {
        class UI {
            class displayMenu {
                description = "Display various UI menus";
                file = "\x\alive\addons\ui\menu\fnc_displayMenu.sqf";
                RECOMPILE;
            };
            class RscDisplayLoadingALiVE {
                description = "Hook loading screen";
                file = "\x\alive\addons\ui\fnc_RscDisplayLoadingALiVE.sqf";
                RECOMPILE;
            };
            class RscDisplayMPInterruptALiVE {
                description = "Hook MP interrupt screen";
                file = "\x\alive\addons\ui\fnc_RscDisplayMPInterruptALiVE.sqf";
                RECOMPILE;
            };
            class RscDisplayInterruptALiVE {
                description = "Hook SP interrupt screen";
                file = "\x\alive\addons\ui\fnc_RscDisplayInterruptALiVE.sqf";
                RECOMPILE;
            };            
            class copyFactionClasses {
                description = "Copy faction classes from selected objects in 3DEN to clipboard";
                file = "\x\alive\addons\ui\fnc_copyFactionClasses.sqf";
            };
        };
    };
};
