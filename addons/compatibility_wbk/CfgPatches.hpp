class CfgPatches {
    class ADDON {
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {"ALIVE_main","WBK_ZombieCreatures_Units"};
        // Loads only alongside WebKnight's Zombies and Creatures, and is skipped quietly without it.
        skipWhenMissingDependencies = 1;
        versionDesc = "ALiVE";
        VERSION_CONFIG;
        author = MODULE_AUTHOR;
        authors[] = {"Jman"};
        authorUrl = "http://alivemod.com/";
    };
};
