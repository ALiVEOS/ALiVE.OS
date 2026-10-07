// ALiVE 3 index v3.1, made 2026-10-06 by the ALiVE web indexer, building positions measured
private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: oski_corran (ALiVE 3 index v3.1, 2026-10-06)"] call ALiVE_fnc_dump;

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

ALiVE_mapCompositionType = "Woodland";

 if (tolower(_worldName) == "oski_corran") then {
    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "a3\props_f_enoch\civilian\camping\woodentable_02_large_f.p3d",
        "a3\props_f_enoch\civilian\forest\feedrack_01_f.p3d",
        "a3\props_f_enoch\infrastructure\traffic\roadbarrier_01_f.p3d",
        "a3\props_f_exp\industrial\heavyequipment\bulldozer_01_abandoned_f.p3d",
        "a3\props_f_exp\industrial\heavyequipment\combineharvester_01_wreck_f.p3d",
        "a3\props_f_exp\industrial\heavyequipment\excavator_01_abandoned_f.p3d",
        "a3\roads_f\decals\decal_white_line_f.p3d",
        "a3\structures_f_argo\commercial\billboards\billboard_02_carrental_f.p3d",
        "a3\structures_f_argo\commercial\billboards\billboard_02_chernarus_f.p3d",
        "a3\structures_f_argo\commercial\billboards\billboard_02_chevre2_f.p3d",
        "a3\structures_f_argo\commercial\billboards\billboard_02_monte_f.p3d",
        "a3\structures_f_argo\commercial\billboards\billboard_02_surreal_f.p3d",
        "a3\structures_f_argo\commercial\billboards\billboard_02_wine_f.p3d",
        "a3\structures_f_argo\commercial\billboards\billboard_03_action_f.p3d",
        "a3\structures_f_argo\commercial\billboards\billboard_03_koke_f.p3d",
        "a3\structures_f_argo\commercial\billboards\billboard_03_pills_f.p3d",
        "a3\structures_f_argo\cultural\statues\pedestal_01_f.p3d",
        "a3\structures_f_argo\cultural\statues\statue_01_f.p3d",
        "a3\structures_f_enoch\civilian\accessories\chickencoop_01_f.p3d",
        "a3\structures_f_enoch\civilian\accessories\hutch_01_f.p3d",
        "a3\structures_f_enoch\civilian\accessories\stonewell_01_f.p3d",
        "a3\structures_f_enoch\civilian\camps\caravan_01_green_f.p3d",
        "a3\structures_f_enoch\civilian\constructions\scaffolding_new_f.p3d",
        "a3\structures_f_enoch\cultural\castleruins\castleruins_01_wall_d_l_f.p3d",
        "a3\structures_f_enoch\cultural\castleruins\castleruins_01_wall_d_r_f.p3d",
        "a3\structures_f_enoch\cultural\cemeteries\grave_08_f.p3d",
        "a3\structures_f_enoch\cultural\cemeteries\grave_11_f.p3d",
        "a3\structures_f_enoch\cultural\cemeteries\tombstone_04_f.p3d",
        "a3\structures_f_enoch\cultural\cemeteries\tombstone_08_damaged_f.p3d",
        "a3\structures_f_enoch\cultural\cemeteries\tombstone_08_f.p3d",
        "a3\structures_f_enoch\cultural\cemeteries\tombstone_09_f.p3d",
        "a3\structures_f_enoch\cultural\cemeteries\tombstone_11_damaged_f.p3d",
        "a3\structures_f_enoch\cultural\cemeteries\tombstone_11_f.p3d",
        "a3\structures_f_enoch\cultural\cemeteries\tombstone_12_f.p3d",
        "a3\structures_f_enoch\cultural\cemeteries\tombstone_16_f.p3d",
        "a3\structures_f_enoch\cultural\cemeteries\tombstone_17_f.p3d",
        "a3\structures_f_enoch\furniture\school_equipment\long_bench.p3d",
        "a3\structures_f_enoch\furniture\various\workbench.p3d",
        "a3\structures_f_enoch\furniture\various\workbench_dz.p3d",
        "a3\structures_f_enoch\industrial\agriculture\feedstorage_01_f.p3d",
        "a3\structures_f_enoch\industrial\agriculture\feedstorage_01_ruins_f.p3d",
        "a3\structures_f_enoch\industrial\agriculture\haybale_01_decayed_f.p3d",
        "a3\structures_f_enoch\industrial\agriculture\haybale_01_f.p3d",
        "a3\structures_f_enoch\industrial\agriculture\haybale_01_packed_f.p3d",
        "a3\structures_f_enoch\industrial\agriculture\haybale_01_stack_f.p3d",
        "a3\structures_f_enoch\industrial\agriculture\manurepile_01_f.p3d",
        "a3\structures_f_enoch\industrial\agriculture\silagestorage_01_f.p3d",
        "a3\structures_f_enoch\industrial\agriculture\trough_01_f.p3d",
        "a3\structures_f_enoch\industrial\farms\strawstack_01_f.p3d",
        "a3\structures_f_enoch\industrial\materials\timberlog_01_f.p3d",
        "a3\structures_f_enoch\industrial\materials\timberlog_02_f.p3d",
        "a3\structures_f_enoch\industrial\materials\timberlog_03_f.p3d",
        "a3\structures_f_enoch\industrial\materials\timberlog_04_f.p3d",
        "a3\structures_f_enoch\industrial\materials\timberpile_02_f.p3d",
        "a3\structures_f_enoch\industrial\materials\timberpile_03_f.p3d",
        "a3\structures_f_enoch\industrial\materials\timberpile_04_f.p3d",
        "a3\structures_f_enoch\industrial\materials\timberpile_05_f.p3d",
        "a3\structures_f_enoch\industrial\materials\woodpile_02_f.p3d",
        "a3\structures_f_enoch\industrial\materials\woodpile_03_f.p3d",
        "a3\structures_f_enoch\industrial\materials\woodpile_04_f.p3d",
        "a3\structures_f_enoch\industrial\mines\mine_01_heap_f.p3d",
        "a3\structures_f_enoch\industrial\mines\mine_01_minecart_f.p3d",
        "a3\structures_f_enoch\industrial\pipes\indpipe3_small_9_f.p3d",
        "a3\structures_f_enoch\industrial\pipes\indpipe3_small_ground1_f.p3d",
        "a3\structures_f_enoch\industrial\pipes\indpipe3_smalll_r_f.p3d",
        "a3\structures_f_enoch\infrastructure\bridges\bridge_asphalt_02_center_f.p3d",
        "a3\structures_f_enoch\infrastructure\lamps\lampindustrial_02_f.p3d",
        "a3\structures_f_enoch\military\radar\radar_01_airshaft_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_small_04_f.p3d",
        "a3\structures_f_enoch\ruins\housewallruin_corner_01_f.p3d",
        "a3\structures_f_enoch\ruins\housewallruin_corner_02_f.p3d",
        "a3\structures_f_enoch\ruins\housewallruin_door_01_f.p3d",
        "a3\structures_f_enoch\walls\brick\brickwall_01_l_5m_f.p3d",
        "a3\structures_f_enoch\walls\brick\brickwall_01_l_end_f.p3d",
        "a3\structures_f_enoch\walls\brick\brickwall_01_l_pole_f.p3d",
        "a3\structures_f_enoch\walls\brick\brickwall_02_l_5m_f.p3d",
        "a3\structures_f_enoch\walls\brick\brickwall_02_l_corner_v1_f.p3d",
        "a3\structures_f_enoch\walls\brick\brickwall_03_l_5m_v2_d_f.p3d",
        "a3\structures_f_enoch\walls\brick\brickwall_03_l_5m_v2_f.p3d",
        "a3\structures_f_enoch\walls\brick\brickwall_03_l_gate_f.p3d",
        "a3\structures_f_enoch\walls\brick\brickwall_03_l_pole_f.p3d",
        "a3\structures_f_enoch\walls\brick\brickwall_04_l_pole_f.p3d",
        "a3\structures_f_enoch\walls\net\gameprooffence_01_l_5m_f.p3d",
        "a3\structures_f_enoch\walls\net\gameprooffence_01_l_d_f.p3d",
        "a3\structures_f_enoch\walls\net\gameprooffence_01_l_gate_f.p3d",
        "a3\structures_f_enoch\walls\net\gameprooffence_01_l_pole_f.p3d",
        "a3\structures_f_enoch\walls\net\netfence_03_m_3m_f.p3d",
        "a3\structures_f_enoch\walls\net\netfence_03_m_3m_hole_f.p3d",
        "a3\structures_f_enoch\walls\net\netfence_03_m_3m_hole_proxy_f.p3d",
        "a3\structures_f_enoch\walls\net\netfence_03_m_9m_f.p3d",
        "a3\structures_f_enoch\walls\net\netfence_03_m_pole_f.p3d",
        "a3\structures_f_enoch\walls\pipe\pipefence_03_m_gate_l_f.p3d",
        "a3\structures_f_enoch\walls\pipe\pipefence_03_m_gate_r_f.p3d",
        "a3\structures_f_enoch\walls\pipe\pipefence_04_m_gate_l_f.p3d",
        "a3\structures_f_enoch\walls\pipe\pipefence_04_m_gate_r_f.p3d",
        "a3\structures_f_enoch\walls\pipe\pipefence_05_m_gate_l_f.p3d",
        "a3\structures_f_enoch\walls\pipe\pipefence_05_m_gate_r_f.p3d",
        "a3\structures_f_enoch\walls\polewalls\polewall_02_3m_v1_f.p3d",
        "a3\structures_f_enoch\walls\polewalls\polewall_02_end_f.p3d",
        "a3\structures_f_enoch\walls\polewalls\polewall_03_5m_v1_f.p3d",
        "a3\structures_f_enoch\walls\polewalls\polewall_03_end_f.p3d",
        "a3\structures_f_enoch\walls\stone\mound03_8m_f.p3d",
        "a3\structures_f_enoch\walls\stone\mound04_8m_f.p3d",
        "a3\structures_f_enoch\walls\stone\stonewall_02_s_10m_f.p3d",
        "a3\structures_f_enoch\walls\wooden\woodenwall_03_s_5m_v1_f.p3d",
        "a3\structures_f_enoch\walls\wooden\woodenwall_03_s_5m_v2_f.p3d",
        "a3\structures_f_enoch\walls\wooden\woodenwall_03_s_d_5m_v1_f.p3d",
        "a3\structures_f_enoch\walls\wooden\woodenwall_03_s_d_5m_v2_f.p3d",
        "a3\structures_f_enoch\walls\wooden\woodenwall_03_s_gate_f.p3d",
        "a3\structures_f_enoch\walls\wooden\woodenwall_04_s_5m_f.p3d",
        "a3\structures_f_enoch\walls\wooden\woodenwall_04_s_d_5m_f.p3d",
        "a3\structures_f_enoch\walls\wooden\woodenwall_04_s_gate_f.p3d",
        "a3\structures_f_enoch\walls\wooden\woodenwall_04_s_pole_f.p3d",
        "a3\structures_f_enoch\walls\wooden\woodenwall_05_m_4m_v1_f.p3d",
        "a3\structures_f_enoch\walls\wooden\woodenwall_05_m_d_4m_f.p3d",
        "a3\structures_f_enoch\wrecks\trailercistern_wreck_f.p3d",
        "a3\structures_f_exp\civilian\accessories\clothesline_01_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_06_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_01\fuelstation_01_arrow_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_01\fuelstation_01_prices_f.p3d",
        "a3\structures_f_exp\cultural\ancientrelics\stonetanoa_01_f.p3d",
        "a3\structures_f_exp\cultural\basaltruins\basaltkerb_01_pile_f.p3d",
        "a3\structures_f_exp\cultural\basaltruins\basaltkerb_01_platform_f.p3d",
        "a3\structures_f_exp\industrial\stockyard_01\sy_01_stockpile_02_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_heap_sugarcane_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shelter_narrow_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shelter_wide_f.p3d",
        "a3\structures_f_exp\infrastructure\runways\runway_01_40m_skids_end_f.p3d",
        "a3\structures_f_exp\infrastructure\runways\runway_01_40m_skids_f.p3d",
        "a3\structures_f_exp\military\emplacements\emplacementgun_01_rusty_f.p3d",
        "a3\structures_f_exp\military\trenches\trench_01_grass_f.p3d",
        "a3\structures_f_exp\military\trenches\trenchframe_01_f.p3d",
        "a3\structures_f_exp\walls\crashbarriers\crashbarrier_01_8m_f.p3d",
        "a3\structures_f_exp\walls\crashbarriers\crashbarrier_01_end_l_f.p3d",
        "a3\structures_f_exp\walls\crashbarriers\crashbarrier_01_end_r_f.p3d",
        "a3\structures_f_exp\walls\hedges\hedge_01_s_2m_f.p3d",
        "a3\structures_f_exp\walls\hedges\hedge_01_s_4m_f.p3d",
        "a3\structures_f_exp\walls\net\netfence_02_m_2m_f.p3d",
        "a3\structures_f_exp\walls\net\netfence_02_m_4m_f.p3d",
        "a3\structures_f_exp\walls\net\netfence_02_m_8m_f.p3d",
        "a3\structures_f_exp\walls\net\netfence_02_m_gate_v1_f.p3d",
        "a3\structures_f_exp\walls\net\netfence_02_m_gate_v2_f.p3d",
        "a3\structures_f_exp\walls\net\netfence_02_m_pole_f.p3d",
        "a3\structures_f_exp\walls\pipe\pipefence_01_m_2m_f.p3d",
        "a3\structures_f_exp\walls\pipe\pipefence_01_m_4m_f.p3d",
        "a3\structures_f_exp\walls\pipe\pipefence_01_m_d_f.p3d",
        "a3\structures_f_exp\walls\pipe\pipefence_01_m_gate_v1_f.p3d",
        "a3\structures_f_exp\walls\pipe\pipefence_01_m_gate_v2_f.p3d",
        "a3\structures_f_exp\walls\pipe\pipefence_01_m_pole_f.p3d",
        "a3\structures_f_exp\walls\polewalls\polewall_01_6m_f.p3d",
        "a3\structures_f_exp\walls\polewalls\polewall_01_pole_f.p3d",
        "a3\structures_f_exp\walls\railings\guardrailing_01_f.p3d",
        "a3\structures_f_exp\walls\tin\tinwall_02_l_4m_f.p3d",
        "a3\structures_f_exp\walls\tin\tinwall_02_l_8m_f.p3d",
        "a3\structures_f_exp\walls\tin\tinwall_02_l_pole_f.p3d",
        "a3\structures_f_exp\walls\wired\wiredfence_01_4m_f.p3d",
        "a3\structures_f_exp\walls\wired\wiredfence_01_8m_d_f.p3d",
        "a3\structures_f_exp\walls\wired\wiredfence_01_8m_f.p3d",
        "a3\structures_f_exp\walls\wired\wiredfence_01_gate_f.p3d",
        "a3\structures_f_exp\walls\wired\wiredfence_01_pole_45_f.p3d",
        "a3\structures_f_exp\walls\wired\wiredfence_01_pole_f.p3d",
        "a3\structures_f_tank\military\fortifications\dragonsteeth_01_1x1_old_f.p3d",
        "ca\buildings2\a_advertisingcolumn\a_advertcolumn.p3d",
        "ca\buildings2\ind_shed_02\ind_shed_02_end.p3d",
        "ca\buildings2\ind_tank\ind_tanksmall.p3d",
        "ca\roads2\dam\dam_barrier_40\dam_barrier_40.p3d"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "a3\structures_f\mil\barracks\i_barracks_v2_f.p3d",
        "a3\structures_f\mil\offices\miloffices_v1_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garageoffice_01_f.p3d",
        "a3\structures_f_enoch\industrial\sawmills\sawmill_01_illuminati_tower_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_02_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_05_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_06_f.p3d",
        "a3\structures_f_enoch\military\barracks\guardbox_01_green_f.p3d",
        "a3\structures_f_enoch\military\barracks\guardbox_01_smooth_f.p3d",
        "a3\structures_f_enoch\military\barracks\guardhouse_02_grey_f.p3d",
        "a3\structures_f_enoch\military\barracks\guardhouse_03_f.p3d",
        "a3\structures_f_enoch\military\bunkers\bunker_02_right_f.p3d",
        "a3\structures_f_enoch\military\radar\radar_01_cooler_f.p3d",
        "a3\structures_f_enoch\military\radar\radar_01_hq_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shed_unfinished_f.p3d",
        "a3\structures_f_exp\military\emplacements\emplacementgun_01_d_mossy_f.p3d",
        "ca\structures\mil\mil_controltower.p3d",
        "ca\structures\mil\mil_house.p3d"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "a3\structures_f\mil\barracks\i_barracks_v2_f.p3d",
        "a3\structures_f\mil\offices\miloffices_v1_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garageoffice_01_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_02_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_05_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_06_f.p3d",
        "a3\structures_f_enoch\military\radar\radar_01_hq_f.p3d",
        "ca\structures\mil\mil_controltower.p3d",
        "ca\structures\mil\mil_house.p3d"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "a3\structures_f\mil\barracks\i_barracks_v2_f.p3d",
        "a3\structures_f\mil\offices\miloffices_v1_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garageoffice_01_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_02_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_05_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_06_f.p3d",
        "a3\structures_f_enoch\military\radar\radar_01_hq_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shed_unfinished_f.p3d",
        "ca\structures\mil\mil_controltower.p3d",
        "ca\structures\mil\mil_house.p3d"
    ];

    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        "a3\structures_f\mil\barracks\i_barracks_v2_f.p3d",
        "a3\structures_f\mil\offices\miloffices_v1_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_06_f.p3d",
        "a3\structures_f_enoch\military\radar\radar_01_hq_f.p3d",
        "ca\structures\mil\mil_controltower.p3d",
        "ca\structures\mil\mil_house.p3d"
    ];

    ALIVE_militaryFieldworkBuildingTypes = ALIVE_militaryFieldworkBuildingTypes + [
        "a3\structures_f_enoch\military\bunkers\bunker_02_right_f.p3d"
    ];

    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
        "a3\structures_f_exp\infrastructure\airports\airport_01_hangar_f.p3d"
    ];

    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [
        "a3\structures_f_exp\infrastructure\airports\airport_01_hangar_f.p3d"
    ];

    ALiVE_HeliBuildingTypes = ALiVE_HeliBuildingTypes + [
        "a3\structures_f\mil\helipads\helipadcircle_f.p3d"
    ];

    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
        "a3\structures_f\mil\helipads\helipadcircle_f.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "a3\props_f_enoch\civilian\forest\deerstand_01_f.p3d",
        "a3\props_f_enoch\civilian\forest\deerstand_02_f.p3d",
        "a3\props_f_enoch\civilian\forest\feedshack_01_f.p3d",
        "a3\structures_f\households\stone_big\i_stone_housebig_v1_f.p3d",
        "a3\structures_f\households\stone_big\i_stone_housebig_v3_dam_f.p3d",
        "a3\structures_f\households\stone_shed\i_stone_shed_v1_dam_f.p3d",
        "a3\structures_f\households\stone_shed\i_stone_shed_v1_f.p3d",
        "a3\structures_f\households\stone_small\i_stone_housesmall_v1_dam_f.p3d",
        "a3\structures_f\households\stone_small\i_stone_housesmall_v1_f.p3d",
        "a3\structures_f\households\wip\unfinished_building_01_f.p3d",
        "a3\structures_f\households\wip\unfinished_building_02_f.p3d",
        "a3\structures_f_argo\industrial\agriculture\barn_01_brown_f.p3d",
        "a3\structures_f_argo\industrial\agriculture\barn_01_grey_f.p3d",
        "a3\structures_f_argo\industrial\agriculture\shed_08_grey_f.p3d",
        "a3\structures_f_enoch\civilian\camps\camp_house_01_brown_f.p3d",
        "a3\structures_f_enoch\civilian\camps\caravan_01_rust_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1b01_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w03_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w04_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w07_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w08_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w10_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w12_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w13_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2b01_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2b03_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2b04_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w01_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w02_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w05_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_09_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_10_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_11_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_12_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_13_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_14_f.p3d",
        "a3\structures_f_enoch\commercial\villagestore_01\villagestore_01_f.p3d",
        "a3\structures_f_enoch\cultural\castleruins\castleruins_01_bastion_f.p3d",
        "a3\structures_f_enoch\cultural\chapel_02\chapel_02_white_f.p3d",
        "a3\structures_f_enoch\cultural\church_04\church_04_white_red_damaged_f.p3d",
        "a3\structures_f_enoch\industrial\cementworks\cementworks_01_grey_f.p3d",
        "a3\structures_f_enoch\industrial\dieselpowerplant_01\dp_bigtank_old_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_02_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_03_large_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_03_small_f.p3d",
        "a3\structures_f_enoch\industrial\farms\cowshed_01_a_f.p3d",
        "a3\structures_f_enoch\industrial\farms\cowshed_01_b_f.p3d",
        "a3\structures_f_enoch\industrial\farms\cowshed_01_c_f.p3d",
        "a3\structures_f_enoch\industrial\farms\greenhouse_01_damaged_f.p3d",
        "a3\structures_f_enoch\industrial\farms\greenhouse_01_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garageoffice_01_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garagerow_01_large_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garagerow_01_small_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_01_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_01_grey_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_02_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_02_grey_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_03_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_03_grey_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_04_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_04_grey_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_05_f.p3d",
        "a3\structures_f_enoch\industrial\sawmills\sawmill_01_f.p3d",
        "a3\structures_f_enoch\industrial\sheds\industrialshed_01_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_big_01_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_big_01_half_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_small_01_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_small_01_half_f.p3d",
        "a3\structures_f_exp\civilian\garages\garageshelter_01_f.p3d",
        "a3\structures_f_exp\civilian\house_small_02\house_small_02_f.p3d",
        "a3\structures_f_exp\civilian\house_small_05\house_small_05_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_01_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_02_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_03_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_05_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_07_f.p3d",
        "a3\structures_f_exp\civilian\slum_01\slum_01_f.p3d",
        "a3\structures_f_exp\civilian\slum_02\slum_02_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_01\fuelstation_01_shop_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_01\fuelstation_01_workshop_f.p3d",
        "a3\structures_f_exp\commercial\supermarket_01\supermarket_01_f.p3d",
        "a3\structures_f_exp\commercial\warehouses\warehouse_03_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shed_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shed_unfinished_f.p3d",
        "ca\buildings\bouda2_vnitrek.p3d",
        "ca\buildings\deutshe_mini.p3d",
        "ca\buildings\dulni_bs.p3d",
        "ca\buildings\dum_mesto2.p3d",
        "ca\buildings\dum_mesto_in.p3d",
        "ca\buildings\dum_rasovna.p3d",
        "ca\buildings\hut_old02.p3d",
        "ca\buildings\sara_domek_sedy.p3d",
        "ca\buildings\sara_domek_zluty.p3d",
        "ca\buildings\sara_hasic_zbroj.p3d",
        "ca\buildings\sara_stodola.p3d",
        "ca\buildings\sara_stodola2.p3d",
        "ca\buildings\sara_zluty_statek_in.p3d"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "a3\structures_f_enoch\civilian\houses\house_2b03_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2b04_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w05_f.p3d",
        "ca\buildings\dum_mesto_in.p3d"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "a3\structures_f\households\stone_big\i_stone_housebig_v1_f.p3d",
        "a3\structures_f\households\stone_big\i_stone_housebig_v3_dam_f.p3d",
        "a3\structures_f\households\stone_shed\i_stone_shed_v1_f.p3d",
        "a3\structures_f\households\stone_small\i_stone_housesmall_v1_dam_f.p3d",
        "a3\structures_f\households\stone_small\i_stone_housesmall_v1_f.p3d",
        "a3\structures_f\households\wip\unfinished_building_01_f.p3d",
        "a3\structures_f_argo\industrial\agriculture\barn_01_brown_f.p3d",
        "a3\structures_f_argo\industrial\agriculture\barn_01_grey_f.p3d",
        "a3\structures_f_enoch\civilian\camps\camp_house_01_brown_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1b01_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w03_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w04_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w07_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w08_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w10_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w12_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w13_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2b01_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2b03_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2b04_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w01_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w02_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w05_f.p3d",
        "a3\structures_f_enoch\commercial\villagestore_01\villagestore_01_f.p3d",
        "a3\structures_f_enoch\industrial\cementworks\cementworks_01_grey_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garageoffice_01_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garagerow_01_large_f.p3d",
        "a3\structures_f_enoch\industrial\sawmills\sawmill_01_f.p3d",
        "a3\structures_f_exp\civilian\house_small_02\house_small_02_f.p3d",
        "a3\structures_f_exp\civilian\house_small_05\house_small_05_f.p3d",
        "a3\structures_f_exp\civilian\slum_01\slum_01_f.p3d",
        "a3\structures_f_exp\civilian\slum_02\slum_02_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_01\fuelstation_01_shop_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_01\fuelstation_01_workshop_f.p3d",
        "a3\structures_f_exp\commercial\supermarket_01\supermarket_01_f.p3d",
        "a3\structures_f_exp\commercial\warehouses\warehouse_03_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shed_f.p3d",
        "ca\buildings\bouda2_vnitrek.p3d",
        "ca\buildings\deutshe_mini.p3d",
        "ca\buildings\dum_mesto_in.p3d",
        "ca\buildings\dum_rasovna.p3d",
        "ca\buildings\sara_domek_sedy.p3d",
        "ca\buildings\sara_domek_zluty.p3d",
        "ca\buildings\sara_stodola.p3d",
        "ca\buildings\sara_stodola2.p3d",
        "ca\buildings\sara_zluty_statek_in.p3d"
    ];

    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
        "a3\structures_f_enoch\industrial\houses\waterstation_01_f.p3d",
        "a3\structures_f_enoch\industrial\power\powerstation_01_f.p3d"
    ];

    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
        "a3\structures_f\ind\transmitter_tower\tbox_f.p3d",
        "a3\structures_f\ind\transmitter_tower\ttowerbig_1_f.p3d",
        "a3\structures_f\ind\transmitter_tower\ttowerbig_2_f.p3d",
        "a3\structures_f\ind\transmitter_tower\ttowersmall_1_f.p3d",
        "a3\structures_f\ind\transmitter_tower\ttowersmall_2_f.p3d"
    ];

    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        "a3\structures_f\dominants\lighthouse\lighthouse_f.p3d",
        "a3\structures_f\naval\piers\pier_f.p3d",
        "a3\structures_f\naval\piers\pier_small_f.p3d",
        "a3\structures_f_exp\naval\piers\pierwooden_01_10m_norails_f.p3d",
        "a3\structures_f_exp\naval\piers\pierwooden_01_hut_f.p3d"
    ];

    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        "a3\structures_f_enoch\industrial\dieselpowerplant_01\dp_bigtank_old_f.p3d",
        "a3\structures_f_enoch\industrial\dieselpowerplant_01\dp_smalltank_old_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_01\fuelstation_01_pump_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_01\fuelstation_01_roof_f.p3d"
    ];

    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
        "a3\structures_f_enoch\industrial\cementworks\cementworks_01_grey_f.p3d",
        "a3\structures_f_enoch\industrial\sawmills\sawmill_01_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_heap_bagasse_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shed_unfinished_f.p3d"
    ];

};
