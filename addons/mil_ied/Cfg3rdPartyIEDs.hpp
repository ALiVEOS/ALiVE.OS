// ----------------------------------------------------------------------------
// Cfg3rdPartyIEDs
//
// Registry of 3rd-party IED integrations that ALiVE's mil_ied module should
// recognise at runtime. The module walks this class at init, keeps only the
// entries whose `cfgPatchesName` is actually loaded (via
// `isClass (configFile >> "CfgPatches" >> cfgPatchesName)`), and can merge
// the declared class lists into the runtime IED pools.
//
// This class is intentionally open - ANY addon (a 3rd-party compat PBO, a
// mission-maker's own mod, or a future ALiVE release) can extend the
// registry by declaring additional subclasses in its own config.cpp. No
// ALiVE core changes required.
//
// Schema per subclass:
//   cfgPatchesName    (string)  REQUIRED - CfgPatches class name to detect.
//   displayName       (string)  REQUIRED - human-readable label for logs and UI.
//   mode              (string)  REQUIRED - runtime arming semantics:
//                                 "alive"      - full ALiVE pipeline
//                                                (proximity accumulator,
//                                                custom disarm, demo charge
//                                                attached, Disarm IED action).
//                                 "mine"       - placed via createVehicle;
//                                                ALiVE skips arming/disarm and
//                                                delegates detonation to the
//                                                3rd-party system. Inert with
//                                                pressure-mine classes that
//                                                aren't auto-armed - prefer
//                                                "alive" + stompRadius for
//                                                those, or "engineMine" below.
//                                 "passive"    - placed via createVehicle; no
//                                                ALiVE pipeline, no demo
//                                                charge, no Disarm IED action.
//                                                Engine handles damage via
//                                                collision physics. For
//                                                contact-damage traps that
//                                                aren't explosive (e.g. SOG
//                                                Prairie Fire punji sticks).
//                                 "engineMine" - placed via CREATEMINE (not
//                                                createVehicle), so the engine
//                                                arms the object as a real
//                                                mine. No ALiVE pipeline, no
//                                                demo charge, no Disarm IED
//                                                action. For tripwire mines
//                                                and pressure mines that the
//                                                engine should fully manage
//                                                (RHS OZM-72, SOG booby
//                                                traps).
//
//   The placementZ / chargeOffsetZ / stompRadius fields below only apply in
//   "alive" mode. For passive / engineMine they're ignored.
//   roadIEDClasses[]  (array)   optional - classes to append to the road
//                                          IED pool when this integration
//                                          is active.
//   urbanIEDClasses[] (array)   optional - classes to append to the urban
//                                          IED pool when this integration
//                                          is active.
//   clutterClasses[]  (array)   optional - classes to append to the clutter
//                                          pool when this integration is
//                                          active.
//   detonator[]       (array)   optional - magazine/ammo classes used for
//                                          detonation - reserved for future
//                                          disarm/recovery logic.
//   placementZ        (number)  optional - vertical placement offset for the
//                                          IED entity. Default: -0.1 (buried,
//                                          matches ALiVE's classic
//                                          trash-pile-with-bomb-inside look).
//                                          Override to 0 / +0.05 for visible
//                                          mine entities (RHS, etc.) so they
//                                          aren't hidden under terrain.
//   chargeOffsetZ     (number)  optional - Z offset of the attached
//                                          ALIVE_DemoCharge_Remote_Ammo
//                                          relative to the IED. Default: 0
//                                          (charge sits on top of IED, fine
//                                          for trash-pile visuals). Override
//                                          to negative (e.g. -0.3) for
//                                          visible mine entities so the
//                                          charge is buried out of sight and
//                                          only the mine is visible. The
//                                          shoot-to-detonate damage handler
//                                          is mirrored to the mine itself in
//                                          this case so a buried charge
//                                          doesn't break that path.
//   stompRadius       (number)  optional - distance (m) at which a relevant
//                                          unit (player, or AI when
//                                          AI_Triggerable=Yes) instantly
//                                          triggers the IED, BYPASSING the
//                                          engineer trip-accumulator. Use for
//                                          pressure-mine integrations (RHS
//                                          PMN-2, PFM-1, etc.) where the
//                                          real-world trigger is "step on
//                                          it". Default: 0 (no stomp check;
//                                          accumulator alone). The disarm
//                                          addAction range (3m) is still
//                                          larger than typical stomp radii
//                                          so engineers can defuse from a
//                                          safe stand-off distance.
//
// Phase-1 note: the arrays above are defined for forward compatibility but
// are not yet consumed by the placement pipeline. The Object Classes merge
// work is Phase 3 of the auto-detection strategy. For now this registry is
// used for detection + logging only.
// ----------------------------------------------------------------------------

class Cfg3rdPartyIEDs {

    // Baseline vanilla Arma 3 entry. Always detected (A3_Weapons_F_Explosives
    // is part of the base game so isClass always returns true). Serves as:
    //   - a reference schema example for community extensions,
    //   - a detection smoke test at init time,
    //   - documentation that ALiVE's compile-time default class lists
    //     already cover the vanilla case (so no class arrays needed here).
    class ALiVE_Vanilla_A3 {
        cfgPatchesName = "A3_Weapons_F_Explosives";
        displayName    = "Arma 3 (Vanilla)";
        mode           = "alive";
        roadIEDClasses[]  = {};
        urbanIEDClasses[] = {};
        clutterClasses[]  = {};
        detonator[]       = {};
        placementZ        = -0.1;       // bury (trash-pile look)
        chargeOffsetZ     = 0;          // charge inside the trash-pile model
        stompRadius       = 0;          // command-detonated, no pressure trigger
    };

