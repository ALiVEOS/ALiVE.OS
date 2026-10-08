// Simply a package which requires other addons.
class CfgPatches {
    class ADDON {
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {"CUP_Misc3_Config"};
        // Without CUP Terrains Core these compositions name objects that do not exist, so the game skips
        // this addon instead of stopping with a missing-addon error.
        skipWhenMissingDependencies = 1;
        versionDesc = "ALiVE";
        //versionAct = "['GRP_A3',_this] execVM '\x\alive\addons\main\about.sqf';";
        VERSION_CONFIG;
        author = MODULE_AUTHOR;
        authors[] = {"Tupolov & 2600K"};
        authorUrl = "http://alivemod.com/";
    };
};
