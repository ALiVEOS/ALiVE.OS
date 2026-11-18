// Simply a package which requires other addons.
class CfgPatches {
    class ADDON {
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = { "ALIVE_main", "ALiVE_ui", "A3_Ui_F", "A3_Map_VR" };
        versionDesc = "ALiVE";
        //versionAct = "['sys_orbatcreator',_this] execVM '\x\alive\addons\main\about.sqf';";
        VERSION_CONFIG;
        author = MODULE_AUTHOR;
        authors[] = { "SpyderBlack" };
        authorUrl = "http://alivemod.com/";
    };
};
class Extended_InitPost_EventHandlers {
    class ADDON {
        init = QUOTE(call COMPILE_FILE(XEH_postInit));
    };
};

