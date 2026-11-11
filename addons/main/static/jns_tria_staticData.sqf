// ALiVE 3 index v3.1, made 2026-11-11 by the ALiVE web indexer, building positions measured
private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: jns_tria (ALiVE 3 index v3.1, 2026-11-11)"] call ALiVE_fnc_dump;

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

ALiVE_mapCompositionType = "Woodland";
[ALIVE_mapBounds, worldName, 10240] call ALIVE_fnc_hashSet;

 if (tolower(_worldName) == "jns_tria") then {
    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "a3\props_f_enoch\military\decontamination\deconshower_01_f.p3d",
        "a3\structures_f_enoch\industrial\power\powerstation_01_ruins_f.p3d",
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
