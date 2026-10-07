// ALiVE 3 index v3.1, made 2026-10-07 by the ALiVE web indexer, building positions measured
private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: sangin_distirict_helmand_province (ALiVE 3 index v3.1, 2026-10-07)"] call ALiVE_fnc_dump;

ALiVE_indexVersion = ["3.1", "2026-10-07", "web", true];

ALIVE_Indexing_Blacklist = [];
ALIVE_militaryBuildingTypes = [];
ALIVE_militaryParkingBuildingTypes = [];
ALIVE_militarySupplyBuildingTypes = [];
ALIVE_militaryHQBuildingTypes = [];
ALIVE_militaryFieldworkBuildingTypes = [];
ALIVE_airBuildingTypes = [];
ALIVE_militaryAirBuildingTypes = [];
ALIVE_civilianAirBuildingTypes = [];
ALiVE_HeliBuildingTypes = [];
ALIVE_militaryHeliBuildingTypes = [];
ALIVE_civilianHeliBuildingTypes = [];
ALIVE_civilianSettlementBuildingTypes = [];
ALIVE_civilianHQBuildingTypes = [];
ALIVE_civilianPopulationBuildingTypes = [];
ALIVE_civilianPowerBuildingTypes = [];
ALIVE_civilianCommsBuildingTypes = [];
ALIVE_civilianMarineBuildingTypes = [];
ALIVE_civilianRailBuildingTypes = [];
ALIVE_civilianFuelBuildingTypes = [];
ALIVE_civilianConstructionBuildingTypes = [];

