// Simply a package which requires other addons.
class CfgPatches {
    class ADDON {
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {"ALIVE_x_lib","ALIVE_sys_profile","ALIVE_mil_opcom"};
        versionDesc = "ALiVE";
        VERSION_CONFIG;
        author = MODULE_AUTHOR;
        authors[] = {"Jman"};
        authorUrl = "http://alivemod.com/";
    };
};
class Extended_InitPost_EventHandlers {
    class ADDON {
        init = QUOTE(call COMPILE_FILE(XEH_postInit));
    };
};
