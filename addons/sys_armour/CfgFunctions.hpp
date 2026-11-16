class cfgFunctions {
    class PREFIX {
        class COMPONENT {
            class armourInit {
                description = "Applies each active armour set once settings are ready";
                file = "\x\alive\addons\sys_armour\fnc_armourInit.sqf";
                ALIVE_RECOMPILE;
            };
            class armourSeed {
                description = "Feeds one armour set's vest and ammo values into ACE medical";
                file = "\x\alive\addons\sys_armour\fnc_armourSeed.sqf";
                ALIVE_RECOMPILE;
            };
            class armourAps {
                description = "Limits or removes the RHS T-14/T-15 active protection";
                file = "\x\alive\addons\sys_armour\fnc_armourAps.sqf";
                ALIVE_RECOMPILE;
            };
        };
    };
};
