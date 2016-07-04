// Simply a package which requires other addons.
class CfgPatches {
    class ADDON {
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {"ALIVE_main","cba_ui"};
        versionDesc = "ALiVE";
        //versionAct = "['sup_multispawn',_this] execVM '\x\alive\addons\main\about.sqf';";
        VERSION_CONFIG;
        author = MODULE_AUTHOR;
        authors[] = {"WobbleyHeadedBob"};
        authorUrl = "http://alivemod.com/";
    };
};
