// ----------------------------------------------------------------------------
// CfgALiVEAmbientAnimals
//
// Registry consumed by the shared ALiVE_AnimalChoiceMulti_Poultry and
// ALiVE_AnimalChoiceMulti_Herd controls (see
// fnc_edenAnimalChoiceMultiLoad.sqf). Enumerates known ambient animal
// classnames per source mod, gated by `cfgPatchesName` so animals
// from unloaded mods don't clutter the Eden dropdowns.
//
// Two species categories drive the placement split:
//   - poultry: spawn near civilian buildings inside towns (urban
//              backyard birds: hens, cocks, etc.)
//   - herd:    spawn in open fields outside the town footprint
//              (sheep, goats, etc.)
// The amb_civ_placement runtime reads each category as a separate
// pool and applies different placement geometry.
//
// This class is intentionally open -- any addon (a 3rd-party compat
// PBO, a mission-maker's own mod) can extend the registry by
// declaring additional subclasses in its own config.cpp. No ALiVE
// core changes required to add new mod-specific animal sources.
//
// Schema per subclass:
//   cfgPatchesName (string)  REQUIRED - CfgPatches class to detect.
//                                       Entry skipped if not loaded.
//                                       Use "A3_Characters_F" for
//                                       vanilla A3 (always present)
//                                       or "ALiVE_main" for ALiVE
//                                       core.
//   displayName    (string)  REQUIRED - mod label shown in the
//                                       dropdown entry suffix
//                                       (e.g. "Goat (Arma 3)").
//   class poultry {                     OPTIONAL - urban birds
//       class <ClassName> {
//           displayName (string) REQUIRED - human-readable label.
//       };
//   };
//   class herd {                        OPTIONAL - field flock animals
//       class <ClassName> { displayName = "..."; };
//   };
//
// All classnames matched case-insensitively against CfgVehicles at
// runtime; casing in the registry doesn't matter.
// ----------------------------------------------------------------------------

class CfgALiVEAmbientAnimals {

    // Vanilla A3 -- always loaded. Standard farm animal classes.
    class ALiVE_Vanilla_A3 {
        cfgPatchesName = "A3_Characters_F";
        displayName    = "Arma 3";
        class poultry {
            class Hen_random_F  { displayName = "Hen"; };
            class Cock_random_F { displayName = "Cockerel"; };
        };
        class herd {
            class Goat_random_F  { displayName = "Goat"; };
            class Sheep_random_F { displayName = "Sheep"; };
        };
    };

    // Western Sahara CDLC (Rotators) -- dromedaries placed in the herd
    // pool. Sahara-appropriate large flock animals that spawn in open
    // ground outside town cluster footprints. Four model variants.
    // Patch detection via `characters_F_lxWS` which always loads when
    // the CDLC is active.
    class WS_RotatorsCDLC {
        cfgPatchesName = "characters_F_lxWS";
        displayName    = "Western Sahara";
        class herd {
            class Dromedary_01_lxWS { displayName = "Dromedary (variant 1)"; };
            class Dromedary_02_lxWS { displayName = "Dromedary (variant 2)"; };
            class Dromedary_03_lxWS { displayName = "Dromedary (variant 3)"; };
            class Dromedary_04_lxWS { displayName = "Dromedary (variant 4)"; };
        };
    };

};
