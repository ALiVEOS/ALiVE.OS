// ----------------------------------------------------------------------------
// CfgALiVEC2ISTARAccessItems
//
// Registry consumed by the ALiVE_C2ISTARAccessItemsChoice multi-select
// control (see fnc_edenC2ISTARAccessItemsLoad.sqf) and the runtime
// gate in mil_c2istar's fnc_C2MenuDef.sqf. Each subclass = one
// equipment CATEGORY (laser designators / radios / binoculars /
// ALiVE tablets / GPS-UAV terminal / ...).
//
// Mission-makers tick categories in Eden; the runtime grants C2ISTAR
// access if the player carries ANY classname listed under ANY ticked
// category.
//
// This class is intentionally open -- 3rd-party compat PBOs and
// mission-maker mods can extend it by declaring additional subclasses
// (their own category, or supplementary classname entries via a
// suffixed subclass like LaserDesignators_RHS) in their own config.
//
// Schema per subclass:
//   displayName    (string)  REQUIRED - row label shown in the listbox.
//   cfgPatchesName (string)  REQUIRED - addon-loaded gate. Category
//                                       is hidden from the listbox if
//                                       this CfgPatches class isn't
//                                       loaded. Use "A3_Characters_F"
//                                       for vanilla A3 (always
//                                       present) or "ALiVE_main" for
//                                       ALiVE core items.
//   classnames[]   (array)   REQUIRED - inventory classnames the
//                                       runtime checks against the
//                                       player's assignedItems +
//                                       items + backpack.
//
// Matching is case-insensitive substring at runtime (mirrors the
// existing fnc_C2MenuDef behaviour), so an entry "LaserDesignator"
// also matches mod-specific subclasses like
// "LaserDesignator_01_khk_F" without needing each variant listed.
// ----------------------------------------------------------------------------

class CfgALiVEC2ISTARAccessItems {

    class LaserDesignators {
        displayName    = "Laser Designators";
        cfgPatchesName = "A3_Characters_F";
        classnames[]   = {"LaserDesignator"};
    };

    class Radios {
        displayName    = "Radios";
        cfgPatchesName = "A3_Characters_F";
        classnames[]   = {"ItemRadio"};
    };

    class Binoculars {
        displayName    = "Binoculars / Range Finders";
        cfgPatchesName = "A3_Characters_F";
        classnames[]   = {"Binocular", "Rangefinder"};
    };

    class Tablets {
        displayName    = "ALiVE Tablet";
        cfgPatchesName = "ALiVE_main";
        classnames[]   = {"ALiVE_Tablet"};
    };

    class GPS {
        displayName    = "GPS / UAV Terminal";
        cfgPatchesName = "A3_Characters_F";
        classnames[]   = {"ItemGPS", "B_UavTerminal", "O_UavTerminal", "I_UavTerminal"};
    };

    // ACE3 radios. Picked up only when ACE3 is loaded.
    class ACE3_Radios {
        displayName    = "Radios (ACE3)";
        cfgPatchesName = "ace_main";
        classnames[]   = {"ACRE_PRC343", "ACRE_PRC152", "ACE_RadioBackpack", "ACE_PRC117F", "ACE_PRC148", "ACE_PRC152", "ACE_PRC77", "ACE_SEM52SL", "ACE_SEM70"};
    };

    // Task Force Arrowhead Radio (TFAR) entries. Picked up only when
    // TFAR is loaded.
    class TFAR_Radios {
        displayName    = "Radios (TFAR)";
        cfgPatchesName = "task_force_radio";
        classnames[]   = {"tf_anprc152", "tf_anprc148jem", "tf_anprc154", "tf_microdagr", "tf_rt1523g", "tf_anarc210", "tf_pnr1000a", "tf_fadak"};
    };

};
