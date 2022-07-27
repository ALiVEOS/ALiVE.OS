// Simply a package which requires other addons.
class CfgPatches {
    class ADDON {
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = { };
        versionDesc = "ALiVE";
        //versionAct = "['sys_pathfinding',_this] execVM '\x\alive\addons\main\about.sqf';";
        VERSION_CONFIG;
        author = MODULE_AUTHOR;
        authors[] = { "SpyderBlack" };
        authorUrl = "http://alivemod.com/";
    };
};

