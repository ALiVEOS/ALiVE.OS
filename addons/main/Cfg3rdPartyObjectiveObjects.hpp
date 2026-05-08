// ----------------------------------------------------------------------------
// Cfg3rdPartyObjectiveObjects
//
// Registry of static / scenery object classes that ALiVE's objective-placement
// modules can spawn at objectives. Backs GitHub issue #875 ("Add objects to
// objectives") - jammers, radars, antennas, satellite dishes, comms gear,
// signal panels, and similar deployable props.
//
// Each subclass declares a CfgPatches detection key + class arrays. At Eden
// editor / runtime the registry walker (consumed by ALiVE_ObjectiveObjectChoice
// + ALiVE_StaticDataObjectChoice picker controls) keeps only the entries
// whose detection passes, then concatenates the active class arrays into the
// picker pool. Unloaded mods drop out automatically.
//
// This class is intentionally open - any addon (a 3rd-party compat PBO, a
// mission-maker's own mod, a future ALiVE release) can extend the registry
// by declaring additional subclasses in its own config.cpp. No ALiVE core
// changes required to add new mod-specific object sources.
//
// Schema per subclass:
//   cfgPatchesName     (string)  REQUIRED - CfgPatches class to detect via
//                                           isClass (configFile >> "CfgPatches" >> name).
//                                           Use a reliably-present patch from
//                                           the mod (e.g. rhs_main_loadorder,
//                                           pook_SAM_Base, crowsEW_main).
//   detectionClass     (string)  OPTIONAL - fallback CfgVehicles class-
//                                           existence test for cases where
//                                           the mod lacks an obvious patch
//                                           umbrella. Resolver tries
//                                           cfgPatchesName first, then this.
//   displayName        (string)  REQUIRED - human-readable label for logs and
//                                           UI grouping.
//   objectClasses[]    (array)   OPTIONAL - comms / radar / antenna / data-
//                                           terminal / jammer props - the
//                                           primary picker pool.
//   staticDataObjects[] (array)  OPTIONAL - visual signal panels, marker
//                                           panels, casualty indicators -
//                                           sibling picker pool with different
//                                           placement semantics (LZ markers,
//                                           drop signage etc.).
//
// All classnames matched case-insensitively against CfgVehicles at runtime.
//
// Source data: in-game CfgVehicles scan 2026-05-08 across vanilla A3 +
// Contact + Jets DLCs + RHS AFRF/USAF/GREF + Crows Electronic Warfare +
// POOK SAM Pack + POOK Camonets + Expanded Anti Air + Drongos Air Operations.
// 269 raw hits, ~213 retained after stripping false positives (handheld
// weapons, weapon attachments, Logic / Module classes, generic buildings
// matched by displayName only).
// ----------------------------------------------------------------------------

class Cfg3rdPartyObjectiveObjects {