    // RHS: AFRF (Armed Forces of the Russian Federation).
    // Detection key is `rhs_main`, the AFRF core addon. Other RHS variants
    // (USAF / GREF / SAF) each have their own cfgPatches name and would
    // get their own registry entries; this one is just AFRF.
    //
    // mode = "alive" - RHS mines are pressure-triggered and Arma's
    // createVehicle does NOT auto-arm them (createMine would, but ALiVE
    // doesn't use that path). In "mine" mode they sit inert: no Arma
    // detonation, no ACE/vanilla defuse hook recognition. So instead we
    // run them through ALiVE's full pipeline:
    //   - armIED attaches a damage-sensitive demo charge to the RHS mine
    //   - proximity-loop trip accumulator handles approach detection
    //   - Disarm IED addAction + skill-scaled wire-guess minigame for defuse
    //   - Detonation creates a separate shell explosion via ALiVE
    // The RHS mine becomes a visual anchor; ALiVE drives all behaviour.
    // The Z=-0.1 bury that ALiVE applies to its own IEDs also applies to
    // these, so the mine sits half-buried under ALiVE clutter (camouflage).
    //
    // Class selection: modern Russian mines that fit insurgent-IED use.
    // IMPORTANT: only **pressure-activated** mines work with ALiVE's
    // proximity-accumulator trigger model. Tripwire mines (e.g. OZM-72)
    // appear inert because their wire is engine-trigger-driven and Arma
    // only wires that up for createMine, not createVehicle.
    //   roadIEDClasses  - TM-62M anti-tank (pressure) for roadside placement
    //   urbanIEDClasses - PMN-2 anti-personnel (pressure) + PFM-1 butterfly
    //                     (pressure) for foot traffic
    // All are placeable entities (no _module / _used / _mag suffix).
    //
    // Note: under iChoice=_auto, the resolver auto-picks either mine-mode
    // integrations or alive-mode entries that explicitly set
    // autoPickEligible=1 (ACE_Explosives is the canonical example -- it
    // wants its class pool applied transparently). RHS_AFRF deliberately
    // omits that flag because its visible-pressure-mine placement is a
    // significant visual + behavioural change that should require the user
    // to opt in via the "Defer to: RHS: AFRF" dropdown.
    class RHS_AFRF {
        cfgPatchesName = "rhs_main";
        displayName    = "RHS: AFRF";
        mode           = "alive";
        roadIEDClasses[] = {
            "rhs_mine_tm62m"
        };
        urbanIEDClasses[] = {
            "rhs_mine_pmn2",
            "rhs_mine_pfm1"
        };
        clutterClasses[]  = {};   // use ALiVE clutter defaults via lenient fallback
        detonator[]       = {};
        placementZ        = 0;    // surface - RHS mines are visible objects
        chargeOffsetZ     = -0.3; // bury the demo charge below the visible mine
        stompRadius       = 0.6;  // pressure-trigger: stepping on the mine = boom
    };

    // RHS: AFRF (Engine-Armed sibling) - tripwire mines.
    // Sibling entry to RHS_AFRF that handles RHS content the alive pipeline
    // can't drive: tripwires need the engine's mine logic (createMine arms
    // them; createVehicle leaves them inert - the OZM-72 lesson). Selected via
    // Eden dropdown "Defer to: RHS: AFRF (Engine-Armed)".
    //
    //   urbanIEDClasses - OZM-72 bouncing tripwire (3 fuze variants a/b/c)
    //
    // Deliberately omitted: rhs_mine_msk40p_* (signal-smoke marker, not
    // damaging), rhs_mine_sm320_* (tripwire signal flares, illumination only),
    // rhs_mine_ptm1 (scatterable AT pressure - already covered by pfm1-style
    // pressure handling under the alive entry).
    class RHS_AFRF_Engine {
        cfgPatchesName = "rhs_main";
        displayName    = "RHS: AFRF (Engine-Armed)";
        mode           = "engineMine";
        roadIEDClasses[]  = {};   // OZM-72 family is anti-personnel only
        urbanIEDClasses[] = {
            "rhs_mine_ozm72_a",
            "rhs_mine_ozm72_b",
            "rhs_mine_ozm72_c"
        };
        clutterClasses[]  = {};
        detonator[]       = {};
        placementZ        = 0;    // ignored by engineMine; left at 0 for clarity
        chargeOffsetZ     = 0;
        stompRadius       = 0;
    };

    // RHS: USAF (United States Armed Forces).
    // Detection key is `rhsusf_main`. Same alive-mode + pressure semantics as
    // AFRF (createVehicle doesn't auto-arm, so ALiVE drives the pipeline).
    //
    // Class selection (pressure-activated only, per the OZM-72 / tripwire
    // lesson):
    //   roadIEDClasses  - M19 anti-tank
    //   urbanIEDClasses - M14 anti-personnel
    // m49a1_* trip flares omitted entirely (illumination, no damage). blu91/92
    // Gator scatterables move to the engine-armed sibling entry below.
    class RHS_USAF {
        cfgPatchesName = "rhsusf_main";
        displayName    = "RHS: USAF";
        mode           = "alive";
        roadIEDClasses[] = {
            "rhsusf_mine_M19"
        };
        urbanIEDClasses[] = {
            "rhsusf_mine_m14"
        };
        clutterClasses[]  = {};
        detonator[]       = {};
        placementZ        = 0;
        chargeOffsetZ     = -0.3;
        stompRadius       = 0.6;
    };

    // RHS: USAF (Engine-Armed sibling) - BLU-91/92 Gator scatterables.
    // Sibling entry to RHS_USAF for the engine-driven scatterable Gator family,
    // which use magnetic / seismic / tripwire / proximity sensors that only
    // work when the engine arms them via createMine. createVehicle would leave
    // them inert (the same problem as OZM-72 under alive mode).
    //
    //   roadIEDClasses  - BLU-91/B Gator anti-tank scatterable
    //   urbanIEDClasses - BLU-92/B Gator anti-personnel scatterable
    //
    // NOTE: untested under createMine in actual missions - if Gator triggers
    // don't fire, drop these and document. M49A1 trip flares deliberately
    // skipped here too (no damage, atmospheric only).
    class RHS_USAF_Engine {
        cfgPatchesName = "rhsusf_main";
        displayName    = "RHS: USAF (Engine-Armed)";
        mode           = "engineMine";
        roadIEDClasses[] = {
            "rhsusf_mine_blu91"
        };
        urbanIEDClasses[] = {
            "rhsusf_mine_blu92"
        };
        clutterClasses[]  = {};
        detonator[]       = {};
        placementZ        = 0;
        chargeOffsetZ     = 0;
        stompRadius       = 0;
    };

    // RHS: GREF (Ground Forces - mostly WWII content).
    // Detection key is `rhsgref_main`. Same alive-mode + pressure semantics as
    // AFRF / USAF.
    //
    // Class selection (pressure-activated only):
    //   roadIEDClasses  - WWII AT mines, mixed nationality:
    //                       rhs_mine_a200_bz       (German Tellermine variant)
    //                       rhs_mine_m3_pressure   (US M3 AT)
    //                       rhs_mine_TM43          (Russian TM-43)
    //   urbanIEDClasses - WWII AP mines, mixed nationality:
    //                       rhs_mine_smine35_press (German S-mine 35 / Bouncing Betty)
    //                       rhs_mine_m2a3b_press   (US M2A3B AP)
    //                       rhs_mine_glasmine43_bz (German glass-cased AP)
    // _trip / _tripwire / stockmine_* variants moved to the engine-armed
    // sibling entry below (createMine arms them properly; createVehicle leaves
    // them inert).
    class RHS_GREF {
        cfgPatchesName = "rhsgref_main";
        displayName    = "RHS: GREF";
        mode           = "alive";
        roadIEDClasses[] = {
            "rhs_mine_a200_bz",
            "rhs_mine_m3_pressure",
            "rhs_mine_TM43"
        };
        urbanIEDClasses[] = {
            "rhs_mine_smine35_press",
            "rhs_mine_m2a3b_press",
            "rhs_mine_glasmine43_bz"
        };
        clutterClasses[]  = {};
        detonator[]       = {};
        placementZ        = 0;
        chargeOffsetZ     = -0.3;
        stompRadius       = 0.6;
    };