ALiVE_mapCompositionType = "Desert";

 if (tolower(_worldName) == "sangin_distirict_helmand_province") then {
    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "a3\data_f\particleeffects\craterlong\craterlong_small.p3d",
        "a3\props_f_enoch\civilian\camping\woodentable_02_large_f.p3d",
        "a3\props_f_enoch\civilian\forest\deerskeleton_pile_01_f.p3d",
        "a3\props_f_enoch\civilian\forest\feedrack_01_f.p3d",
        "a3\props_f_enoch\civilian\forest\woodenlog_02_f.p3d",
        "a3\props_f_enoch\industrial\supplies\woodenbox_02_f.p3d",
        "a3\props_f_enoch\military\decontamination\containmentarea_01_f.p3d",
        "a3\props_f_enoch\military\decontamination\containmentarea_02_f.p3d",
        "a3\props_f_enoch\military\decontamination\powercable_01_corner_f.p3d",
        "a3\props_f_enoch\military\decontamination\spinalboard_01_f.p3d",
        "a3\props_f_enoch\military\decontamination\stretcherrollersystem_01_f.p3d",
        "a3\props_f_enoch\military\decontamination\tarp_01_large_black_f.p3d",
        "a3\props_f_enoch\military\decontamination\tarp_01_large_green_f.p3d",
        "a3\props_f_enoch\military\decontamination\tarp_01_large_red_f.p3d",
        "a3\props_f_enoch\military\decontamination\tarp_01_large_yellow_f.p3d",
        "a3\props_f_enoch\military\decontamination\tarp_01_small_black_f.p3d",
        "a3\props_f_enoch\military\decontamination\tarp_01_small_green_f.p3d",
        "a3\props_f_enoch\military\decontamination\tarp_01_small_red_f.p3d",
        "a3\props_f_enoch\military\decontamination\tarp_01_small_yellow_f.p3d",
        "a3\props_f_enoch\military\decontamination\walkingframe_01_f.p3d",
        "a3\props_f_enoch\military\equipment\batterypack_01_battery_f.p3d",
        "a3\props_f_exp\industrial\heavyequipment\bulldozer_01_abandoned_f.p3d",
        "a3\props_f_exp\industrial\heavyequipment\bulldozer_01_wreck_f.p3d",
        "a3\props_f_exp\industrial\heavyequipment\combineharvester_01_wreck_f.p3d",
        "a3\props_f_exp\industrial\heavyequipment\excavator_01_abandoned_f.p3d",
        "a3\props_f_exp\industrial\heavyequipment\excavator_01_wreck_f.p3d",
        "a3\props_f_exp\naval\boats\boat_05_wreck_f.p3d",
        "a3\props_f_jets\military\tractor\land_decktractor_01_f.p3d",
        "a3\props_f_jets\military\tractor\land_towbar_01_f.p3d",
        "a3\props_f_jets\military\trolley\land_bomb_trolley_01_f.p3d",
        "a3\props_f_jets\military\trolley\land_missle_trolley_02_f.p3d",
        "a3\props_f_orange\furniture\rug_01_f.p3d",
        "a3\props_f_orange\furniture\sofa_01_f.p3d",
        "a3\props_f_orange\furniture\tablebig_01_f.p3d",
        "a3\props_f_orange\furniture\tablesmall_01_f.p3d",
        "a3\props_f_orange\humanitarian\camps\bodybag_01_f.p3d",
        "a3\props_f_orange\humanitarian\camps\stretcher_01_folded_f.p3d",
        "a3\props_f_orange\humanitarian\supplies\foodsacks_01_large_f.p3d",
        "a3\props_f_orange\humanitarian\supplies\foodsacks_01_small_f.p3d",
        "a3\props_f_orange\humanitarian\supplies\orange_01_f.p3d",
        "a3\props_f_orange\humanitarian\supplies\paperbox_01_open_boxes_f.p3d",
        "a3\props_f_orange\humanitarian\supplies\paperbox_01_small_destroyed_f.p3d",
        "a3\props_f_orange\humanitarian\supplies\paperbox_01_small_open_f.p3d",
        "a3\props_f_orange\humanitarian\supplies\paperbox_01_small_ransacked_f.p3d",
        "a3\props_f_orange\humanitarian\supplies\pumpkin_01_f.p3d",
        "a3\props_f_orange\humanitarian\supplies\waterbottle_01_compressed_f.p3d",
        "a3\props_f_orange\humanitarian\supplies\waterbottle_01_full_f.p3d",
        "a3\props_f_orange\humanitarian\supplies\waterbottle_01_pack_f.p3d",
        "a3\props_f_orange\humanitarian\supplies\waterbottle_01_stack_f.p3d",
        "a3\props_f_tank\military\tankacc\refuelinghose_01_f.p3d",
        "a3\props_f_tank\military\tankacc\tankboresighter_01_f.p3d",
        "a3\props_f_tank\military\tankacc\tankengine_01_f.p3d",
        "a3\props_f_tank\military\tankacc\tankengine_01_used_f.p3d",
        "a3\props_f_tank\military\tankacc\tankroadwheels_01_single_f.p3d",
        "a3\props_f_tank\military\tankacc\tanksprocketwheels_01_single_f.p3d",
        "a3\props_f_tank\military\tankacc\tanktracks_01_long_f.p3d",
        "a3\props_f_tank\military\tankacc\tanktracks_01_short_f.p3d",
        "a3\props_f_tank\military\tankacc\torquewrench_01_f.p3d",
        "a3\props_f_tank\military\wrecks\wreck_afv_wheeled_01_f.p3d",
        "a3\props_f_tank\military\wrecks\wreck_lt_01_f.p3d",
        "a3\props_f_tank\military\wrecks\wreck_mbt_04_f.p3d",
        "a3\structures_f\bridges\bridge_01_f.p3d",
        "a3\structures_f\civ\accessories\timbers_f.p3d",
        "a3\structures_f\ind\dieselpowerplant\dp_mainfactory_addon1_f.p3d",
        "a3\structures_f\ind\dieselpowerplant\dp_mainfactory_addon2_f.p3d",
        "a3\structures_f\training\invisibletarget\center.p3d",
        "a3\structures_f_argo\industrial\agriculture\vineyardfence_01_f.p3d",
        "a3\structures_f_argo\industrial\materials\woodenplanks_01_messy_pine_f.p3d",
        "a3\structures_f_argo\industrial\materials\woodenplanks_01_pine_f.p3d",
        "a3\structures_f_argo\military\fortifications\sandbagbarricade_01_f.p3d",
        "a3\structures_f_argo\military\fortifications\sandbagbarricade_01_half_f.p3d",
        "a3\structures_f_argo\military\fortifications\sandbagbarricade_01_hole_f.p3d",
        "a3\structures_f_argo\walls\city\wallcity_01_gate_pink_f.p3d",
        "a3\structures_f_argo\walls\city\wallcity_01_gate_whiteblue_f.p3d",
        "a3\structures_f_enoch\civilian\camps\caravan_01_green_f.p3d",
        "a3\structures_f_enoch\industrial\agriculture\manurepile_01_f.p3d",
        "a3\structures_f_enoch\industrial\agriculture\trough_01_f.p3d",
        "a3\structures_f_enoch\industrial\farms\strawstack_01_f.p3d",
        "a3\structures_f_enoch\industrial\materials\timberlog_01_f.p3d",
        "a3\structures_f_enoch\industrial\materials\timberlog_02_f.p3d",
        "a3\structures_f_enoch\industrial\materials\timberlog_03_f.p3d",
        "a3\structures_f_enoch\industrial\materials\timberlog_04_f.p3d",
        "a3\structures_f_enoch\industrial\materials\timberlog_05_f.p3d",
        "a3\structures_f_enoch\industrial\materials\timberpile_02_f.p3d",
        "a3\structures_f_enoch\industrial\materials\timberpile_03_f.p3d",
        "a3\structures_f_enoch\industrial\materials\timberpile_04_f.p3d",
        "a3\structures_f_enoch\industrial\materials\timberpile_05_f.p3d",
        "a3\structures_f_enoch\industrial\materials\woodpile_02_f.p3d",
        "a3\structures_f_enoch\industrial\materials\woodpile_03_f.p3d",
        "a3\structures_f_enoch\industrial\materials\woodpile_04_f.p3d",
        "a3\structures_f_enoch\military\training\disturbedsoil_01_decal_f.p3d",
        "a3\structures_f_enoch\military\training\disturbedsoil_02_decal_f.p3d",
        "a3\structures_f_heli\civ\constructions\gastank_01_blue_f.p3d",
        "a3\structures_f_heli\civ\constructions\gastank_01_khaki_f.p3d",
        "a3\structures_f_heli\civ\constructions\mobilescafolding_01_f.p3d",
        "a3\structures_f_heli\civ\constructions\tooltrolley_01_f.p3d",
        "a3\structures_f_heli\civ\constructions\tooltrolley_02_f.p3d",
        "a3\structures_f_heli\civ\constructions\weldingtrolley_01_f.p3d",
        "a3\structures_f_heli\civ\market\pallettrolley_01_khaki_f.p3d",
        "a3\structures_f_heli\ind\airport\mobilelandingplatform_01_f.p3d",
        "a3\structures_f_heli\ind\machines\dieselgroundpowerunit_01_f.p3d",
        "a3\structures_f_heli\ind\machines\waterpump_01_f.p3d",
        "a3\structures_f_heli\items\airport\helicopterwheels_01_disassembled_f.p3d",
        "a3\structures_f_heli\items\airport\rotorcoversbag_01_f.p3d",
        "a3\structures_f_heli\items\luggage\plasticcase_01_large_f.p3d",
        "a3\structures_f_heli\items\luggage\plasticcase_01_medium_f.p3d",
        "a3\structures_f_heli\items\luggage\plasticcase_01_small_f.p3d",
        "a3\structures_f_heli\items\tools\wheelchock_01_f.p3d",
        "a3\structures_f_orange\industrial\cargo\cargo10_idap_f.p3d",
        "a3\structures_f_orange\industrial\cargo\cargo20_idap_f.p3d",
        "a3\structures_f_orange\industrial\cargo\cargo40_idap_f.p3d",
        "a3\structures_f_orange\vr\helpers\memoryfragment_f.p3d",
        "a3\structures_f_tank\military\repairdepot\repairdepot_01_civ_f.p3d",
        "a3\structures_f_tank\military\repairdepot\repairdepot_01_green_f.p3d",
        "a3\structures_f_tank\military\repairdepot\repairdepot_01_tan_f.p3d",
        "a3\supplies_f_heli\fuel\flexibletank_01_f.p3d",
        "a3\supplies_f_heli\slingload\slingload_01_ammo_f.p3d",
        "a3\supplies_f_heli\slingload\slingload_01_fuel_f.p3d",
        "hesco\controlcentre.p3d",
        "hesco\enginer.p3d",
        "hesco\hesco tower.p3d",
        "hesco\hesco1x6.p3d",
        "hesco\hesco2x2x6.p3d",
        "hesco\hesco3x3x6.p3d",
        "hesco\hesco3x3x6f.p3d",
        "hesco\hesco3x3x6ramp.p3d",
        "hesco\hesco3x3x6rampf.p3d",
        "hesco\hescobase.p3d",
        "hesco\hescoop.p3d",
        "hesco\livingarea.p3d",
        "hesco\medic.p3d",
        "hesco\reme.p3d",
        "hesco\sangernoroof.p3d",
        "hesco\unloadingbay1.p3d",
        "jbad_misc\billboards\jbad_board1.p3d",
        "jbad_misc\billboards\jbad_board10.p3d",
        "jbad_misc\billboards\jbad_board11.p3d",
        "jbad_misc\billboards\jbad_board12.p3d",
        "jbad_misc\billboards\jbad_board14.p3d",
        "jbad_misc\billboards\jbad_board15.p3d",
        "jbad_misc\billboards\jbad_board16.p3d",
        "jbad_misc\billboards\jbad_board17.p3d",
        "jbad_misc\billboards\jbad_board18.p3d",
        "jbad_misc\billboards\jbad_board2.p3d",
        "jbad_misc\billboards\jbad_board20.p3d",
        "jbad_misc\billboards\jbad_board22.p3d",
        "jbad_misc\billboards\jbad_board23.p3d",
        "jbad_misc\billboards\jbad_board24.p3d",
        "jbad_misc\billboards\jbad_board25.p3d",
        "jbad_misc\billboards\jbad_board3.p3d",
        "jbad_misc\billboards\jbad_board4.p3d",
        "jbad_misc\billboards\jbad_board5.p3d",
        "jbad_misc\billboards\jbad_board6.p3d",
        "jbad_misc\billboards\jbad_board7.p3d",
        "jbad_misc\billboards\jbad_board8.p3d",
        "jbad_misc\billboards\jbad_board9.p3d",
        "jbad_misc\billboards\jbad_poste3.p3d",
        "jbad_misc\billboards\jbad_poster10.p3d",
        "jbad_misc\billboards\jbad_poster14.p3d",
        "jbad_misc\misc_breadoven\jbad_breadoven.p3d",
        "jbad_misc\misc_dead\jbad_dead.p3d",
        "jbad_misc\misc_fueltank\jbad_ind_tanksmall.p3d",
        "jbad_misc\misc_interier\jbad_carpet.p3d",
        "jbad_misc\misc_interier\jbad_carpet_2.p3d",
        "jbad_misc\misc_interier\jbad_cloth.p3d",
        "jbad_misc\misc_interier\jbad_cloth_2.p3d",
        "jbad_misc\misc_interier\jbad_cloth_3.p3d",
        "jbad_misc\misc_interier\jbad_pillow.p3d",
        "jbad_misc\misc_interier\jbad_pillowv2.p3d",
        "jbad_misc\misc_interier\jbad_rack.p3d",
        "jbad_misc\misc_interier\jbad_teapot.p3d",
        "jbad_misc\misc_interier\jbad_urn.p3d",
        "jbad_misc\misc_interier\jbad_vase.p3d",
        "jbad_misc\misc_market\jbad_counter.p3d",
        "jbad_misc\misc_market\jbad_leanto_1.p3d",
        "jbad_misc\misc_market\jbad_leanto_2.p3d",
        "jbad_misc\misc_market\jbad_sunshade.p3d",
        "jbad_misc\misc_opium\jbad_rawopium.p3d",
        "jbad_misc\misc_powerline\jbad_pole_speaker.p3d",
        "jbad_misc\misc_ramps\jbad_ramp.p3d",
        "jbad_misc\misc_steps\jbad_plank.p3d",
        "jbad_misc\misc_steps\jbad_stairs3.p3d",
        "jbad_misc\misc_steps\jbad_steps.p3d",
        "jbad_structures\afghan_houses\jbad_outside_living.p3d",
        "jbad_structures\afghan_houses_old\damageproxies\jbad_house_4_dam1.p3d",
        "jbad_structures\afghan_houses_old\damageproxies\jbad_house_9_stuff.p3d",
        "jbad_structures\afghan_houses_old\jbad_entrance.p3d",
        "jbad_structures\bridges\bridge\jbad_bridge.p3d",
        "jbad_structures\bridges\bridge\jbad_bridge2.p3d",
        "jbad_structures\bridges\bridge\jbad_bridge_hid.p3d",
        "jbad_structures\bridges\bridge_wood\jbad_bridge_wood.p3d",
        "jbad_structures\ind\ind_coltan_mine\jbad_misc_coltan_heap.p3d",
        "jbad_structures\ind\ind_fuelstation\jbad_ind_fuelstation_feed.p3d",
        "jbad_structures\ind\ind_shed\jbad_ind_shed_01.p3d",
        "jbad_structures\ind\ind_shed\jbad_ind_shed_02.p3d",
        "jbad_structures\opxmisc2\gate\jbad_opx2_gateturquoise.p3d",
        "jbad_structures\sidewalks\jbad_ramp_02.p3d",
        "jbad_structures\sidewalks\jbad_walkway.p3d",
        "jbad_structures\sidewalks\jbad_walkway2.p3d",
        "jbad_structures\walls\fences\jbad_fence1.p3d",
        "jbad_structures\walls\fences\jbad_fence2.p3d",
        "jbad_structures\walls\fences\jbad_fence_gate.p3d",
        "jbad_structures\walls\wall_l\jbad_doorwall1.p3d",
        "jbad_structures\walls\wall_l\jbad_wall_gate.p3d",
        "jbad_structures\walls\wall_l\jbad_wall_l_gate.p3d",
        "jbad_structures\walls\wall_l\jbad_wall_l_pillar.p3d",
        "jbad_structures\walls\wall_l\jbad_wallend.p3d",
        "jbad_structures\walls\wall_l\jbad_wallentrance2.p3d",
        "jbad_structures\walls\wall_l\jbad_wallwin.p3d",
        "jbad_structures\walls\wall_l\jbad_wideentrance.p3d",
        "jbad_vehicles\trailers\jbad_freight_trailer.p3d",
        "jbad_vehicles\trailers\jbad_fuel_tanker.p3d",
        "jbad_vehicles\trailers\jbad_gravel_trailer.p3d",
        "smoke\billboards\hellskitchen_billboard1.p3d",
        "smoke\billboards\hellskitchen_billboard2.p3d",
        "smoke\billboards\hellskitchen_billboard3.p3d",
        "smoke\billboards\hellskitchen_billboard4.p3d",
        "smoke\billboards\hellskitchen_billboard5.p3d",
        "smoke\billboards\hellskitchen_billboard6.p3d"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "a3\structures_f\mil\cargo\medevac_house_v1_f.p3d",
        "a3\structures_f\mil\cargo\medevac_hq_v1_f.p3d",
        "a3\structures_f_enoch\military\radar\radar_01_hq_f.p3d",
        "a3\structures_f_orange\humanitarian\camps\medicaltent_01_f.p3d",
        "a3\structures_f_orange\humanitarian\camps\medicaltent_01_floor_dark_f.p3d",
        "a3\supplies_f_heli\slingload\slingload_01_cargo_f.p3d",
        "a3\supplies_f_heli\slingload\slingload_01_medevac_f.p3d",
        "a3\supplies_f_heli\slingload\slingload_01_repair_f.p3d",
        "jbad_structures\mil\jbad_mil_barracks.p3d",
        "jbad_structures\mil\jbad_mil_controltower.p3d",
        "jbad_structures\mil\jbad_mil_guardhouse.p3d",
        "jbad_structures\mil\jbad_mil_house.p3d",
        "jbad_structures\mil\jbad_mil_repair_center.p3d",
        "jbad_structures\opxbuildings2\jbad_opx2_policestation.p3d"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "a3\structures_f_enoch\military\radar\radar_01_hq_f.p3d",
        "jbad_structures\mil\jbad_mil_barracks.p3d",
        "jbad_structures\mil\jbad_mil_repair_center.p3d"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "a3\structures_f_enoch\military\radar\radar_01_hq_f.p3d",
        "a3\supplies_f_heli\slingload\slingload_01_medevac_f.p3d",
        "jbad_structures\mil\jbad_mil_barracks.p3d",
        "jbad_structures\mil\jbad_mil_controltower.p3d",
        "jbad_structures\mil\jbad_mil_repair_center.p3d"
    ];

    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        "a3\structures_f_enoch\military\radar\radar_01_hq_f.p3d",
        "jbad_structures\mil\jbad_mil_barracks.p3d"
    ];

    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
        "a3\structures_f\mil\tenthangar\tenthangar_v1_f.p3d"
    ];

    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [
        "a3\structures_f\mil\tenthangar\tenthangar_v1_f.p3d"
    ];

    ALiVE_HeliBuildingTypes = ALiVE_HeliBuildingTypes + [
        "a3\structures_f\mil\helipads\helipadcircle_f.p3d",
        "a3\structures_f\mil\helipads\helipadempty_f.p3d",
        "a3\structures_f\mil\helipads\helipadrescue_f.p3d"
    ];

    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
        "a3\structures_f\mil\helipads\helipadcircle_f.p3d",
        "a3\structures_f\mil\helipads\helipadempty_f.p3d",
        "a3\structures_f\mil\helipads\helipadrescue_f.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "a3\structures_f\households\addons\i_garage_v1_dam_f.p3d",
        "a3\structures_f\households\addons\i_garage_v2_dam_f.p3d",
        "a3\structures_f\households\addons\i_garage_v2_f.p3d",
        "a3\structures_f\households\slum\cargo_house_slum_f.p3d",
        "a3\structures_f\households\wip\unfinished_building_01_f.p3d",
        "a3\structures_f\ind\carservice\carservice_f.p3d",
        "a3\structures_f_argo\industrial\agriculture\shed_08_grey_f.p3d",
        "a3\structures_f_enoch\civilian\camps\caravan_01_rust_f.p3d",
        "a3\structures_f_enoch\industrial\sawmills\sawmill_01_f.p3d",
        "jbad_structures\afghan_house_a\a_minaret\jbad_a_minaret.p3d",
        "jbad_structures\afghan_house_a\a_minaret_porto\jbad_a_minaret_porto.p3d",
        "jbad_structures\afghan_house_a\a_mosque_small\jbad_a_mosque_small_1.p3d",
        "jbad_structures\afghan_house_a\a_mosque_small\jbad_a_mosque_small_2.p3d",
        "jbad_structures\afghan_houses\jbad_fp1.p3d",
        "jbad_structures\afghan_houses\jbad_house3.p3d",
        "jbad_structures\afghan_houses\jbad_house3_dam.p3d",
        "jbad_structures\afghan_houses\jbad_house3_ruins.p3d",
        "jbad_structures\afghan_houses\jbad_house5.p3d",
        "jbad_structures\afghan_houses\jbad_house5_dam.p3d",
        "jbad_structures\afghan_houses\jbad_house5_ruins.p3d",
        "jbad_structures\afghan_houses\jbad_house6.p3d",
        "jbad_structures\afghan_houses\jbad_house6_dam.p3d",
        "jbad_structures\afghan_houses\jbad_house6_ruins.p3d",
        "jbad_structures\afghan_houses\jbad_house7.p3d",
        "jbad_structures\afghan_houses\jbad_house7_dam.p3d",
        "jbad_structures\afghan_houses\jbad_house7_ruins.p3d",
        "jbad_structures\afghan_houses\jbad_house8.p3d",
        "jbad_structures\afghan_houses\jbad_house8_dam.p3d",
        "jbad_structures\afghan_houses\jbad_house8_ruins.p3d",
        "jbad_structures\afghan_houses\jbad_house_1.p3d",
        "jbad_structures\afghan_houses\jbad_terrace.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_1.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_10.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_11.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_12.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_1_v2.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_2.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_3.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_4.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_5.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_9.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_1_old.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_1_old_ruins.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_3_old.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_3_old_dam.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_3_old_h.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_3_old_ruins.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_4_old.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_4_old_ruins.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_6_old.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_6_old_dam.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_6_old_ruins.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_7_old.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_7_old_ruins.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_8_old.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_9_old.p3d",
        "jbad_structures\ind\ind_workshop01\jbad_ind_workshop01_01.p3d",
        "jbad_structures\ind\ind_workshop01\jbad_ind_workshop01_02.p3d",
        "jbad_structures\ind\ind_workshop01\jbad_ind_workshop01_03.p3d",
        "jbad_structures\ind\ind_workshop01\jbad_ind_workshop01_04.p3d",
        "jbad_structures\ind\ind_workshop01\jbad_ind_workshop01_l.p3d",
        "jbad_structures\shops\jbad_grainstore.p3d",
        "jbad_structures\shops\jbad_grainstore2.p3d",
        "jbad_structures\shops\jbad_grainstore3.p3d",
        "jbad_structures\shops\jbad_shop_01.p3d",
        "jbad_structures\shops\jbad_shop_02.p3d",
        "jbad_structures\shops\jbad_shop_03.p3d",
        "jbad_structures\shops\jbad_shop_04.p3d"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "jbad_structures\afghan_houses\jbad_house3_dam.p3d"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "a3\structures_f\households\slum\cargo_house_slum_f.p3d",
        "a3\structures_f\households\wip\unfinished_building_01_f.p3d",
        "a3\structures_f\ind\carservice\carservice_f.p3d",
        "a3\structures_f_enoch\industrial\sawmills\sawmill_01_f.p3d",
        "jbad_structures\afghan_house_a\a_minaret_porto\jbad_a_minaret_porto.p3d",
        "jbad_structures\afghan_house_a\a_mosque_small\jbad_a_mosque_small_1.p3d",
        "jbad_structures\afghan_houses\jbad_fp1.p3d",
        "jbad_structures\afghan_houses\jbad_house3.p3d",
        "jbad_structures\afghan_houses\jbad_house3_dam.p3d",
        "jbad_structures\afghan_houses\jbad_house5.p3d",
        "jbad_structures\afghan_houses\jbad_house5_dam.p3d",
        "jbad_structures\afghan_houses\jbad_house6.p3d",
        "jbad_structures\afghan_houses\jbad_house6_dam.p3d",
        "jbad_structures\afghan_houses\jbad_house7.p3d",
        "jbad_structures\afghan_houses\jbad_house7_dam.p3d",
        "jbad_structures\afghan_houses\jbad_house8.p3d",
        "jbad_structures\afghan_houses\jbad_house8_dam.p3d",
        "jbad_structures\afghan_houses\jbad_house_1.p3d",
        "jbad_structures\afghan_houses\jbad_terrace.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_1.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_10.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_11.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_12.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_1_v2.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_2.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_3.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_4.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_5.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_9.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_1_old.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_3_old.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_3_old_dam.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_3_old_h.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_4_old.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_6_old.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_6_old_dam.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_7_old.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_8_old.p3d",
        "jbad_structures\shops\jbad_grainstore3.p3d",
        "jbad_structures\shops\jbad_shop_01.p3d"
    ];

    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
        "a3\structures_f\ind\dieselpowerplant\dp_smallfactory_f.p3d",
        "jbad_structures\ind\ind_powerstation\jbad_ind_powerstation.p3d"
    ];

    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
        "a3\props_f_exp\infrastructure\railways\railwaycar_01_sugarcane_f.p3d"
    ];

    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        "jbad_structures\ind\ind_fuelstation\jbad_ind_fuelstation_build.p3d",
        "jbad_structures\ind\ind_fuelstation\jbad_ind_fuelstation_shed.p3d"
    ];

    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
        "a3\structures_f\ind\dieselpowerplant\dp_mainfactory_f.p3d",
        "a3\structures_f_enoch\industrial\sawmills\sawmill_01_f.p3d"
    ];

};
