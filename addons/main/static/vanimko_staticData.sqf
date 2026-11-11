// ALiVE 3 index v3.1, made 2026-11-11 by the ALiVE web indexer, building positions measured
private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: vanimko (ALiVE 3 index v3.1, 2026-11-11)"] call ALiVE_fnc_dump;

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

ALiVE_mapCompositionType = "Pacific";

 if (tolower(_worldName) == "vanimko") then {
    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "a3\map_tanoabuka\data\objects\structures\satellitedish.p3d",
        "a3\props_f_enoch\military\camps\tentsolar_01_f.p3d",
        "ca\misc\empty.p3d"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "a3\structures_f\mil\barracks\i_barracks_v2_f.p3d",
        "a3\structures_f\mil\cargo\medevac_house_v1_f.p3d",
        "a3\structures_f\mil\cargo\medevac_hq_v1_f.p3d",
        "a3\structures_f\mil\offices\miloffices_v1_f.p3d",
        "a3\structures_f\mil\radar\radar_f.p3d",
        "a3\structures_f\mil\radar\radar_small_f.p3d",
        "a3\structures_f\research\dome_big_f.p3d",
        "a3\structures_f\research\research_house_v1_f.p3d",
        "a3\structures_f\research\research_hq_f.p3d",
        "a3\structures_f_enoch\civilian\police\policestation_01_f.p3d",
        "a3\structures_f_enoch\industrial\sawmills\sawmill_01_illuminati_tower_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_02_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_04_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_05_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_06_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_06_ruins_f.p3d",
        "a3\structures_f_enoch\military\barracks\guardhouse_02_grey_f.p3d",
        "a3\structures_f_enoch\military\barracks\guardtower_02_f.p3d",
        "a3\structures_f_enoch\military\barracks\guardtower_02_ruins_f.p3d",
        "a3\structures_f_enoch\military\radar\radar_01_cooler_ruins_f.p3d",
        "a3\structures_f_enoch\military\radar\radar_01_hq_f.p3d",
        "a3\structures_f_enoch\military\radar\radar_01_hq_ruins_f.p3d",
        "a3\structures_f_enoch\military\radar\radar_01_kitchen_f.p3d",
        "a3\structures_f_enoch\military\radar\radar_01_kitchen_ruins_f.p3d",
        "a3\structures_f_exp\industrial\port\guardhouse_01_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shed_unfinished_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_01_controltower_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_01_terminal_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_02_controltower_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_02_hangar_left_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_02_terminal_f.p3d",
        "a3\structures_f_exp\military\barracks_01\barracks_01_camo_f.p3d",
        "a3\structures_f_exp\military\barracks_01\barracks_01_dilapidated_f.p3d",
        "a3\structures_f_exp\military\barracks_01\barracks_01_grey_f.p3d",
        "a3\structures_f_exp\military\containerbases\cargo_house_v4_f.p3d",
        "a3\structures_f_exp\military\containerbases\cargo_house_v4_ruins_f.p3d",
        "a3\structures_f_exp\military\containerbases\cargo_hq_v4_f.p3d",
        "a3\structures_f_exp\military\containerbases\cargo_hq_v4_ruins_f.p3d",
        "a3\structures_f_exp\military\containerbases\cargo_patrol_v4_f.p3d",
        "a3\structures_f_exp\military\containerbases\cargo_patrol_v4_ruins_f.p3d",
        "a3\structures_f_exp\military\containerbases\cargo_tower_v4_f.p3d",
        "a3\structures_f_exp\military\containerbases\cargo_tower_v4_ruins_f.p3d",
        "a3\structures_f_exp\military\emplacements\emplacementgun_01_d_mossy_f.p3d",
        "a3\structures_f_exp\military\fortifications\hbarrier_01_big_tower_green_f.p3d",
        "a3\structures_f_exp\military\fortifications\hbarrier_01_tower_green_f.p3d",
        "a3\structures_f_exp\military\pillboxes\pillboxbunker_01_big_f.p3d",
        "a3\structures_f_exp\military\pillboxes\pillboxbunker_01_hex_f.p3d",
        "a3\structures_f_orange\humanitarian\camps\medicaltent_01_f.p3d"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "a3\structures_f\mil\barracks\i_barracks_v2_f.p3d",
        "a3\structures_f\mil\offices\miloffices_v1_f.p3d",
        "a3\structures_f\research\dome_big_f.p3d",
        "a3\structures_f\research\research_hq_f.p3d",
        "a3\structures_f_enoch\civilian\police\policestation_01_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_02_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_05_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_06_f.p3d",
        "a3\structures_f_enoch\military\radar\radar_01_hq_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_01_terminal_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_02_terminal_f.p3d",
        "a3\structures_f_exp\military\barracks_01\barracks_01_camo_f.p3d",
        "a3\structures_f_exp\military\barracks_01\barracks_01_dilapidated_f.p3d",
        "a3\structures_f_exp\military\barracks_01\barracks_01_grey_f.p3d",
        "a3\structures_f_exp\military\containerbases\cargo_hq_v4_f.p3d",
        "a3\structures_f_exp\military\containerbases\cargo_tower_v4_f.p3d"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "a3\structures_f\mil\barracks\i_barracks_v2_f.p3d",
        "a3\structures_f\mil\offices\miloffices_v1_f.p3d",
        "a3\structures_f\research\dome_big_f.p3d",
        "a3\structures_f\research\research_hq_f.p3d",
        "a3\structures_f_enoch\civilian\police\policestation_01_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_02_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_05_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_06_f.p3d",
        "a3\structures_f_enoch\military\radar\radar_01_hq_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shed_unfinished_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_01_terminal_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_02_terminal_f.p3d",
        "a3\structures_f_exp\military\barracks_01\barracks_01_camo_f.p3d",
        "a3\structures_f_exp\military\barracks_01\barracks_01_dilapidated_f.p3d",
        "a3\structures_f_exp\military\barracks_01\barracks_01_grey_f.p3d",
        "a3\structures_f_exp\military\containerbases\cargo_hq_v4_f.p3d",
        "a3\structures_f_exp\military\containerbases\cargo_patrol_v4_f.p3d",
        "a3\structures_f_exp\military\containerbases\cargo_tower_v4_f.p3d"
    ];

    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        "a3\structures_f\mil\barracks\i_barracks_v2_f.p3d",
        "a3\structures_f\mil\offices\miloffices_v1_f.p3d",
        "a3\structures_f\research\dome_big_f.p3d",
        "a3\structures_f\research\research_hq_f.p3d",
        "a3\structures_f_enoch\civilian\police\policestation_01_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_06_f.p3d",
        "a3\structures_f_enoch\military\radar\radar_01_hq_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_02_terminal_f.p3d",
        "a3\structures_f_exp\military\barracks_01\barracks_01_camo_f.p3d",
        "a3\structures_f_exp\military\barracks_01\barracks_01_dilapidated_f.p3d",
        "a3\structures_f_exp\military\barracks_01\barracks_01_grey_f.p3d",
        "a3\structures_f_exp\military\containerbases\cargo_hq_v4_f.p3d",
        "a3\structures_f_exp\military\containerbases\cargo_tower_v4_f.p3d"
    ];

    ALIVE_militaryFieldworkBuildingTypes = ALIVE_militaryFieldworkBuildingTypes + [
        "a3\structures_f_enoch\military\barracks\guardtower_02_f.p3d",
        "a3\structures_f_exp\military\pillboxes\pillboxbunker_01_big_f.p3d",
        "a3\structures_f_exp\military\pillboxes\pillboxbunker_01_hex_f.p3d"
    ];

    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
        "a3\structures_f\ind\airport\hangar_f.p3d",
        "a3\structures_f\mil\tenthangar\tenthangar_v1_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_01_hangar_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_02_hangar_left_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_02_hangar_right_f.p3d"
    ];

    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [
        "a3\structures_f\ind\airport\hangar_f.p3d",
        "a3\structures_f\mil\tenthangar\tenthangar_v1_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_01_hangar_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_02_hangar_left_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_02_hangar_right_f.p3d"
    ];

    ALiVE_HeliBuildingTypes = ALiVE_HeliBuildingTypes + [
        "a3\structures_f\mil\helipads\helipadcircle_f.p3d",
        "a3\structures_f\mil\helipads\helipadcivil_f.p3d",
        "a3\structures_f\mil\helipads\helipadsquare_f.p3d"
    ];

    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
        "a3\structures_f\mil\helipads\helipadcircle_f.p3d",
        "a3\structures_f\mil\helipads\helipadcivil_f.p3d",
        "a3\structures_f\mil\helipads\helipadsquare_f.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "a3\structures_f\civ\infoboards\infostand_v1_f.p3d",
        "a3\structures_f\civ\offices\offices_01_v1_f.p3d",
        "a3\structures_f\dominants\hospital\hospital_main_f.p3d",
        "a3\structures_f\dominants\hospital\hospital_side1_f.p3d",
        "a3\structures_f\dominants\hospital\hospital_side2_f.p3d",
        "a3\structures_f\households\house_big01\i_house_big_01_v2_f.p3d",
        "a3\structures_f\households\slum\cargo_house_slum_f.p3d",
        "a3\structures_f\households\slum\slum_house01_f.p3d",
        "a3\structures_f\households\slum\slum_house02_f.p3d",
        "a3\structures_f\households\slum\slum_house03_f.p3d",
        "a3\structures_f\households\wip\unfinished_building_01_f.p3d",
        "a3\structures_f\households\wip\unfinished_building_02_f.p3d",
        "a3\structures_f\ind\shed\i_shed_ind_f.p3d",
        "a3\structures_f\ind\solarpowerplant\spp_tower_ruins_f.p3d",
        "a3\structures_f_argo\civilian\house_big01\i_house_big_01_b_blue_f.p3d",
        "a3\structures_f_argo\civilian\house_big01\i_house_big_01_b_white_f.p3d",
        "a3\structures_f_argo\civilian\house_big02\i_house_big_02_b_blue_f.p3d",
        "a3\structures_f_argo\civilian\house_big02\i_house_big_02_b_white_f.p3d",
        "a3\structures_f_argo\civilian\house_big02\i_house_big_02_b_whiteblue_f.p3d",
        "a3\structures_f_argo\commercial\shop_02\i_shop_02_b_blue_f.p3d",
        "a3\structures_f_argo\commercial\shop_02\i_shop_02_b_pink_f.p3d",
        "a3\structures_f_argo\commercial\shop_02\i_shop_02_b_white_f.p3d",
        "a3\structures_f_argo\commercial\shop_02\i_shop_02_b_whiteblue_f.p3d",
        "a3\structures_f_enoch\civilian\police\policestation_01_f.p3d",
        "a3\structures_f_enoch\commercial\fuelstation_03\fuelstation_03_shop_f.p3d",
        "a3\structures_f_enoch\cultural\castleruins\castleruins_01_bastion_f.p3d",
        "a3\structures_f_enoch\industrial\cementworks\cementworks_01_grey_f.p3d",
        "a3\structures_f_enoch\industrial\coalplant_01\coalplant_01_loadinghouse_f.p3d",
        "a3\structures_f_enoch\industrial\coalplant_01\coalplant_01_mainbuilding_f.p3d",
        "a3\structures_f_enoch\industrial\houses\factory_02_f.p3d",
        "a3\structures_f_enoch\industrial\sawmills\sawmill_01_f.p3d",
        "a3\structures_f_exp\civilian\house_big_01\house_big_01_f.p3d",
        "a3\structures_f_exp\civilian\house_big_01\house_big_01_ruins_f.p3d",
        "a3\structures_f_exp\civilian\house_big_02\house_big_02_f.p3d",
        "a3\structures_f_exp\civilian\house_big_03\house_big_03_f.p3d",
        "a3\structures_f_exp\civilian\house_big_04\house_big_04_f.p3d",
        "a3\structures_f_exp\civilian\house_big_05\house_big_05_f.p3d",
        "a3\structures_f_exp\civilian\house_native_01\house_native_01_f.p3d",
        "a3\structures_f_exp\civilian\house_native_02\house_native_02_f.p3d",
        "a3\structures_f_exp\civilian\house_small_01\house_small_01_f.p3d",
        "a3\structures_f_exp\civilian\house_small_01\house_small_01_ruins_f.p3d",
        "a3\structures_f_exp\civilian\house_small_02\house_small_02_f.p3d",
        "a3\structures_f_exp\civilian\house_small_02\house_small_02_ruins_f.p3d",
        "a3\structures_f_exp\civilian\house_small_03\house_small_03_f.p3d",
        "a3\structures_f_exp\civilian\house_small_03\house_small_03_ruins_f.p3d",
        "a3\structures_f_exp\civilian\house_small_04\house_small_04_f.p3d",
        "a3\structures_f_exp\civilian\house_small_04\house_small_04_ruins_f.p3d",
        "a3\structures_f_exp\civilian\house_small_05\house_small_05_f.p3d",
        "a3\structures_f_exp\civilian\house_small_05\house_small_05_ruins_f.p3d",
        "a3\structures_f_exp\civilian\house_small_06\house_small_06_f.p3d",
        "a3\structures_f_exp\civilian\school_01\school_01_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_01_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_01_ruins_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_02_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_02_ruins_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_03_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_03_ruins_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_05_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_05_ruins_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_07_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_07_ruins_f.p3d",
        "a3\structures_f_exp\civilian\slum_01\slum_01_f.p3d",
        "a3\structures_f_exp\civilian\slum_01\slum_01_ruins_f.p3d",
        "a3\structures_f_exp\civilian\slum_02\slum_02_f.p3d",
        "a3\structures_f_exp\civilian\slum_02\slum_02_ruins_f.p3d",
        "a3\structures_f_exp\civilian\slum_03\slum_03_f.p3d",
        "a3\structures_f_exp\civilian\slum_03\slum_03_ruins_f.p3d",
        "a3\structures_f_exp\civilian\slum_04\slum_04_f.p3d",
        "a3\structures_f_exp\civilian\slum_04\slum_04_ruins_f.p3d",
        "a3\structures_f_exp\civilian\slum_05\slum_05_f.p3d",
        "a3\structures_f_exp\commercial\addons\addon_01_f.p3d",
        "a3\structures_f_exp\commercial\addons\addon_04_f.p3d",
        "a3\structures_f_exp\commercial\addons\addon_05_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_01\fuelstation_01_shop_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_01\fuelstation_01_workshop_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_02\fuelstation_02_workshop_f.p3d",
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
        "a3\structures_f_exp\commercial\shop_town_02\shop_town_02_ruins_f.p3d",
        "a3\structures_f_exp\commercial\shop_town_03\shop_town_03_f.p3d",
        "a3\structures_f_exp\commercial\shop_town_03\shop_town_03_ruins_f.p3d",
        "a3\structures_f_exp\commercial\shop_town_04\shop_town_04_f.p3d",
        "a3\structures_f_exp\commercial\shop_town_04\shop_town_04_ruins_f.p3d",
        "a3\structures_f_exp\commercial\shop_town_05\shop_town_05_f.p3d",
        "a3\structures_f_exp\commercial\supermarket_01\supermarket_01_f.p3d",
        "a3\structures_f_exp\commercial\warehouses\warehouse_03_f.p3d",
        "a3\structures_f_exp\commercial\warehouses\warehouse_03_ruins_f.p3d",
        "a3\structures_f_exp\cultural\cathedral_01\cathedral_01_f.p3d",
        "a3\structures_f_exp\cultural\church_01\church_01_f.p3d",
        "a3\structures_f_exp\cultural\church_02\church_02_f.p3d",
        "a3\structures_f_exp\cultural\church_03\church_03_f.p3d",
        "a3\structures_f_exp\cultural\temple_native_01\temple_native_01_f.p3d",
        "a3\structures_f_exp\industrial\port\warehouse_01_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_generalbuilding_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_warehouse_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shed_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shed_unfinished_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_01_terminal_f.p3d"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "a3\structures_f\civ\offices\offices_01_v1_f.p3d",
        "a3\structures_f\dominants\hospital\hospital_main_f.p3d",
        "a3\structures_f\dominants\hospital\hospital_side2_f.p3d",
        "a3\structures_f_argo\civilian\house_big01\i_house_big_01_b_blue_f.p3d",
        "a3\structures_f_argo\civilian\house_big02\i_house_big_02_b_whiteblue_f.p3d",
        "a3\structures_f_enoch\civilian\police\policestation_01_f.p3d",
        "a3\structures_f_exp\civilian\house_big_03\house_big_03_f.p3d",
        "a3\structures_f_exp\civilian\house_small_04\house_small_04_ruins_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_01_terminal_f.p3d"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "a3\structures_f\civ\infoboards\infostand_v1_f.p3d",
        "a3\structures_f\civ\offices\offices_01_v1_f.p3d",
        "a3\structures_f\dominants\hospital\hospital_main_f.p3d",
        "a3\structures_f\dominants\hospital\hospital_side2_f.p3d",
        "a3\structures_f\households\house_big01\i_house_big_01_v2_f.p3d",
        "a3\structures_f\households\slum\cargo_house_slum_f.p3d",
        "a3\structures_f\households\slum\slum_house01_f.p3d",
        "a3\structures_f\households\slum\slum_house02_f.p3d",
        "a3\structures_f\households\slum\slum_house03_f.p3d",
        "a3\structures_f\households\wip\unfinished_building_01_f.p3d",
        "a3\structures_f_argo\civilian\house_big01\i_house_big_01_b_blue_f.p3d",
        "a3\structures_f_argo\civilian\house_big01\i_house_big_01_b_white_f.p3d",
        "a3\structures_f_argo\civilian\house_big02\i_house_big_02_b_blue_f.p3d",
        "a3\structures_f_argo\civilian\house_big02\i_house_big_02_b_white_f.p3d",
        "a3\structures_f_argo\civilian\house_big02\i_house_big_02_b_whiteblue_f.p3d",
        "a3\structures_f_argo\commercial\shop_02\i_shop_02_b_blue_f.p3d",
        "a3\structures_f_argo\commercial\shop_02\i_shop_02_b_pink_f.p3d",
        "a3\structures_f_argo\commercial\shop_02\i_shop_02_b_white_f.p3d",
        "a3\structures_f_argo\commercial\shop_02\i_shop_02_b_whiteblue_f.p3d",
        "a3\structures_f_enoch\civilian\police\policestation_01_f.p3d",
        "a3\structures_f_enoch\commercial\fuelstation_03\fuelstation_03_shop_f.p3d",
        "a3\structures_f_enoch\industrial\cementworks\cementworks_01_grey_f.p3d",
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
        "a3\structures_f_exp\civilian\house_small_04\house_small_04_ruins_f.p3d",
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
        "a3\structures_f_exp\commercial\fuelstation_02\fuelstation_02_workshop_f.p3d",
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
        "a3\structures_f_exp\commercial\supermarket_01\supermarket_01_f.p3d",
        "a3\structures_f_exp\commercial\warehouses\warehouse_03_f.p3d",
        "a3\structures_f_exp\cultural\cathedral_01\cathedral_01_f.p3d",
        "a3\structures_f_exp\cultural\church_01\church_01_f.p3d",
        "a3\structures_f_exp\cultural\church_02\church_02_f.p3d",
        "a3\structures_f_exp\cultural\church_03\church_03_f.p3d",
        "a3\structures_f_exp\cultural\temple_native_01\temple_native_01_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shed_f.p3d"
    ];

    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
        "a3\structures_f\ind\dieselpowerplant\dp_smallfactory_f.p3d",
        "a3\structures_f\ind\solarpowerplant\solarpanel_1_f.p3d",
        "a3\structures_f\ind\solarpowerplant\solarpanel_2_f.p3d",
        "a3\structures_f\ind\solarpowerplant\spp_transformer_f.p3d",
        "a3\structures_f_enoch\industrial\houses\waterstation_01_f.p3d",
        "a3\structures_f_enoch\industrial\power\powerstation_01_f.p3d",
        "a3\structures_f_enoch\military\radar\mobileradar_01_generator_f.p3d",
        "a3\structures_f_exp\industrial\dieselpowerplant_01\dpp_01_transformer_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_chimney_f.p3d"
    ];

    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
        "a3\structures_f\ind\transmitter_tower\communication_f.p3d",
        "a3\structures_f\ind\transmitter_tower\tbox_f.p3d",
        "a3\structures_f\ind\transmitter_tower\ttowerbig_1_f.p3d",
        "a3\structures_f\ind\transmitter_tower\ttowerbig_2_f.p3d",
        "a3\structures_f\ind\transmitter_tower\ttowersmall_1_f.p3d",
        "a3\structures_f\ind\transmitter_tower\ttowersmall_2_f.p3d"
    ];

    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        "a3\structures_f\dominants\lighthouse\lighthouse_small_f.p3d",
        "a3\structures_f_exp\industrial\port\containercrane_01_arm_f.p3d",
        "a3\structures_f_exp\industrial\port\containercrane_01_arm_lowered_f.p3d",
        "a3\structures_f_exp\industrial\port\containercrane_01_f.p3d",
        "a3\structures_f_exp\industrial\port\containerline_01_f.p3d",
        "a3\structures_f_exp\industrial\port\containerline_02_f.p3d",
        "a3\structures_f_exp\industrial\port\containerline_03_f.p3d",
        "a3\structures_f_exp\industrial\port\gantrycrane_01_f.p3d",
        "a3\structures_f_exp\industrial\port\warehouse_02_f.p3d",
        "a3\structures_f_exp\naval\piers\pierwooden_01_10m_norails_f.p3d",
        "a3\structures_f_exp\naval\piers\pierwooden_01_dock_f.p3d",
        "a3\structures_f_exp\naval\piers\pierwooden_01_hut_f.p3d",
        "a3\structures_f_exp\naval\piers\pierwooden_02_16m_f.p3d",
        "a3\structures_f_exp\naval\piers\pierwooden_02_30deg_f.p3d",
        "a3\structures_f_exp\naval\piers\pierwooden_02_hut_f.p3d"
    ];

    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        "a3\structures_f\ind\dieselpowerplant\dp_bigtank_f.p3d",
        "a3\structures_f\ind\dieselpowerplant\dp_smalltank_f.p3d",
        "a3\structures_f\ind\reservoirtank\reservoirtank_v1_f.p3d",
        "a3\structures_f_enoch\commercial\fuelstation_03\fuelstation_03_roof_f.p3d",
        "a3\structures_f_enoch\commercial\fuelstation_03\fuelstation_03_shop_f.p3d",
        "a3\structures_f_enoch\industrial\dieselpowerplant_01\dp_smalltank_old_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_01\fuelstation_01_pump_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_01\fuelstation_01_roof_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_02\fuelstation_02_pump_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_02\fuelstation_02_roof_f.p3d",
        "a3\structures_f_exp\industrial\port\storagetank_01_large_f.p3d",
        "a3\structures_f_exp\industrial\port\storagetank_01_small_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_crystallizertowers_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_storagebin_big_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_storagebin_medium_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_reservoirtower_f.p3d"
    ];

    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
        "a3\structures_f\dominants\wip\wip_f.p3d",
        "a3\structures_f\ind\crane\crane_f.p3d",
        "a3\structures_f_enoch\industrial\cementworks\cementworks_01_grey_f.p3d",
        "a3\structures_f_enoch\industrial\coalplant_01\coalplant_01_mainbuilding_f.p3d",
        "a3\structures_f_enoch\industrial\sawmills\sawmill_01_f.p3d",
        "a3\structures_f_enoch\infrastructure\bridges\bridge_metal_01_25m_f.p3d",
        "a3\structures_f_exp\industrial\dieselpowerplant_01\dpp_01_mainfactory_f.p3d",
        "a3\structures_f_exp\industrial\dieselpowerplant_01\dpp_01_smallfactory_f.p3d",
        "a3\structures_f_exp\industrial\stockyard_01\sy_01_conveyor_end_f.p3d",
        "a3\structures_f_exp\industrial\stockyard_01\sy_01_conveyor_junction_f.p3d",
        "a3\structures_f_exp\industrial\stockyard_01\sy_01_reclaimer_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_boilerbuilding_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_clarifier_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_condenser_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_conveyor_8m_high_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_conveyor_end_high_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_crystallizer_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_feeder_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_heap_bagasse_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_washer_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shed_unfinished_f.p3d"
    ];

};
