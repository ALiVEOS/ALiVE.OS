// Simply a package which requires other addons.
class CfgPatches {
    class ADDON {
        units[] = { };
        weapons[] = { };
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {"A3_Modules_F","ALiVE_main"};
        versionDesc = "ALiVE";
        //versionAct = "['sys_aiskill',_this] execVM '\x\alive\addons\main\about.sqf';";
        VERSION_CONFIG;
        author = MODULE_AUTHOR;
        authors[] = { "ARJay" };
        authorUrl = "http://alivemod.com/";
    };
};
class Extended_InitPost_EventHandlers {
    class ADDON {
        init = QUOTE(call COMPILE_FILE(XEH_postInit));
    };
};