    // RHS: GREF (Engine-Armed sibling) - WWII tripwire mines.
    // Sibling entry to RHS_GREF for the WWII tripwire variants that the alive
    // pipeline can't drive. These are the classes we deliberately excluded
    // earlier (M2A3B trip, M3 tripwire, Mk II tripwire, S-mine 35/44 trip,
    // Schützenmine 43 stake mines) - all engine-driven tripwires that need
    // createMine to arm.
    //
    //   urbanIEDClasses - all anti-personnel tripwires, mixed nationality
    //
    // No road pool: tripwire mines are AP by design. Anti-tank tripwires
    // weren't a real WWII weapon system.
    class RHS_GREF_Engine {
        cfgPatchesName = "rhsgref_main";
        displayName    = "RHS: GREF (Engine-Armed)";
        mode           = "engineMine";
        roadIEDClasses[]  = {};
        urbanIEDClasses[] = {
            "rhs_mine_m2a3b_trip",
            "rhs_mine_M3_tripwire",
            "rhs_mine_Mk2_tripwire",
            "rhs_mine_smine35_trip",
            "rhs_mine_smine44_trip",
            "rhs_mine_stockmine43_2m",
            "rhs_mine_stockmine43_4m"
        };
        clutterClasses[]  = {};
        detonator[]       = {};
        placementZ        = 0;
        chargeOffsetZ     = 0;
        stompRadius       = 0;
    };

    // CUP: IEDs (Community Upgrade Project - command-detonated IED variants).
    // Both CUP entries detect on `CUP_Weapons_Put`, the addon that owns these
    // class definitions. CUP doesn't have a single "main" patch like RHS, but
    // CUP_Weapons_Put is reliably present whenever CUP IED/mine content is.
    //
    // Mode + placement: ACE-style. CUP_IED_V1..V4 are visual variants (similar
    // role to vanilla A3 IEDs - trash-pile-with-bomb-inside concept). Buried
    // (-0.1) so they sit naturally on terrain, no stomp trigger (these are
    // command-detonated by design, ALiVE's damage handler drives detonation).
    class CUP_IEDs {
        cfgPatchesName = "CUP_Weapons_Put";
        displayName    = "CUP: IEDs";
        mode           = "alive";
        roadIEDClasses[] = {
            "CUP_IED_V1",
            "CUP_IED_V2"
        };
        urbanIEDClasses[] = {
            "CUP_IED_V3",
            "CUP_IED_V4"
        };
        // CUP clutter: Chernarus / Takistan civilian trash props (Operation
        // Arrowhead -era visuals). Mirrors the vanilla A3 clutter pool's
        // semantic categories (garbage / baskets / sacks / barrels / tires) so
        // CUP missions get period-appropriate IED disguise rather than A3
        // Mediterranean trash. Curated from CUP_CAStructures_E_* and
        // CUP_Misc3_Config probes.
        clutterClasses[] = {
            "Land_Misc_Garb_3_EP1",
            "Land_Misc_Garb_4_EP1",
            "Land_Misc_Garb_Heap_EP1",
            "Land_Misc_Garb_Square_EP1",
            "Land_Misc_GContainer_Big",
            "Land_Misc_Coltan_Heap_EP1",
            "Land_Misc_Rubble_EP1",
            "Land_Wicker_basket_EP1",
            "Land_Basket_EP1",
            "Land_Sack_EP1",
            "Land_Fire_barrel",
            "Land_Fire_barrel_burning",
            "Land_Barrel_empty",
            "Land_Barrel_water",
            "Land_Barrel_sand",
            "Land_Canister_EP1",
            "Land_tires_EP1"
        };
        detonator[]       = {};
        placementZ        = -0.1;
        chargeOffsetZ     = 0;
        stompRadius       = 0;
    };

    // CUP: Mines (Community Upgrade Project - pressure-activated mines).
    // Same cfgPatchesName as CUP: IEDs since both class sets live in
    // CUP_Weapons_Put. Splitting into two registry entries lets the
    // mission-maker pick the style explicitly via the Eden Integration
    // dropdown ("Defer to: CUP: IEDs" vs "Defer to: CUP: Mines").
    //
    // Mode + placement: RHS-style. Pressure mines need ALiVE's pipeline
    // (createVehicle doesn't auto-arm), surface placement so they're visible,
    // charge buried under, stomp trigger for instant pressure-step detonation.
    // CUP_Mine assigned to road (assumed AT), CUP_MineE assigned to urban
    // (assumed AP) - swap if testing shows the assignment is wrong.
    class CUP_Mines {
        cfgPatchesName = "CUP_Weapons_Put";
        displayName    = "CUP: Mines";
        mode           = "alive";
        roadIEDClasses[] = {
            "CUP_Mine"
        };
        urbanIEDClasses[] = {
            "CUP_MineE"
        };
        // Same CUP clutter as CUP_IEDs - Chernarus / Takistan civilian trash
        // props. Identical pool because clutter aesthetic is terrain-driven not
        // IED-style-driven (a CUP mine on a Takistan road wants the same
        // garbage around it as a CUP_IED on the same road).
        clutterClasses[] = {
            "Land_Misc_Garb_3_EP1",
            "Land_Misc_Garb_4_EP1",
            "Land_Misc_Garb_Heap_EP1",
            "Land_Misc_Garb_Square_EP1",
            "Land_Misc_GContainer_Big",
            "Land_Misc_Coltan_Heap_EP1",
            "Land_Misc_Rubble_EP1",
            "Land_Wicker_basket_EP1",
            "Land_Basket_EP1",
            "Land_Sack_EP1",
            "Land_Fire_barrel",
            "Land_Fire_barrel_burning",
            "Land_Barrel_empty",
            "Land_Barrel_water",
            "Land_Barrel_sand",
            "Land_Canister_EP1",
            "Land_tires_EP1"
        };
        detonator[]       = {};
        placementZ        = 0;
        chargeOffsetZ     = -0.3;
        stompRadius       = 0.6;
    };

    // RHS: SAF (Serbian Armed Forces) - INTENTIONALLY OMITTED.
    // RHS SAF doesn't define any unique mine entity classes (probe found
    // count=0 mine classes attributed to rhssaf_*). Yugoslav/Serbian forces
    // historically used Soviet-derived equipment so SAF users effectively get
    // RHS:AFRF coverage via that entry. Don't waste time hunting for SAF mine
    // classes - none exist as of this commit.