    // ------------------------------------------------------------------------
    // Vanilla Arma 3 + DLC content (always loaded; A3_Data_F_Loadorder is
    // present in every A3 install). Includes Apex, Contact, Jets DLC classes
    // - Arma 3's stub-loading means these resolve via configFile even without
    // DLC ownership (the player just gets a different in-game permission
    // experience when interacting). For scenery placement via createVehicle
    // the classes spawn fine regardless of DLC status.
    //
    // Stripped during triage:
    //   - Item_*_UavTerminal (inventory items - deferred to a future
    //     inventory-loot consumer, see strategy_objective_static_objects_875.md)
    //   - Item_SatPhone (inventory item)
    //   - Item_muzzle_antenna_0[123]_F (Spectrum Device weapon attachments)
    //   - Weapon_hgun_esd_01_* (handheld Spectrum Device family)
    //   - Land_Rail_Signals_F (railway signals - false positive)
    //   - Land_Airport_0[12]_terminal_F (generic airport buildings)
    // ------------------------------------------------------------------------
    class A3_vanilla {
        cfgPatchesName = "A3_Data_F_Loadorder";
        displayName    = "Arma 3 (Vanilla + DLC)";
        objectClasses[] = {
            // Stock A3 - Land_Communication_F shows up under @CBA_A3 attribution
            // because CBA's XEH touches it last, but the class is genuinely
            // vanilla. Including it here.
            "Land_Communication_F",
            "Land_DataTerminal_01_F",
            "Land_Radar_F",
            "Land_Radar_ruins_F",
            "Land_Radar_Small_F",
            "Land_Radar_Small_ruins_F",
            "Land_SatellitePhone_F",
            "Land_TBox_F",
            "Land_TBox_ruins_F",
            "Land_TTowerBig_1_F",
            "Land_TTowerBig_1_ruins_F",
            "Land_TTowerBig_2_F",
            "Land_TTowerBig_2_ruins_F",
            "Land_TTowerSmall_1_F",
            "Land_TTowerSmall_2_F",
            "RuggedTerminal_01_communications_F",
            "RuggedTerminal_01_communications_hub_F",
            "RuggedTerminal_01_F",
            "RuggedTerminal_02_communications_F",

            // Contact DLC (enoch) - Spectrum Device-themed radar complex,
            // mobile radar, satellite antennas, omnidirectional antennas,
            // Comms Offroad variants.
            "B_GEN_Offroad_01_comms_F",
            "C_Offroad_01_comms_F",
            "I_E_Offroad_01_comms_F",
            "I_E_Radar_System_01_F",
            "Land_MobileRadar_01_generator_F",
            "Land_MobileRadar_01_radar_F",
            "Land_MobileRadar_01_radar_ruins_F",
            "Land_Radar_01_airshaft_F",
            "Land_Radar_01_antenna_base_F",
            "Land_Radar_01_antenna_F",
            "Land_Radar_01_cooler_F",
            "Land_Radar_01_HQ_F",
            "Land_Radar_01_HQ_ruins_F",
            "Land_Radar_01_kitchen_F",
            "Land_Radar_01_kitchen_ruins_F",
            "Land_SatelliteAntenna_01_F",
            "OmniDirectionalAntenna_01_black_F",
            "OmniDirectionalAntenna_01_olive_F",
            "OmniDirectionalAntenna_01_sand_F",
            "SatelliteAntenna_01_Black_F",
            "SatelliteAntenna_01_Mounted_Black_F",
            "SatelliteAntenna_01_Mounted_Olive_F",
            "SatelliteAntenna_01_Mounted_Sand_F",
            "SatelliteAntenna_01_Olive_F",
            "SatelliteAntenna_01_Sand_F",
            "SatelliteAntenna_01_Small_Black_F",
            "SatelliteAntenna_01_Small_Mounted_Black_F",
            "SatelliteAntenna_01_Small_Mounted_Olive_F",
            "SatelliteAntenna_01_Small_Mounted_Sand_F",
            "SatelliteAntenna_01_Small_Olive_F",
            "SatelliteAntenna_01_Small_Sand_F",

            // Jets DLC - radar systems for SAM placements
            "B_Radar_System_01_F",
            "O_Radar_System_02_F"
        };
        staticDataObjects[] = {};
    };

    // ------------------------------------------------------------------------
    // Crows Electronic Warfare (Crowdedlight). EW behaviour (jammers, signal
    // sources, radio tracking) is delivered via Eden / Zeus modules that
    // attach to ANY existing object via setVariable hooks - so the mod's
    // value to ALiVE is the placeable PROP classes, not the Logic modules.
    //
    // Stripped:
    //   - crowsEW_editormodules_moduleAddJammer
    //   - crowsEW_editormodules_moduleAddRandomSignalSource
    //   - crowsEW_editormodules_moduleAddSignalSource
    //   (all Module_F-derived Logic classes, not scenery)
    // ------------------------------------------------------------------------
    class CrowsEW {
        cfgPatchesName = "crowsEW_main";
        displayName    = "Crows Electronic Warfare";
        objectClasses[] = {
            "Crows_dataterminal",      // Destructible Apex Data Terminal
            "Crows_Emp_Device"         // EMP Device (slingloadable)
        };
        staticDataObjects[] = {};
    };

