// ALiVE 3 index v3.1, made 2026-11-11 by the ALiVE web indexer, building positions measured
private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: bozoum (ALiVE 3 index v3.1, 2026-11-11)"] call ALiVE_fnc_dump;

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

 if (tolower(_worldName) == "bozoum") then {
    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "a3\structures_f_enoch\industrial\sawmills\sawmill_01_illuminati_tower_f.p3d",
        "a3\structures_f_enoch\military\barracks\guardbox_01_smooth_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_01_terminal_f.p3d"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "a3\structures_f_exp\infrastructure\airports\airport_01_terminal_f.p3d"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "a3\structures_f_exp\infrastructure\airports\airport_01_terminal_f.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "a3\structures_f\households\house_small03\i_house_small_03_v1_f.p3d",
        "a3\structures_f\households\slum\cargo_house_slum_f.p3d",
        "a3\structures_f\households\slum\slum_house01_f.p3d",
        "a3\structures_f\households\slum\slum_house02_f.p3d",
        "a3\structures_f\households\slum\slum_house03_f.p3d",
        "a3\structures_f_enoch\civilian\camps\caravan_01_rust_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_10_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_11_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_12_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_13_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_14_f.p3d",
        "a3\structures_f_enoch\commercial\fuelstation_03\fuelstation_03_shop_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garagerow_01_large_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garagerow_01_small_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_03_grey_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_04_f.p3d",
        "a3\structures_f_enoch\industrial\sawmills\sawmill_01_f.p3d",
        "a3\structures_f_enoch\industrial\sheds\i_shed_ind_old_f.p3d",
        "a3\structures_f_exp\civilian\garages\garageshelter_01_f.p3d",
        "a3\structures_f_exp\civilian\house_big_01\house_big_01_f.p3d",
        "a3\structures_f_exp\civilian\house_big_02\house_big_02_f.p3d",
        "a3\structures_f_exp\civilian\house_big_04\house_big_04_f.p3d",
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
        "a3\structures_f_exp\civilian\slum_02\slum_02_ruins_f.p3d",
        "a3\structures_f_exp\civilian\slum_03\slum_03_f.p3d",
        "a3\structures_f_exp\civilian\slum_04\slum_04_f.p3d",
        "a3\structures_f_exp\civilian\slum_05\slum_05_f.p3d",
        "a3\structures_f_exp\commercial\market\metalshelter_02_f.p3d",
        "a3\structures_f_exp\commercial\market\metalshelter_02_ruins_f.p3d",
        "a3\structures_f_exp\cultural\church_02\church_02_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_01_terminal_f.p3d"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "a3\structures_f_exp\infrastructure\airports\airport_01_terminal_f.p3d"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "a3\structures_f\households\house_small03\i_house_small_03_v1_f.p3d",
        "a3\structures_f\households\slum\cargo_house_slum_f.p3d",
        "a3\structures_f\households\slum\slum_house01_f.p3d",
        "a3\structures_f\households\slum\slum_house02_f.p3d",
        "a3\structures_f\households\slum\slum_house03_f.p3d",
        "a3\structures_f_enoch\commercial\fuelstation_03\fuelstation_03_shop_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garagerow_01_large_f.p3d",
        "a3\structures_f_enoch\industrial\sawmills\sawmill_01_f.p3d",
        "a3\structures_f_exp\civilian\house_big_01\house_big_01_f.p3d",
        "a3\structures_f_exp\civilian\house_big_02\house_big_02_f.p3d",
        "a3\structures_f_exp\civilian\house_big_04\house_big_04_f.p3d",
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
        "a3\structures_f_exp\cultural\church_02\church_02_f.p3d"
    ];

    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
        "a3\structures_f\ind\solarpowerplant\spp_transformer_f.p3d",
        "a3\structures_f_enoch\industrial\houses\waterstation_01_f.p3d",
        "a3\structures_f_enoch\military\radar\mobileradar_01_generator_f.p3d"
    ];

    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
        "a3\structures_f\ind\transmitter_tower\tbox_f.p3d",
        "a3\structures_f\ind\transmitter_tower\ttowerbig_2_f.p3d",
        "a3\structures_f\ind\transmitter_tower\ttowersmall_1_f.p3d",
        "a3\structures_f\ind\transmitter_tower\ttowersmall_2_f.p3d"
    ];

    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        "a3\structures_f_exp\naval\piers\pierwooden_01_10m_norails_f.p3d",
        "a3\structures_f_exp\naval\piers\pierwooden_01_hut_f.p3d"
    ];

    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        "a3\structures_f_enoch\commercial\fuelstation_03\fuelstation_03_shop_f.p3d"
    ];

    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
        "a3\structures_f_enoch\industrial\sawmills\sawmill_01_f.p3d"
    ];

};
