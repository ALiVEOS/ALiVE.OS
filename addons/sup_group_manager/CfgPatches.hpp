// Simply a package which requires other addons.
class CfgPatches {
    class ADDON {
        units[] = { };
        weapons[] = { };
        requiredVersion = REQUIRED_VERSION;
        // ALIVE_main for the Who Can Manage control (ALiVE_SideChoiceMulti) and the shared Who Can check
        requiredAddons[] = { "A3_Ui_F", "ALIVE_main" };
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

