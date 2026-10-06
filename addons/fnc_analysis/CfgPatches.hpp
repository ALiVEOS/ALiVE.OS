// Simply a package which requires other addons.
class CfgPatches {
    class ADDON {
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        // A3_3DEN defines the editor's top menu. It has to load first, or its
        // items[] would replace the ALiVE heading that config.cpp adds.
        requiredAddons[] = {"ALIVE_main", "A3_3DEN"};
        versionDesc = "ALiVE";
        //versionAct = "['FNC_ANALYSIS',_this] execVM '\x\alive\addons\main\about.sqf';";
        VERSION_CONFIG;
        author = MODULE_AUTHOR;
        authors[] = {"ARJay"};
        authorUrl = "http://alivemod.com/";
    };
};
class Extended_PreInit_EventHandlers {
    class ADDON {
        init = QUOTE(call COMPILE_FILE(XEH_preInit));
    };
};

