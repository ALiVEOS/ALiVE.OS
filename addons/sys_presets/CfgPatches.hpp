class CfgPatches {
    class ADDON {
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        // sys_classpicker declares the ALiVE folder in the editor's right click
        // menu. This addon adds an entry to that folder, and a config can only
        // add to a list that already exists, so the folder's own addon has to be
        // read first. fnc_analysis owns the ALiVE menu at the top of the editor,
        // which this addon adds to as well.
        requiredAddons[] = {"ALIVE_main", "ALIVE_sys_classpicker", "ALIVE_fnc_analysis"};
        versionDesc = "ALiVE";
        VERSION_CONFIG;
        author = MODULE_AUTHOR;
        authors[] = {"Jman"};
        authorUrl = "http://alivemod.com/";
    };
};
class Extended_PreInit_EventHandlers {
    class ADDON {
        init = QUOTE(call COMPILE_FILE(XEH_preInit));
    };
};
