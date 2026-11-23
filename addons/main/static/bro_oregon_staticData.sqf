// ALiVE 3 index v3.1, made 2026-11-21 by the ALiVE web indexer, building positions measured
private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: bro_oregon (ALiVE 3 index v3.1, 2026-11-21)"] call ALiVE_fnc_dump;

ALiVE_indexVersion = ["3.1", "2026-11-21", "web", true];

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

 if (tolower(_worldName) == "bro_oregon") then {
    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "bro_structures\common\bro_wfence_2.p3d",
        "bro_structures\common\bro_wfence_4.p3d",
        "bro_structures\decals\bro_decal_6.p3d",
        "bro_structures\decals\bro_decal_7.p3d",
        "bro_structures\overhangs\bro_car_port.p3d",
        "bro_structures\overhangs\bro_car_port_blue.p3d",
        "bro_structures\overhangs\bro_overhang_10m.p3d",
        "bro_structures\overhangs\bro_overhang_half_10m.p3d",
        "bro_structures\parking\bro_parking_1.p3d",
        "bro_structures\suburb\bro_suburb_4_siding_mirror.p3d",
        "bromine\bro_oregon_assets\bro_runway_flush_white.p3d"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "a3\structures_f_enoch\industrial\farms\barn_04_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_04_ruins_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garageoffice_01_f.p3d",
        "a3\structures_f_enoch\military\airfield\controltower_02_f.p3d",
        "a3\structures_f_exp\industrial\port\guardhouse_01_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shed_unfinished_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_02_terminal_f.p3d",
        "bro_structures\guardtower\bro_lookout_tower.p3d"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "a3\structures_f_enoch\industrial\farms\barn_04_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garageoffice_01_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_02_terminal_f.p3d"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "a3\structures_f_enoch\industrial\farms\barn_04_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garageoffice_01_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shed_unfinished_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_02_terminal_f.p3d"
    ];

    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        "a3\structures_f_exp\infrastructure\airports\airport_02_terminal_f.p3d"
    ];

    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
        "a3\structures_f_exp\infrastructure\airports\airport_01_hangar_f.p3d"
    ];

    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [
        "a3\structures_f_exp\infrastructure\airports\airport_01_hangar_f.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "a3\props_f_enoch\civilian\forest\deerstand_01_f.p3d",
        "a3\props_f_enoch\civilian\forest\deerstand_02_f.p3d",
        "a3\props_f_enoch\civilian\forest\feedshack_01_f.p3d",
        "a3\structures_f\households\house_small03\i_house_small_03_v1_f.p3d",
        "a3\structures_f\households\slum\cargo_house_slum_f.p3d",
        "a3\structures_f\households\slum\slum_house01_f.p3d",
        "a3\structures_f\households\slum\slum_house02_f.p3d",
        "a3\structures_f\households\slum\slum_house03_f.p3d",
        "a3\structures_f_argo\industrial\agriculture\barn_01_grey_f.p3d",
        "a3\structures_f_enoch\civilian\camps\camp_house_01_brown_f.p3d",
        "a3\structures_f_enoch\civilian\camps\caravan_01_rust_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1b01_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w02_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w04_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w07_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w08_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w10_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w12_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w13_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2b01_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2b02_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2b03_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w01_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w03_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w04_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w05_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_09_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_10_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_11_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_12_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_13_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_14_f.p3d",
        "a3\structures_f_enoch\industrial\cementworks\cementworks_01_grey_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_02_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_03_large_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_03_small_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_04_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_04_ruins_f.p3d",
        "a3\structures_f_enoch\industrial\farms\cowshed_01_a_f.p3d",
        "a3\structures_f_enoch\industrial\farms\cowshed_01_b_f.p3d",
        "a3\structures_f_enoch\industrial\farms\cowshed_01_c_f.p3d",
        "a3\structures_f_enoch\industrial\farms\greenhouse_01_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garageoffice_01_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garagerow_01_large_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garagerow_01_small_f.p3d",
        "a3\structures_f_enoch\industrial\houses\factory_02_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_01_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_01_grey_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_02_grey_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_03_grey_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_04_grey_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_05_grey_f.p3d",
        "a3\structures_f_enoch\industrial\sawmills\sawmill_01_f.p3d",
        "a3\structures_f_enoch\industrial\sheds\industrialshed_01_f.p3d",
        "a3\structures_f_exp\civilian\garages\garageshelter_01_f.p3d",
        "a3\structures_f_exp\civilian\house_big_01\house_big_01_f.p3d",
        "a3\structures_f_exp\civilian\house_big_02\house_big_02_f.p3d",
        "a3\structures_f_exp\civilian\house_big_03\house_big_03_f.p3d",
        "a3\structures_f_exp\civilian\house_small_01\house_small_01_f.p3d",
        "a3\structures_f_exp\civilian\house_small_02\house_small_02_f.p3d",
        "a3\structures_f_exp\civilian\house_small_04\house_small_04_f.p3d",
        "a3\structures_f_exp\civilian\house_small_05\house_small_05_f.p3d",
        "a3\structures_f_exp\civilian\house_small_06\house_small_06_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_01_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_02_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_03_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_05_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_07_f.p3d",
        "a3\structures_f_exp\civilian\slum_03\slum_03_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_01\fuelstation_01_shop_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_01\fuelstation_01_workshop_f.p3d",
        "a3\structures_f_exp\commercial\market\metalshelter_02_f.p3d",
        "a3\structures_f_exp\commercial\shop_town_01\shop_town_01_f.p3d",
        "a3\structures_f_exp\commercial\shop_town_03\shop_town_03_f.p3d",
        "a3\structures_f_exp\commercial\supermarket_01\supermarket_01_f.p3d",
        "a3\structures_f_exp\commercial\warehouses\warehouse_03_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shed_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shed_unfinished_f.p3d",
        "bro_structures\offices\bro_container_office.p3d",
        "bro_structures\offices\bro_container_office_small.p3d",
        "bro_structures\offices\bro_offices_portable.p3d",
        "bro_structures\stripmall\bro_stripmall.p3d",
        "bro_structures\suburb\bro_suburb_1_siding.p3d",
        "bro_structures\suburb\bro_suburb_1_siding_mirror.p3d",
        "bro_structures\suburb\bro_suburb_2.p3d",
        "bro_structures\suburb\bro_suburb_2_siding.p3d",
        "bro_structures\suburb\bro_suburb_4_siding.p3d",
        "bro_structures\suburb_2\bro_suburb_ranch_1.p3d",
        "bro_structures\suburb_2\bro_suburb_ranch_2.p3d",
        "bro_structures\suburb_2\bro_suburb_ranch_3.p3d",
        "bro_structures\suburb_2\bro_suburb_ranch_4.p3d",
        "bro_structures\suburb_2\bro_suburb_ranch_wh.p3d",
        "bro_structures\warehouse\bro_warehouse_2.p3d"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "a3\structures_f_enoch\civilian\houses\house_2b02_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2b03_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w03_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w04_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w05_f.p3d",
        "a3\structures_f_exp\civilian\house_big_03\house_big_03_f.p3d",
        "bro_structures\offices\bro_offices_portable.p3d"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "a3\structures_f\households\house_small03\i_house_small_03_v1_f.p3d",
        "a3\structures_f\households\slum\cargo_house_slum_f.p3d",
        "a3\structures_f\households\slum\slum_house01_f.p3d",
        "a3\structures_f\households\slum\slum_house02_f.p3d",
        "a3\structures_f\households\slum\slum_house03_f.p3d",
        "a3\structures_f_argo\industrial\agriculture\barn_01_grey_f.p3d",
        "a3\structures_f_enoch\civilian\camps\camp_house_01_brown_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1b01_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w02_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w04_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w07_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w08_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w10_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w12_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w13_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2b01_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2b02_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2b03_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w01_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w03_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w04_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w05_f.p3d",
        "a3\structures_f_enoch\industrial\cementworks\cementworks_01_grey_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garageoffice_01_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garagerow_01_large_f.p3d",
        "a3\structures_f_enoch\industrial\sawmills\sawmill_01_f.p3d",
        "a3\structures_f_exp\civilian\house_big_01\house_big_01_f.p3d",
        "a3\structures_f_exp\civilian\house_big_02\house_big_02_f.p3d",
        "a3\structures_f_exp\civilian\house_big_03\house_big_03_f.p3d",
        "a3\structures_f_exp\civilian\house_small_01\house_small_01_f.p3d",
        "a3\structures_f_exp\civilian\house_small_02\house_small_02_f.p3d",
        "a3\structures_f_exp\civilian\house_small_04\house_small_04_f.p3d",
        "a3\structures_f_exp\civilian\house_small_05\house_small_05_f.p3d",
        "a3\structures_f_exp\civilian\house_small_06\house_small_06_f.p3d",
        "a3\structures_f_exp\civilian\slum_03\slum_03_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_01\fuelstation_01_shop_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_01\fuelstation_01_workshop_f.p3d",
        "a3\structures_f_exp\commercial\shop_town_01\shop_town_01_f.p3d",
        "a3\structures_f_exp\commercial\shop_town_03\shop_town_03_f.p3d",
        "a3\structures_f_exp\commercial\supermarket_01\supermarket_01_f.p3d",
        "a3\structures_f_exp\commercial\warehouses\warehouse_03_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shed_f.p3d",
        "bro_structures\offices\bro_offices_portable.p3d",
        "bro_structures\suburb\bro_suburb_1_siding.p3d",
        "bro_structures\suburb\bro_suburb_1_siding_mirror.p3d",
        "bro_structures\suburb\bro_suburb_2.p3d",
        "bro_structures\suburb\bro_suburb_2_siding.p3d",
        "bro_structures\suburb_2\bro_suburb_ranch_1.p3d",
        "bro_structures\suburb_2\bro_suburb_ranch_2.p3d",
        "bro_structures\suburb_2\bro_suburb_ranch_3.p3d",
        "bro_structures\suburb_2\bro_suburb_ranch_4.p3d",
        "bro_structures\suburb_2\bro_suburb_ranch_wh.p3d"
    ];

    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
        "a3\structures_f\ind\dieselpowerplant\dp_transformer_f.p3d",
        "a3\structures_f\ind\solarpowerplant\solarpanel_1_f.p3d",
        "a3\structures_f_enoch\industrial\power\powerstation_01_f.p3d"
    ];

    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
        "a3\structures_f\ind\transmitter_tower\communication_f.p3d",
        "a3\structures_f\ind\transmitter_tower\tbox_f.p3d",
        "a3\structures_f\ind\transmitter_tower\ttowerbig_2_f.p3d",
        "a3\structures_f\ind\transmitter_tower\ttowersmall_2_f.p3d"
    ];

    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        "a3\structures_f_exp\naval\piers\pierwooden_02_16m_f.p3d"
    ];

    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        "a3\structures_f\ind\dieselpowerplant\dp_smalltank_f.p3d",
        "a3\structures_f\ind\fuelstation\fuelstation_feed_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_02\fuelstation_02_pump_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_02\fuelstation_02_roof_f.p3d"
    ];

    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
        "a3\structures_f\dominants\wip\wip_f.p3d",
        "a3\structures_f\ind\crane\crane_f.p3d",
        "a3\structures_f_enoch\industrial\cementworks\cementworks_01_grey_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_04_f.p3d",
        "a3\structures_f_enoch\industrial\sawmills\sawmill_01_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_heap_bagasse_f.p3d",
        "a3\structures_f_exp\industrial\surfacemine_01\sm_01_shed_unfinished_f.p3d"
    ];

};
