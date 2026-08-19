// Simply a package which requires other addons.
class CfgPatches {
    class ADDON {
        units[] = { };
        weapons[] = { };
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = { "A3_Modules_F", "cba_xeh_a3", "CBA_events" };
        versionDesc = "ALiVE";
        //versionAct = "['MAIN',_this] execVM '\x\alive\addons\main\about.sqf';";
        VERSION_CONFIG;
        // Read back at startup alongside the version. Kept in the config rather
        // than read from the macro so it comes from what was actually packed:
        // with file patching on, loose source and packed config can disagree.
        buildType = BUILDTYPE;
        author = MODULE_AUTHOR;
        authors[] = {
            "AndrewKhan",
            "ARJay",
            "Friznit",
            "Gunny",
            "Hazey",
            "HighHead",
            "Javen",
            "Jman",
            "Naught",
            "Raptor",
            "Rye",
            "Secure",
            "SpyderBlack",
            "Tupolov",
            "WobbleyHeadedBob",
            "Wolffy_au"
        };
        authorUrl = "http://alivemod.com/";
    };
};