    // ACE 3 Explosives - place vanilla A3 IED ammo classes (rather than
    // ALiVE's own ALIVE_IED* classes) so that ACE's defuse-interaction
    // wheel auto-attaches to them. ACE adds those handlers to the vanilla
    // IED ammo classes when `ace_explosives` is loaded; it doesn't ship
    // its own ACE_IED_* class hierarchy. ALiVE's ALIVE_IED* inherit from
    // Thing, not MineBase, and don't get the ACE interaction wheel.
    //
    // Mode is "alive" (not "mine") so ALiVE's full pipeline (armIED +
    // polling-loop proximity detonation + addAction Disarm) runs on the
    // placed IEDs. Both systems coexist on the same object: ACE provides
    // the defuse-interaction wheel for skilled / careful players, ALiVE
    // provides the step-on-it detonation for the careless. Earlier this
    // block used mode="mine" on the assumption that ACE's framework
    // replaced detonation entirely, but ACE only adds defuse-interaction
    // -- nothing in ACE pressure-triggers vanilla IED ammo, so mode="mine"
    // left the IEDs unarmed (community report 2026-05-13).
    //
    // chargeOffsetZ stays 0 (charge inside the trash-pile model so it
    // doesn't visibly sit above ground when armIED attaches it).
    //
    // autoPickEligible = 1: under iChoice=_auto the resolver normally only
    // auto-picks mine-mode integrations as candidates (so RHS/CUP/etc. with
    // mode="alive" require an explicit "Defer to" dropdown selection). This
    // flag is the ACE-specific opt-in to also be auto-picked despite being
    // mode="alive", because ACE's defuse-interaction wheel auto-attaches to
    // the vanilla A3 IED ammo classes specified below -- placing those
    // classes is the whole point of this integration entry, so we want the
    // class pool applied under Auto without requiring users to know about
    // the dropdown.
    class ACE_Explosives {
        cfgPatchesName = "ace_explosives";
        displayName    = "ACE 3 Explosives";
        mode           = "alive";
        autoPickEligible = 1;
        roadIEDClasses[] = {
            "IEDLandSmall_Remote_Ammo",
            "IEDLandBig_Remote_Ammo"
        };
        urbanIEDClasses[] = {
            "IEDUrbanSmall_Remote_Ammo",
            "IEDUrbanBig_Remote_Ammo"
        };
        clutterClasses[]  = {};   // use ALiVE clutter defaults via lenient fallback
        detonator[]       = {};
        placementZ        = -0.1; // bury slightly (vanilla A3 IED visuals are trash piles)
        chargeOffsetZ     = 0;    // charge inside the trash-pile model
        stompRadius       = 0;    // ALiVE accumulator handles proximity; no pressure shortcut
    };

    // ------------------------------------------------------------------------
    // SOG Prairie Fire (S.O.G. - Vietnam-era CDLC).
    //
    // SOG splits IED-style content across three CfgPatches:
    //   weapons_f_vietnam_c     - core mines (M14/15/16, TM57, M18 claymore,
    //                             tripwires, satchels, punji sticks)
    //   weapons_f_vietnam_03_c  - improvised IEDs (bike, pot, jerrycan, DH-10,
    //                             cartridge, lighter)
    //   structures_f_vietnam_c  - punji fence terrain props
    // We detect on `weapons_f_vietnam_c` (always loaded with SOG) for all
    // three SOG entries; if `_03_c` is somehow absent the bike/pot/jerrycan
    // createVehicle calls return objNull and the null-IED guard in
    // fnc_createIED handles it silently.
    //
    // Three entries because SOG needs three different runtime semantics:
    //   SOG_Command     - command-detonated _range / _remote variants run
    //                     through the full ALiVE pipeline (charge + accumulator
    //                     + Disarm action). This is the closest match to how
    //                     ALiVE has always worked.
    //   SOG_Mines       - pressure mines and tripwires placed via createMINE
    //                     (engineMine mode) so the engine arms them as proper
    //                     mines. ALiVE skips arming so the engine's pressure /
    //                     tripwire detection actually fires.
    //   SOG_Punji       - punji sticks and punji fences are NON-explosive
    //                     contact-damage hazards. createVehicle places them and
    //                     the engine handles damage on collision. No ALiVE
    //                     pipeline, no demo charge.
    // ------------------------------------------------------------------------

    // SOG: command-detonated improvised IEDs (bike, pot, jerrycan, DH-10
    // directional, M18 claymore range, satchel remote, ammo box booby trap).
    // All classes selected are the `_range` / `_remote` variants that the SOG
    // mod treats as command-detonated - perfect match for ALiVE's accumulator-
    // driven pipeline (the trigger-man "decides" when to detonate based on
    // proximity / damage).
    //
    // Placement is trash-pile style (bury -0.1, charge inside) so the props
    // sit naturally on roads and aren't hovering. ALiVE's clutter spawn doesn't
    // hide these because they're the visual themselves (bike, pot etc.).
    class SOG_Command {
        cfgPatchesName = "weapons_f_vietnam_c";
        displayName    = "SOG Prairie Fire: Command IEDs";
        mode           = "alive";
        roadIEDClasses[] = {
            "vn_mine_bike_range",
            "vn_mine_jerrycan_range",
            "vn_mine_dh10_range"
        };
        urbanIEDClasses[] = {
            "vn_mine_pot_range",
            "vn_mine_ammobox_range",
            "vn_mine_satchel_remote_02",
            "vn_mine_m18_range",
            "vn_mine_m112_remote"
        };
        // SOG clutter: Vietnam village / market trash props. Mirrors vanilla's
        // semantic categories (junkpile / garbage / sacks / baskets / crates /
        // trashcans) with period-appropriate Vietnamese village content.
        // Curated from structures_f_vietnam_c + objects_f_vietnam_c.
        clutterClasses[] = {
            "Land_vn_junkpile_f",
            "Land_vn_garbagebags_f",
            "Land_vn_garbagepallet_f",
            "Land_vn_garbageheap_01_f",
            "Land_vn_garbageheap_02_f",
            "Land_vn_garbageheap_03_f",
            "Land_vn_garbageheap_04_f",
            "Land_vn_garbage_line_f",
            "Land_vn_basket_ep1",
            "Land_vn_c_prop_basket_01",
            "Land_vn_c_prop_basket_03",
            "Land_vn_sack_f",
            "Land_vn_sacks_goods_f",
            "Land_vn_sacks_heap_f",
            "Land_vn_woodencrate_01_f",
            "Land_vn_object_trashcan_01",
            "Land_vn_object_trashcan_02",
            "Land_vn_canisterfuel_f"
        };
        detonator[]       = {};
        placementZ        = -0.1;
        chargeOffsetZ     = 0;
        stompRadius       = 0;
    };