    // ------------------------------------------------------------------------
    // POOK SAM Pack. The volume mod - 153 distinct radar / SAM-component /
    // antenna classes covering Cold War / modern Soviet + Western SAM
    // systems with multiple side variants (Base / _BLUFOR / _IND) and camo
    // schemes (Brown / CDF / CHDKZ / Desert / Drab / Jungle / NATO / RUS /
    // TAK / TAN / Woodland) per radar.
    //
    // ALL variants intentionally retained (Jman decision 2026-05-08): the
    // filterable picker (ALiVE_FilteredMultiSelect_Base substrate) handles
    // the listing volume, and mission-makers want to pick the side / camo
    // variant matching their objective faction.
    //
    // Distinct radar models present (each with multiple variants):
    //   1S12, 1S32, 9S36, 30N6E, 30N6E2, 36D6, 64N6E, 76N6, 91N6E, 92N6E,
    //   96L6E, P-12, P-18, PRV-11, PRV-13, PRV-16, SON-9, SON-50, SNR-75,
    //   SA3 (SNR-125), Nebo-SV, Nebo-UE, RADOME large/small (sensor)
    // Plus OE-349 Antenna Mast Group (forest + desert variants).
    // ------------------------------------------------------------------------
    class POOK_SAM {
        cfgPatchesName = "pook_SAM_Base";
        displayName    = "POOK SAM Pack";
        objectClasses[] = {
            // 1S12 EW Radar
            "pook_1S12_Base", "pook_1S12_Base_BLUFOR", "pook_1S12_Base_IND",
            // 1S32 SA-4 Radar
            "pook_1S32_Base", "pook_1S32_Base_BLUFOR", "pook_1S32_Base_IND",
            // 30N6E2 SA-20 Radar (base + 40V6M mast)
            "pook_30N6E2_Base", "pook_30N6E2_Base_BLUFOR", "pook_30N6E2_Base_IND",
            "pook_30N6E2_mast", "pook_30N6E2_mast_BLUFOR", "pook_30N6E2_mast_IND",
            // 30N6E SA-10 Radar (base + 40V6M mast)
            "pook_30N6E_Base", "pook_30N6E_Base_BLUFOR", "pook_30N6E_Base_IND",
            "pook_30N6E_mast", "pook_30N6E_mast_BLUFOR", "pook_30N6E_mast_IND",
            // 36D6 (camo + side variants)
            "pook_36D6_radar", "pook_36D6_radar_INDFOR", "pook_36D6_radar_OPFOR",
            "pook_36D6_radarBROWN_BLUFOR", "pook_36D6_radarBROWN_INDFOR", "pook_36D6_radarBROWN_OPFOR",
            "pook_36D6_radarCDF", "pook_36D6_radarCDF_INDFOR",
            "pook_36D6_radarCHDKZ_BLUFOR", "pook_36D6_radarCHDKZ_INDFOR", "pook_36D6_radarCHDKZ_OPFOR",
            "pook_36D6_radarNATO", "pook_36D6_radarNATO_INDFOR", "pook_36D6_radarNATO_OPFOR",
            "pook_36D6_radarRUS", "pook_36D6_radarRUS_BLUFOR", "pook_36D6_radarRUS_INDFOR",
            "pook_36D6_radarTAK", "pook_36D6_radarTAK_INDFOR",
            // 64N6E (camo variants - Drab/Brown/DesertCamo/Tan, plus side suffixes)
            "pook_64N6E_base", "pook_64N6E_base_BLUFOR", "pook_64N6E_base_IND",
            "pook_64N6E_BROWN", "pook_64N6E_BROWN_BLUFOR", "pook_64N6E_BROWN_IND",
            "pook_64N6E_DESERTCAMO", "pook_64N6E_DESERTCAMO_BLUFOR", "pook_64N6E_DESERTCAMO_IND",
            "pook_64N6E_DRAB", "pook_64N6E_DRAB_BLUFOR", "pook_64N6E_DRAB_IND",
            "pook_64N6E_TAN", "pook_64N6E_TAN_BLUFOR", "pook_64N6E_TAN_IND",
            // 76N6 (same camo set as 36D6)
            "pook_76N6_radar", "pook_76N6_radar_INDFOR", "pook_76N6_radar_OPFOR",
            "pook_76N6_radarBROWN_BLUFOR", "pook_76N6_radarBROWN_INDFOR", "pook_76N6_radarBROWN_OPFOR",
            "pook_76N6_radarCDF", "pook_76N6_radarCDF_INDFOR",
            "pook_76N6_radarCHDKZ_BLUFOR", "pook_76N6_radarCHDKZ_INDFOR", "pook_76N6_radarCHDKZ_OPFOR",
            "pook_76N6_radarNATO", "pook_76N6_radarNATO_INDFOR", "pook_76N6_radarNATO_OPFOR",
            "pook_76N6_radarRUS", "pook_76N6_radarRUS_BLUFOR", "pook_76N6_radarRUS_INDFOR",
            "pook_76N6_radarTAK", "pook_76N6_radarTAK_INDFOR",
            // 91N6E (Drab / Brown / DesertCamo / Tan)
            "pook_91N6E_base", "pook_91N6E_base_BLUFOR", "pook_91N6E_base_IND",
            "pook_91N6E_BROWN", "pook_91N6E_BROWN_BLUFOR", "pook_91N6E_BROWN_IND",
            "pook_91N6E_DESERTCAMO", "pook_91N6E_DESERTCAMO_BLUFOR", "pook_91N6E_DESERTCAMO_IND",
            "pook_91N6E_DRAB", "pook_91N6E_DRAB_BLUFOR", "pook_91N6E_DRAB_IND",
            "pook_91N6E_TAN", "pook_91N6E_TAN_BLUFOR", "pook_91N6E_TAN_IND",
            // 92N6E SA-21 Radar (base + 40V6M mast)
            "pook_92N6E_Base", "pook_92N6E_Base_BLUFOR", "pook_92N6E_Base_IND",
            "pook_92N6E_mast", "pook_92N6E_mast_BLUFOR", "pook_92N6E_mast_IND",
            // 96L6E (same camo set as 36D6/76N6)
            "pook_96L6E_radar", "pook_96L6E_radar_INDFOR", "pook_96L6E_radar_OPFOR",
            "pook_96L6E_radarBROWN_BLUFOR", "pook_96L6E_radarBROWN_INDFOR", "pook_96L6E_radarBROWN_OPFOR",
            "pook_96L6E_radarCDF", "pook_96L6E_radarCDF_INDFOR",
            "pook_96L6E_radarCHDKZ_BLUFOR", "pook_96L6E_radarCHDKZ_INDFOR", "pook_96L6E_radarCHDKZ_OPFOR",
            "pook_96L6E_radarNATO", "pook_96L6E_radarNATO_INDFOR", "pook_96L6E_radarNATO_OPFOR",
            "pook_96L6E_radarRUS", "pook_96L6E_radarRUS_BLUFOR", "pook_96L6E_radarRUS_INDFOR",
            "pook_96L6E_radarTAK", "pook_96L6E_radarTAK_INDFOR",
            // 9S36 SA-11 Radar
            "pook_9S36_Root", "pook_9S36_Root_BLUFOR", "pook_9S36_Root_IND",
            // Nebo (SV + UE, desert only)
            "pook_Nebo_SV_radar", "pook_Nebo_UE_radar",
            // OE-349 Antenna Mast Group
            "pook_OE349", "pook_OE349_DES",
            // P-12 / P-18 / PRV-11/13/16
            "pook_P12_root", "pook_P12_root_BLUFOR", "pook_P12_root_IND",
            "pook_P18_root", "pook_P18_root_BLUFOR", "pook_P18_root_IND",
            "pook_PRV11_base", "pook_PRV11_base_BLUFOR", "pook_PRV11_base_IND",
            "pook_PRV13_base", "pook_PRV13_base_BLUFOR", "pook_PRV13_base_IND",
            "pook_PRV16_base", "pook_PRV16_base_BLUFOR", "pook_PRV16_base_IND",
            // RADOME (large + small, per side)
            "pook_RADOME_BLUFOR", "pook_RADOME_BLUFOR_S",
            "pook_RADOME_CIV", "pook_RADOME_CIV_S",
            "pook_RADOME_IND", "pook_RADOME_IND_S",
            "pook_RADOME_OPFOR", "pook_RADOME_OPFOR_S",
            // SA-3 (SNR-125)
            "pook_SA3_radar_base", "pook_SA3_radar_base_BLUFOR", "pook_SA3_radar_base_IND",
            // SNR-75 / SON-9 / SON-50
            "pook_SNR75_radar_base", "pook_SNR75_radar_base_BLUFOR", "pook_SNR75_radar_base_IND",
            "POOK_SON50_BASE", "POOK_SON50_BASE_BLUFOR", "POOK_SON50_BASE_IND",
            "pook_SON9_base", "pook_SON9_base_BLUFOR", "pook_SON9_base_IND"
        };
        staticDataObjects[] = {};
    };

