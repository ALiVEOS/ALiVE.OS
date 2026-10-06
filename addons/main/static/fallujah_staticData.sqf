// ALiVE 3 index v3.1, made 2026-10-06 by the ALiVE web indexer, building positions measured
private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: fallujah (ALiVE 3 index v3.1, 2026-10-06)"] call ALiVE_fnc_dump;

ALiVE_indexVersion = ["3.1", "2026-10-06", "web", true];

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

 if (tolower(_worldName) == "fallujah") then {
    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "a3\structures_f\mil\barracks\barracks_acc_proxy_1_f.p3d",
        "a3\structures_f\mil\fortification\hbarrier_big_f.p3d",
        "a3\structures_f\mil\fortification\hbarrierwall6_f.p3d",
        "a3\structures_f_enoch\industrial\smokestacks\smokestack_03_f.p3d",
        "a3\structures_f_exp\civilian\accessories\clothesline_01_f.p3d",
        "ca\buildings2\a_crane_02\crane_rails.p3d",
        "ca\buildings2\a_crane_02\crane_rails_end.p3d",
        "ca\buildings2\ind_cementworks\ind_dopravnik\d_mlyn_vys.p3d",
        "ca\buildings2\ind_cementworks\ind_silomale\ind_silomale.p3d",
        "ca\buildings2\ind_shed_02\ind_shed_02_end.p3d",
        "ca\buildings2\ind_shed_02\ind_shed_02_main.p3d",
        "ca\buildings2\ind_tank\ind_tankbig_ruins.p3d",
        "ca\buildings2\ind_tank\ind_tanksmall.p3d",
        "ca\buildings2\misc_cargo\misc_cargo1e.p3d",
        "ca\buildings2\misc_cargo\misc_cargo1f.p3d",
        "ca\buildings2\misc_cargo\misc_cargo1g.p3d",
        "ca\buildings\dum_zboreny_lidice.p3d",
        "ca\buildings\misc\zavora_2.p3d",
        "ca\buildings\misc\zed_civil.p3d",
        "ca\buildings\misc\zed_dira_civil.p3d",
        "ca\buildings\misc\zed_podplaz_civil.p3d",
        "ca\misc2\bighbarrier.p3d",
        "ca\misc2\hbarrier5.p3d",
        "ca\misc3\fort_bagfence_round.p3d",
        "ca\roads_pmc\bridge\bridge_asf_pmc.p3d",
        "ca\structures\house\a_fuelstation\a_fuelstation_shed_ruins.p3d",
        "ca\structures\ind_quarry\ind_hammermill.p3d",
        "ca\structures\misc\armory\pneu\pneu.p3d",
        "ca\structures\rail\rail_misc\rail_najazdovarampa.p3d"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "a3\structures_f\mil\bagbunker\bagbunker_large_f.p3d",
        "a3\structures_f\mil\bagbunker\bagbunker_tower_f.p3d",
        "a3\structures_f\mil\barracks\i_barracks_v1_f.p3d",
        "a3\structures_f\mil\barracks\u_barracks_v2_f.p3d",
        "a3\structures_f\mil\cargo\cargo_house_v2_f.p3d",
        "a3\structures_f\mil\cargo\cargo_house_v3_f.p3d",
        "a3\structures_f\mil\cargo\cargo_hq_v2_f.p3d",
        "a3\structures_f\mil\cargo\cargo_tower_v2_f.p3d",
        "a3\structures_f\mil\fortification\hbarriertower_f.p3d",
        "a3\structures_f\mil\offices\miloffices_v1_f.p3d",
        "a3\structures_f\mil\tenthangar\tenthangar_v1_dam_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garageoffice_01_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_02_f.p3d",
        "a3\structures_f_enoch\military\barracks\guardhouse_02_f.p3d",
        "ca\buildings\budova1.p3d",
        "ca\buildings\budova4.p3d",
        "ca\buildings\budova4_in.p3d",
        "ca\buildings\budova5.p3d",
        "ca\buildings\hangar_2.p3d",
        "ca\buildings\hlidac_budka.p3d",
        "ca\buildings\repair_center.p3d",
        "ca\buildings\tents\camo_box.p3d",
        "ca\buildings\tents\mash.p3d",
        "ca\buildings\tents\pristresek.p3d",
        "ca\misc2\barrack2\barrack2.p3d",
        "ca\misc3\fort_watchtower.p3d",
        "ca\misc3\fortified_nest_big.p3d",
        "ca\misc3\wf\wf_anti_radar_west.p3d",
        "ca\misc3\wf\wf_artilery_radar_west.p3d",
        "ca\misc3\wf\wf_bunker.p3d",
        "ca\misc3\wf\wf_depot.p3d",
        "ca\misc3\wf\wf_field_hospital_west.p3d",
        "ca\misc3\wf\wf_vehicle_service_point_east.p3d",
        "ca\structures\ind_sawmill\ind_illuminanttower.p3d",
        "ca\structures\mil\mil_barracks_i.p3d",
        "ca\structures\mil\mil_controltower.p3d",
        "ca\structures\mil\mil_guardhouse.p3d",
        "ca\structures\mil\mil_house.p3d"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "a3\structures_f\mil\barracks\i_barracks_v1_f.p3d",
        "a3\structures_f\mil\barracks\u_barracks_v2_f.p3d",
        "a3\structures_f\mil\cargo\cargo_tower_v2_f.p3d",
        "a3\structures_f\mil\offices\miloffices_v1_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garageoffice_01_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_02_f.p3d",
        "ca\buildings\hangar_2.p3d",
        "ca\structures\mil\mil_controltower.p3d",
        "ca\structures\mil\mil_house.p3d"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "a3\structures_f\mil\barracks\i_barracks_v1_f.p3d",
        "a3\structures_f\mil\barracks\u_barracks_v2_f.p3d",
        "a3\structures_f\mil\cargo\cargo_hq_v2_f.p3d",
        "a3\structures_f\mil\cargo\cargo_tower_v2_f.p3d",
        "a3\structures_f\mil\offices\miloffices_v1_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garageoffice_01_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_02_f.p3d",
        "ca\buildings\budova1.p3d",
        "ca\buildings\budova4_in.p3d",
        "ca\buildings\hangar_2.p3d",
        "ca\structures\mil\mil_controltower.p3d",
        "ca\structures\mil\mil_house.p3d"
    ];

    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        "a3\structures_f\mil\barracks\i_barracks_v1_f.p3d",
        "a3\structures_f\mil\barracks\u_barracks_v2_f.p3d",
        "a3\structures_f\mil\cargo\cargo_hq_v2_f.p3d",
        "a3\structures_f\mil\cargo\cargo_tower_v2_f.p3d",
        "a3\structures_f\mil\offices\miloffices_v1_f.p3d",
        "ca\buildings\budova4_in.p3d",
        "ca\structures\mil\mil_controltower.p3d",
        "ca\structures\mil\mil_house.p3d"
    ];

    ALIVE_militaryFieldworkBuildingTypes = ALIVE_militaryFieldworkBuildingTypes + [
        "ca\misc3\fortified_nest_big.p3d"
    ];

    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
        "ca\roads2\runway_end15.p3d",
        "ca\roads2\runway_end33.p3d",
        "ca\roads2\runway_main.p3d"
    ];

    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [
        "ca\roads2\runway_end15.p3d",
        "ca\roads2\runway_end33.p3d",
        "ca\roads2\runway_main.p3d"
    ];

    ALiVE_HeliBuildingTypes = ALiVE_HeliBuildingTypes + [
        "a3\structures_f\mil\helipads\helipadcivil_f.p3d",
        "a3\structures_f\mil\helipads\helipadempty_f.p3d",
        "ca\misc\heli_h_army.p3d"
    ];

    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
        "a3\structures_f\mil\helipads\helipadcivil_f.p3d",
        "a3\structures_f\mil\helipads\helipadempty_f.p3d",
        "ca\misc\heli_h_army.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "a3\structures_f\households\house_big01\d_house_big_01_v1_f.p3d",
        "a3\structures_f\households\house_big01\i_house_big_01_v1_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garageoffice_01_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garagerow_01_large_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garagerow_01_small_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_02_f.p3d",
        "a3\structures_f_exp\civilian\garages\garageshelter_01_f.p3d",
        "a3\structures_f_exp\civilian\house_big_01\house_big_01_f.p3d",
        "a3\structures_f_exp\civilian\house_big_01\house_big_01_ruins_f.p3d",
        "a3\structures_f_exp\civilian\house_big_02\house_big_02_f.p3d",
        "a3\structures_f_exp\civilian\house_big_03\house_big_03_f.p3d",
        "a3\structures_f_exp\civilian\house_big_04\house_big_04_f.p3d",
        "a3\structures_f_exp\civilian\house_big_05\house_big_05_f.p3d",
        "a3\structures_f_exp\civilian\house_small_01\house_small_01_f.p3d",
        "a3\structures_f_exp\civilian\house_small_02\house_small_02_f.p3d",
        "a3\structures_f_exp\civilian\house_small_03\house_small_03_f.p3d",
        "a3\structures_f_exp\civilian\house_small_04\house_small_04_f.p3d",
        "a3\structures_f_exp\civilian\house_small_05\house_small_05_f.p3d",
        "a3\structures_f_exp\civilian\house_small_06\house_small_06_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_02_f.p3d",
        "a3\structures_f_exp\commercial\shop_city_01\shop_city_01_f.p3d",
        "a3\structures_f_exp\commercial\shop_city_03\shop_city_03_f.p3d",
        "a3\structures_f_exp\commercial\shop_city_04\shop_city_04_f.p3d",
        "a3\structures_f_exp\commercial\shop_city_05\shop_city_05_f.p3d",
        "a3\structures_f_exp\commercial\shop_city_06\shop_city_06_f.p3d",
        "a3\structures_f_exp\commercial\shop_city_07\shop_city_07_f.p3d",
        "a3\structures_f_exp\commercial\shop_town_01\shop_town_01_f.p3d",
        "a3\structures_f_exp\commercial\shop_town_02\shop_town_02_f.p3d",
        "a3\structures_f_exp\commercial\shop_town_03\shop_town_03_f.p3d",
        "a3\structures_f_exp\commercial\shop_town_04\shop_town_04_f.p3d",
        "a3\structures_f_exp\commercial\shop_town_05\shop_town_05_f.p3d",
        "ca\buildings2\a_generalstore_01\a_generalstore_01.p3d",
        "ca\buildings2\a_generalstore_01\a_generalstore_01_ruins.p3d",
        "ca\buildings2\a_generalstore_01\a_generalstore_01a.p3d",
        "ca\buildings2\barn_metal\barn_metal.p3d",
        "ca\buildings2\ind_cementworks\ind_pec\ind_pec_03a.p3d",
        "ca\buildings2\ind_cementworks\ind_vysypka\ind_vysypka.p3d",
        "ca\buildings2\ind_garage01\ind_garage01.p3d",
        "ca\buildings2\ind_garage01\ind_garage01_ruins.p3d",
        "ca\buildings2\ind_shed_01\ind_shed_01_end.p3d",
        "ca\buildings2\ind_shed_01\ind_shed_01_main.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_01.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_02.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_03.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_04.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_l.p3d",
        "ca\buildings2\shed_small\shed_w03_ruins.p3d",
        "ca\buildings\bouda3.p3d",
        "ca\buildings\budova2.p3d",
        "ca\buildings\dum01.p3d",
        "ca\buildings\dum_istan3_hromada2.p3d",
        "ca\buildings\dum_zboreny.p3d",
        "ca\buildings\dum_zboreny_total.p3d",
        "ca\buildings\garaz_mala.p3d",
        "ca\buildings\hospital.p3d",
        "ca\buildings\hut06.p3d",
        "ca\buildings\hut_old02.p3d",
        "ca\buildings\komin.p3d",
        "ca\buildings\kostel_trosky.p3d",
        "ca\buildings\ruins\dum_istan3_hromada2_ruins.p3d",
        "ca\buildings\ruins\dum_olez_istan2_maly2_ruins.p3d",
        "ca\buildings\ruins\dum_olez_istan2_maly_ruins.p3d",
        "ca\buildings\zalchata.p3d",
        "ca\structures\house\a_fuelstation\a_fuelstation_build.p3d",
        "ca\structures\house\a_hospital\a_hospital.p3d",
        "ca\structures\house\a_hospital\a_hospital_dam.p3d",
        "ca\structures\house\a_office01\a_office01.p3d",
        "ca\structures\house\a_office01\a_office01_ruins.p3d",
        "ca\structures\house\a_office02\a_office02.p3d",
        "ca\structures\house\a_office02\a_office02_dam.p3d",
        "ca\structures\house\a_office02\a_office02_ruins.p3d",
        "ca\structures\house\a_stationhouse\a_stationhouse.p3d",
        "ca\structures\house\a_stationhouse\a_stationhouse_ruins.p3d",
        "ca\structures\house\housebt\houseb_tenement_ruins.p3d",
        "ca\structures\ind\ind_stack_big.p3d",
        "ca\structures\ind_quarry\ind_quarry.p3d",
        "ca\structures\shed_ind\shed_ind02.p3d",
        "ca\structures_e\housea\a_minaret_porto\a_minaret_porto_ep1.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_addon_ep1.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_hq_ep1.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_minaret_1_ep1.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_minaret_2_ep1.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_wall_corner_ep1.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_wall_ep1.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_wall_gate_ep1.p3d",
        "ca\structures_e\housec\house_c_10_ep1.p3d",
        "ca\structures_e\housec\house_c_11_ep1.p3d",
        "ca\structures_e\housec\house_c_12_ep1.p3d",
        "ca\structures_e\housec\house_c_1_ep1.p3d",
        "ca\structures_e\housec\house_c_1_v2_ep1.p3d",
        "ca\structures_e\housec\house_c_2_ep1.p3d",
        "ca\structures_e\housec\house_c_3_ep1.p3d",
        "ca\structures_e\housec\house_c_4_ep1.p3d",
        "ca\structures_e\housec\house_c_5_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v1_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v2_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v3_ep1.p3d",
        "ca\structures_e\housec\house_c_9_ep1.p3d",
        "fallujah_hou\dum_istan2.p3d",
        "fallujah_hou\dum_istan2_01.p3d",
        "fallujah_hou\dum_istan2_02.p3d",
        "fallujah_hou\dum_istan2_03.p3d",
        "fallujah_hou\dum_istan2_03a.p3d",
        "fallujah_hou\dum_istan2_04a.p3d",
        "fallujah_hou\dum_istan3.p3d",
        "fallujah_hou\dum_istan4.p3d",
        "fallujah_hou\dum_istan4_big.p3d",
        "fallujah_hou\dum_istan4_big_inverse.p3d",
        "fallujah_hou\dum_istan4_detaily1.p3d",
        "fallujah_hou\dum_istan4_inverse.p3d",
        "fallujah_hou\misc\stanek_2b.p3d",
        "fallujah_hou\misc\stanek_4c.p3d"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "a3\structures_f_exp\civilian\house_big_03\house_big_03_f.p3d",
        "ca\buildings\hospital.p3d",
        "ca\structures\house\a_hospital\a_hospital.p3d",
        "ca\structures\house\a_office01\a_office01.p3d",
        "ca\structures\house\a_stationhouse\a_stationhouse.p3d",
        "ca\structures_e\housec\house_c_4_ep1.p3d"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "a3\structures_f\households\house_big01\i_house_big_01_v1_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garageoffice_01_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garagerow_01_large_f.p3d",
        "a3\structures_f_exp\civilian\house_big_01\house_big_01_f.p3d",
        "a3\structures_f_exp\civilian\house_big_02\house_big_02_f.p3d",
        "a3\structures_f_exp\civilian\house_big_03\house_big_03_f.p3d",
        "a3\structures_f_exp\civilian\house_big_04\house_big_04_f.p3d",
        "a3\structures_f_exp\civilian\house_big_05\house_big_05_f.p3d",
        "a3\structures_f_exp\civilian\house_small_01\house_small_01_f.p3d",
        "a3\structures_f_exp\civilian\house_small_02\house_small_02_f.p3d",
        "a3\structures_f_exp\civilian\house_small_03\house_small_03_f.p3d",
        "a3\structures_f_exp\civilian\house_small_04\house_small_04_f.p3d",
        "a3\structures_f_exp\civilian\house_small_05\house_small_05_f.p3d",
        "a3\structures_f_exp\civilian\house_small_06\house_small_06_f.p3d",
        "a3\structures_f_exp\commercial\shop_city_01\shop_city_01_f.p3d",
        "a3\structures_f_exp\commercial\shop_city_03\shop_city_03_f.p3d",
        "a3\structures_f_exp\commercial\shop_city_04\shop_city_04_f.p3d",
        "a3\structures_f_exp\commercial\shop_city_06\shop_city_06_f.p3d",
        "a3\structures_f_exp\commercial\shop_city_07\shop_city_07_f.p3d",
        "a3\structures_f_exp\commercial\shop_town_01\shop_town_01_f.p3d",
        "a3\structures_f_exp\commercial\shop_town_03\shop_town_03_f.p3d",
        "a3\structures_f_exp\commercial\shop_town_04\shop_town_04_f.p3d",
        "ca\buildings2\a_generalstore_01\a_generalstore_01.p3d",
        "ca\buildings2\a_generalstore_01\a_generalstore_01a.p3d",
        "ca\buildings2\barn_metal\barn_metal.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_01.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_l.p3d",
        "ca\buildings\dum_istan3_hromada2.p3d",
        "ca\structures\house\a_fuelstation\a_fuelstation_build.p3d",
        "ca\structures\house\a_hospital\a_hospital.p3d",
        "ca\structures\house\a_office01\a_office01.p3d",
        "ca\structures\house\a_stationhouse\a_stationhouse.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_addon_ep1.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_hq_ep1.p3d",
        "ca\structures_e\housea\a_mosque_big\a_mosque_big_minaret_2_ep1.p3d",
        "ca\structures_e\housec\house_c_10_ep1.p3d",
        "ca\structures_e\housec\house_c_11_ep1.p3d",
        "ca\structures_e\housec\house_c_12_ep1.p3d",
        "ca\structures_e\housec\house_c_1_ep1.p3d",
        "ca\structures_e\housec\house_c_1_v2_ep1.p3d",
        "ca\structures_e\housec\house_c_2_ep1.p3d",
        "ca\structures_e\housec\house_c_3_ep1.p3d",
        "ca\structures_e\housec\house_c_4_ep1.p3d",
        "ca\structures_e\housec\house_c_5_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v1_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v2_ep1.p3d",
        "ca\structures_e\housec\house_c_5_v3_ep1.p3d",
        "ca\structures_e\housec\house_c_9_ep1.p3d",
        "fallujah_hou\dum_istan2.p3d",
        "fallujah_hou\dum_istan2_01.p3d",
        "fallujah_hou\dum_istan2_02.p3d",
        "fallujah_hou\dum_istan2_03.p3d",
        "fallujah_hou\dum_istan2_03a.p3d",
        "fallujah_hou\dum_istan2_04a.p3d",
        "fallujah_hou\dum_istan3.p3d",
        "fallujah_hou\dum_istan4.p3d",
        "fallujah_hou\dum_istan4_big.p3d",
        "fallujah_hou\dum_istan4_big_inverse.p3d",
        "fallujah_hou\dum_istan4_detaily1.p3d",
        "fallujah_hou\dum_istan4_inverse.p3d",
        "fallujah_hou\misc\stanek_2b.p3d",
        "fallujah_hou\misc\stanek_4c.p3d"
    ];

    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
        "ca\buildings2\misc_powerstation\misc_powerstation.p3d",
        "ca\buildings\trafostanica_mala.p3d",
        "ca\buildings\trafostanica_velka.p3d"
    ];

    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
        "ca\buildings\vysilac_fm.p3d",
        "ca\misc3\wf\wf_anti_radar_west.p3d",
        "ca\misc3\wf\wf_artilery_radar_west.p3d",
        "ca\structures\a_tvtower\a_tvtower_base.p3d",
        "ca\structures\a_tvtower\a_tvtower_mid.p3d",
        "ca\structures\a_tvtower\a_tvtower_top.p3d"
    ];

    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        "ca\buildings2\a_crane_02\a_crane_02a.p3d",
        "ca\buildings2\a_crane_02\a_crane_02b.p3d"
    ];

    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        "ca\buildings2\ind_cementworks\ind_expedice\ind_expedice_3.p3d",
        "ca\buildings2\ind_tank\ind_tankbig.p3d",
        "ca\structures\house\a_fuelstation\a_fuelstation_build.p3d",
        "ca\structures\house\a_fuelstation\a_fuelstation_feed.p3d",
        "ca\structures\house\a_fuelstation\a_fuelstation_shed.p3d",
        "fallujah_hou\watertower1.p3d"
    ];

    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
        "a3\structures_f_exp\industrial\dieselpowerplant_01\dpp_01_mainfactory_f.p3d",
        "a3\structures_f_exp\industrial\dieselpowerplant_01\dpp_01_smallfactory_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_boilerbuilding_f.p3d",
        "ca\buildings2\ind_cementworks\ind_malykomin\ind_malykomin.p3d",
        "ca\buildings2\ind_cementworks\ind_pec\ind_pec_03.p3d",
        "ca\buildings2\ind_cementworks\ind_silovelke\ind_silovelke_01.p3d",
        "ca\buildings\misc\leseni2x.p3d",
        "ca\structures\ind_sawmill\ind_sawmill.p3d",
        "ca\structures\ind_sawmill\ind_sawmillpen.p3d"
    ];

};