    // SOG: pressure mines + tripwire mines, placed via createMine so the
    // engine arms them. ALiVE pipeline is skipped entirely (no charge attached,
    // no Disarm IED action, no accumulator) - the engine's built-in mine
    // trigger logic handles detection and detonation.
    //
    // Anti-tank pressure mines (TM-57, M15) -> road pool.
    // Anti-personnel pressure (M14, M16) + tripwires (M16/F1/M49 frag, arty,
    // mortar) + booby-trap pickups (lighter, board with nails) -> urban pool.
    //
    // placementZ / chargeOffsetZ / stompRadius are all ignored in engineMine
    // mode (engine handles trigger + visual placement). Defaults left at 0
    // for clarity.
    class SOG_Mines {
        cfgPatchesName = "weapons_f_vietnam_c";
        displayName    = "SOG Prairie Fire: Mines & Tripwires";
        mode           = "engineMine";
        roadIEDClasses[] = {
            "vn_mine_tm57",
            "vn_mine_m15"
        };
        urbanIEDClasses[] = {
            "vn_mine_m14",
            "vn_mine_m16",
            "vn_mine_tripwire_m16_02",
            "vn_mine_tripwire_m16_04",
            "vn_mine_tripwire_f1_02",
            "vn_mine_tripwire_f1_04",
            "vn_mine_tripwire_arty",
            "vn_mine_tripwire_m49_02",
            "vn_mine_tripwire_m49_04",
            "vn_mine_tripwire_mortar",
            "vn_mine_gboard",
            "vn_mine_lighter"
        };
        // Same SOG clutter pool as SOG_Command - terrain-driven not mode-
        // driven. Vietnam village trash works the same around a tripwire as
        // around a command-detonated jerrycan.
        clutterClasses[] = {
            "Land_vn_junkpile_f",
            "Land_vn_garbagebags_f",
            "Land_vn_garbagepallet_f",
            "Land_vn_garbageheap_01_f",
            "Land_vn_garbageheap_02_f",
            "Land_vn_garbageheap_03_f",
            "Land_vn_garbageheap_04_f",
            "Land_vn_garbage_line_f",
            "Land_vn_basket_ep1",
            "Land_vn_c_prop_basket_01",
            "Land_vn_c_prop_basket_03",
            "Land_vn_sack_f",
            "Land_vn_sacks_goods_f",
            "Land_vn_sacks_heap_f",
            "Land_vn_woodencrate_01_f",
            "Land_vn_object_trashcan_01",
            "Land_vn_object_trashcan_02",
            "Land_vn_canisterfuel_f"
        };
        detonator[]       = {};
        placementZ        = 0;
        chargeOffsetZ     = 0;
        stompRadius       = 0;
    };

    // SOG: punji sticks + punji fences. NON-EXPLOSIVE contact-damage hazards
    // (sharpened bamboo) - the engine handles damage on collision via the
    // model itself. Placed via createVehicle (passive mode) with no ALiVE
    // pipeline whatsoever: no arm, no charge, no Disarm action, no marker
    // (these are area-denial obstacles, not detonating IEDs).
    //
    // All assigned to urban pool because they're jungle-path / perimeter
    // hazards that fit infantry-traffic areas, not vehicle roads.
    //
    // Land_vn_fence_punji_* are terrain props from structures_f_vietnam_c -
    // included here because they serve the same role (passive contact damage)
    // and this entry's mode handles them correctly.
    class SOG_Punji {
        cfgPatchesName = "weapons_f_vietnam_c";
        displayName    = "SOG Prairie Fire: Punji Hazards";
        mode           = "passive";
        roadIEDClasses[] = {};
        urbanIEDClasses[] = {
            "vn_mine_punji_01",
            "vn_mine_punji_02",
            "vn_mine_punji_03",
            "vn_mine_punji_04",
            "vn_mine_punji_05",
            "Land_vn_fence_punji_01_03",
            "Land_vn_fence_punji_01_05",
            "Land_vn_fence_punji_01_10",
            "Land_vn_fence_punji_02_03",
            "Land_vn_fence_punji_02_05",
            "Land_vn_fence_punji_02_10"
        };
        // Same SOG clutter pool. Punji sticks especially benefit from
        // garbage / sacks scattered nearby - they hide visually amongst
        // village trash on a jungle path.
        clutterClasses[] = {
            "Land_vn_junkpile_f",
            "Land_vn_garbagebags_f",
            "Land_vn_garbagepallet_f",
            "Land_vn_garbageheap_01_f",
            "Land_vn_garbageheap_02_f",
            "Land_vn_garbageheap_03_f",
            "Land_vn_garbageheap_04_f",
            "Land_vn_garbage_line_f",
            "Land_vn_basket_ep1",
            "Land_vn_c_prop_basket_01",
            "Land_vn_c_prop_basket_03",
            "Land_vn_sack_f",
            "Land_vn_sacks_goods_f",
            "Land_vn_sacks_heap_f",
            "Land_vn_woodencrate_01_f",
            "Land_vn_object_trashcan_01",
            "Land_vn_object_trashcan_02",
            "Land_vn_canisterfuel_f"
        };
        detonator[]       = {};
        placementZ        = 0;
        chargeOffsetZ     = 0;
        stompRadius       = 0;
    };

    // ------------------------------------------------------------------------
    // SPE - Spearhead 1944 (WWII Western Front CDLC).
    //
    // SPE owns 31 mine/IED-relevant classes in WW2_SPE_Assets_c_Weapons_Mines_c
    // covering German + US WWII content: Tellermine, S-mine 35 (Bouncing Betty),
    // Schümine 42, Schützenmine 43 stake, US M1A1 / M3, Ladung demo charges,
    // an improvised IED (7 stick grenades wired together), TNT blocks, and a
    // Bangalore torpedo.
    //
    // Naming convention discovered from probe: pressure variants use explicit
    // `_Pressure_MINE` suffix. Classes WITHOUT that suffix are the default
    // tripwire / standard variants. This drives the alive vs engineMine split:
    //
    //   SPE_Pressure - mode=alive, pressure mines need ALiVE's pipeline because
    //                  createVehicle doesn't auto-arm them (same RHS_GREF
    //                  lesson). Visible mine + buried charge + stomp trigger.
    //   SPE_Tripwire - mode=engineMine, default-fuze (tripwire) variants placed
    //                  via createMine so the engine arms them as proper mines.
    //                  Stockmine 43 stake mine especially needs this.
    //   SPE_Charges  - mode=alive, command-detonated demolition charges
    //                  (Ladung Big/Small, US TNT blocks, Bangalore) plus the
    //                  Shg24x7 improvised IED. Trash-pile-style placement
    //                  similar to vanilla A3 / SOG_Command.
    //
    // All three detect on `WW2_SPE_Assets_c_Weapons_Mines_c` (the patch that
    // actually owns these classes), not on a generic SPE Core sentinel - if
    // the Mines patch isn't loaded, none of these classes resolve and the
    // entries shouldn't fire.
    //
    // Skipped:
    //   SPE_ModuleMine_*           - Eden modules, not runtime entities
    //   SPE_MINE_*_Field_*         - minefield templates that scatter many
    //                                mines per placement, breaks ALiVE's
    //                                one-entity-per-IED accounting
    //   Land_SPE_Mine_*            - coal/industrial mining buildings (the
    //                                "mining" sense, not military)
    //   SPE_Mine_Ammo_Box_Ger/US   - crates that contain mines as cargo, not
    //                                IEDs themselves (clutter candidates)
    //   SPE_US_Rangers_engineer_*  - soldier loadout class
    // ------------------------------------------------------------------------