    // ------------------------------------------------------------------------
    // POOK Camonets - Maghrebi / Vietnam / European camo nets pack also ships
    // a satellite dish + sat phone (radar/comms category) and visual signal
    // panels (LZ / casualty / ammo-request markers).
    //
    // Two-section split: comms props in objectClasses[], visual marker
    // panels in staticDataObjects[] (different consumer per Jman decision
    // 2026-05-08).
    // ------------------------------------------------------------------------
    class POOK_Camonets {
        cfgPatchesName = "pook_camonets";
        displayName    = "POOK Camonets";
        objectClasses[] = {
            "pook_Satellite_dish",
            "pook_SatPhone"
        };
        staticDataObjects[] = {
            "pook_Itemminespanel",         // Mines warning panel
            "pook_Itemsignalpanel1",       // Triangle - Land Here
            "pook_Itemsignalpanel2",       // Arrow ->
            "pook_Itemsignalpanel3",       // X - Unable / Negative
            "pook_Itemsignalpanel4",       // W - Require Mechanic
            "pook_Itemsignalpanel5",       // >> - Require Ammo
            "pook_Itemsignalpanel6",       // I - Require Medical Assistance
            "pook_Itemsignalpanel7",       // L - Require Fuel
            "pook_signalmarkerammobox"     // Signal Panels - Crate
        };
    };

