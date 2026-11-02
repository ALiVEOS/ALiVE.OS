class Extended_Init_EventHandlers {
    class CAManBase {
        init = "_this spawn ALiVE_fnc_AIskillSetter";
    };
};

class Extended_PostInit_EventHandlers {
    class ADDON {
        init = QUOTE(call COMPILE_FILE(XEH_postInit));
    };
};
