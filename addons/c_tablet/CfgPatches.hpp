// Simply a package which requires other addons.
class CfgPatches {
    class ADDON {
        units[] = {"Item_ALIVE_Tablet"};
        weapons[] = {"ALIVE_Tablet"};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {"A3_Weapons_F"};
        versionDesc = "ALiVE";
        //versionAct = "['c_tablet',_this] execVM '\x\alive\addons\main\about.sqf';";
        VERSION_CONFIG;
        author = MODULE_AUTHOR;
        authors[] = {"Tupolov"};
        authorUrl = "http://alivemod.com/";
    };
};