    // ------------------------------------------------------------------------
    // RHS Escalation - AFRF (Armed Forces of the Russian Federation).
    // Detection key is rhs_main_loadorder, the canonical final-loaded patch
    // RHS uses to gate addon presence.
    //
    // Object set: Soviet / Russian air-defence radars + antenna masts.
    //   P-37  - Soviet air-search radar
    //   PRV-13 - height-finder radar
    //   2-P-3 - mast antenna
    //   V-2 / V-3 - antenna masts
    // ------------------------------------------------------------------------
    class RHS_AFRF {
        cfgPatchesName = "rhs_main_loadorder";
        displayName    = "RHS: AFRF";
        objectClasses[] = {
            "rhs_2P3_1",                   // 2-P-3 mast variant 1
            "rhs_2P3_2",                   // 2-P-3 mast variant 2
            "rhs_p37",                     // P-37 air-search radar
            "rhs_p37_turret_vpvo",         // P-37 (VPVO turret)
            "rhs_prv13",                   // PRV-13 height-finder
            "rhs_prv13_turret_vpvo",       // PRV-13 (VPVO turret)
            "rhs_v2",                      // V-2 antenna mast
            "rhs_v3"                       // V-3 antenna mast
        };
        staticDataObjects[] = {};
    };

    // ------------------------------------------------------------------------
    // RHS Escalation - USAF (United States Armed Forces).
    // Detection key is rhsusf_main_loadorder.
    //
    // Object set: AN/PRC-152 radio prop + DUKE jammer antenna props (broken
    // variants, suitable as battlefield-debris scenery near US vehicles).
    // ------------------------------------------------------------------------
    class RHS_USAF {
        cfgPatchesName = "rhsusf_main_loadorder";
        displayName    = "RHS: USAF";
        objectClasses[] = {
            "rhsusf_duke_d",               // Broken DUKE antenna (desert)
            "rhsusf_duke_m1a2_d",          // Broken DUKE antenna (long, M1A2 mount, desert)
            "rhsusf_duke_m1a2_wd",         // Broken DUKE antenna (long, M1A2 mount, woodland)
            "rhsusf_duke_wd",              // Broken DUKE antenna (woodland)
            "rhsusf_props_anprc152"        // AN/PRC-152 radio prop
        };
        staticDataObjects[] = {};
    };

