// Simply a package which requires other addons.
class CfgPatches {
    class ADDON {
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {"WW2_SPE_Structures_c"};
        // Without Spearhead 1944 these compositions name objects that do not exist, so the game skips
        // this addon instead of stopping with a missing-addon error.
        skipWhenMissingDependencies = 1;
        versionDesc = "ALiVE";
        VERSION_CONFIG;
        author = MODULE_AUTHOR;
        authors[] = {"Jman"};
        authorUrl = "http://alivemod.com/";
    };
};
