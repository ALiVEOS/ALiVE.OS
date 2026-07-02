// Simply a package which requires other addons.
class CfgPatches {
    class ADDON {
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {"ALIVE_main"};
        versionDesc = "ALiVE";
        //versionAct = "['SUP_COMBATSUPPORT',_this] execVM '\x\alive\addons\main\about.sqf';";
        VERSION_CONFIG;
        author = MODULE_AUTHOR;
        authors[] = {"Gunny"};
        authorUrl = "http://alivemod.com/";
    };
};

class Extended_PostInit_EventHandlers {
    class ADDON {
        init = QUOTE(call COMPILE_FILE(XEH_postInit));
    };
};

//#include "\x\alive\addons\sys_newsfeed\newsfeed\newsfeed.hpp"