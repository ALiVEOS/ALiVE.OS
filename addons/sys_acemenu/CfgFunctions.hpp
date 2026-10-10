class cfgFunctions {
    class PREFIX {
        class COMPONENT {
            class aceMenu {
                description = "Initializes the ALiVE ACE interaction menu";
                file = "\x\alive\addons\sys_acemenu\fnc_aceMenu.sqf";
                ALIVE_RECOMPILE;
            };
            class aceMenuC2 {
                description = "Initializes the ALiVE C2ISTAR ACE interaction menu and items";
                file = "\x\alive\addons\sys_acemenu\fnc_aceMenuC2.sqf";
                ALIVE_RECOMPILE;
            };
            class aceMenuCS {
                description = "Initializes the ALiVE Combat Support ACE interaction menu and items";
                file = "\x\alive\addons\sys_acemenu\fnc_aceMenuCS.sqf";
                ALIVE_RECOMPILE;
            };
            class aceMenuPR {
                description = "Initializes the ALiVE Player Resupply / Logistics ACE interaction menu and items";
                file = "\x\alive\addons\sys_acemenu\fnc_aceMenuPR.sqf";
                ALIVE_RECOMPILE;
            };
            class aceMenuCiv {
                description = "Registers the ALiVE civilian-interaction ACE menu branch on CAManBase targets";
                file = "\x\alive\addons\sys_acemenu\fnc_aceMenuCiv.sqf";
                ALIVE_RECOMPILE;
            };
            class aceMenu_repDialog {
                description = "SITREP and PATROLREP dialog wrapper";
                file = "\x\alive\addons\sys_acemenu\fnc_aceMenu_repDialog.sqf";
                ALIVE_RECOMPILE;
            };
            class aceMenu_readIntel {
                description = "Adds ACE interaction to dropped intel";
                file = "\x\alive\addons\sys_acemenu\fnc_aceMenu_readIntel.sqf";
                ALIVE_RECOMPILE;
            };
            class aceMenu_addActionIED {
                description = "Adds ACE interaction to IEDs";
                file = "\x\alive\addons\sys_acemenu\fnc_aceMenu_addActionIED.sqf";
                ALIVE_RECOMPILE;
            };
            class aceMenu_removeActionIED {
                description = "Removes ACE interaction from IEDs";
                file = "\x\alive\addons\sys_acemenu\fnc_aceMenu_removeActionIED.sqf";
                ALIVE_RECOMPILE;
            };
        };
    };
};
