#include "script_component.hpp"


class CfgPatches {
    class ADDON {
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {"A3_Weapons_F"};
        versionDesc = "ALiVE";
        //versionAct = "['m_tablet',_this] execVM '\x\alive\addons\main\about.sqf';";
        VERSION_CONFIG;
        author = MODULE_AUTHOR;
        authors[] = {"Spartan [VCB]"};
        authorUrl = "http://alivemod.com/";
    };
};

