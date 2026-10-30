// Optional Zeus modules. Zeus Enhanced is never required: when it is loaded, the modules use
// its option dialogs, checked for at run time.
class CfgPatches {
    class ADDON {
        units[] = {
            "ALiVE_ModuleZeusSave",
            "ALiVE_ModuleZeusDebug",
            "ALiVE_ModuleZeusSoloTest",
            "ALiVE_ModuleZeusSpotReport",
            "ALiVE_ModuleZeusHandGroup",
            "ALiVE_ModuleZeusBomber",
            "ALiVE_ModuleZeusConvertBomber",
            "ALiVE_ModuleZeusCarBomb",
            "ALiVE_ModuleZeusIED",
            "ALiVE_ModuleZeusIEDAmbush",
            "ALiVE_ModuleZeusSpawnGroup",
            "ALiVE_ModuleZeusRemoveGroup",
            "ALiVE_ModuleZeusObjective",
            "ALiVE_ModuleZeusRevealInstallations",
            "ALiVE_ModuleZeusCreateTask",
            "ALiVE_ModuleZeusCloseTask",
            "ALiVE_ModuleZeusAirStrike",
            "ALiVE_ModuleZeusResupply",
            "ALiVE_ModuleZeusTownMood",
            "ALiVE_ModuleZeusTipOff",
            "ALiVE_ModuleZeusAngryCrowd",
            "ALiVE_ModuleZeusCreateHub",
            "ALiVE_ModuleZeusRemoveHub",
            "ALiVE_ModuleZeusCreateFob",
            "ALiVE_ModuleZeusRemoveFob",
            "ALiVE_ModuleZeusCreateRally",
            "ALiVE_ModuleZeusRemoveRally"
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