    // ------------------------------------------------------------------------
    // RHS Escalation - GREF (mostly mid-tier nation forces).
    // Detection key is rhsgref_main_loadorder.
    //
    // Object set: Turkish SERHAT short-range air-defence radar (woodland +
    // desert variants).
    // ------------------------------------------------------------------------
    class RHS_GREF {
        cfgPatchesName = "rhsgref_main_loadorder";
        displayName    = "RHS: GREF";
        objectClasses[] = {
            "rhsgref_serhat_radar",        // SERHAT radar (woodland)
            "rhsgref_serhat_radar_d"       // SERHAT radar (desert)
        };
        staticDataObjects[] = {};
    };

    // ------------------------------------------------------------------------
    // Drongos Air Operations.
    // Detection key is DrongosAirOps (no _main suffix - mod uses the umbrella
    // class directly). Sister patch DrongosAirOpsGunship covers gunship
    // sub-content; not relevant to the radar prop the mod contributes.
    //
    // Object set: AN/MPQ-105 Radar (DRA_ replacement of vanilla I_E_Radar_System_01_F).
    //
    // Stripped:
    //   - DAO_NoComms (Module_F-derived, suppresses comms hints - UI logic)
    //   - DAO_RadarHintOff (Module_F-derived, suppresses radar hints - UI logic)
    // ------------------------------------------------------------------------
    class Drongos {
        cfgPatchesName = "DrongosAirOps";
        displayName    = "Drongos Air Operations";
        objectClasses[] = {
            "DRA_I_Radar_System_01_F"      // AN/MPQ-105 Radar (Drongos variant)
        };
        staticDataObjects[] = {};
    };

    // ------------------------------------------------------------------------
    // Expanded Anti Air (EAA) - vanilla-asset retexture / re-deployment mod.
    // Detection key is EAA (umbrella class, no suffix).
    //
    // Notable: EAA's CfgPatches units[] array RE-DECLARES vanilla NYX class
    // names (B_LT_01_scout_F, B_T_LT_01_scout_F) - those classes spawn the
    // EAA radar variant when EAA is loaded, vanilla NYX otherwise. Including
    // them in this block means the picker only surfaces them when EAA is
    // actually loaded (correct UX).
    //
    // Object set: HEMTT Radar (NATO + Pacific + AAF variants), AWC 302 Nyx
    // Radar, AN/MPQ-105 Radar (NATO Pacific), R-750 Cronus Radar, Tempest
    // Radar (CSAT + Pacific).
    // ------------------------------------------------------------------------
    class EAA {
        cfgPatchesName = "EAA";
        displayName    = "Expanded Anti Air";
        objectClasses[] = {
            "B_LT_01_scout_F",                   // AWC 302 Nyx (Radar) - NATO
            "B_T_LT_01_scout_F",                 // AWC 302 Nyx (Radar) - NATO Pacific
            "B_T_Radar_System_01_F",             // AN/MPQ-105 Radar - NATO Pacific
            "B_T_Truck_01_radar_F",              // HEMTT Radar - NATO Pacific
            "B_T_Truck_01_radar_F_deployed",     // HEMTT Radar (Deployed) - NATO Pacific
            "B_Truck_01_radar_F",                // HEMTT Radar - NATO
            "B_Truck_01_radar_F_deployed",       // HEMTT Radar (Deployed) - NATO
            "I_E_Truck_01_radar_F",              // HEMTT Radar - LDF
            "I_E_Truck_01_radar_F_deployed",     // HEMTT Radar (Deployed) - LDF
            "O_T_Radar_System_02_F_CSAT",        // R-750 Cronus Radar - CSAT Pacific
            "O_T_Truck_03_Radar_F_CSAT",         // Tempest Radar - CSAT Pacific
            "O_Truck_03_Radar_F_CSAT"            // Tempest Radar - CSAT
        };
        staticDataObjects[] = {};
    };

};
