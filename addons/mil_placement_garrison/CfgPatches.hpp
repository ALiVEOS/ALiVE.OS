// Simply a package which requires other addons.
class CfgPatches {
    class ADDON {
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {"ALIVE_fnc_strategic","ALIVE_sys_factioncompiler"};
        versionDesc = "ALiVE";
        VERSION_CONFIG;
        author = MODULE_AUTHOR;
        authors[] = {"Jman"};
        authorUrl = "http://alivemod.com/";
    };
    // This addon was called mil_placement_spe. Missions saved before the rename list
    // alive_mil_placement_spe as a required addon, so the old name is still provided here.
    // It must not list ADDON as a requirement: Arma orders whole PBOs, so a class needing
    // another class in the same PBO makes the PBO need itself and the game refuses to start.
    class alive_mil_placement_spe {
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {"ALIVE_fnc_strategic","ALIVE_sys_factioncompiler"};
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
// Once per mission on every machine: warns when the old mil_placement_spe.pbo is still installed
// beside this one.
class Extended_PostInit_EventHandlers {
    class ADDON {
        init = QUOTE(call COMPILE_FILE(XEH_oldPboCheck));
    };
};
