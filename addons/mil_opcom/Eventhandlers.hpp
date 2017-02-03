class Extended_Killed_Eventhandlers {
    class CAManBase {
        class ADDON {
            killed = "[_this,0] call ALiVE_fnc_OPCOMDropIntel";
        };
    };
};

class Extended_InitPost_EventHandlers {
    class ADDON {
        init = QUOTE(call COMPILE_FILE(XEH_postInit));
    };
};