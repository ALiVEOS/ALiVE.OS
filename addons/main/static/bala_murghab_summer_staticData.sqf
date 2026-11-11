// ALiVE 3 index v3.1, made 2026-11-11 by the ALiVE web indexer, building positions measured
private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: bala_murghab_summer (ALiVE 3 index v3.1, 2026-11-11)"] call ALiVE_fnc_dump;

ALiVE_indexVersion = ["3.1", "2026-11-11", "web", true];

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

 if (tolower(_worldName) == "bala_murghab_summer") then {
    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "a3\structures_f_tank\military\repairdepot\repairdepot_01_green_ruins_f.p3d",
        "bmg_custom_billboards\aia.p3d",
        "bmg_custom_billboards\cmdo.p3d",
        "bmg_custom_billboards\cqb.p3d",
        "bmg_custom_billboards\herat.p3d",
        "bmg_custom_billboards\hrbek.p3d",
        "bmg_custom_billboards\lzh.p3d",
        "bmg_custom_billboards\prius.p3d",
        "bmg_custom_billboards\range.p3d",
        "bmg_custom_billboards\school.p3d",
        "bmg_custom_billboards\spino.p3d",
        "bmg_custom_billboards\stone.p3d",
        "bmg_custom_billboards\todd.p3d",
        "jbad_structures\afghan_houses_old\damageproxies\jbad_house_9_stuff.p3d",
        "jbad_structures\walls\wall_l\jbad_wall_l_mosque_1.p3d",
        "jbad_structures\walls\wall_l\jbad_wall_l_mosque_2.p3d"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "a3\static_f_gamma\hmg_01\hmg_01_high_f.p3d",
        "a3\structures_f\ind\airport\airport_tower_f.p3d",
        "a3\structures_f\mil\bagbunker\bagbunker_small_f.p3d",
        "a3\structures_f\mil\barracks\u_barracks_v2_f.p3d",
        "a3\structures_f\mil\bunker\bunker_f.p3d",
        "a3\structures_f\mil\cargo\cargo_house_v1_f.p3d",
        "a3\structures_f\mil\cargo\cargo_house_v2_f.p3d",
        "a3\structures_f\mil\cargo\cargo_house_v3_f.p3d",
        "a3\structures_f\mil\cargo\cargo_hq_v1_f.p3d",
        "a3\structures_f\mil\cargo\cargo_hq_v2_f.p3d",
        "a3\structures_f\mil\cargo\cargo_hq_v3_f.p3d",
        "a3\structures_f\mil\cargo\cargo_patrol_v1_f.p3d",
        "a3\structures_f\mil\cargo\cargo_patrol_v2_f.p3d",
        "a3\structures_f\mil\cargo\cargo_patrol_v3_f.p3d",
        "a3\structures_f\mil\cargo\cargo_tower_v3_f.p3d",
        "a3\structures_f\mil\cargo\medevac_house_v1_f.p3d",
        "a3\structures_f\mil\cargo\medevac_hq_v1_f.p3d",
        "a3\structures_f\mil\fortification\hbarriertower_f.p3d",
        "a3\structures_f\mil\radar\radar_small_f.p3d",
        "a3\structures_f_enoch\military\airfield\servicehangar_01_l_f.p3d",
        "a3\structures_f_enoch\military\airfield\servicehangar_01_r_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_02_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_06_f.p3d",
        "a3\structures_f_enoch\military\barracks\controltower_01_f.p3d",
        "a3\structures_f_enoch\military\barracks\guardbox_01_brown_f.p3d",
        "a3\structures_f_enoch\military\barracks\guardbox_01_smooth_f.p3d",
        "a3\structures_f_enoch\military\barracks\guardhouse_02_f.p3d",
        "a3\structures_f_enoch\military\barracks\guardhouse_02_grey_f.p3d",
        "a3\structures_f_enoch\military\barracks\guardtower_01_f.p3d",
        "a3\structures_f_enoch\military\barracks\guardtower_02_f.p3d",
        "a3\structures_f_enoch\military\bunkers\bunker_02_light_double_f.p3d",
        "a3\structures_f_enoch\military\radar\mobileradar_01_radar_f.p3d",
        "a3\structures_f_enoch\military\radar\radar_01_cooler_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shed_unfinished_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_02_terminal_f.p3d",
        "a3\structures_f_exp\military\barracks_01\barracks_01_dilapidated_f.p3d",
        "a3\structures_f_exp\military\pillboxes\pillboxbunker_01_big_f.p3d",
        "a3\structures_f_exp\military\pillboxes\pillboxbunker_01_hex_f.p3d",
        "a3\structures_f_exp\military\pillboxes\pillboxbunker_01_rectangle_f.p3d",
        "jbad_structures\ind\hangar_2\jbad_hangar_2.p3d",
        "jbad_structures\mil\jbad_mil_controltower.p3d",
        "jbad_structures\mil\jbad_mil_guardhouse.p3d"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "a3\structures_f\mil\barracks\u_barracks_v2_f.p3d",
        "a3\structures_f\mil\cargo\cargo_hq_v1_f.p3d",
        "a3\structures_f\mil\cargo\cargo_hq_v3_f.p3d",
        "a3\structures_f\mil\cargo\cargo_tower_v3_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_02_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_06_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_02_terminal_f.p3d",
        "a3\structures_f_exp\military\barracks_01\barracks_01_dilapidated_f.p3d",
        "jbad_structures\ind\hangar_2\jbad_hangar_2.p3d"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "a3\structures_f\mil\barracks\u_barracks_v2_f.p3d",
        "a3\structures_f\mil\cargo\cargo_hq_v1_f.p3d",
        "a3\structures_f\mil\cargo\cargo_hq_v2_f.p3d",
        "a3\structures_f\mil\cargo\cargo_hq_v3_f.p3d",
        "a3\structures_f\mil\cargo\cargo_tower_v3_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_02_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_06_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shed_unfinished_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_02_terminal_f.p3d",
        "a3\structures_f_exp\military\barracks_01\barracks_01_dilapidated_f.p3d",
        "jbad_structures\ind\hangar_2\jbad_hangar_2.p3d",
        "jbad_structures\mil\jbad_mil_controltower.p3d"
    ];

    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        "a3\structures_f\mil\barracks\u_barracks_v2_f.p3d",
        "a3\structures_f\mil\cargo\cargo_hq_v1_f.p3d",
        "a3\structures_f\mil\cargo\cargo_hq_v2_f.p3d",
        "a3\structures_f\mil\cargo\cargo_hq_v3_f.p3d",
        "a3\structures_f\mil\cargo\cargo_tower_v3_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_06_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_02_terminal_f.p3d",
        "a3\structures_f_exp\military\barracks_01\barracks_01_dilapidated_f.p3d"
    ];

    ALIVE_militaryFieldworkBuildingTypes = ALIVE_militaryFieldworkBuildingTypes + [
        "a3\structures_f_enoch\military\barracks\guardtower_01_f.p3d",
        "a3\structures_f_enoch\military\barracks\guardtower_02_f.p3d",
        "a3\structures_f_enoch\military\bunkers\bunker_02_light_double_f.p3d",
        "a3\structures_f_exp\military\pillboxes\pillboxbunker_01_big_f.p3d",
        "a3\structures_f_exp\military\pillboxes\pillboxbunker_01_hex_f.p3d",
        "a3\structures_f_exp\military\pillboxes\pillboxbunker_01_rectangle_f.p3d"
    ];

    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
        "a3\structures_f\mil\tenthangar\tenthangar_v1_f.p3d",
        "a3\structures_f_enoch\military\airfield\servicehangar_01_l_f.p3d",
        "a3\structures_f_enoch\military\airfield\servicehangar_01_r_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_01_hangar_f.p3d",
        "jbad_structures\ind\hangar_2\jbad_hangar_2.p3d",
        "jbad_structures\mil\hanger\jbad_hanger_withdoor.p3d"
    ];

    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [
        "a3\structures_f\mil\tenthangar\tenthangar_v1_f.p3d",
        "a3\structures_f_enoch\military\airfield\servicehangar_01_l_f.p3d",
        "a3\structures_f_enoch\military\airfield\servicehangar_01_r_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_01_hangar_f.p3d",
        "jbad_structures\ind\hangar_2\jbad_hangar_2.p3d",
        "jbad_structures\mil\hanger\jbad_hanger_withdoor.p3d"
    ];

    ALiVE_HeliBuildingTypes = ALiVE_HeliBuildingTypes + [
        "a3\structures_f\mil\helipads\helipadcircle_f.p3d",
        "a3\structures_f\mil\helipads\helipadcivil_f.p3d",
        "a3\structures_f\mil\helipads\helipadrescue_f.p3d",
        "a3\structures_f\mil\helipads\helipadsquare_f.p3d"
    ];

    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
        "a3\structures_f\mil\helipads\helipadcircle_f.p3d",
        "a3\structures_f\mil\helipads\helipadcivil_f.p3d",
        "a3\structures_f\mil\helipads\helipadrescue_f.p3d",
        "a3\structures_f\mil\helipads\helipadsquare_f.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "a3\structures_f\civ\offices\offices_01_v1_f.p3d",
        "a3\structures_f\households\addons\i_garage_v2_f.p3d",
        "a3\structures_f\households\house_big01\d_house_big_01_v1_f.p3d",
        "a3\structures_f\households\house_big01\u_house_big_01_v1_f.p3d",
        "a3\structures_f\households\slum\cargo_house_slum_f.p3d",
        "a3\structures_f\households\slum\slum_house01_f.p3d",
        "a3\structures_f\households\slum\slum_house02_f.p3d",
        "a3\structures_f\households\slum\slum_house03_f.p3d",
        "a3\structures_f\households\stone_big\d_stone_housebig_v1_f.p3d",
        "a3\structures_f\households\stone_shed\i_stone_shed_v1_f.p3d",
        "a3\structures_f\households\stone_shed\i_stone_shed_v3_f.p3d",
        "a3\structures_f\households\stone_small\d_stone_housesmall_v1_f.p3d",
        "a3\structures_f\households\stone_small\i_stone_housesmall_v2_f.p3d",
        "a3\structures_f\households\wip\unfinished_building_01_f.p3d",
        "a3\structures_f\households\wip\unfinished_building_02_f.p3d",
        "a3\structures_f\ind\shed\i_shed_ind_f.p3d",
        "a3\structures_f\ind\shed\u_shed_ind_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_02_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_04_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_small_01_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_small_01_half_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_small_02_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_02_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_03_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_05_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_07_f.p3d",
        "a3\structures_f_exp\commercial\addons\addon_05_f.p3d",
        "a3\structures_f_exp\commercial\market\metalshelter_02_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_warehouse_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shed_unfinished_f.p3d",
        "jbad_structures\afghan_house_a\a_minaret\jbad_a_minaret.p3d",
        "jbad_structures\afghan_house_a\a_mosque_small\jbad_a_mosque_small_1.p3d",
        "jbad_structures\afghan_house_a\a_mosque_small\jbad_a_mosque_small_2.p3d",
        "jbad_structures\afghan_house_a\a_stationhouse\jbad_a_stationhouse.p3d",
        "jbad_structures\afghan_houses\jbad_house2_basehide.p3d",
        "jbad_structures\afghan_houses\jbad_house3.p3d",
        "jbad_structures\afghan_houses\jbad_house3_dam.p3d",
        "jbad_structures\afghan_houses\jbad_house5.p3d",
        "jbad_structures\afghan_houses\jbad_house6.p3d",
        "jbad_structures\afghan_houses\jbad_house7.p3d",
        "jbad_structures\afghan_houses\jbad_house7_dam.p3d",
        "jbad_structures\afghan_houses\jbad_house8.p3d",
        "jbad_structures\afghan_houses\jbad_house_1.p3d",
        "jbad_structures\afghan_houses_c2\jbad_dum_istan2.p3d",
        "jbad_structures\afghan_houses_c2\jbad_dum_istan4.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_1.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_10.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_11.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_12.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_1_v2.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_2.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_3.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_4.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_5.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_5_v1.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_5_v2.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_9.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_9_dam.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_1_old.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_1_old_ruins.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_3_old.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_3_old_h.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_3_old_ruins.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_4_old.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_4_old_ruins.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_6_old.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_7_old.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_8_old.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_9_old.p3d",
        "jbad_structures\mosque_big\jbad_mosque_big_minaret_2.p3d",
        "jbad_structures\opxbuildings2\jbad_opx2_big_b.p3d",
        "jbad_structures\opxbuildings2\jbad_opx2_big_c.p3d",
        "jbad_structures\opxbuildings2\jbad_opx2_big_d.p3d",
        "jbad_structures\opxbuildings2\jbad_opx2_big_e.p3d",
        "jbad_structures\opxbuildings2\jbad_opx2_complex1.p3d",
        "jbad_structures\opxbuildings2\jbad_opx2_complex5.p3d",
        "jbad_structures\opxbuildings2\jbad_opx2_complex8.p3d",
        "jbad_structures\opxbuildings2\jbad_opx2_store1.p3d",
        "jbad_structures\opxbuildings2\jbad_opx2_tower1.p3d",
        "jbad_structures\shops\jbad_grainstore.p3d",
        "jbad_structures\shops\jbad_grainstore3.p3d"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "a3\structures_f\civ\offices\offices_01_v1_f.p3d",
        "jbad_structures\afghan_houses\jbad_house3_dam.p3d",
        "jbad_structures\opxbuildings2\jbad_opx2_big_b.p3d",
        "jbad_structures\opxbuildings2\jbad_opx2_big_e.p3d"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "a3\structures_f\civ\offices\offices_01_v1_f.p3d",
        "a3\structures_f\households\house_big01\u_house_big_01_v1_f.p3d",
        "a3\structures_f\households\slum\cargo_house_slum_f.p3d",
        "a3\structures_f\households\slum\slum_house01_f.p3d",
        "a3\structures_f\households\slum\slum_house02_f.p3d",
        "a3\structures_f\households\slum\slum_house03_f.p3d",
        "a3\structures_f\households\stone_shed\i_stone_shed_v1_f.p3d",
        "a3\structures_f\households\stone_shed\i_stone_shed_v3_f.p3d",
        "a3\structures_f\households\stone_small\i_stone_housesmall_v2_f.p3d",
        "a3\structures_f\households\wip\unfinished_building_01_f.p3d",
        "jbad_structures\afghan_house_a\a_mosque_small\jbad_a_mosque_small_1.p3d",
        "jbad_structures\afghan_house_a\a_stationhouse\jbad_a_stationhouse.p3d",
        "jbad_structures\afghan_houses\jbad_house2_basehide.p3d",
        "jbad_structures\afghan_houses\jbad_house3.p3d",
        "jbad_structures\afghan_houses\jbad_house3_dam.p3d",
        "jbad_structures\afghan_houses\jbad_house5.p3d",
        "jbad_structures\afghan_houses\jbad_house6.p3d",
        "jbad_structures\afghan_houses\jbad_house7.p3d",
        "jbad_structures\afghan_houses\jbad_house7_dam.p3d",
        "jbad_structures\afghan_houses\jbad_house8.p3d",
        "jbad_structures\afghan_houses\jbad_house_1.p3d",
        "jbad_structures\afghan_houses_c2\jbad_dum_istan4.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_1.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_10.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_11.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_12.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_1_v2.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_2.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_3.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_4.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_5.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_5_v1.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_5_v2.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_9.p3d",
        "jbad_structures\afghan_houses_c\jbad_house_c_9_dam.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_1_old.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_3_old.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_3_old_h.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_4_old.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_6_old.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_7_old.p3d",
        "jbad_structures\afghan_houses_old\jbad_house_8_old.p3d",
        "jbad_structures\mosque_big\jbad_mosque_big_minaret_2.p3d",
        "jbad_structures\opxbuildings2\jbad_opx2_big_b.p3d",
        "jbad_structures\opxbuildings2\jbad_opx2_big_c.p3d",
        "jbad_structures\opxbuildings2\jbad_opx2_big_d.p3d",
        "jbad_structures\opxbuildings2\jbad_opx2_big_e.p3d",
        "jbad_structures\opxbuildings2\jbad_opx2_complex1.p3d",
        "jbad_structures\opxbuildings2\jbad_opx2_complex5.p3d",
        "jbad_structures\opxbuildings2\jbad_opx2_complex8.p3d",
        "jbad_structures\opxbuildings2\jbad_opx2_store1.p3d",
        "jbad_structures\shops\jbad_grainstore3.p3d"
    ];

    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
        "a3\structures_f\ind\dieselpowerplant\dp_smallfactory_f.p3d",
        "a3\structures_f\ind\solarpowerplant\spp_transformer_f.p3d",
        "a3\structures_f_enoch\industrial\houses\waterstation_01_f.p3d",
        "a3\structures_f_enoch\industrial\power\powerstation_01_f.p3d",
        "a3\structures_f_enoch\military\radar\mobileradar_01_generator_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_chimney_f.p3d"
    ];

    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
        "a3\structures_f\ind\transmitter_tower\communication_f.p3d",
        "a3\structures_f\ind\transmitter_tower\tbox_f.p3d",
        "a3\structures_f\ind\transmitter_tower\ttowerbig_2_f.p3d",
        "a3\structures_f\ind\transmitter_tower\ttowersmall_1_f.p3d",
        "a3\structures_f\ind\transmitter_tower\ttowersmall_2_f.p3d"
    ];

    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        "a3\structures_f\naval\piers\pier_small_f.p3d",
        "a3\structures_f_exp\naval\piers\pierwooden_02_16m_f.p3d"
    ];

    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        "a3\structures_f\ind\dieselpowerplant\dp_bigtank_f.p3d",
        "a3\structures_f\ind\dieselpowerplant\dp_smalltank_f.p3d",
        "a3\structures_f\ind\fuelstation\fuelstation_build_f.p3d",
        "a3\structures_f\ind\fuelstation\fuelstation_feed_f.p3d",
        "a3\structures_f\ind\fuelstation\fuelstation_shed_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_crystallizertowers_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_storagebin_small_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_reservoirtower_f.p3d",
        "jbad_structures\ind\ind_oil_mine\jbad_ind_oil_tower.p3d"
    ];

    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
        "a3\structures_f\ind\dieselpowerplant\dp_mainfactory_f.p3d",
        "a3\structures_f\ind\factory\factory_main_f.p3d",
        "a3\structures_f_exp\industrial\dieselpowerplant_01\dpp_01_mainfactory_f.p3d",
        "a3\structures_f_exp\industrial\dieselpowerplant_01\dpp_01_smallfactory_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_boilerbuilding_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_clarifier_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_condenser_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_crystallizer_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_diffuser_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_feeder_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_heap_bagasse_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shed_unfinished_f.p3d"
    ];

};
