// Simply a package which requires other addons.
class CfgPatches {
    class ADDON {
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {"ALIVE_fnc_strategic"};
        versionDesc = "ALiVE";
        //versionAct = "['mil_opcom',_this] execVM '\x\alive\addons\main\about.sqf';";
        VERSION_CONFIG;
        author = MODULE_AUTHOR;
        authors[] = {"Highhead"};
        authorUrl = "http://alivemod.com/";
    };
};