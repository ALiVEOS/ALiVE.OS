// Simply a package which requires other addons.
class CfgPatches {
    class ADDON {
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {"alive_composition_a3","alive_mil_ato"};
        versionDesc = "ALiVE";
        //versionAct = "['GRP_A3',_this] execVM '\x\alive\addons\main\about.sqf';";
        VERSION_CONFIG;
        author = MODULE_AUTHOR;
        authors[] = {"Tupolov"};
        authorUrl = "http://alivemod.com/";
    };
};
