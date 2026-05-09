// ----------------------------------------------------------------------------
// Cfg3rdPartyObjectiveObjects
//
// Registry of 3rd-party static / scenery object classes that ALiVE's
// objective-placement modules can spawn at objectives. Backs GitHub issue
// #875 ("Add objects to objectives") - jammers, radars, antennas,
// satellite dishes, comms gear, signal panels, and similar deployable
// props.
//
// Each subclass declares a CfgPatches detection key + per-category class
// arrays. At Eden editor / runtime the registry walker (consumed by
// ALiVE_ObjectiveObjectChoice picker control) keeps only the entries
// whose detection passes, then concatenates the surviving class arrays
// into the picker pool. Unloaded mods drop out automatically.
//
// This class is intentionally open - any addon (a 3rd-party compat PBO,
// a mission-maker's own mod, a future ALiVE release) can extend the
// registry by declaring additional subclasses in its own config.cpp.
// No ALiVE core changes required to add new mod-specific object sources.
//
// Schema per subclass:
//   cfgPatchesName     (string)  REQUIRED - CfgPatches class to detect via
//                                           isClass (configFile >> "CfgPatches" >> name).
//   detectionClass     (string)  OPTIONAL - fallback CfgVehicles class-
//                                           existence test for cases where
//                                           the mod lacks an obvious patch
//                                           umbrella.
//   displayName        (string)  REQUIRED - human-readable label for logs
//                                           and picker UI grouping.
//   radar[]            (array)   OPTIONAL - radar systems (air-search,
//                                           height-finder, SAM-component,
//                                           radome / dish / generator
//                                           pieces of radar complexes).
//   antenna[]          (array)   OPTIONAL - antennas (transmitter towers /
//                                           poles, omnidirectional, satellite
//                                           antennas, mast antennas).
//   dataTerminal[]     (array)   OPTIONAL - interactive data / rugged
//                                           terminals.
//   jammer[]           (array)   OPTIONAL - EMP / electronic-warfare /
//                                           jammer-themed props (DUKE
//                                           antennas, EMP devices).
//   comms[]            (array)   OPTIONAL - generic comms gear (transmitter
//                                           boxes, satellite phones, comms-
//                                           variant vehicles, radio props,
//                                           generators).
//   staticData[]       (array)   OPTIONAL - visual signal panels, marker
//                                           panels, casualty indicators
//                                           (different placement semantics
//                                           than the radar / antenna props
//                                           above - typically LZ markers,
//                                           drop signage etc.).
//
// All classnames matched case-insensitively against CfgVehicles at
// runtime.
//
// Source data: in-game CfgVehicles scan 2026-05-08 across vanilla A3 +
// Contact + Jets DLCs + RHS AFRF/USAF/GREF + Crows Electronic Warfare +
// POOK SAM Pack + POOK Camonets + Expanded Anti Air + Drongos Air
// Operations. 269 raw hits, ~246 retained after stripping false positives
// (handheld weapons, weapon attachments, Logic / Module classes, generic
// buildings false-matched on displayName only).
//
// Per-category counts (across all 9 mod blocks):
//   radar=190 antenna=26 dataTerminal=6 jammer=5 comms=10 staticData=9
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
        radar[] = {
            // Stock A3
            "Land_Radar_F",
            "Land_Radar_ruins_F",
            "Land_Radar_Small_F",
            "Land_Radar_Small_ruins_F",

            // Contact DLC (enoch) - Mobile Radar truck + Radar Complex pieces
            "Land_MobileRadar_01_radar_F",
            "Land_MobileRadar_01_radar_ruins_F",
            "Land_Radar_01_airshaft_F",
            "Land_Radar_01_antenna_F",
            "Land_Radar_01_antenna_base_F",
            "Land_Radar_01_cooler_F",
            "Land_Radar_01_HQ_F",
            "Land_Radar_01_HQ_ruins_F",
            "Land_Radar_01_kitchen_F",
            "Land_Radar_01_kitchen_ruins_F",
            "I_E_Radar_System_01_F",            // LDF AN/MPQ-105

            // Jets DLC
            "B_Radar_System_01_F",              // AN/MPQ-105 NATO
            "O_Radar_System_02_F"               // R-750 Cronus CSAT
        };
        antenna[] = {
            // Stock A3 Transmitter Towers / Poles
            "Land_TTowerBig_1_F",
            "Land_TTowerBig_1_ruins_F",
            "Land_TTowerBig_2_F",
            "Land_TTowerBig_2_ruins_F",
            "Land_TTowerSmall_1_F",
            "Land_TTowerSmall_2_F",

            // Contact DLC Satellite + Omnidirectional antennas
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
            "SatelliteAntenna_01_Small_Sand_F"
        };
        dataTerminal[] = {
            "Land_DataTerminal_01_F",
            "RuggedTerminal_01_communications_F",
            "RuggedTerminal_01_communications_hub_F",
            "RuggedTerminal_01_F",
            "RuggedTerminal_02_communications_F"
        };
        jammer[] = {};
        comms[] = {
            // Stock A3
            "Land_Communication_F",                  // Comms Tower (CBA-attributed but vanilla)
            "Land_TBox_F",                           // Transmitter Box
            "Land_TBox_ruins_F",
            "Land_SatellitePhone_F",                 // Satellite Phone (placeable structure)

            // Contact DLC Comms Offroad variants + Mobile Radar generator
            "B_GEN_Offroad_01_comms_F",              // Offroad (Comms) - Government
            "C_Offroad_01_comms_F",                  // Offroad (Comms) - Civilian
            "I_E_Offroad_01_comms_F",                // Offroad (Comms) - LDF
            "Land_MobileRadar_01_generator_F"        // Mobile Radar generator (utility)
        };
        staticData[] = {};
    };

    // ------------------------------------------------------------------------
    // Crows Electronic Warfare (Crowdedlight). EW behaviour (jammers,
    // signal sources, radio tracking) is delivered via Eden / Zeus modules
    // that attach to ANY existing object via setVariable hooks - so the
    // mod's value to ALiVE is the placeable PROP classes, not the Logic
    // modules.
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
        radar[] = {};
        antenna[] = {};
        dataTerminal[] = {
            "Crows_dataterminal"           // Destructible Apex Data Terminal
        };
        jammer[] = {
            "Crows_Emp_Device"             // EMP Device (slingloadable)
        };
        comms[] = {};
        staticData[] = {};
    };

    // ------------------------------------------------------------------------
    // POOK SAM Pack. The volume mod - 153 distinct radar / SAM-component
    // classes covering Cold War / modern Soviet + Western SAM systems with
    // multiple side variants (Base / _BLUFOR / _IND) and camo schemes
    // (Brown / CDF / CHDKZ / Desert / Drab / Jungle / NATO / RUS / TAK /
    // TAN / Woodland) per radar.
    //
    // ALL variants intentionally retained (Jman decision 2026-05-08): the
    // filterable picker (ALiVE_FilteredMultiSelect_Base substrate) handles
    // the listing volume, and mission-makers want to pick the side / camo
    // variant matching their objective faction.
    //
    // Distinct radar models present:
    //   1S12, 1S32, 9S36, 30N6E, 30N6E2, 36D6, 64N6E, 76N6, 91N6E, 92N6E,
    //   96L6E, P-12, P-18, PRV-11, PRV-13, PRV-16, SON-9, SON-50, SNR-75,
    //   SA3 (SNR-125), Nebo-SV, Nebo-UE, RADOME large/small (sensor)
    // Plus OE-349 Antenna Mast Group (forest + desert variants).
    //
    // OE-349 sits under antenna[] not radar[] - it's an antenna mast,
    // physically distinct from the radar dishes / arrays elsewhere in the
    // pack.
    // ------------------------------------------------------------------------
    class POOK_SAM {
        cfgPatchesName = "pook_SAM_Base";
        displayName    = "POOK SAM Pack";
        radar[] = {
            "pook_1S12_Base", "pook_1S12_Base_BLUFOR", "pook_1S12_Base_IND",
            "pook_1S32_Base", "pook_1S32_Base_BLUFOR", "pook_1S32_Base_IND",
            "pook_30N6E2_Base", "pook_30N6E2_Base_BLUFOR", "pook_30N6E2_Base_IND",
            "pook_30N6E2_mast", "pook_30N6E2_mast_BLUFOR", "pook_30N6E2_mast_IND",
            "pook_30N6E_Base", "pook_30N6E_Base_BLUFOR", "pook_30N6E_Base_IND",
            "pook_30N6E_mast", "pook_30N6E_mast_BLUFOR", "pook_30N6E_mast_IND",
            "pook_36D6_radar", "pook_36D6_radar_INDFOR", "pook_36D6_radar_OPFOR",
            "pook_36D6_radarBROWN_BLUFOR", "pook_36D6_radarBROWN_INDFOR", "pook_36D6_radarBROWN_OPFOR",
            "pook_36D6_radarCDF", "pook_36D6_radarCDF_INDFOR",
            "pook_36D6_radarCHDKZ_BLUFOR", "pook_36D6_radarCHDKZ_INDFOR", "pook_36D6_radarCHDKZ_OPFOR",
            "pook_36D6_radarNATO", "pook_36D6_radarNATO_INDFOR", "pook_36D6_radarNATO_OPFOR",
            "pook_36D6_radarRUS", "pook_36D6_radarRUS_BLUFOR", "pook_36D6_radarRUS_INDFOR",
            "pook_36D6_radarTAK", "pook_36D6_radarTAK_INDFOR",
            "pook_64N6E_base", "pook_64N6E_base_BLUFOR", "pook_64N6E_base_IND",
            "pook_64N6E_BROWN", "pook_64N6E_BROWN_BLUFOR", "pook_64N6E_BROWN_IND",
            "pook_64N6E_DESERTCAMO", "pook_64N6E_DESERTCAMO_BLUFOR", "pook_64N6E_DESERTCAMO_IND",
            "pook_64N6E_DRAB", "pook_64N6E_DRAB_BLUFOR", "pook_64N6E_DRAB_IND",
            "pook_64N6E_TAN", "pook_64N6E_TAN_BLUFOR", "pook_64N6E_TAN_IND",
            "pook_76N6_radar", "pook_76N6_radar_INDFOR", "pook_76N6_radar_OPFOR",
            "pook_76N6_radarBROWN_BLUFOR", "pook_76N6_radarBROWN_INDFOR", "pook_76N6_radarBROWN_OPFOR",
            "pook_76N6_radarCDF", "pook_76N6_radarCDF_INDFOR",
            "pook_76N6_radarCHDKZ_BLUFOR", "pook_76N6_radarCHDKZ_INDFOR", "pook_76N6_radarCHDKZ_OPFOR",
            "pook_76N6_radarNATO", "pook_76N6_radarNATO_INDFOR", "pook_76N6_radarNATO_OPFOR",
            "pook_76N6_radarRUS", "pook_76N6_radarRUS_BLUFOR", "pook_76N6_radarRUS_INDFOR",
            "pook_76N6_radarTAK", "pook_76N6_radarTAK_INDFOR",
            "pook_91N6E_base", "pook_91N6E_base_BLUFOR", "pook_91N6E_base_IND",
            "pook_91N6E_BROWN", "pook_91N6E_BROWN_BLUFOR", "pook_91N6E_BROWN_IND",
            "pook_91N6E_DESERTCAMO", "pook_91N6E_DESERTCAMO_BLUFOR", "pook_91N6E_DESERTCAMO_IND",
            "pook_91N6E_DRAB", "pook_91N6E_DRAB_BLUFOR", "pook_91N6E_DRAB_IND",
            "pook_91N6E_TAN", "pook_91N6E_TAN_BLUFOR", "pook_91N6E_TAN_IND",
            "pook_92N6E_Base", "pook_92N6E_Base_BLUFOR", "pook_92N6E_Base_IND",
            "pook_92N6E_mast", "pook_92N6E_mast_BLUFOR", "pook_92N6E_mast_IND",
            "pook_96L6E_radar", "pook_96L6E_radar_INDFOR", "pook_96L6E_radar_OPFOR",
            "pook_96L6E_radarBROWN_BLUFOR", "pook_96L6E_radarBROWN_INDFOR", "pook_96L6E_radarBROWN_OPFOR",
            "pook_96L6E_radarCDF", "pook_96L6E_radarCDF_INDFOR",
            "pook_96L6E_radarCHDKZ_BLUFOR", "pook_96L6E_radarCHDKZ_INDFOR", "pook_96L6E_radarCHDKZ_OPFOR",
            "pook_96L6E_radarNATO", "pook_96L6E_radarNATO_INDFOR", "pook_96L6E_radarNATO_OPFOR",
            "pook_96L6E_radarRUS", "pook_96L6E_radarRUS_BLUFOR", "pook_96L6E_radarRUS_INDFOR",
            "pook_96L6E_radarTAK", "pook_96L6E_radarTAK_INDFOR",
            "pook_9S36_Root", "pook_9S36_Root_BLUFOR", "pook_9S36_Root_IND",
            "pook_Nebo_SV_radar", "pook_Nebo_UE_radar",
            "pook_P12_root", "pook_P12_root_BLUFOR", "pook_P12_root_IND",
            "pook_P18_root", "pook_P18_root_BLUFOR", "pook_P18_root_IND",
            "pook_PRV11_base", "pook_PRV11_base_BLUFOR", "pook_PRV11_base_IND",
            "pook_PRV13_base", "pook_PRV13_base_BLUFOR", "pook_PRV13_base_IND",
            "pook_PRV16_base", "pook_PRV16_base_BLUFOR", "pook_PRV16_base_IND",
            "pook_RADOME_BLUFOR", "pook_RADOME_BLUFOR_S",
            "pook_RADOME_CIV", "pook_RADOME_CIV_S",
            "pook_RADOME_IND", "pook_RADOME_IND_S",
            "pook_RADOME_OPFOR", "pook_RADOME_OPFOR_S",
            "pook_SA3_radar_base", "pook_SA3_radar_base_BLUFOR", "pook_SA3_radar_base_IND",
            "pook_SNR75_radar_base", "pook_SNR75_radar_base_BLUFOR", "pook_SNR75_radar_base_IND",
            "POOK_SON50_BASE", "POOK_SON50_BASE_BLUFOR", "POOK_SON50_BASE_IND",
            "pook_SON9_base", "pook_SON9_base_BLUFOR", "pook_SON9_base_IND"
        };
        antenna[] = {
            "pook_OE349",                  // OE-349 Antenna Mast Group (forest)
            "pook_OE349_DES"               // OE-349 Antenna Mast Group (desert)
        };
        dataTerminal[] = {};
        jammer[] = {};
        comms[] = {};
        staticData[] = {};
    };

    // ------------------------------------------------------------------------
    // POOK Camonets - Maghrebi / Vietnam / European camo nets pack also
    // ships a satellite dish + sat phone (comms category) and visual
    // signal panels (LZ / casualty / ammo-request markers).
    //
    // Two-section split: comms props in comms[], visual marker panels in
    // staticData[] (different consumer per Jman decision 2026-05-08:
    // signal panels have different placement semantics than scenery
    // radars / antennas).
    // ------------------------------------------------------------------------
    class POOK_Camonets {
        cfgPatchesName = "pook_camonets";
        displayName    = "POOK Camonets";
        radar[] = {};
        antenna[] = {};
        dataTerminal[] = {};
        jammer[] = {};
        comms[] = {
            "pook_Satellite_dish",         // Satellite Dish (tall)
            "pook_SatPhone"                // Satellite Phone (placeable)
        };
        staticData[] = {
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
    //   P-37 / PRV-13 - air-search + height-finder radars
    //   2-P-3 / V-2 / V-3 - antenna masts
    // ------------------------------------------------------------------------
    class RHS_AFRF {
        cfgPatchesName = "rhs_main_loadorder";
        displayName    = "RHS: AFRF";
        radar[] = {
            "rhs_p37",                     // P-37 air-search radar
            "rhs_p37_turret_vpvo",         // P-37 (VPVO turret)
            "rhs_prv13",                   // PRV-13 height-finder
            "rhs_prv13_turret_vpvo"        // PRV-13 (VPVO turret)
        };
        antenna[] = {
            "rhs_2P3_1",                   // 2-P-3 mast variant 1
            "rhs_2P3_2",                   // 2-P-3 mast variant 2
            "rhs_v2",                      // V-2 antenna mast
            "rhs_v3"                       // V-3 antenna mast
        };
        dataTerminal[] = {};
        jammer[] = {};
        comms[] = {};
        staticData[] = {};
    };

    // ------------------------------------------------------------------------
    // RHS Escalation - USAF (United States Armed Forces).
    // Detection key is rhsusf_main_loadorder.
    //
    // Object set: AN/PRC-152 radio prop (comms) + DUKE jammer antenna props
    // (broken variants, suitable as battlefield-debris scenery near US
    // vehicles - the broken state actually fits the EW / IED counter-
    // measure narrative, since the antennas were destroyed during EW
    // operations).
    // ------------------------------------------------------------------------
    class RHS_USAF {
        cfgPatchesName = "rhsusf_main_loadorder";
        displayName    = "RHS: USAF";
        radar[] = {};
        antenna[] = {};
        dataTerminal[] = {};
        jammer[] = {
            "rhsusf_duke_d",               // Broken DUKE antenna (desert)
            "rhsusf_duke_m1a2_d",          // Broken DUKE antenna (long, M1A2 mount, desert)
            "rhsusf_duke_m1a2_wd",         // Broken DUKE antenna (long, M1A2 mount, woodland)
            "rhsusf_duke_wd"               // Broken DUKE antenna (woodland)
        };
        comms[] = {
            "rhsusf_props_anprc152"        // AN/PRC-152 radio prop
        };
        staticData[] = {};
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
        radar[] = {
            "rhsgref_serhat_radar",        // SERHAT radar (woodland)
            "rhsgref_serhat_radar_d"       // SERHAT radar (desert)
        };
        antenna[] = {};
        dataTerminal[] = {};
        jammer[] = {};
        comms[] = {};
        staticData[] = {};
    };

    // ------------------------------------------------------------------------
    // Drongos Air Operations.
    // Detection key is DrongosAirOps (no _main suffix - mod uses the
    // umbrella class directly).
    //
    // Object set: AN/MPQ-105 Radar (DRA_ replacement of vanilla
    // I_E_Radar_System_01_F).
    //
    // Stripped:
    //   - DAO_NoComms (Module_F-derived, suppresses comms hints - UI logic)
    //   - DAO_RadarHintOff (Module_F-derived, suppresses radar hints - UI logic)
    // ------------------------------------------------------------------------
    class Drongos {
        cfgPatchesName = "DrongosAirOps";
        displayName    = "Drongos Air Operations";
        radar[] = {
            "DRA_I_Radar_System_01_F"      // AN/MPQ-105 Radar (Drongos variant)
        };
        antenna[] = {};
        dataTerminal[] = {};
        jammer[] = {};
        comms[] = {};
        staticData[] = {};
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
    // Object set: HEMTT Radar (NATO + Pacific + LDF variants), AWC 302 Nyx
    // Radar, AN/MPQ-105 Radar (NATO Pacific), R-750 Cronus Radar, Tempest
    // Radar (CSAT + Pacific). All radars.
    // ------------------------------------------------------------------------
    class EAA {
        cfgPatchesName = "EAA";
        displayName    = "Expanded Anti Air";
        radar[] = {
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
        antenna[] = {};
        dataTerminal[] = {};
        jammer[] = {};
        comms[] = {};
        staticData[] = {};
    };

};
