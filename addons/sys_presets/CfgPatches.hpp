class CfgPatches {
    class ADDON {
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        // sys_classpicker declares the ALiVE folder in the editor's right click
        // menu. This addon adds an entry to that folder, and a config can only
        // add to a list that already exists, so the folder's own addon has to be
        // read first.
        requiredAddons[] = {"ALIVE_main", "ALIVE_sys_classpicker"};
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