    // SPE: pressure mines (German + US WWII).
    // RHS_GREF-style: visible mine on surface, ALiVE drives the pipeline,
    // demo charge buried under for the shoot-to-detonate path, stomp trigger
    // for instant pressure-step detonation.
    class SPE_Pressure {
        cfgPatchesName = "WW2_SPE_Assets_c_Weapons_Mines_c";
        displayName    = "SPE: Pressure Mines";
        mode           = "alive";
        roadIEDClasses[] = {
            "SPE_TMI_42_MINE",          // German Tellermine 42 (AT pressure)
            "SPE_US_M1A1_ATMINE"        // US M1A1 (AT pressure)
        };
        urbanIEDClasses[] = {
            "SPE_SMI_35_Pressure_MINE", // German S-mine 35 (pressure variant of Bouncing Betty)
            "SPE_shumine_42_MINE",      // German Schümine 42 (wooden box AP, pressure)
            "SPE_US_M3_Pressure_MINE"   // US M3 (pressure variant)
        };
        // SPE clutter: Norman village (1944) + Allied / German military supply
        // props. Mirrors vanilla's semantic categories (sacks / pallets /
        // crates / barrels / debris piles) with period-appropriate French
        // farmland and supply-dump content. Curated from WW2_SPE_Structures_c
        // + WW2_SPE_Structures2_c + WW2_SPE_Water_c_Rivers (riverside leaves).
        clutterClasses[] = {
            // Food sacks - Norman farmland staple
            "Land_SPE_Sack_Corn_Heap",
            "Land_SPE_Sack_Potato_Heap",
            "Land_SPE_Sack_Wheat_Heap",
            "Land_SPE_Sack_Corn_Pile",
            "Land_SPE_Sack_Potato_Pile",
            // Pallets / crates (mixed civilian + supply-dump)
            "Land_SPE_Pallet",
            "Land_SPE_Covered_Pallets_01",
            "Land_SPE_Cider_Crate_Empty",
            "Land_SPE_Foodcrate_US_A",
            "Land_SPE_Ammocrate_US_01",
            // Barrels - civilian + fuel
            "Land_SPE_Wooden_Barrel_01",
            "Land_SPE_Wooden_Barrel_01_Small",
            "Land_SPE_Wooden_Barrel_02_Brown",
            "Land_SPE_Wooden_Barrel_02_Open_Brown",
            "Land_SPE_Fuel_Barrel_German",
            "Land_SPE_Fuel_Barrel_US",
            "Land_SPE_Jerrycan",
            // Debris / leaf piles - perfect tripwire / pressure-mine disguise
            "Land_SPE_Dugout_Pile_01",
            "Land_SPE_Dugout_Pile_02",
            "land_spe_riverside_leaves_pile_01",
            "land_spe_riverside_leaves_pile_02"
        };
        detonator[]       = {};
        placementZ        = 0;
        chargeOffsetZ     = -0.3;
        stompRadius       = 0.6;
    };

    // SPE: tripwire mines (default-fuze variants of S-Mine 35, Stockmine 43,
    // US M3). createMine arms them so the engine handles tripwire trigger.
    // ALiVE pipeline skipped entirely (no charge, no Disarm action).
    class SPE_Tripwire {
        cfgPatchesName = "WW2_SPE_Assets_c_Weapons_Mines_c";
        displayName    = "SPE: Tripwire Mines";
        mode           = "engineMine";
        roadIEDClasses[]  = {};         // tripwire mines are AP by design
        urbanIEDClasses[] = {
            "SPE_SMI_35_MINE",          // German S-mine 35 (tripwire - the original Bouncing Betty)
            "SPE_SMI_35_1_MINE",        // German S-mine 35 variant 1 (alternate fuze)
            "SPE_STMI_MINE",            // German Stockmine 43 (Schützenmine 43 stake mine, tripwire)
            "SPE_US_M3_MINE"            // US M3 (default tripwire variant)
        };
        // SPE clutter: Norman village (1944) + Allied / German military supply
        // props. Mirrors vanilla's semantic categories (sacks / pallets /
        // crates / barrels / debris piles) with period-appropriate French
        // farmland and supply-dump content. Curated from WW2_SPE_Structures_c
        // + WW2_SPE_Structures2_c + WW2_SPE_Water_c_Rivers (riverside leaves).
        clutterClasses[] = {
            // Food sacks - Norman farmland staple
            "Land_SPE_Sack_Corn_Heap",
            "Land_SPE_Sack_Potato_Heap",
            "Land_SPE_Sack_Wheat_Heap",
            "Land_SPE_Sack_Corn_Pile",
            "Land_SPE_Sack_Potato_Pile",
            // Pallets / crates (mixed civilian + supply-dump)
            "Land_SPE_Pallet",
            "Land_SPE_Covered_Pallets_01",
            "Land_SPE_Cider_Crate_Empty",
            "Land_SPE_Foodcrate_US_A",
            "Land_SPE_Ammocrate_US_01",
            // Barrels - civilian + fuel
            "Land_SPE_Wooden_Barrel_01",
            "Land_SPE_Wooden_Barrel_01_Small",
            "Land_SPE_Wooden_Barrel_02_Brown",
            "Land_SPE_Wooden_Barrel_02_Open_Brown",
            "Land_SPE_Fuel_Barrel_German",
            "Land_SPE_Fuel_Barrel_US",
            "Land_SPE_Jerrycan",
            // Debris / leaf piles - perfect tripwire / pressure-mine disguise
            "Land_SPE_Dugout_Pile_01",
            "Land_SPE_Dugout_Pile_02",
            "land_spe_riverside_leaves_pile_01",
            "land_spe_riverside_leaves_pile_02"
        };
        detonator[]       = {};
        placementZ        = 0;
        chargeOffsetZ     = 0;
        stompRadius       = 0;
    };

    // SPE: command-detonated demolition charges + improvised IED.
    // SOG_Command-style: trash-pile placement, ALiVE drives full pipeline,
    // charge inside the visual model. The Shg24x7 in particular is explicitly
    // an "Improvised Mine" (7 stick grenades wired together) - a literal IED
    // in the WWII insurgent / partisan sense.
    class SPE_Charges {
        cfgPatchesName = "WW2_SPE_Assets_c_Weapons_Mines_c";
        displayName    = "SPE: Demo Charges & Improvised";
        mode           = "alive";
        roadIEDClasses[] = {
            "SPE_Ladung_Big_MINE",                  // German large demolition charge
            "SPE_Shg24x7_Improvised_Mine_MINE"      // German improvised IED (7x Shg24 grenades)
        };
        urbanIEDClasses[] = {
            "SPE_Ladung_Small_MINE",                // German small demolition charge
            "SPE_US_TNT_4pound",                    // US TNT 4-pound block
            "SPE_US_TNT_half_pound",                // US TNT half-pound block
            "SPE_US_Bangalore"                      // US Bangalore torpedo
        };
        // SPE clutter: same Norman village + supply prop pool as SPE_Pressure
        // and SPE_Tripwire. Terrain-driven not mode-driven (a Bangalore on a
        // Normandy lane wants the same farmland trash around it as a German
        // S-mine on the same lane).
        clutterClasses[] = {
            "Land_SPE_Sack_Corn_Heap",
            "Land_SPE_Sack_Potato_Heap",
            "Land_SPE_Sack_Wheat_Heap",
            "Land_SPE_Sack_Corn_Pile",
            "Land_SPE_Sack_Potato_Pile",
            "Land_SPE_Pallet",
            "Land_SPE_Covered_Pallets_01",
            "Land_SPE_Cider_Crate_Empty",
            "Land_SPE_Foodcrate_US_A",
            "Land_SPE_Ammocrate_US_01",
            "Land_SPE_Wooden_Barrel_01",
            "Land_SPE_Wooden_Barrel_01_Small",
            "Land_SPE_Wooden_Barrel_02_Brown",
            "Land_SPE_Wooden_Barrel_02_Open_Brown",
            "Land_SPE_Fuel_Barrel_German",
            "Land_SPE_Fuel_Barrel_US",
            "Land_SPE_Jerrycan",
            "Land_SPE_Dugout_Pile_01",
            "Land_SPE_Dugout_Pile_02",
            "land_spe_riverside_leaves_pile_01",
            "land_spe_riverside_leaves_pile_02"
        };
        detonator[]       = {};
        placementZ        = -0.1;
        chargeOffsetZ     = 0;
        stompRadius       = 0;
    };

