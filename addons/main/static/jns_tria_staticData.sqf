// ALiVE 3 index v3.1, made 2026-10-10 by the ALiVE web indexer, building positions measured
private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: jns_tria (ALiVE 3 index v3.1, 2026-10-10)"] call ALiVE_fnc_dump;

ALiVE_indexVersion = ["3.1", "2026-10-10", "web", true];

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

 if (tolower(_worldName) == "jns_tria") then {
    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "a3\props_f_enoch\civilian\camping\woodentable_02_large_f.p3d",
        "a3\props_f_enoch\civilian\forest\anthill_01_f.p3d",
        "a3\props_f_enoch\civilian\forest\bark_beetle_trap_03_f.p3d",
        "a3\props_f_enoch\civilian\forest\deerskeleton_damaged_01_f.p3d",
        "a3\props_f_enoch\civilian\forest\deerskeleton_full_01_f.p3d",
        "a3\props_f_enoch\civilian\forest\deerskeleton_pile_01_f.p3d",
        "a3\props_f_enoch\industrial\supplies\woodenbox_02_f.p3d",
        "a3\props_f_enoch\infrastructure\traffic\roadbarrier_01_f.p3d",
        "a3\props_f_enoch\military\decontamination\deconshower_01_f.p3d",
        "a3\props_f_enoch\military\decontamination\layflathose_01_curveshort_f.p3d",
        "a3\props_f_enoch\military\decontamination\layflathose_01_sbend_f.p3d",
        "a3\props_f_enoch\military\decontamination\layflathose_01_straightshort_f.p3d",
        "a3\props_f_enoch\military\wrecks\heli_light_02_wreck_01_f.p3d",
        "a3\props_f_enoch\military\wrecks\heli_light_02_wreck_02_f.p3d",
        "a3\props_f_enoch\military\wrecks\heli_light_02_wreck_03_f.p3d",
        "a3\props_f_enoch\military\wrecks\heli_light_02_wreck_04_f.p3d",
        "a3\props_f_exp\industrial\heavyequipment\bulldozer_01_abandoned_f.p3d",
        "a3\props_f_exp\industrial\heavyequipment\bulldozer_01_wreck_f.p3d",
        "a3\props_f_exp\industrial\heavyequipment\excavator_01_abandoned_f.p3d",
        "a3\props_f_exp\industrial\heavyequipment\excavator_01_wreck_f.p3d",
        "a3\props_f_exp\infrastructure\railways\railwaycar_01_passenger_f.p3d",
        "a3\props_f_exp\infrastructure\railways\railwaycar_01_tank_f.p3d",
        "a3\props_f_exp\naval\boats\boat_05_wreck_f.p3d",
        "a3\structures_f\civ\accessories\timbers_f.p3d",
        "a3\structures_f\ind\cargo\cargo40_color_v3_ruins_f.p3d",
        "a3\structures_f\ind\shed\shed_big_f.p3d",
        "a3\structures_f_argo\commercial\billboards\billboard_02_redstone_f.p3d",
        "a3\structures_f_argo\decals\horizontal\roadcrack_01_4x4_f.p3d",
        "a3\structures_f_argo\decals\horizontal\roadcrack_01_6x2_f.p3d",
        "a3\structures_f_argo\industrial\materials\woodenplanks_01_pine_f.p3d",
        "a3\structures_f_argo\military\fortifications\barricade_01_10m_f.p3d",
        "a3\structures_f_argo\military\fortifications\barricade_01_4m_f.p3d",
        "a3\structures_f_argo\walls\city\wallcity_01_4m_grey_f.p3d",
        "a3\structures_f_argo\walls\city\wallcity_01_8m_dmg_grey_f.p3d",
        "a3\structures_f_argo\walls\city\wallcity_01_8m_grey_f.p3d",
        "a3\structures_f_argo\walls\city\wallcity_01_gate_grey_f.p3d",
        "a3\structures_f_argo\walls\city\wallcity_01_pillar_grey_f.p3d",
        "a3\structures_f_argo\walls\military\mil_wallbig_debris_f.p3d",
        "a3\structures_f_enoch\civilian\accessories\chickencoop_01_f.p3d",
        "a3\structures_f_enoch\civilian\accessories\hutch_01_f.p3d",
        "a3\structures_f_enoch\civilian\camps\caravan_01_green_f.p3d",
        "a3\structures_f_enoch\civilian\constructions\scaffolding_new_f.p3d",
        "a3\structures_f_enoch\commercial\fuelstation_03\fuelstation_03_prices_f.p3d",
        "a3\structures_f_enoch\commercial\fuelstation_03\fuelstation_03_pump_f.p3d",
        "a3\structures_f_enoch\cultural\calvary_03\calvary_03_f.p3d",
        "a3\structures_f_enoch\cultural\cemeteries\grave_08_f.p3d",
        "a3\structures_f_enoch\cultural\cemeteries\grave_09_f.p3d",
        "a3\structures_f_enoch\cultural\cemeteries\grave_10_f.p3d",
        "a3\structures_f_enoch\cultural\cemeteries\grave_11_f.p3d",
        "a3\structures_f_enoch\cultural\cemeteries\gravefence_01_f.p3d",
        "a3\structures_f_enoch\cultural\cemeteries\gravefence_02_f.p3d",
        "a3\structures_f_enoch\cultural\cemeteries\gravefence_03_f.p3d",
        "a3\structures_f_enoch\cultural\cemeteries\gravefence_04_f.p3d",
        "a3\structures_f_enoch\cultural\cemeteries\tombstone_05_f.p3d",
        "a3\structures_f_enoch\cultural\cemeteries\tombstone_06_f.p3d",
        "a3\structures_f_enoch\cultural\cemeteries\tombstone_12_f.p3d",
        "a3\structures_f_enoch\cultural\cemeteries\tombstone_13_f.p3d",
        "a3\structures_f_enoch\cultural\cemeteries\tombstone_14_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\decal_damage_long_01_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\decal_damage_long_02_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\decal_damage_long_03_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\decal_damage_long_04_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\decal_damage_medium1_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\dirt_road_damage_long_01_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\dirt_road_damage_long_02_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\dirt_road_damage_long_03_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\dirt_road_damage_long_04_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\dirt_road_damage_long_05_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\dirtpatch_05_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\roads_ars_01_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\roads_ars_02_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\roads_ars_03_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\roads_ars_04_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\roads_ars_05_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\roads_ars_06_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\roads_cracks_01_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\roads_cracks_02_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\roads_cracks_03_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\roads_cracks_04_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\roads_cracks_05_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\roads_patch_01_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\roads_patch_02_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\roads_patch_03_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\roads_patch_04_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\roads_patch_05_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\roads_patch_06_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\roads_patch_07_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\roads_patch_08_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\roads_patch_09_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\roads_patch_10_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\roads_patch_11_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\roads_patch_12_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\vehicletrack_01_left_crossing_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\vehicletrack_01_left_v1_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\vehicletrack_01_left_v2_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\vehicletrack_01_right_crossing_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\vehicletrack_01_straight_end_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\vehicletrack_01_straight_start_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\vehicletrack_01_straight_v1_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\vehicletrack_01_straight_v2_f.p3d",
        "a3\structures_f_enoch\furniture\school_equipment\yellow_star.p3d",
        "a3\structures_f_enoch\furniture\various\debris_small_house.p3d",
        "a3\structures_f_enoch\furniture\various\dirtpile_small_house.p3d",
        "a3\structures_f_enoch\industrial\agriculture\drainage_01_f.p3d",
        "a3\structures_f_enoch\industrial\agriculture\feedstorage_01_f.p3d",
        "a3\structures_f_enoch\industrial\agriculture\feedstorage_01_ruins_f.p3d",
        "a3\structures_f_enoch\industrial\agriculture\manurepile_01_f.p3d",
        "a3\structures_f_enoch\industrial\agriculture\silagestorage_01_f.p3d",
        "a3\structures_f_enoch\industrial\farms\watertower_02_f.p3d",
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
        "a3\structures_f_enoch\industrial\mines\mine_01_heap_f.p3d",
        "a3\structures_f_enoch\industrial\mines\mine_01_hopper_silo_f.p3d",
        "a3\structures_f_enoch\industrial\mines\mine_01_minecart_f.p3d",
        "a3\structures_f_enoch\industrial\mines\mine_01_rail_track_end_f.p3d",
        "a3\structures_f_enoch\industrial\power\powerstation_01_ruins_f.p3d",
        "a3\structures_f_enoch\industrial\power\substation_01_ruins_f.p3d",
        "a3\structures_f_enoch\industrial\smokestacks\smokestack_03_ruins_f.p3d",
        "a3\structures_f_enoch\infrastructure\lamps\lampindustrial_01_f.p3d",
        "a3\structures_f_enoch\infrastructure\roads\cobblestonesquare_01_2m_f.p3d",
        "a3\structures_f_enoch\infrastructure\roads\cobblestonesquare_01_32m_f.p3d",
        "a3\structures_f_enoch\infrastructure\roads\cobblestonesquare_01_4m_f.p3d",
        "a3\structures_f_enoch\infrastructure\roads\cobblestonesquare_01_8m_f.p3d",
        "a3\structures_f_enoch\infrastructure\roads\cobblestonesquare_01_edge_2m_v2_f.p3d",
        "a3\structures_f_enoch\infrastructure\roads\cobblestonesquare_01_edge_32m_v1_f.p3d",
        "a3\structures_f_enoch\infrastructure\roads\cobblestonesquare_01_edge_4m_v1_f.p3d",
        "a3\structures_f_enoch\infrastructure\roads\cobblestonesquare_01_edge_4m_v2_f.p3d",
        "a3\structures_f_enoch\infrastructure\roads\cobblestonesquare_01_edge_8m_v2_f.p3d",
        "a3\structures_f_enoch\military\radar\radar_01_airshaft_f.p3d",
        "a3\structures_f_enoch\military\training\craterlong_02_f.p3d",
        "a3\structures_f_enoch\military\training\shellcrater_01_f.p3d",
        "a3\structures_f_enoch\military\training\shellcrater_02_debris_f.p3d",
        "a3\structures_f_enoch\military\training\shellcrater_02_extralarge_f.p3d",
        "a3\structures_f_enoch\military\training\shellcrater_02_small_f.p3d",
        "a3\structures_f_enoch\military\training\shootingpos_roof_01_f.p3d",
        "a3\structures_f_enoch\military\training\target_line_01_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_small_03_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_small_04_f.p3d",
        "a3\structures_f_enoch\ruins\housewallruin_corner_01_f.p3d",
        "a3\structures_f_enoch\ruins\housewallruin_corner_02_f.p3d",
        "a3\structures_f_enoch\ruins\housewallruin_door_01_f.p3d",
        "a3\structures_f_enoch\walls\brick\brickwall_03_l_5m_v1_d_f.p3d",
        "a3\structures_f_enoch\walls\brick\brickwall_03_l_5m_v1_f.p3d",
        "a3\structures_f_enoch\walls\brick\brickwall_03_l_5m_v2_d_f.p3d",
        "a3\structures_f_enoch\walls\brick\brickwall_03_l_gate_f.p3d",
        "a3\structures_f_enoch\walls\brick\brickwall_03_l_pole_f.p3d",
        "a3\structures_f_enoch\walls\brick\brickwall_04_l_5m_old_f.p3d",
        "a3\structures_f_enoch\walls\brick\brickwall_04_l_pole_f.p3d",
        "a3\structures_f_enoch\walls\net\gameprooffence_01_l_5m_f.p3d",
        "a3\structures_f_enoch\walls\net\gameprooffence_01_l_d_f.p3d",
        "a3\structures_f_enoch\walls\net\gameprooffence_01_l_gate_f.p3d",
        "a3\structures_f_enoch\walls\net\netfence_03_m_3m_corner_f.p3d",
        "a3\structures_f_enoch\walls\net\netfence_03_m_3m_d_f.p3d",
        "a3\structures_f_enoch\walls\net\netfence_03_m_3m_f.p3d",
        "a3\structures_f_enoch\walls\net\netfence_03_m_9m_f.p3d",
        "a3\structures_f_enoch\walls\net\netfence_03_m_pole_f.p3d",
        "a3\structures_f_enoch\walls\pipe\pipefence_03_m_gate_l_f.p3d",
        "a3\structures_f_enoch\walls\pipe\pipefence_03_m_gate_r_f.p3d",
        "a3\structures_f_enoch\walls\stone\mound03_8m_f.p3d",
        "a3\structures_f_enoch\walls\stone\stonewall_02_s_10m_f.p3d",
        "a3\structures_f_enoch\walls\wooden\woodenwall_04_s_5m_f.p3d",
        "a3\structures_f_enoch\walls\wooden\woodenwall_04_s_d_5m_f.p3d",
        "a3\structures_f_enoch\walls\wooden\woodenwall_04_s_end_v1_f.p3d",
        "a3\structures_f_enoch\walls\wooden\woodenwall_04_s_gate_f.p3d",
        "a3\structures_f_enoch\walls\wooden\woodenwall_04_s_pole_f.p3d",
        "a3\structures_f_enoch\wrecks\mi8_wreck_f.p3d",
        "a3\structures_f_enoch\wrecks\powergenerator_wreck_f.p3d",
        "a3\structures_f_enoch\wrecks\trailercistern_wreck_f.p3d",
        "a3\structures_f_enoch\wrecks\v3s_wreck_f.p3d",
        "a3\structures_f_exp\civilian\accessories\clothesline_01_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_06_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_01\fuelstation_01_arrow_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_pipe_24m_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_pipe_24m_high_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_pipe_8m_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_pipe_8m_high_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_pipe_curve_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_pipe_curve_high_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_pipe_end_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_pipe_up_f.p3d",
        "a3\structures_f_exp\infrastructure\bridges\bridgewooden_01_f.p3d",
        "a3\structures_f_exp\infrastructure\bridges\bridgewooden_01_pillar_f.p3d",
        "a3\structures_f_exp\infrastructure\railways\track_01_15deg_f.p3d",
        "a3\structures_f_exp\infrastructure\railways\track_01_30deg_f.p3d",
        "a3\structures_f_exp\infrastructure\railways\track_01_7deg_f.p3d",
        "a3\structures_f_exp\infrastructure\railways\track_01_bumper_f.p3d",
        "a3\structures_f_exp\naval\piers\pierwooden_03_f.p3d",
        "a3\structures_f_exp\walls\net\netfence_02_m_gate_v1_f.p3d",
        "a3\structures_f_exp\walls\slum\slumwall_01_s_2m_f.p3d",
        "a3\structures_f_exp\walls\tin\tinwall_01_m_4m_v1_f.p3d",
        "a3\structures_f_exp\walls\tin\tinwall_01_m_4m_v2_f.p3d",
        "a3\structures_f_heli\civ\constructions\mobilescafolding_01_f.p3d",
        "a3\structures_f_heli\ind\cargo\cargo10_cyan_f.p3d",
        "a3\structures_f_heli\ind\machines\dieselgroundpowerunit_01_f.p3d",
        "a3\structures_f_heli\ind\machines\pressurewasher_01_f.p3d",
        "a3\structures_f_heli\ind\machines\waterpump_01_f.p3d",
        "a3\structures_f_orange\walls\plastic\plasticnetfence_01_long_d_f.p3d",
        "a3\structures_f_orange\walls\plastic\plasticnetfence_01_long_f.p3d",
        "a3\structures_f_orange\walls\plastic\plasticnetfence_01_roll_f.p3d",
        "a3\structures_f_tank\decals\horizontal\dirtpatch_02_f.p3d",
        "a3\structures_f_tank\military\fortifications\dragonsteeth_01_4x2_old_f.p3d",
        "jns_tria_obj\billboards\billboard_tria_01.p3d",
        "jns_tria_obj\billboards\billboard_tria_02.p3d",
        "jns_tria_obj\ind_oil_mine\jns_ind_oil_pump_ep1.p3d"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "a3\structures_f\mil\cargo\cargo_house_v1_ruins_f.p3d",
        "a3\structures_f\mil\cargo\cargo_hq_v1_ruins_f.p3d",
        "a3\structures_f\mil\offices\miloffices_v1_f.p3d",
        "a3\structures_f_enoch\civilian\police\policestation_01_f.p3d",
        "a3\structures_f_enoch\civilian\police\policestation_01_ruins_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_04_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garageoffice_01_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garageoffice_01_ruins_f.p3d",
        "a3\structures_f_enoch\industrial\sawmills\sawmill_01_illuminati_tower_f.p3d",
        "a3\structures_f_enoch\military\airfield\controltower_02_f.p3d",
        "a3\structures_f_enoch\military\airfield\controltower_02_ruins_f.p3d",
        "a3\structures_f_enoch\military\airfield\servicehangar_01_l_f.p3d",
        "a3\structures_f_enoch\military\airfield\servicehangar_01_r_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_03_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_04_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_05_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_06_f.p3d",
        "a3\structures_f_enoch\military\barracks\controltower_01_f.p3d",
        "a3\structures_f_enoch\military\barracks\controltower_01_ruins_f.p3d",
        "a3\structures_f_enoch\military\barracks\guardbox_01_brown_f.p3d",
        "a3\structures_f_enoch\military\barracks\guardbox_01_brown_ruins_f.p3d",
        "a3\structures_f_enoch\military\barracks\guardhouse_02_f.p3d",
        "a3\structures_f_enoch\military\barracks\guardhouse_02_grey_f.p3d",
        "a3\structures_f_enoch\military\barracks\guardhouse_03_f.p3d",
        "a3\structures_f_enoch\military\barracks\guardtower_02_f.p3d",
        "a3\structures_f_enoch\military\radar\mobileradar_01_radar_ruins_f.p3d",
        "a3\structures_f_enoch\military\radar\radar_01_cooler_f.p3d",
        "a3\structures_f_enoch\military\radar\radar_01_hq_f.p3d",
        "a3\structures_f_enoch\military\radar\radar_01_kitchen_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shed_unfinished_f.p3d"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "a3\structures_f\mil\offices\miloffices_v1_f.p3d",
        "a3\structures_f_enoch\civilian\police\policestation_01_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_04_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garageoffice_01_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_05_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_06_f.p3d",
        "a3\structures_f_enoch\military\radar\radar_01_hq_f.p3d"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "a3\structures_f\mil\offices\miloffices_v1_f.p3d",
        "a3\structures_f_enoch\civilian\police\policestation_01_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_04_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garageoffice_01_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_05_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_06_f.p3d",
        "a3\structures_f_enoch\military\radar\radar_01_hq_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shed_unfinished_f.p3d"
    ];

    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        "a3\structures_f\mil\offices\miloffices_v1_f.p3d",
        "a3\structures_f_enoch\civilian\police\policestation_01_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_06_f.p3d",
        "a3\structures_f_enoch\military\radar\radar_01_hq_f.p3d"
    ];

    ALIVE_militaryFieldworkBuildingTypes = ALIVE_militaryFieldworkBuildingTypes + [
        "a3\structures_f_enoch\military\barracks\guardtower_02_f.p3d"
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
        "a3\structures_f\mil\helipads\helipadcivil_f.p3d",
        "a3\structures_f\mil\helipads\helipadsquare_f.p3d"
    ];

    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
        "a3\structures_f\mil\helipads\helipadcivil_f.p3d",
        "a3\structures_f\mil\helipads\helipadsquare_f.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "a3\props_f_enoch\civilian\forest\deerstand_01_f.p3d",
        "a3\props_f_enoch\civilian\forest\deerstand_02_f.p3d",
        "a3\structures_f\households\addons\i_garage_v2_f.p3d",
        "a3\structures_f\households\house_small03\i_house_small_03_v1_f.p3d",
        "a3\structures_f\households\slum\cargo_house_slum_f.p3d",
        "a3\structures_f\households\slum\slum_house01_f.p3d",
        "a3\structures_f\households\slum\slum_house02_f.p3d",
        "a3\structures_f\households\slum\slum_house03_f.p3d",
        "a3\structures_f\households\wip\unfinished_building_01_f.p3d",
        "a3\structures_f\ind\shed\i_shed_ind_f.p3d",
        "a3\structures_f_argo\industrial\agriculture\barn_01_brown_ruins_f.p3d",
        "a3\structures_f_argo\industrial\agriculture\barn_01_grey_ruins_f.p3d",
        "a3\structures_f_enoch\civilian\camps\camp_house_01_brown_f.p3d",
        "a3\structures_f_enoch\civilian\camps\camp_house_01_brown_ruins_f.p3d",
        "a3\structures_f_enoch\civilian\camps\caravan_01_rust_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1b01_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1b01_ruins_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w07_ruins_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w08_ruins_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w11_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w13_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w04_ruins_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w05_f.p3d",
        "a3\structures_f_enoch\civilian\medical\healthcenter_01_f.p3d",
        "a3\structures_f_enoch\civilian\police\policestation_01_f.p3d",
        "a3\structures_f_enoch\civilian\police\policestation_01_ruins_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_12_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_14_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_14_ruins_f.p3d",
        "a3\structures_f_enoch\commercial\fuelstation_03\fuelstation_03_roof_ruins_f.p3d",
        "a3\structures_f_enoch\commercial\fuelstation_03\fuelstation_03_shop_f.p3d",
        "a3\structures_f_enoch\commercial\villagestore_01\villagestore_01_ruins_f.p3d",
        "a3\structures_f_enoch\cultural\chapel_01\chapel_01_f.p3d",
        "a3\structures_f_enoch\cultural\chapel_02\chapel_02_white_ruins_f.p3d",
        "a3\structures_f_enoch\cultural\chapel_02\chapel_02_yellow_ruins_f.p3d",
        "a3\structures_f_enoch\cultural\church_05\church_05_f.p3d",
        "a3\structures_f_enoch\cultural\orthodoxchurches\orthodoxchurch_03_ruins_f.p3d",
        "a3\structures_f_enoch\industrial\cementworks\cementworks_01_brick_f.p3d",
        "a3\structures_f_enoch\industrial\coalplant_01\coalplant_01_loadinghouse_f.p3d",
        "a3\structures_f_enoch\industrial\coalplant_01\coalplant_01_mainbuilding_f.p3d",
        "a3\structures_f_enoch\industrial\dieselpowerplant_01\dp_bigtank_old_ruins_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_03_large_ruins_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_04_f.p3d",
        "a3\structures_f_enoch\industrial\farms\greenhouse_01_damaged_f.p3d",
        "a3\structures_f_enoch\industrial\farms\greenhouse_01_f.p3d",
        "a3\structures_f_enoch\industrial\farms\greenhouse_01_ruins_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garageoffice_01_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garageoffice_01_ruins_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garagerow_01_large_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garagerow_01_small_f.p3d",
        "a3\structures_f_enoch\industrial\houses\factory_02_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_01_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_01_ruins_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_02_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_02_ruins_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_03_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_03_grey_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_04_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_05_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_05_grey_f.p3d",
        "a3\structures_f_enoch\industrial\mines\mine_01_warehouse_f.p3d",
        "a3\structures_f_enoch\industrial\sawmills\sawmill_01_f.p3d",
        "a3\structures_f_enoch\industrial\sheds\i_shed_ind_old_f.p3d",
        "a3\structures_f_enoch\industrial\sheds\industrialshed_01_f.p3d",
        "a3\structures_f_enoch\infrastructure\railways\rail_warehouse_small_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_big_01_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_big_01_half_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_big_02_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_big_02_half_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_big_03_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_big_03_half_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_small_01_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_small_01_half_f.p3d",
        "a3\structures_f_enoch\ruins\houseruin_small_02_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_07_f.p3d",
        "a3\structures_f_exp\civilian\slum_01\slum_01_f.p3d",
        "a3\structures_f_exp\civilian\slum_01\slum_01_ruins_f.p3d",
        "a3\structures_f_exp\civilian\slum_02\slum_02_f.p3d",
        "a3\structures_f_exp\civilian\slum_02\slum_02_ruins_f.p3d",
        "a3\structures_f_exp\civilian\slum_03\slum_03_f.p3d",
        "a3\structures_f_exp\civilian\slum_03\slum_03_ruins_f.p3d",
        "a3\structures_f_exp\civilian\slum_04\slum_04_f.p3d",
        "a3\structures_f_exp\civilian\slum_04\slum_04_ruins_f.p3d",
        "a3\structures_f_exp\civilian\slum_05\slum_05_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shed_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shed_unfinished_f.p3d"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "a3\structures_f_enoch\civilian\houses\house_2w05_f.p3d",
        "a3\structures_f_enoch\civilian\police\policestation_01_f.p3d"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "a3\structures_f\households\house_small03\i_house_small_03_v1_f.p3d",
        "a3\structures_f\households\slum\cargo_house_slum_f.p3d",
        "a3\structures_f\households\slum\slum_house01_f.p3d",
        "a3\structures_f\households\slum\slum_house02_f.p3d",
        "a3\structures_f\households\slum\slum_house03_f.p3d",
        "a3\structures_f\households\wip\unfinished_building_01_f.p3d",
        "a3\structures_f_enoch\civilian\camps\camp_house_01_brown_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1b01_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w11_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w13_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w05_f.p3d",
        "a3\structures_f_enoch\civilian\medical\healthcenter_01_f.p3d",
        "a3\structures_f_enoch\civilian\police\policestation_01_f.p3d",
        "a3\structures_f_enoch\commercial\fuelstation_03\fuelstation_03_shop_f.p3d",
        "a3\structures_f_enoch\cultural\church_05\church_05_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garageoffice_01_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garagerow_01_large_f.p3d",
        "a3\structures_f_enoch\industrial\sawmills\sawmill_01_f.p3d",
        "a3\structures_f_exp\civilian\slum_01\slum_01_f.p3d",
        "a3\structures_f_exp\civilian\slum_02\slum_02_f.p3d",
        "a3\structures_f_exp\civilian\slum_03\slum_03_f.p3d",
        "a3\structures_f_exp\civilian\slum_05\slum_05_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shed_f.p3d"
    ];

    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
        "a3\structures_f_enoch\industrial\houses\waterstation_01_f.p3d",
        "a3\structures_f_enoch\military\radar\mobileradar_01_generator_f.p3d"
    ];

    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        "a3\structures_f_exp\industrial\port\containerline_03_f.p3d",
        "a3\structures_f_exp\industrial\port\mobilecrane_01_f.p3d",
        "a3\structures_f_exp\naval\piers\pierwooden_02_16m_f.p3d",
        "a3\structures_f_exp\naval\piers\pierwooden_02_30deg_f.p3d"
    ];

    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
        "a3\props_f_exp\infrastructure\railways\locomotive_01_v1_f.p3d",
        "a3\props_f_exp\infrastructure\railways\locomotive_01_v3_f.p3d",
        "a3\props_f_exp\infrastructure\railways\railwaycar_01_sugarcane_empty_f.p3d",
        "a3\props_f_exp\infrastructure\railways\railwaycar_01_sugarcane_f.p3d",
        "a3\structures_f_exp\infrastructure\railways\track_01_bridge_f.p3d"
    ];

    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        "a3\structures_f\ind\reservoirtank\reservoirtank_airport_f.p3d",
        "a3\structures_f_enoch\commercial\fuelstation_03\fuelstation_03_roof_f.p3d",
        "a3\structures_f_enoch\commercial\fuelstation_03\fuelstation_03_shop_f.p3d",
        "a3\structures_f_exp\industrial\port\storagetank_01_large_f.p3d",
        "a3\structures_f_exp\industrial\port\storagetank_01_small_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_crystallizertowers_f.p3d",
        "jns_tria_obj\ind_oil_mine\jns_ind_oil_tower_ep1.p3d"
    ];

    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
        "a3\structures_f\dominants\wip\wip_f.p3d",
        "a3\structures_f\ind\crane\crane_f.p3d",
        "a3\structures_f_enoch\industrial\coalplant_01\coalplant_01_mainbuilding_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_04_f.p3d",
        "a3\structures_f_enoch\industrial\sawmills\sawmill_01_f.p3d",
        "a3\structures_f_enoch\infrastructure\bridges\bridge_metal_01_25m_f.p3d",
        "a3\structures_f_exp\industrial\dieselpowerplant_01\dpp_01_mainfactory_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_condenser_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shed_unfinished_f.p3d"
    ];

};
