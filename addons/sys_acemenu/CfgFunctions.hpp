class cfgFunctions {
    class PREFIX {
        class COMPONENT {
            class aceMenu {
                description = "Initializes the ALiVE ACE interaction menu";
                file = "\x\alive\addons\sys_acemenu\fnc_aceMenu.sqf";
                RECOMPILE;
            };
            class aceMenuC2 {
                description = "Initializes the ALiVE C2ISTAR ACE interaction menu and items";
                file = "\x\alive\addons\sys_acemenu\fnc_aceMenuC2.sqf";
                RECOMPILE;
            };
            class aceMenuCS {
                description = "Initializes the ALiVE Combat Support ACE interaction menu and items";
                file = "\x\alive\addons\sys_acemenu\fnc_aceMenuCS.sqf";
                RECOMPILE;
            };
            class aceMenuPR {
                description = "Initializes the ALiVE Player Resupply / Logistics ACE interaction menu and items";
                file = "\x\alive\addons\sys_acemenu\fnc_aceMenuPR.sqf";
                RECOMPILE;
            };
            class aceMenu_repDialog {
                description = "SITREP and PATROLREP dialog wrapper";
                file = "\x\alive\addons\sys_acemenu\fnc_aceMenu_repDialog.sqf";
                RECOMPILE;
            };
            class aceMenu_readIntel {
                description = "Adds ACE interaction to dropped intel";
                file = "\x\alive\addons\sys_acemenu\fnc_aceMenu_readIntel.sqf";
                RECOMPILE;
            };
            class aceMenu_addActionIED {
                description = "Adds ACE interaction to IEDs";
                file = "\x\alive\addons\sys_acemenu\fnc_aceMenu_addActionIED.sqf";
                RECOMPILE;
            };
            class aceMenu_removeActionIED {
                description = "Removes ACE interaction from IEDs";
                file = "\x\alive\addons\sys_acemenu\fnc_aceMenu_removeActionIED.sqf";
                RECOMPILE;
            };
        };
    };
};