    // ------------------------------------------------------------------------
    // GM - Global Mobilization (Cold War Germany CDLC, 1980s setting).
    //
    // GM owns 8 placeable mine + demo-charge classes in `gm_weapons_put`,
    // covering BOTH political factions of the divided Germany era:
    //   West (Bundeswehr / BRD): DM-21 AT, DM-31 AP, DM-1233 scatterable AT
    //   East (Volksarmee / NVA): TM-46 AT, PFM-1 AP butterfly, PTM-3 scatter AT
    //   Universal demo charges:  PETN, PLNP
    //
    // Naming convention is uniform and predictable:
    //   gm_minestatic_at_*           anti-tank pressure mines
    //   gm_minestatic_ap_*           anti-personnel pressure mines
    //   gm_explosivestatic_charge_*  command-detonated demolition charges
    //
    // NOTABLE ABSENCE: zero tripwire mines. GM is 1980s Cold War content;
    // tripwire doctrine was WWII-era and had largely been retired by the
    // setting period. So no GM_Engine sibling entry needed - all GM mines
    // are pressure-triggered or command-detonated, both of which work under
    // ALiVE's alive-mode pipeline (visible mine + buried charge + stomp).
    //
    // Mixed East/West classes in single entries (like RHS_GREF mixes German
    // /US/Russian WWII mines): mission-maker can edit the field in Eden if
    // they want a single-faction Bundeswehr-only or NVA-only IED pool.
    //
    // Skipped:
    //   gm_AmmoBox_*Rnd_mine_*_put   crates that contain mines as cargo, not
    //                                IEDs themselves (clutter candidates)
    // ------------------------------------------------------------------------

    // GM: pressure mines (mixed BRD + NVA factions).
    // Same RHS_GREF / SPE_Pressure shape: visible surface mine, buried demo
    // charge underneath, stomp trigger for instant pressure-step detonation.
    // PFM-1 butterfly is intentionally in urban pool here (small AP scatter
    // mine, foot-traffic context) - same logic as RHS_AFRF.
    class GM_Mines {
        cfgPatchesName = "gm_weapons_put";
        displayName    = "GM: Mines";
        mode           = "alive";
        roadIEDClasses[] = {
            "gm_minestatic_at_dm21",        // West Bundeswehr DM-21 AT pressure
            "gm_minestatic_at_tm46",        // East NVA TM-46 AT pressure (Soviet)
            "gm_minestatic_at_dm1233",      // West Bundeswehr DM-1233 AT scatterable
            "gm_minestatic_at_ptm3"         // East NVA PTM-3 AT scatterable (Soviet)
        };
        urbanIEDClasses[] = {
            "gm_minestatic_ap_dm31",        // West Bundeswehr DM-31 AP (bouncing)
            "gm_minestatic_ap_pfm1"         // East NVA PFM-1 butterfly AP scatterable
        };
        // GM clutter: Cold War German military supply props. GM is a military-
        // only mod with no civilian trash content - the "trash pile" concept
        // becomes "military supply dump leftover" which still reads correctly
        // for an insurgent / partisan IED disguise. Curated from
        // gm_objects_barrel / _canister / _pallet + gm_weapons_ammoboxes.
        // All ammo box variants chosen are the `_empty` ones (no cargo inside;
        // pure visual clutter).
        clutterClasses[] = {
            // Barrels
            "gm_barrel",
            "gm_barrel_rusty",
            // Canister
            "gm_jerrycan",
            // Pallets (civilian + military supply)
            "gm_pallet_01",
            "gm_fuelpallet_01",
            "gm_ammobox_pallet_01_empty",
            "gm_ammobox_pallet_02_empty",
            // Empty ammo crates (mixed wood + aluminium)
            "gm_AmmoBox_wood_01_empty",
            "gm_AmmoBox_wood_02_empty",
            "gm_AmmoBox_wood_03_empty",
            "gm_ammobox_aluminium_01_empty",
            "gm_ammobox_aluminium_02_empty",
            // Ammo box piles (junkpile-equivalent)
            "gm_ammobox_pile_small_01_empty",
            "gm_ammobox_pile_small_02_empty",
            "gm_ammobox_pile_large_01_empty"
        };
        detonator[]       = {};
        placementZ        = 0;
        chargeOffsetZ     = -0.3;
        stompRadius       = 0.6;
    };

    // GM: command-detonated demolition charges (PETN + PLNP).
    // SOG_Command / SPE_Charges shape: trash-pile placement, ALiVE drives the
    // full pipeline, charge inside the visual model. PETN is the heavier of
    // the two (high explosive) so road; PLNP urban. Distribution can be
    // swapped in Eden if testing shows the visuals fit the other way.
    class GM_Charges {
        cfgPatchesName = "gm_weapons_put";
        displayName    = "GM: Demolition Charges";
        mode           = "alive";
        roadIEDClasses[] = {
            "gm_explosivestatic_charge_petn"   // PETN high-explosive demo charge
        };
        urbanIEDClasses[] = {
            "gm_explosivestatic_charge_plnp"   // PLNP demolition charge (smaller)
        };
        // Same GM military-supply clutter as GM_Mines - terrain/era-driven not
        // mode-driven. A PETN charge on a Cold War German supply route wants
        // the same ammo-pile / barrel / pallet props around it as a TM-46.
        clutterClasses[] = {
            "gm_barrel",
            "gm_barrel_rusty",
            "gm_jerrycan",
            "gm_pallet_01",
            "gm_fuelpallet_01",
            "gm_ammobox_pallet_01_empty",
            "gm_ammobox_pallet_02_empty",
            "gm_AmmoBox_wood_01_empty",
            "gm_AmmoBox_wood_02_empty",
            "gm_AmmoBox_wood_03_empty",
            "gm_ammobox_aluminium_01_empty",
            "gm_ammobox_aluminium_02_empty",
            "gm_ammobox_pile_small_01_empty",
            "gm_ammobox_pile_small_02_empty",
            "gm_ammobox_pile_large_01_empty"
        };
        detonator[]       = {};
        placementZ        = -0.1;
        chargeOffsetZ     = 0;
        stompRadius       = 0;
    };

