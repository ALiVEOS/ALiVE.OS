// Optional Zeus modules. Zeus Enhanced is never required: when it is loaded, the modules use
// its option dialogs, checked for at run time.
class CfgPatches {
    class ADDON {
        units[] = {
            "ALiVE_ModuleZeusSave",
            "ALiVE_ModuleZeusDebug",
            "ALiVE_ModuleZeusSpotReport",
            "ALiVE_ModuleZeusHandGroup",
            "ALiVE_ModuleZeusBomber"
        };
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {"ALIVE_main","ALIVE_x_lib"};
        versionDesc = "ALiVE";
        VERSION_CONFIG;
        author = MODULE_AUTHOR;
        authors[] = {"Jman"};
        authorUrl = "http://alivemod.com/";
    };
};
