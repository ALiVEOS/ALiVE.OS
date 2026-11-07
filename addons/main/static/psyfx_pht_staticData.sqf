// ALiVE 3 index v3.1, made 2026-11-07 by the ALiVE web indexer, building positions measured
private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: psyfx_pht (ALiVE 3 index v3.1, 2026-11-07)"] call ALiVE_fnc_dump;

ALiVE_indexVersion = ["3.1", "2026-11-07", "web", true];

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

ALiVE_mapCompositionType = "Jungle";
[ALIVE_mapBounds, worldName, 15360] call ALIVE_fnc_hashSet;

 if (tolower(_worldName) == "psyfx_pht") then {
    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "a3\structures_f\ind\factory\factory_main_ruins_f.p3d",
        "csj_seaobj\csj_stall01.p3d",
        "csj_seaobj\csj_stall02.p3d",
        "csj_seaobj\csj_stall05.p3d",
        "raz_nam_obj\clutter\ricegrass.p3d",
        "raz_nam_obj\m\bridge\lbridge2.p3d",
        "raz_nam_obj\m\pier\pier1_clutter.p3d",
        "raz_nam_obj\m\pier\pier1_tyres.p3d",
        "raz_nam_obj\m\pier\pier3_clutter.p3d",
        "raz_nam_obj\m\timbers\timbers.p3d",
        "uns_village\bridge\uns_villbridge2.p3d",
        "uns_village\bridge\uns_villbridge3.p3d",
        "wx_objects\wx_baileybridge_01.p3d",
        "wx_objects\wx_baileybridge_02.p3d",
        "wx_objects\wx_baileybridge_03.p3d"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "a3\structures_f\ind\airport\airport_tower_f.p3d",
        "a3\structures_f\mil\barracks\i_barracks_v2_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_01_controltower_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_02_controltower_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_02_terminal_f.p3d",
        "a3\structures_f_exp\military\barracks_01\barracks_01_camo_f.p3d",
        "a3\structures_f_exp\military\barracks_01\barracks_01_grey_f.p3d",
        "raz_nam_obj\m\tent\tent_east_o.p3d",
        "raz_nam_obj\m\wood_tower\vil_tower.p3d",
        "uc\buildings\hangar_2.p3d",
        "uc\misc3\wf\wf_field_hospital_east.p3d",
        "uc\structures_e\housea\a_office01\a_office01_ep1.p3d",
        "uc\structures_e\mil\mil_barracks_i_ep1.p3d",
        "uns_buildings\west_buildings\mortarpit_sb.p3d",
        "uns_buildings\west_buildings\sb_bunker_main.p3d",
        "uns_buildings\west_buildings\sb_bunker_main02.p3d",
        "uns_buildings\west_buildings\sb_bunker_small.p3d",
        "uns_buildings\west_buildings\scntr_open.p3d",
        "uns_buildings\west_buildings\t_2_fop2.p3d",
        "uns_buildings\west_buildings\tower_1.p3d",
        "uns_buildings\west_buildings\uns_army_med.p3d",
        "uns_buildings\west_buildings\uns_armyhut2.p3d",
        "uns_buildings\west_buildings\uns_armyhut3.p3d",
        "uns_buildings\west_buildings\uns_bunker_troop.p3d",
        "uns_buildings\west_buildings\uns_bunker_troop2.p3d",
        "uns_buildings\west_buildings\uns_bunker_troop3.p3d",
        "uns_buildings\west_buildings\uns_guardhouse.p3d",
        "uns_buildings\west_buildings\uns_hanger1.p3d",
        "uns_buildings\west_buildings\uns_hootch.p3d",
        "uns_buildings\west_buildings\uns_hootche.p3d",
        "uns_buildings\west_buildings\uns_hootche1.p3d",
        "uns_buildings\west_buildings\uns_motorpool1.p3d",
        "uns_buildings\west_buildings\uns_om.p3d",
        "uns_buildings\west_buildings\uns_showers.p3d",
        "uns_buildings\west_buildings\uns_weapon_pit.p3d",
        "uns_buildings\west_objects\csj_gunpit.p3d",
        "uns_buildings\west_objects\sb_revetment.p3d",
        "uns_buildings\west_objects\scntr.p3d",
        "uns_buildings\west_objects\t_sb_20_half.p3d",
        "uns_buildings\west_objects\t_sb_45_half.p3d",
        "uns_buildings\west_objects\t_sb_5_half.p3d",
        "uns_buildings\west_objects\t_sb_cnr_half.p3d",
        "uns_buildings\west_objects\t_sb_pit1.p3d",
        "uns_ksobjects\uns_tent3supply.p3d",
        "uns_ksobjects\uns_tentbarracks.p3d"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "a3\structures_f\mil\barracks\i_barracks_v2_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_02_terminal_f.p3d",
        "a3\structures_f_exp\military\barracks_01\barracks_01_camo_f.p3d",
        "a3\structures_f_exp\military\barracks_01\barracks_01_grey_f.p3d",
        "uns_buildings\west_buildings\uns_motorpool1.p3d",
        "uns_ksobjects\uns_tentbarracks.p3d"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "a3\structures_f\mil\barracks\i_barracks_v2_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_02_terminal_f.p3d",
        "a3\structures_f_exp\military\barracks_01\barracks_01_camo_f.p3d",
        "a3\structures_f_exp\military\barracks_01\barracks_01_grey_f.p3d",
        "raz_nam_obj\m\tent\tent_east_o.p3d",
        "uc\buildings\hangar_2.p3d",
        "uc\misc3\wf\wf_field_hospital_east.p3d",
        "uc\structures_e\housea\a_office01\a_office01_ep1.p3d",
        "uns_buildings\west_buildings\sb_bunker_main.p3d",
        "uns_buildings\west_buildings\sb_bunker_main02.p3d",
        "uns_buildings\west_buildings\uns_army_med.p3d",
        "uns_buildings\west_buildings\uns_hanger1.p3d",
        "uns_buildings\west_buildings\uns_hootche1.p3d",
        "uns_buildings\west_buildings\uns_motorpool1.p3d",
        "uns_buildings\west_objects\csj_gunpit.p3d",
        "uns_buildings\west_objects\sb_revetment.p3d",
        "uns_ksobjects\uns_tent3supply.p3d"
    ];

    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        "a3\structures_f\mil\barracks\i_barracks_v2_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_02_terminal_f.p3d",
        "a3\structures_f_exp\military\barracks_01\barracks_01_camo_f.p3d",
        "a3\structures_f_exp\military\barracks_01\barracks_01_grey_f.p3d",
        "raz_nam_obj\m\tent\tent_east_o.p3d",
        "uc\buildings\hangar_2.p3d",
        "uc\misc3\wf\wf_field_hospital_east.p3d",
        "uc\structures_e\housea\a_office01\a_office01_ep1.p3d",
        "uc\structures_e\mil\mil_barracks_i_ep1.p3d",
        "uns_buildings\west_buildings\sb_bunker_main.p3d",
        "uns_buildings\west_buildings\sb_bunker_main02.p3d",
        "uns_buildings\west_buildings\uns_army_med.p3d",
        "uns_buildings\west_buildings\uns_bunker_troop.p3d",
        "uns_buildings\west_buildings\uns_guardhouse.p3d",
        "uns_buildings\west_buildings\uns_hootche.p3d",
        "uns_buildings\west_buildings\uns_hootche1.p3d",
        "uns_buildings\west_buildings\uns_motorpool1.p3d",
        "uns_buildings\west_buildings\uns_om.p3d"
    ];

    ALIVE_militaryFieldworkBuildingTypes = ALIVE_militaryFieldworkBuildingTypes + [
        "raz_nam_obj\m\wood_tower\vil_tower.p3d",
        "uns_buildings\west_buildings\sb_bunker_main.p3d",
        "uns_buildings\west_buildings\sb_bunker_small.p3d",
        "uns_buildings\west_buildings\uns_bunker_troop.p3d",
        "uns_buildings\west_buildings\uns_bunker_troop2.p3d",
        "uns_buildings\west_buildings\uns_bunker_troop3.p3d",
        "uns_buildings\west_objects\t_sb_20_half.p3d",
        "uns_buildings\west_objects\t_sb_45_half.p3d"
    ];

    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
        "a3\structures_f_exp\infrastructure\airports\airport_01_hangar_f.p3d"
    ];

    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [
        "a3\structures_f_exp\infrastructure\airports\airport_01_hangar_f.p3d"
    ];

    ALiVE_HeliBuildingTypes = ALiVE_HeliBuildingTypes + [
        "uns_buildings\west_objects\uns_evac_pad.p3d",
        "uns_buildings\west_objects\uns_heli_pad.p3d"
    ];

    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
        "uns_buildings\west_objects\uns_evac_pad.p3d",
        "uns_buildings\west_objects\uns_heli_pad.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "a3\structures_f\civ\belltowers\belltower_02_v2_f.p3d",
        "a3\structures_f\civ\chapels\chapel_small_v2_f.p3d",
        "a3\structures_f\civ\chapels\chapel_v2_f.p3d",
        "a3\structures_f\civ\offices\offices_01_v1_f.p3d",
        "a3\structures_f\dominants\church\church_01_v1_f.p3d",
        "a3\structures_f\households\house_big01\d_house_big_01_v1_f.p3d",
        "a3\structures_f\households\house_big01\u_house_big_01_v1_f.p3d",
        "a3\structures_f\households\house_big02\d_house_big_02_v1_f.p3d",
        "a3\structures_f\households\house_big02\u_house_big_02_v1_f.p3d",
        "a3\structures_f\households\house_shop01\d_shop_01_v1_f.p3d",
        "a3\structures_f\households\house_shop01\i_shop_01_v1_f.p3d",
        "a3\structures_f\households\house_shop01\i_shop_01_v2_f.p3d",
        "a3\structures_f\households\house_shop01\i_shop_01_v3_f.p3d",
        "a3\structures_f\households\house_shop01\u_shop_01_v1_f.p3d",
        "a3\structures_f\households\house_shop02\d_shop_02_v1_f.p3d",
        "a3\structures_f\households\house_shop02\i_shop_02_v2_f.p3d",
        "a3\structures_f\households\house_shop02\i_shop_02_v3_f.p3d",
        "a3\structures_f\households\house_shop02\u_shop_02_v1_f.p3d",
        "a3\structures_f\households\house_small02\u_house_small_02_v1_f.p3d",
        "a3\structures_f\households\slum\slum_house01_f.p3d",
        "a3\structures_f\households\slum\slum_house02_f.p3d",
        "a3\structures_f\households\slum\slum_house03_f.p3d",
        "a3\structures_f\households\stone_big\d_stone_housebig_v1_f.p3d",
        "a3\structures_f\households\stone_big\i_stone_housebig_v1_f.p3d",
        "a3\structures_f\households\stone_big\i_stone_housebig_v2_f.p3d",
        "a3\structures_f\households\stone_big\i_stone_housebig_v3_f.p3d",
        "a3\structures_f\households\stone_shed\i_stone_shed_v1_f.p3d",
        "a3\structures_f\households\stone_shed\i_stone_shed_v2_f.p3d",
        "a3\structures_f\households\stone_small\d_stone_housesmall_v1_f.p3d",
        "a3\structures_f\households\stone_small\i_stone_housesmall_v1_f.p3d",
        "a3\structures_f_argo\civilian\house_small02\house_small_02_b_v1_ruins_f.p3d",
        "a3\structures_f_argo\civilian\stone_house_big_01\i_stone_house_big_01_b_clay_f.p3d",
        "a3\structures_f_argo\civilian\stone_shed_01\i_stone_shed_01_c_clay_f.p3d",
        "a3\structures_f_argo\civilian\stone_shed_01\i_stone_shed_01_c_raw_f.p3d",
        "a3\structures_f_argo\commercial\shop_02\i_shop_02_b_white_f.p3d",
        "a3\structures_f_argo\industrial\agriculture\barn_01_brown_f.p3d",
        "a3\structures_f_argo\industrial\agriculture\barn_01_grey_f.p3d",
        "a3\structures_f_argo\industrial\agriculture\barn_01_grey_ruins_f.p3d",
        "a3\structures_f_argo\industrial\agriculture\shed_08_grey_f.p3d",
        "a3\structures_f_exp\civilian\house_big_03\house_big_03_f.p3d",
        "a3\structures_f_exp\civilian\house_big_04\house_big_04_f.p3d",
        "a3\structures_f_exp\civilian\house_big_05\house_big_05_f.p3d",
        "a3\structures_f_exp\civilian\house_native_01\house_native_01_f.p3d",
        "a3\structures_f_exp\civilian\house_native_01\house_native_01_ruins_f.p3d",
        "a3\structures_f_exp\civilian\house_native_02\house_native_02_f.p3d",
        "a3\structures_f_exp\civilian\house_native_02\house_native_02_ruins_f.p3d",
        "a3\structures_f_exp\civilian\house_small_02\house_small_02_ruins_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_02_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_05_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_07_f.p3d",
        "a3\structures_f_exp\civilian\slum_01\slum_01_f.p3d",
        "a3\structures_f_exp\civilian\slum_02\slum_02_f.p3d",
        "a3\structures_f_exp\civilian\slum_03\slum_03_f.p3d",
        "a3\structures_f_exp\civilian\slum_04\slum_04_f.p3d",
        "a3\structures_f_exp\civilian\slum_05\slum_05_f.p3d",
        "a3\structures_f_exp\commercial\addons\addon_04_f.p3d",
        "a3\structures_f_exp\commercial\addons\addon_04_ruins_f.p3d",
        "a3\structures_f_exp\commercial\shop_city_02\shop_city_02_f.p3d",
        "a3\structures_f_exp\commercial\shop_city_03\shop_city_03_f.p3d",
        "a3\structures_f_exp\commercial\shop_city_04\shop_city_04_f.p3d",
        "a3\structures_f_exp\commercial\shop_city_06\shop_city_06_f.p3d",
        "a3\structures_f_exp\commercial\shop_city_07\shop_city_07_f.p3d",
        "a3\structures_f_exp\commercial\shop_town_01\shop_town_01_f.p3d",
        "a3\structures_f_exp\commercial\shop_town_01\shop_town_01_ruins_f.p3d",
        "a3\structures_f_exp\commercial\shop_town_02\shop_town_02_f.p3d",
        "a3\structures_f_exp\commercial\shop_town_02\shop_town_02_ruins_f.p3d",
        "a3\structures_f_exp\commercial\shop_town_03\shop_town_03_f.p3d",
        "a3\structures_f_exp\commercial\shop_town_03\shop_town_03_ruins_f.p3d",
        "a3\structures_f_exp\commercial\shop_town_04\shop_town_04_f.p3d",
        "a3\structures_f_exp\cultural\church_01\church_01_f.p3d",
        "a3\structures_f_exp\cultural\church_03\church_03_f.p3d",
        "a3\structures_f_exp\cultural\temple_native_01\temple_native_01_f.p3d",
        "a3\structures_f_exp\cultural\temple_native_01\temple_native_01_ruins_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_warehouse_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shed_f.p3d",
        "indo_building\indo_hut_1.p3d",
        "indo_building\indo_hut_2.p3d",
        "raz_nam_obj\m\hut\raz_hut01.p3d",
        "raz_nam_obj\m\hut\raz_hut02.p3d",
        "raz_nam_obj\m\hut\raz_hut03.p3d",
        "raz_nam_obj\m\hut\raz_hut04.p3d",
        "raz_nam_obj\m\hut\raz_hut05.p3d",
        "raz_nam_obj\m\hut\raz_hut06.p3d",
        "raz_nam_obj\m\hut\raz_hut07.p3d",
        "raz_nam_obj\m\hut\raz_hut08.p3d",
        "uc\buildings\hangar_2.p3d",
        "uc\structures_e\housea\a_office01\a_office01_ep1.p3d",
        "uc\structures_e\misc\misc_market\kiosk_ep1.p3d",
        "uc\structures_e\misc\misc_market\market_stalls_01_ep1.p3d",
        "uns_buildings\civilian_buildings\csj_bar.p3d",
        "uns_buildings\civilian_buildings\uns_shopold_01.p3d",
        "uns_buildings\civilian_buildings\uns_shopold_02.p3d",
        "uns_buildings\civilian_buildings\uns_shopold_03.p3d",
        "uns_buildings\civilian_buildings\uns_shopold_04.p3d",
        "uns_buildings\civilian_buildings\uns_shopold_05.p3d",
        "uns_buildings\civilian_buildings\uns_shopold_06.p3d",
        "uns_buildings\civilian_buildings\uns_shopold_07.p3d",
        "uns_ksobjects\uns_burnedhut1.p3d",
        "uns_ksobjects\uns_burnedhut3.p3d",
        "uns_ksobjects\uns_burnedhut4.p3d",
        "uns_ksobjects\uns_burnedhut5.p3d"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "a3\structures_f\civ\offices\offices_01_v1_f.p3d",
        "a3\structures_f_exp\civilian\house_big_03\house_big_03_f.p3d",
        "uc\structures_e\housea\a_office01\a_office01_ep1.p3d"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "a3\structures_f\civ\chapels\chapel_v2_f.p3d",
        "a3\structures_f\civ\offices\offices_01_v1_f.p3d",
        "a3\structures_f\dominants\church\church_01_v1_f.p3d",
        "a3\structures_f\households\house_big01\u_house_big_01_v1_f.p3d",
        "a3\structures_f\households\house_big02\d_house_big_02_v1_f.p3d",
        "a3\structures_f\households\house_big02\u_house_big_02_v1_f.p3d",
        "a3\structures_f\households\house_shop01\d_shop_01_v1_f.p3d",
        "a3\structures_f\households\house_shop01\i_shop_01_v1_f.p3d",
        "a3\structures_f\households\house_shop01\i_shop_01_v2_f.p3d",
        "a3\structures_f\households\house_shop01\i_shop_01_v3_f.p3d",
        "a3\structures_f\households\house_shop01\u_shop_01_v1_f.p3d",
        "a3\structures_f\households\house_shop02\i_shop_02_v2_f.p3d",
        "a3\structures_f\households\house_shop02\i_shop_02_v3_f.p3d",
        "a3\structures_f\households\house_shop02\u_shop_02_v1_f.p3d",
        "a3\structures_f\households\house_small02\u_house_small_02_v1_f.p3d",
        "a3\structures_f\households\slum\slum_house01_f.p3d",
        "a3\structures_f\households\slum\slum_house02_f.p3d",
        "a3\structures_f\households\slum\slum_house03_f.p3d",
        "a3\structures_f\households\stone_big\i_stone_housebig_v1_f.p3d",
        "a3\structures_f\households\stone_big\i_stone_housebig_v2_f.p3d",
        "a3\structures_f\households\stone_big\i_stone_housebig_v3_f.p3d",
        "a3\structures_f\households\stone_shed\i_stone_shed_v1_f.p3d",
        "a3\structures_f\households\stone_shed\i_stone_shed_v2_f.p3d",
        "a3\structures_f\households\stone_small\i_stone_housesmall_v1_f.p3d",
        "a3\structures_f_argo\civilian\stone_house_big_01\i_stone_house_big_01_b_clay_f.p3d",
        "a3\structures_f_argo\civilian\stone_shed_01\i_stone_shed_01_c_clay_f.p3d",
        "a3\structures_f_argo\civilian\stone_shed_01\i_stone_shed_01_c_raw_f.p3d",
        "a3\structures_f_argo\commercial\shop_02\i_shop_02_b_white_f.p3d",
        "a3\structures_f_argo\industrial\agriculture\barn_01_brown_f.p3d",
        "a3\structures_f_argo\industrial\agriculture\barn_01_grey_f.p3d",
        "a3\structures_f_exp\civilian\house_big_03\house_big_03_f.p3d",
        "a3\structures_f_exp\civilian\house_big_04\house_big_04_f.p3d",
        "a3\structures_f_exp\civilian\house_big_05\house_big_05_f.p3d",
        "a3\structures_f_exp\civilian\house_native_01\house_native_01_f.p3d",
        "a3\structures_f_exp\civilian\house_native_02\house_native_02_f.p3d",
        "a3\structures_f_exp\civilian\slum_01\slum_01_f.p3d",
        "a3\structures_f_exp\civilian\slum_02\slum_02_f.p3d",
        "a3\structures_f_exp\civilian\slum_03\slum_03_f.p3d",
        "a3\structures_f_exp\civilian\slum_05\slum_05_f.p3d",
        "a3\structures_f_exp\commercial\addons\addon_04_f.p3d",
        "a3\structures_f_exp\commercial\shop_city_03\shop_city_03_f.p3d",
        "a3\structures_f_exp\commercial\shop_city_04\shop_city_04_f.p3d",
        "a3\structures_f_exp\commercial\shop_city_06\shop_city_06_f.p3d",
        "a3\structures_f_exp\commercial\shop_city_07\shop_city_07_f.p3d",
        "a3\structures_f_exp\commercial\shop_town_01\shop_town_01_f.p3d",
        "a3\structures_f_exp\commercial\shop_town_03\shop_town_03_f.p3d",
        "a3\structures_f_exp\commercial\shop_town_04\shop_town_04_f.p3d",
        "a3\structures_f_exp\cultural\church_01\church_01_f.p3d",
        "a3\structures_f_exp\cultural\church_03\church_03_f.p3d",
        "a3\structures_f_exp\cultural\temple_native_01\temple_native_01_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shed_f.p3d",
        "indo_building\indo_hut_1.p3d",
        "indo_building\indo_hut_2.p3d",
        "raz_nam_obj\m\hut\raz_hut01.p3d",
        "raz_nam_obj\m\hut\raz_hut02.p3d",
        "raz_nam_obj\m\hut\raz_hut03.p3d",
        "raz_nam_obj\m\hut\raz_hut04.p3d",
        "raz_nam_obj\m\hut\raz_hut05.p3d",
        "raz_nam_obj\m\hut\raz_hut06.p3d",
        "raz_nam_obj\m\hut\raz_hut07.p3d",
        "raz_nam_obj\m\hut\raz_hut08.p3d",
        "uc\buildings\hangar_2.p3d",
        "uc\structures_e\housea\a_office01\a_office01_ep1.p3d",
        "uc\structures_e\misc\misc_market\kiosk_ep1.p3d",
        "uns_buildings\civilian_buildings\csj_bar.p3d",
        "uns_buildings\civilian_buildings\uns_shopold_01.p3d",
        "uns_buildings\civilian_buildings\uns_shopold_02.p3d",
        "uns_buildings\civilian_buildings\uns_shopold_03.p3d",
        "uns_buildings\civilian_buildings\uns_shopold_04.p3d",
        "uns_buildings\civilian_buildings\uns_shopold_05.p3d",
        "uns_buildings\civilian_buildings\uns_shopold_07.p3d",
        "uns_ksobjects\uns_burnedhut1.p3d",
        "uns_ksobjects\uns_burnedhut3.p3d",
        "uns_ksobjects\uns_burnedhut4.p3d",
        "uns_ksobjects\uns_burnedhut5.p3d"
    ];

    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
        "a3\structures_f\ind\solarpowerplant\spp_transformer_f.p3d"
    ];

    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
        "a3\structures_f\ind\transmitter_tower\ttowersmall_2_f.p3d",
        "uc\buildings\vysilac_fm.p3d"
    ];

    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        "a3\structures_f\dominants\lighthouse\lighthouse_f.p3d",
        "a3\structures_f\naval\piers\pier_f.p3d",
        "a3\structures_f_exp\industrial\port\containerline_02_f.p3d",
        "a3\structures_f_exp\industrial\port\containerline_03_f.p3d",
        "raz_nam_obj\m\pier\pier2.p3d"
    ];

    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
        "a3\structures_f\ind\dieselpowerplant\dp_mainfactory_f.p3d",
        "a3\structures_f\ind\factory\factory_main_f.p3d",
        "uc\buildings\hangar_2.p3d"
    ];

};
