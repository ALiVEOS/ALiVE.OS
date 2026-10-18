// ALiVE 3 index v3.1, made 2026-10-18 by the ALiVE web indexer, building positions measured
private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: islapera (ALiVE 3 index v3.1, 2026-10-18)"] call ALiVE_fnc_dump;

ALiVE_indexVersion = ["3.1", "2026-10-18", "web", true];

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

ALiVE_mapCompositionType = "Pacific";

 if (tolower(_worldName) == "islapera") then {
    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "a3\props_f_enoch\military\decontamination\layflathose_01_curvelong_f.p3d",
        "a3\props_f_enoch\military\decontamination\layflathose_01_straightlong_f.p3d",
        "a3\props_f_enoch\military\decontamination\pressurehose_01_sbend_f.p3d",
        "a3\props_f_enoch\military\decontamination\pressurehose_01_step_f.p3d",
        "a3\props_f_enoch\military\decontamination\tarp_01_large_green_f.p3d",
        "a3\props_f_orange\humanitarian\camps\airconditioner_01_f.p3d",
        "a3\props_f_orange\humanitarian\camps\emergencyblanket_02_stack_f.p3d",
        "a3\structures_f_argo\walls\city\wallcity_01_4m_plain_dmg_blue_f.p3d",
        "a3\structures_f_enoch\furniture\school_equipment\school_cage.p3d",
        "go_structures_ip\misc\go_ropebridge\go_ropebridge.p3d"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "a3\structures_f\mil\barracks\i_barracks_v1_f.p3d",
        "a3\structures_f\mil\barracks\i_barracks_v2_f.p3d",
        "a3\structures_f\mil\bunker\bunker_f.p3d",
        "a3\structures_f\mil\offices\miloffices_v1_f.p3d",
        "a3\structures_f\mil\radar\radar_f.p3d",
        "a3\structures_f\mil\radar\radar_small_f.p3d",
        "a3\structures_f\research\dome_small_f.p3d",
        "a3\structures_f\research\research_house_v1_f.p3d",
        "a3\structures_f\research\research_hq_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_04_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garageoffice_01_f.p3d",
        "a3\structures_f_enoch\industrial\sawmills\sawmill_01_illuminati_tower_f.p3d",
        "a3\structures_f_enoch\military\airfield\servicehangar_01_l_f.p3d",
        "a3\structures_f_enoch\military\airfield\servicehangar_01_r_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_03_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_06_f.p3d",
        "a3\structures_f_enoch\military\barracks\guardhouse_03_f.p3d",
        "a3\structures_f_enoch\military\radar\mobileradar_01_radar_f.p3d",
        "a3\structures_f_enoch\military\radar\radar_01_hq_f.p3d",
        "a3\structures_f_exp\industrial\port\guardhouse_01_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shed_unfinished_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_01_controltower_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_01_terminal_f.p3d",
        "a3\structures_f_exp\military\fortifications\bagbunker_01_large_green_f.p3d",
        "ca\buildings\army_hut3_long_int.p3d",
        "cup\terrains\cup_terrains_buildings\bunker\bunker_garage.p3d"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "a3\structures_f\mil\barracks\i_barracks_v1_f.p3d",
        "a3\structures_f\mil\barracks\i_barracks_v2_f.p3d",
        "a3\structures_f\mil\offices\miloffices_v1_f.p3d",
        "a3\structures_f\research\dome_small_f.p3d",
        "a3\structures_f\research\research_hq_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_04_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garageoffice_01_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_06_f.p3d",
        "a3\structures_f_enoch\military\radar\radar_01_hq_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_01_terminal_f.p3d"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "a3\structures_f\mil\barracks\i_barracks_v1_f.p3d",
        "a3\structures_f\mil\barracks\i_barracks_v2_f.p3d",
        "a3\structures_f\mil\offices\miloffices_v1_f.p3d",
        "a3\structures_f\research\dome_small_f.p3d",
        "a3\structures_f\research\research_hq_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_04_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garageoffice_01_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_06_f.p3d",
        "a3\structures_f_enoch\military\radar\radar_01_hq_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shed_unfinished_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_01_terminal_f.p3d"
    ];

    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        "a3\structures_f\mil\barracks\i_barracks_v1_f.p3d",
        "a3\structures_f\mil\barracks\i_barracks_v2_f.p3d",
        "a3\structures_f\mil\offices\miloffices_v1_f.p3d",
        "a3\structures_f\research\dome_small_f.p3d",
        "a3\structures_f\research\research_hq_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_06_f.p3d",
        "a3\structures_f_enoch\military\radar\radar_01_hq_f.p3d"
    ];

    ALIVE_militaryFieldworkBuildingTypes = ALIVE_militaryFieldworkBuildingTypes + [
        "a3\structures_f_exp\military\fortifications\bagbunker_01_large_green_f.p3d",
        "cup\terrains\cup_terrains_buildings\bunker\bunker_garage.p3d"
    ];

    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
        "a3\structures_f_enoch\military\airfield\servicehangar_01_l_f.p3d",
        "a3\structures_f_enoch\military\airfield\servicehangar_01_r_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_01_hangar_f.p3d"
    ];

    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [
        "a3\structures_f_enoch\military\airfield\servicehangar_01_l_f.p3d",
        "a3\structures_f_enoch\military\airfield\servicehangar_01_r_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_01_hangar_f.p3d"
    ];

    ALiVE_HeliBuildingTypes = ALiVE_HeliBuildingTypes + [
        "a3\structures_f\mil\helipads\helipadsquare_f.p3d"
    ];

    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
        "a3\structures_f\mil\helipads\helipadsquare_f.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "a3\props_f_enoch\civilian\forest\deerstand_01_f.p3d",
        "a3\props_f_enoch\civilian\forest\deerstand_02_f.p3d",
        "a3\props_f_enoch\civilian\forest\feedshack_01_f.p3d",
        "a3\structures_f\civ\chapels\chapel_small_v2_f.p3d",
        "a3\structures_f\civ\chapels\chapel_v2_f.p3d",
        "a3\structures_f\civ\offices\offices_01_v1_f.p3d",
        "a3\structures_f\dominants\hospital\hospital_main_f.p3d",
        "a3\structures_f\dominants\hospital\hospital_side1_f.p3d",
        "a3\structures_f\dominants\hospital\hospital_side2_f.p3d",
        "a3\structures_f\households\addons\i_garage_v2_f.p3d",
        "a3\structures_f\households\house_big01\d_house_big_01_v1_f.p3d",
        "a3\structures_f\households\house_big02\d_house_big_02_v1_f.p3d",
        "a3\structures_f\households\house_big02\i_house_big_02_v2_f.p3d",
        "a3\structures_f\households\house_shop01\d_shop_01_v1_f.p3d",
        "a3\structures_f\households\house_shop01\i_shop_01_v2_f.p3d",
        "a3\structures_f\households\house_shop01\i_shop_01_v3_dam_f.p3d",
        "a3\structures_f\households\house_shop01\u_shop_01_v1_dam_f.p3d",
        "a3\structures_f\households\house_shop01\u_shop_01_v1_f.p3d",
        "a3\structures_f\households\house_shop02\i_shop_02_v1_f.p3d",
        "a3\structures_f\households\house_shop02\i_shop_02_v2_f.p3d",
        "a3\structures_f\households\house_shop02\i_shop_02_v3_f.p3d",
        "a3\structures_f\households\house_shop02\u_shop_02_v1_dam_f.p3d",
        "a3\structures_f\households\house_shop02\u_shop_02_v1_f.p3d",
        "a3\structures_f\households\house_small01\i_house_small_01_v1_f.p3d",
        "a3\structures_f\households\house_small01\i_house_small_01_v2_f.p3d",
        "a3\structures_f\households\house_small01\i_house_small_01_v3_f.p3d",
        "a3\structures_f\households\house_small02\d_house_small_02_v1_f.p3d",
        "a3\structures_f\households\house_small02\i_house_small_02_v1_f.p3d",
        "a3\structures_f\households\house_small02\i_house_small_02_v2_f.p3d",
        "a3\structures_f\households\house_small02\i_house_small_02_v3_f.p3d",
        "a3\structures_f\households\house_small03\i_house_small_03_v1_f.p3d",
        "a3\structures_f\households\slum\slum_house01_f.p3d",
        "a3\structures_f\households\slum\slum_house02_f.p3d",
        "a3\structures_f\households\slum\slum_house03_f.p3d",
        "a3\structures_f\households\stone_big\d_stone_housebig_v1_f.p3d",
        "a3\structures_f\households\stone_big\i_stone_housebig_v1_f.p3d",
        "a3\structures_f\households\stone_big\i_stone_housebig_v2_f.p3d",
        "a3\structures_f\households\stone_big\i_stone_housebig_v3_f.p3d",
        "a3\structures_f\households\stone_shed\i_stone_shed_v1_f.p3d",
        "a3\structures_f\households\stone_shed\i_stone_shed_v2_f.p3d",
        "a3\structures_f\households\stone_shed\i_stone_shed_v3_f.p3d",
        "a3\structures_f\households\stone_small\d_stone_housesmall_v1_f.p3d",
        "a3\structures_f\households\stone_small\i_stone_housesmall_v2_f.p3d",
        "a3\structures_f\households\wip\unfinished_building_01_f.p3d",
        "a3\structures_f\ind\airport\airport_center_f.p3d",
        "a3\structures_f\ind\carservice\carservice_f.p3d",
        "a3\structures_f\ind\shed\i_shed_ind_f.p3d",
        "a3\structures_f\ind\shed\u_shed_ind_f.p3d",
        "a3\structures_f_argo\civilian\addons\i_addon_02_b_white_f.p3d",
        "a3\structures_f_argo\civilian\house_big01\i_house_big_01_b_blue_f.p3d",
        "a3\structures_f_argo\civilian\house_big01\i_house_big_01_b_brown_f.p3d",
        "a3\structures_f_argo\civilian\house_big01\i_house_big_01_b_pink_f.p3d",
        "a3\structures_f_argo\civilian\house_big01\i_house_big_01_b_white_f.p3d",
        "a3\structures_f_argo\civilian\house_big01\i_house_big_01_b_whiteblue_f.p3d",
        "a3\structures_f_argo\civilian\house_big01\i_house_big_01_b_yellow_f.p3d",
        "a3\structures_f_argo\civilian\house_big02\i_house_big_02_b_blue_f.p3d",
        "a3\structures_f_argo\civilian\house_big02\i_house_big_02_b_brown_f.p3d",
        "a3\structures_f_argo\civilian\house_big02\i_house_big_02_b_pink_f.p3d",
        "a3\structures_f_argo\civilian\house_big02\i_house_big_02_b_white_f.p3d",
        "a3\structures_f_argo\civilian\house_big02\i_house_big_02_b_whiteblue_f.p3d",
        "a3\structures_f_argo\civilian\house_big02\i_house_big_02_b_yellow_f.p3d",
        "a3\structures_f_argo\civilian\house_small01\i_house_small_01_b_blue_f.p3d",
        "a3\structures_f_argo\civilian\house_small01\i_house_small_01_b_brown_f.p3d",
        "a3\structures_f_argo\civilian\house_small01\i_house_small_01_b_pink_f.p3d",
        "a3\structures_f_argo\civilian\house_small01\i_house_small_01_b_white_f.p3d",
        "a3\structures_f_argo\civilian\house_small01\i_house_small_01_b_whiteblue_f.p3d",
        "a3\structures_f_argo\civilian\house_small01\i_house_small_01_b_yellow_f.p3d",
        "a3\structures_f_argo\civilian\house_small02\i_house_small_02_b_blue_f.p3d",
        "a3\structures_f_argo\civilian\house_small02\i_house_small_02_b_yellow_f.p3d",
        "a3\structures_f_argo\civilian\house_small02\i_house_small_02_c_blue_f.p3d",
        "a3\structures_f_argo\civilian\house_small02\i_house_small_02_c_whiteblue_f.p3d",
        "a3\structures_f_argo\civilian\house_small02\i_house_small_02_c_yellow_f.p3d",
        "a3\structures_f_argo\civilian\stone_house_big_01\i_stone_house_big_01_b_clay_f.p3d",
        "a3\structures_f_argo\civilian\stone_shed_01\i_stone_shed_01_c_white_f.p3d",
        "a3\structures_f_argo\commercial\shop_02\i_shop_02_b_blue_f.p3d",
        "a3\structures_f_argo\commercial\shop_02\i_shop_02_b_brown_f.p3d",
        "a3\structures_f_argo\commercial\shop_02\i_shop_02_b_pink_f.p3d",
        "a3\structures_f_argo\commercial\shop_02\i_shop_02_b_white_f.p3d",
        "a3\structures_f_argo\commercial\shop_02\i_shop_02_b_whiteblue_f.p3d",
        "a3\structures_f_argo\commercial\shop_02\i_shop_02_b_yellow_f.p3d",
        "a3\structures_f_argo\commercial\supermarket_01\supermarket_01_malden_f.p3d",
        "a3\structures_f_argo\cultural\church\church_01_v2_f.p3d",
        "a3\structures_f_argo\industrial\agriculture\barn_01_grey_f.p3d",
        "a3\structures_f_argo\industrial\agriculture\shed_08_grey_f.p3d",
        "a3\structures_f_enoch\civilian\camps\camp_house_01_brown_f.p3d",
        "a3\structures_f_enoch\civilian\camps\caravan_01_rust_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1b01_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w03_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w04_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w08_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w10_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w13_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2b02_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2b03_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2b04_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w05_f.p3d",
        "a3\structures_f_enoch\civilian\medical\healthcenter_01_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_09_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_12_f.p3d",
        "a3\structures_f_enoch\commercial\villagestore_01\villagestore_01_f.p3d",
        "a3\structures_f_enoch\cultural\church_04\church_04_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_03_large_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_03_small_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_04_f.p3d",
        "a3\structures_f_enoch\industrial\farms\greenhouse_01_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garageoffice_01_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garagerow_01_large_f.p3d",
        "a3\structures_f_enoch\industrial\houses\factory_02_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_01_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_02_grey_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_03_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_05_f.p3d",
        "a3\structures_f_enoch\industrial\mines\mine_01_warehouse_f.p3d",
        "a3\structures_f_enoch\industrial\sawmills\sawmill_01_f.p3d",
        "a3\structures_f_enoch\industrial\sheds\industrialshed_01_f.p3d",
        "a3\structures_f_exp\civilian\garages\garageshelter_01_f.p3d",
        "a3\structures_f_exp\civilian\house_big_01\house_big_01_f.p3d",
        "a3\structures_f_exp\civilian\house_big_02\house_big_02_f.p3d",
        "a3\structures_f_exp\civilian\house_big_03\house_big_03_f.p3d",
        "a3\structures_f_exp\civilian\house_big_04\house_big_04_f.p3d",
        "a3\structures_f_exp\civilian\house_big_05\house_big_05_f.p3d",
        "a3\structures_f_exp\civilian\house_native_01\house_native_01_f.p3d",
        "a3\structures_f_exp\civilian\house_native_02\house_native_02_f.p3d",
        "a3\structures_f_exp\civilian\house_small_01\house_small_01_f.p3d",
        "a3\structures_f_exp\civilian\house_small_02\house_small_02_f.p3d",
        "a3\structures_f_exp\civilian\house_small_03\house_small_03_f.p3d",
        "a3\structures_f_exp\civilian\house_small_04\house_small_04_f.p3d",
        "a3\structures_f_exp\civilian\house_small_05\house_small_05_f.p3d",
        "a3\structures_f_exp\civilian\house_small_06\house_small_06_f.p3d",
        "a3\structures_f_exp\civilian\school_01\school_01_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_01_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_02_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_03_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_05_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_07_f.p3d",
        "a3\structures_f_exp\civilian\slum_01\slum_01_f.p3d",
        "a3\structures_f_exp\civilian\slum_02\slum_02_f.p3d",
        "a3\structures_f_exp\civilian\slum_03\slum_03_f.p3d",
        "a3\structures_f_exp\civilian\slum_04\slum_04_f.p3d",
        "a3\structures_f_exp\civilian\slum_05\slum_05_f.p3d",
        "a3\structures_f_exp\commercial\addons\addon_01_f.p3d",
        "a3\structures_f_exp\commercial\addons\addon_04_f.p3d",
        "a3\structures_f_exp\commercial\addons\addon_05_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_01\fuelstation_01_shop_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_01\fuelstation_01_workshop_f.p3d",
        "a3\structures_f_exp\commercial\market\metalshelter_02_f.p3d",
        "a3\structures_f_exp\commercial\multistorybuilding_01\multistorybuilding_01_f.p3d",
        "a3\structures_f_exp\commercial\multistorybuilding_03\multistorybuilding_03_f.p3d",
        "a3\structures_f_exp\commercial\multistorybuilding_04\multistorybuilding_04_f.p3d",
        "a3\structures_f_exp\commercial\shop_city_01\shop_city_01_f.p3d",
        "a3\structures_f_exp\commercial\shop_city_02\shop_city_02_f.p3d",
        "a3\structures_f_exp\commercial\shop_city_03\shop_city_03_f.p3d",
        "a3\structures_f_exp\commercial\shop_city_04\shop_city_04_f.p3d",
        "a3\structures_f_exp\commercial\shop_city_05\shop_city_05_f.p3d",
        "a3\structures_f_exp\commercial\shop_city_06\shop_city_06_f.p3d",
        "a3\structures_f_exp\commercial\shop_city_07\shop_city_07_f.p3d",
        "a3\structures_f_exp\commercial\shop_town_01\shop_town_01_f.p3d",
        "a3\structures_f_exp\commercial\shop_town_01\shop_town_01_ruins_f.p3d",
        "a3\structures_f_exp\commercial\shop_town_02\shop_town_02_f.p3d",
        "a3\structures_f_exp\commercial\shop_town_03\shop_town_03_f.p3d",
        "a3\structures_f_exp\commercial\shop_town_04\shop_town_04_f.p3d",
        "a3\structures_f_exp\commercial\shop_town_05\shop_town_05_f.p3d",
        "a3\structures_f_exp\commercial\warehouses\warehouse_03_f.p3d",
        "a3\structures_f_exp\cultural\cathedral_01\cathedral_01_f.p3d",
        "a3\structures_f_exp\cultural\church_02\church_02_f.p3d",
        "a3\structures_f_exp\cultural\temple_native_01\temple_native_01_f.p3d",
        "a3\structures_f_exp\industrial\port\warehouse_01_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_generalbuilding_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_warehouse_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shed_unfinished_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_01_terminal_f.p3d",
        "ca\buildings2\ind_garage01\ind_garage01.p3d",
        "ca\buildings2\shed_small\shed_m01.p3d",
        "ca\buildings2\shed_small\shed_w01.p3d",
        "ca\buildings\hut_old02.p3d",
        "ca\buildings\sara_stodola.p3d",
        "ca\buildings\sara_stodola2.p3d",
        "cup\terrains\cup_terrains_buildings\warehouse\mezzanine\mezzanine_01.p3d",
        "cup\terrains\cup_terrains_buildings\warehouse\mezzanine\mezzanine_02.p3d",
        "cup\terrains\cup_terrains_buildings\warehouse\mezzanine\mezzanine_03.p3d",
        "cup\terrains\cup_terrains_buildings\warehouse\mezzanine\mezzanine_03a.p3d",
        "go_structures_ip\civilian\houses\house_small_01_f\go_ip_house_small_01_f.p3d",
        "go_structures_ip\civilian\shacks\go_ip_shack_01_f.p3d",
        "go_structures_ip\industrial\warehouse_01_f\go_ip_warehouse_01_f.p3d"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "a3\structures_f\civ\offices\offices_01_v1_f.p3d",
        "a3\structures_f\dominants\hospital\hospital_main_f.p3d",
        "a3\structures_f\dominants\hospital\hospital_side2_f.p3d",
        "a3\structures_f_argo\civilian\house_big01\i_house_big_01_b_blue_f.p3d",
        "a3\structures_f_argo\civilian\house_big01\i_house_big_01_b_brown_f.p3d",
        "a3\structures_f_argo\civilian\house_big01\i_house_big_01_b_pink_f.p3d",
        "a3\structures_f_argo\civilian\house_big01\i_house_big_01_b_whiteblue_f.p3d",
        "a3\structures_f_argo\civilian\house_big02\i_house_big_02_b_whiteblue_f.p3d",
        "a3\structures_f_argo\civilian\house_big02\i_house_big_02_b_yellow_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2b02_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2b03_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2b04_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w05_f.p3d",
        "a3\structures_f_exp\civilian\house_big_03\house_big_03_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_01_terminal_f.p3d"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "a3\structures_f\civ\chapels\chapel_v2_f.p3d",
        "a3\structures_f\civ\offices\offices_01_v1_f.p3d",
        "a3\structures_f\dominants\hospital\hospital_main_f.p3d",
        "a3\structures_f\dominants\hospital\hospital_side2_f.p3d",
        "a3\structures_f\households\house_big02\d_house_big_02_v1_f.p3d",
        "a3\structures_f\households\house_big02\i_house_big_02_v2_f.p3d",
        "a3\structures_f\households\house_shop01\d_shop_01_v1_f.p3d",
        "a3\structures_f\households\house_shop01\i_shop_01_v2_f.p3d",
        "a3\structures_f\households\house_shop01\i_shop_01_v3_dam_f.p3d",
        "a3\structures_f\households\house_shop01\u_shop_01_v1_dam_f.p3d",
        "a3\structures_f\households\house_shop01\u_shop_01_v1_f.p3d",
        "a3\structures_f\households\house_shop02\i_shop_02_v1_f.p3d",
        "a3\structures_f\households\house_shop02\i_shop_02_v2_f.p3d",
        "a3\structures_f\households\house_shop02\i_shop_02_v3_f.p3d",
        "a3\structures_f\households\house_shop02\u_shop_02_v1_dam_f.p3d",
        "a3\structures_f\households\house_shop02\u_shop_02_v1_f.p3d",
        "a3\structures_f\households\house_small01\i_house_small_01_v1_f.p3d",
        "a3\structures_f\households\house_small01\i_house_small_01_v2_f.p3d",
        "a3\structures_f\households\house_small01\i_house_small_01_v3_f.p3d",
        "a3\structures_f\households\house_small02\i_house_small_02_v1_f.p3d",
        "a3\structures_f\households\house_small02\i_house_small_02_v2_f.p3d",
        "a3\structures_f\households\house_small02\i_house_small_02_v3_f.p3d",
        "a3\structures_f\households\house_small03\i_house_small_03_v1_f.p3d",
        "a3\structures_f\households\slum\slum_house01_f.p3d",
        "a3\structures_f\households\slum\slum_house02_f.p3d",
        "a3\structures_f\households\slum\slum_house03_f.p3d",
        "a3\structures_f\households\stone_big\i_stone_housebig_v1_f.p3d",
        "a3\structures_f\households\stone_big\i_stone_housebig_v2_f.p3d",
        "a3\structures_f\households\stone_big\i_stone_housebig_v3_f.p3d",
        "a3\structures_f\households\stone_shed\i_stone_shed_v1_f.p3d",
        "a3\structures_f\households\stone_shed\i_stone_shed_v2_f.p3d",
        "a3\structures_f\households\stone_shed\i_stone_shed_v3_f.p3d",
        "a3\structures_f\households\stone_small\i_stone_housesmall_v2_f.p3d",
        "a3\structures_f\households\wip\unfinished_building_01_f.p3d",
        "a3\structures_f\ind\airport\airport_center_f.p3d",
        "a3\structures_f\ind\carservice\carservice_f.p3d",
        "a3\structures_f_argo\civilian\addons\i_addon_02_b_white_f.p3d",
        "a3\structures_f_argo\civilian\house_big01\i_house_big_01_b_blue_f.p3d",
        "a3\structures_f_argo\civilian\house_big01\i_house_big_01_b_brown_f.p3d",
        "a3\structures_f_argo\civilian\house_big01\i_house_big_01_b_pink_f.p3d",
        "a3\structures_f_argo\civilian\house_big01\i_house_big_01_b_white_f.p3d",
        "a3\structures_f_argo\civilian\house_big01\i_house_big_01_b_whiteblue_f.p3d",
        "a3\structures_f_argo\civilian\house_big01\i_house_big_01_b_yellow_f.p3d",
        "a3\structures_f_argo\civilian\house_big02\i_house_big_02_b_blue_f.p3d",
        "a3\structures_f_argo\civilian\house_big02\i_house_big_02_b_brown_f.p3d",
        "a3\structures_f_argo\civilian\house_big02\i_house_big_02_b_pink_f.p3d",
        "a3\structures_f_argo\civilian\house_big02\i_house_big_02_b_white_f.p3d",
        "a3\structures_f_argo\civilian\house_big02\i_house_big_02_b_whiteblue_f.p3d",
        "a3\structures_f_argo\civilian\house_big02\i_house_big_02_b_yellow_f.p3d",
        "a3\structures_f_argo\civilian\house_small01\i_house_small_01_b_blue_f.p3d",
        "a3\structures_f_argo\civilian\house_small01\i_house_small_01_b_brown_f.p3d",
        "a3\structures_f_argo\civilian\house_small01\i_house_small_01_b_pink_f.p3d",
        "a3\structures_f_argo\civilian\house_small01\i_house_small_01_b_white_f.p3d",
        "a3\structures_f_argo\civilian\house_small01\i_house_small_01_b_whiteblue_f.p3d",
        "a3\structures_f_argo\civilian\house_small01\i_house_small_01_b_yellow_f.p3d",
        "a3\structures_f_argo\civilian\house_small02\i_house_small_02_b_blue_f.p3d",
        "a3\structures_f_argo\civilian\house_small02\i_house_small_02_b_yellow_f.p3d",
        "a3\structures_f_argo\civilian\house_small02\i_house_small_02_c_blue_f.p3d",
        "a3\structures_f_argo\civilian\house_small02\i_house_small_02_c_whiteblue_f.p3d",
        "a3\structures_f_argo\civilian\house_small02\i_house_small_02_c_yellow_f.p3d",
        "a3\structures_f_argo\civilian\stone_house_big_01\i_stone_house_big_01_b_clay_f.p3d",
        "a3\structures_f_argo\civilian\stone_shed_01\i_stone_shed_01_c_white_f.p3d",
        "a3\structures_f_argo\commercial\shop_02\i_shop_02_b_blue_f.p3d",
        "a3\structures_f_argo\commercial\shop_02\i_shop_02_b_brown_f.p3d",
        "a3\structures_f_argo\commercial\shop_02\i_shop_02_b_pink_f.p3d",
        "a3\structures_f_argo\commercial\shop_02\i_shop_02_b_white_f.p3d",
        "a3\structures_f_argo\commercial\shop_02\i_shop_02_b_whiteblue_f.p3d",
        "a3\structures_f_argo\commercial\shop_02\i_shop_02_b_yellow_f.p3d",
        "a3\structures_f_argo\commercial\supermarket_01\supermarket_01_malden_f.p3d",
        "a3\structures_f_argo\cultural\church\church_01_v2_f.p3d",
        "a3\structures_f_argo\industrial\agriculture\barn_01_grey_f.p3d",
        "a3\structures_f_enoch\civilian\camps\camp_house_01_brown_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1b01_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w03_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w04_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w08_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w10_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w13_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2b02_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2b03_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2b04_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w05_f.p3d",
        "a3\structures_f_enoch\civilian\medical\healthcenter_01_f.p3d",
        "a3\structures_f_enoch\commercial\villagestore_01\villagestore_01_f.p3d",
        "a3\structures_f_enoch\cultural\church_04\church_04_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garageoffice_01_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garagerow_01_large_f.p3d",
        "a3\structures_f_enoch\industrial\sawmills\sawmill_01_f.p3d",
        "a3\structures_f_exp\civilian\house_big_01\house_big_01_f.p3d",
        "a3\structures_f_exp\civilian\house_big_02\house_big_02_f.p3d",
        "a3\structures_f_exp\civilian\house_big_03\house_big_03_f.p3d",
        "a3\structures_f_exp\civilian\house_big_04\house_big_04_f.p3d",
        "a3\structures_f_exp\civilian\house_big_05\house_big_05_f.p3d",
        "a3\structures_f_exp\civilian\house_native_01\house_native_01_f.p3d",
        "a3\structures_f_exp\civilian\house_native_02\house_native_02_f.p3d",
        "a3\structures_f_exp\civilian\house_small_01\house_small_01_f.p3d",
        "a3\structures_f_exp\civilian\house_small_02\house_small_02_f.p3d",
        "a3\structures_f_exp\civilian\house_small_03\house_small_03_f.p3d",
        "a3\structures_f_exp\civilian\house_small_04\house_small_04_f.p3d",
        "a3\structures_f_exp\civilian\house_small_05\house_small_05_f.p3d",
        "a3\structures_f_exp\civilian\house_small_06\house_small_06_f.p3d",
        "a3\structures_f_exp\civilian\school_01\school_01_f.p3d",
        "a3\structures_f_exp\civilian\slum_01\slum_01_f.p3d",
        "a3\structures_f_exp\civilian\slum_02\slum_02_f.p3d",
        "a3\structures_f_exp\civilian\slum_03\slum_03_f.p3d",
        "a3\structures_f_exp\civilian\slum_05\slum_05_f.p3d",
        "a3\structures_f_exp\commercial\addons\addon_04_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_01\fuelstation_01_shop_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_01\fuelstation_01_workshop_f.p3d",
        "a3\structures_f_exp\commercial\multistorybuilding_01\multistorybuilding_01_f.p3d",
        "a3\structures_f_exp\commercial\multistorybuilding_04\multistorybuilding_04_f.p3d",
        "a3\structures_f_exp\commercial\shop_city_01\shop_city_01_f.p3d",
        "a3\structures_f_exp\commercial\shop_city_03\shop_city_03_f.p3d",
        "a3\structures_f_exp\commercial\shop_city_04\shop_city_04_f.p3d",
        "a3\structures_f_exp\commercial\shop_city_06\shop_city_06_f.p3d",
        "a3\structures_f_exp\commercial\shop_city_07\shop_city_07_f.p3d",
        "a3\structures_f_exp\commercial\shop_town_01\shop_town_01_f.p3d",
        "a3\structures_f_exp\commercial\shop_town_03\shop_town_03_f.p3d",
        "a3\structures_f_exp\commercial\shop_town_04\shop_town_04_f.p3d",
        "a3\structures_f_exp\commercial\warehouses\warehouse_03_f.p3d",
        "a3\structures_f_exp\cultural\cathedral_01\cathedral_01_f.p3d",
        "a3\structures_f_exp\cultural\church_02\church_02_f.p3d",
        "a3\structures_f_exp\cultural\temple_native_01\temple_native_01_f.p3d",
        "ca\buildings\sara_stodola.p3d",
        "ca\buildings\sara_stodola2.p3d",
        "cup\terrains\cup_terrains_buildings\warehouse\mezzanine\mezzanine_03a.p3d",
        "go_structures_ip\civilian\houses\house_small_01_f\go_ip_house_small_01_f.p3d"
    ];

    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
        "a3\structures_f\ind\dieselpowerplant\dp_smallfactory_f.p3d",
        "a3\structures_f\ind\solarpowerplant\solarpanel_1_f.p3d",
        "a3\structures_f\ind\solarpowerplant\spp_tower_f.p3d",
        "a3\structures_f\ind\solarpowerplant\spp_transformer_f.p3d",
        "a3\structures_f_enoch\industrial\houses\waterstation_01_f.p3d",
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
        "a3\structures_f_exp\industrial\port\mobilecrane_01_hook_f.p3d",
        "a3\structures_f_exp\industrial\port\warehouse_02_f.p3d",
        "a3\structures_f_exp\naval\piers\pierwooden_01_10m_norails_f.p3d",
        "a3\structures_f_exp\naval\piers\pierwooden_01_dock_f.p3d",
        "a3\structures_f_exp\naval\piers\pierwooden_01_hut_f.p3d",
        "a3\structures_f_exp\naval\piers\pierwooden_01_platform_f.p3d",
        "a3\structures_f_exp\naval\piers\pierwooden_02_16m_f.p3d",
        "a3\structures_f_exp\naval\piers\pierwooden_02_30deg_f.p3d",
        "a3\structures_f_exp\naval\piers\pierwooden_02_hut_f.p3d"
    ];

    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
        "a3\props_f_exp\infrastructure\railways\locomotive_01_v1_f.p3d",
        "a3\props_f_exp\infrastructure\railways\locomotive_01_v2_f.p3d",
        "a3\props_f_exp\infrastructure\railways\railwaycar_01_sugarcane_empty_f.p3d",
        "a3\props_f_exp\infrastructure\railways\railwaycar_01_sugarcane_f.p3d"
    ];

    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        "a3\structures_f\ind\dieselpowerplant\dp_bigtank_f.p3d",
        "a3\structures_f\ind\dieselpowerplant\dp_smalltank_f.p3d",
        "a3\structures_f\ind\fuelstation\fuelstation_build_f.p3d",
        "a3\structures_f_argo\commercial\fuelstation_01\fuelstation_01_pump_malevil_f.p3d",
        "a3\structures_f_enoch\industrial\dieselpowerplant_01\dp_smalltank_old_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_02\fuelstation_02_pump_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_02\fuelstation_02_roof_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_crystallizertowers_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_storagebin_big_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_storagebin_medium_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_storagebin_small_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_reservoirtower_f.p3d",
        "ca\buildings2\ind_cementworks\ind_expedice\ind_expedice_3.p3d"
    ];

    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
        "a3\structures_f\dominants\wip\wip_f.p3d",
        "a3\structures_f\ind\factory\factory_main_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_04_f.p3d",
        "a3\structures_f_enoch\industrial\sawmills\sawmill_01_f.p3d",
        "a3\structures_f_exp\industrial\dieselpowerplant_01\dpp_01_mainfactory_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_boilerbuilding_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_clarifier_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_condenser_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_conveyor_end_high_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_crystallizer_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_diffuser_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_feeder_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_heap_bagasse_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_washer_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shed_unfinished_f.p3d",
        "ca\buildings2\ind_cementworks\ind_silovelke\ind_silovelke_01.p3d",
        "cup\terrains\cup_terrains_buildings\warehouse\mezzanine\mezzanine_03a.p3d"
    ];

};
