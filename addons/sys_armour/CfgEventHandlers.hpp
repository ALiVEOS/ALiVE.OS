class Extended_PreInit_EventHandlers {
    class ADDON {
        init = QUOTE(call COMPILE_FILE(XEH_preInit));
    };
};

class Extended_PostInit_EventHandlers {
    class ADDON {
        init = QUOTE(call COMPILE_FILE(XEH_postInit));
    };
};

// RHS T-14 / T-15: runs after RHS's own init has added the tank to its
// active-protection list. Does nothing until the armour set has been applied
// (vehicles that exist before that are handled by ALIVE_fnc_armourInit).
class Extended_InitPost_EventHandlers {
    class rhs_t14_base {
        class ADDON {
            init = "['vehicle', [_this select 0]] call ALIVE_fnc_armourAps";
        };
    };
    class rhs_t15_base {
        class ADDON {
            init = "['vehicle', [_this select 0]] call ALIVE_fnc_armourAps";
        };
    };
};
