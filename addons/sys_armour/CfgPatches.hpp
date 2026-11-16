// ALiVE's own armour and ammo values for other mods' kit (RHS first).
// No dependency on RHS or ACE: the data below is ALiVE's own config, and the
// values are applied at mission start, only when a set's mod is loaded and its
// ALiVE Addon Options switch is on.
class CfgPatches {
    class ADDON {
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {"ALIVE_main","cba_settings","cba_xeh_a3"};
        versionDesc = "ALiVE";
        VERSION_CONFIG;
        author = MODULE_AUTHOR;
        authors[] = {"Jman"};
        authorUrl = "http://alivemod.com/";
    };
};
