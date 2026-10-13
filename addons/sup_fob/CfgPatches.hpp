class CfgPatches {
    class ADDON {
        units[] = {"ALiVE_FOB_Kit", "ALiVE_FOB_SupplyCrate"};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {"ALIVE_main", "A3_Weapons_F_Ammoboxes"};
        versionDesc = "ALiVE";
        VERSION_CONFIG;
        author = MODULE_AUTHOR;
        authors[] = {"Jman"};
        authorUrl = "http://alivemod.com/";
    };
};
class Extended_PreInit_EventHandlers {
    class ADDON {
        init = QUOTE(call COMPILE_FILE(XEH_preInit));
    };
};
// FOB kits and supply crates by class: made a kit or crate when the server made them
class Extended_Init_EventHandlers {
    class ALiVE_FOB_Kit { class ADDON { init = "['kitInit', [_this select 0]] call ALiVE_fnc_fobOps"; }; };
    class ALiVE_FOB_SupplyCrate { class ADDON { init = "['kitInit', [_this select 0]] call ALiVE_fnc_fobOps"; }; };
};