    // ------------------------------------------------------------------------
    // CSLA - Iron Curtain (Czechoslovakian People's Army CDLC, 1980s setting).
    //
    // CSLA owns 5 placeable Czech-designation pressure mines in the `CSLA`
    // core patch. Class names follow Czech military designations:
    //   PT-Mi-Ba-3   Protitanková Mina Bakelitová (anti-tank, bakelite)
    //   PT-Mi-D      Protitanková Mina Dřevěná (anti-tank, wooden)
    //   PP-Mi-Na     Protipěchotní Mina Nárazná (AP, impact)
    //   PP-Mi-Sr-2   Protipěchotní Mina Stupní (AP, stake/pressure)
    //   NO-2         Nárazná Ostrá 2 (AP fragmentation)
    //
    // Like GM (Cold War Germany sibling era): zero tripwire mines, no
    // command-detonated charges. Pure pressure-trigger doctrine - one entry
    // covers everything. Same RHS_GREF / GM_Mines shape: visible surface
    // mine, ALiVE pipeline drives detonation, buried demo charge, stomp
    // trigger.
    //
    // Mixed AT + AP roles in a single Czechoslovakian-faction entry -
    // matches the "one mod = one nationality" semantic and avoids
    // multiplying entries for a small mine inventory.
    //
    // CLUTTER: clutterClasses[] left empty. CSLA structure namespace probes
    // returned no findable Land-prefix conventions through standard keyword
    // filters. CSLA missions fall through to vanilla A3 Mediterranean
    // clutter - functional but not period-perfect for 1980s Czechoslovakia.
    // Revisit if a CSLA expert can name the Czech-village clutter classes
    // directly.
    //
    // Skipped:
    //   CSLA_MineBase / CSLA_SatchelCharge_Base   abstract base classes
    //   CSLA_ammobox_explosives                   ammo box, not placeable
    //   CSLA_engMiner / CSLA_engMinerDES          soldier loadout characters
    // ------------------------------------------------------------------------

    class CSLA_Mines {
        cfgPatchesName = "CSLA";
        displayName    = "CSLA: Mines";
        mode           = "alive";
        roadIEDClasses[] = {
            "CSLA_PtMiBa3Mine",          // PT-Mi-Ba-3 (AT pressure, bakelite)
            "CSLA_PTMiDMine"             // PT-Mi-D (AT pressure, wooden)
        };
        urbanIEDClasses[] = {
            "CSLA_PPMiNaMine",           // PP-Mi-Na (AP impact)
            "CSLA_NO2Mine",              // NO-2 (AP fragmentation)
            "CSLA_PPMiSr2Mine"           // PP-Mi-Sr-2 (AP stake/pressure)
        };
        clutterClasses[]  = {};          // see comment block above
        detonator[]       = {};
        placementZ        = 0;
        chargeOffsetZ     = -0.3;
        stompRadius       = 0.6;
    };

    // ------------------------------------------------------------------------
    // Western Sahara (Rotators CDLC) - CLUTTER-ONLY ENTRY.
    //
    // PIONEERING NEW PATTERN: this is the first registry entry that contributes
    // ONLY clutter, no IED classes. The mod ships zero mine/IED-relevant
    // classes (probed across all 88 lxWS patches with broad keyword filters -
    // confirmed by drilling into Items_Misc / Misc / Ammoboxes / Items_Food
    // patches individually). But it ships rich Sahara/Maghrebi civilian props
    // that perfectly disguise an IED on a desert road - tea service, tajines,
    // dates, carpets, refugee tent debris.
    //
    // Resolver behavior: an integration entry with empty roadIEDClasses[] +
    // empty urbanIEDClasses[] + populated clutterClasses[] gives, when picked
    // via the Eden dropdown:
    //   - resolvedRoadIEDClasses  -> falls back to base ALiVE A3 IEDs
    //                                (lenient fallback: empty integration
    //                                pool means use base attribute)
    //   - resolvedUrbanIEDClasses -> falls back to base ALiVE A3 IEDs
    //   - resolvedClutterClasses  -> uses WS Sahara clutter
    // Net effect: vanilla A3 IEDs (trash-pile-with-bomb-inside concept),
    // wrapped in WS-themed civilian props for visual context match.
    //
    // mode = "alive" because the resolved IED classes are vanilla A3 ALiVE
    // IEDs, which the alive pipeline handles correctly.
    //
    // This pattern unlocks future addons that ship props but no mines (any
    // terrain/structures CDLC, basically) - they can register a clutter-only
    // integration here without requiring custom IED content.
    //
    // Detection on `structures_F_lxWS_Items_Food` (a reliably-loaded Western
    // Sahara patch that always exists when the CDLC is active).
    // ------------------------------------------------------------------------

    class WS_Clutter {
        cfgPatchesName = "structures_F_lxWS_Items_Food";
        displayName    = "Western Sahara: Clutter (vanilla IEDs)";
        mode           = "alive";
        roadIEDClasses[]  = {};                 // intentionally empty - falls through to base
        urbanIEDClasses[] = {};                 // intentionally empty - falls through to base
        // WS clutter: Maghrebi market service + tent/carpet debris + faction
        // ammo crates. Authentic Sahara village aesthetic - tajines, teapots,
        // dates, sugar cups around a roadside IED reads as "leftover from a
        // raided market stall" in a way A3 Mediterranean trash never could on
        // Sahara terrain.
        clutterClasses[] = {
            // Tea / food service - Maghrebi market staple
            "Land_Teapot_lxWS",
            "Land_Tajine_lxWS",
            "Land_Tajine_small_lxWS",
            "Land_Tray_lxWS",
            "Land_Glass_lxWS",
            "Land_Cup_Empty_lxWS",
            "Land_Cup_Sugar_lxWS",
            "Land_Cup_Dates_lxWS",
            // Carpets / pillows / blankets - bedouin tent goods
            "Land_Carpet_folded_01_lxWS",
            "Land_Carpet_folded_02_lxWS",
            "Land_Carpet_folded_03_lxWS",
            "Land_Pillow_01_lxWS",
            "Land_Pillow_03_lxWS",
            "Land_Wicker_basket_EP1_lxWS",
            "Land_Blankets_EP1_lxWS",
            // Agriculture - rural Sahara roadside
            "Land_HayBlock_01_lxWS",
            "Land_HayBlock_02_lxWS",
            "Land_Dates_01_lxWS",
            "Land_Dates_02_lxWS",
            // Cages + boxes (livestock market detritus)
            "Cage_Small_lxWS",
            "Cage_Medium_lxWS",
            "Box_Medium_lxWS",
            // Faction ammo crates ("left behind by combatants")
            "SFIA_Box_Wps_lxWS",
            "ION_Box_Wps_lxWS"
        };
        detonator[]       = {};
        placementZ        = -0.1;
        chargeOffsetZ     = 0;
        stompRadius       = 0;
    };

};
