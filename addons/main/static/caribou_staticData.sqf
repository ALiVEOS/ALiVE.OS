// ALiVE 3 index v3.1, made 2026-10-09 by the ALiVE web indexer, building positions measured
private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: caribou (ALiVE 3 index v3.1, 2026-10-09)"] call ALiVE_fnc_dump;

ALiVE_indexVersion = ["3.1", "2026-10-09", "web", true];

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

 if (tolower(_worldName) == "caribou") then {
    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "ca\buildings2\a_crane_02\crane_rails.p3d",
        "ca\buildings2\a_crane_02\crane_rails_end.p3d",
        "ca\buildings2\ind_shed_02\ind_shed_02_end.p3d",
        "ca\buildings2\ind_shed_02\ind_shed_02_main.p3d",
        "ca\buildings2\ind_tank\ind_tanksmall.p3d",
        "ca\buildings2\misc_cargo\misc_cargo1e.p3d",
        "ca\buildings2\misc_cargo\misc_cargo1f.p3d",
        "ca\buildings2\misc_cargo\misc_cargo1g.p3d",
        "ca\buildings2\misc_waterstation\misc_waterstation.p3d",
        "ca\buildings\misc\zavora_2.p3d",
        "ca\data\library\road_cone.p3d",
        "ca\data\library\roadbarrier_light.p3d",
        "ca\data\library\roadbarrier_long.p3d",
        "ca\roads2\asf2_10 25.p3d",
        "ca\roads2\asf2_10 50.p3d",
        "ca\structures\nav_pier\nav_pier_uvaz.p3d",
        "ca\structures_e\ind\ind_coltan_mine\ind_coltan_conv1_10_ep1.p3d",
        "ca\structures_e\ind\ind_coltan_mine\ind_coltan_conv1_end_ep1.p3d",
        "ca\structures_e\ind\ind_coltan_mine\ind_coltan_tunnel_ep1.p3d",
        "ca\structures_e\ind\ind_oil_mine\ind_oil_pump_ruins_ep1.p3d",
        "ca\structures_e\ind\ind_shed\ind_shed_02_ep1.p3d",
        "rhnet\caribou_models\mdl\misc\rhnet_borderf01.p3d",
        "rhnet\caribou_models\mdl\misc\rhnet_dk.p3d",
        "rhnet\caribou_models\mdl\misc\rhnet_geoc.p3d",
        "rhnet\caribou_models\mdl\misc\rhnet_grave01.p3d",
        "rhnet\caribou_models\mdl\rd\tanktr_10 100.p3d",
        "rhnet\caribou_models\mdl\rd\tanktr_10 25.p3d",
        "rhnet\caribou_models\mdl\rd\tanktr_10 50.p3d",
        "rhnet\caribou_models\mdl\rd\tanktr_10 75.p3d",
        "rhnet\caribou_models\mdl\rd\tanktr_12.p3d",
        "rhnet\caribou_models\mdl\rd\tanktr_25.p3d",
        "rhnet\caribou_models\mdl\rd\tanktr_6.p3d",
        "rhnet\caribou_models\mdl\rd\tanktr_6konec.p3d"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "ca\buildings\hangar_2.p3d",
        "ca\misc2\barrack2\barrack2.p3d",
        "ca\structures\ind_sawmill\ind_illuminanttower.p3d",
        "ca\structures\mil\mil_barracks_i.p3d",
        "ca\structures\mil\mil_barracks_l.p3d",
        "ca\structures\mil\mil_controltower.p3d",
        "ca\structures\mil\mil_controltower_ruins.p3d",
        "ca\structures\mil\mil_guardhouse.p3d"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "ca\buildings\hangar_2.p3d",
        "ca\structures\mil\mil_controltower.p3d"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "ca\buildings\hangar_2.p3d",
        "ca\structures\mil\mil_controltower.p3d"
    ];

    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        "ca\structures\mil\mil_controltower.p3d"
    ];

    ALiVE_HeliBuildingTypes = ALiVE_HeliBuildingTypes + [
        "ca\misc\heli_h_army.p3d"
    ];

    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
        "ca\misc\heli_h_army.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "ca\buildings2\barn_metal\barn_metal.p3d",
        "ca\buildings2\houseblocks\houseblock_c\houseblock_c2_ruins.p3d",
        "ca\buildings2\houseblocks\houseblock_d\houseblock_d1_ruins.p3d",
        "ca\buildings2\houseblocks\houseblock_d\houseblock_d2_ruins.p3d",
        "ca\buildings2\houseruins\r_a_generalstore_01a.p3d",
        "ca\buildings2\houseruins\r_barn_w_01.p3d",
        "ca\buildings2\houseruins\r_farm_cowshed_a.p3d",
        "ca\buildings2\houseruins\r_housev2_03b.p3d",
        "ca\buildings2\ind_cementworks\ind_pec\ind_pec_03a.p3d",
        "ca\buildings2\ind_cementworks\ind_vysypka\ind_vysypka.p3d",
        "ca\buildings2\ind_garage01\ind_garage01.p3d",
        "ca\buildings2\ind_shed_01\ind_shed_01_end.p3d",
        "ca\buildings2\ind_shed_01\ind_shed_01_main.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_01.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_02.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_04.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_l.p3d",
        "ca\structures\house\a_fuelstation\a_fuelstation_build.p3d",
        "ca\structures\house\a_office01\a_office01.p3d",
        "ca\structures\house\a_stationhouse\a_stationhouse.p3d",
        "ca\structures\house\church_05r\church_05r.p3d",
        "ca\structures\nav_pier\nav_pier_m.p3d",
        "ca\structures\shed_ind\shed_ind02.p3d"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "ca\buildings2\houseruins\r_barn_w_01.p3d",
        "ca\structures\house\a_office01\a_office01.p3d",
        "ca\structures\house\a_stationhouse\a_stationhouse.p3d"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "ca\buildings2\barn_metal\barn_metal.p3d",
        "ca\buildings2\houseruins\r_barn_w_01.p3d",
        "ca\buildings2\houseruins\r_housev2_03b.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_01.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_l.p3d",
        "ca\structures\house\a_fuelstation\a_fuelstation_build.p3d",
        "ca\structures\house\a_office01\a_office01.p3d",
        "ca\structures\house\a_stationhouse\a_stationhouse.p3d"
    ];

    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
        "ca\buildings2\misc_powerstation\misc_powerstation.p3d",
        "ca\buildings\trafostanica_velka.p3d"
    ];

    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
        "ca\buildings\telek1.p3d",
        "ca\buildings\vysilac_fm.p3d"
    ];

    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        "ca\buildings2\a_crane_02\a_crane_02a.p3d",
        "ca\buildings2\a_crane_02\a_crane_02b.p3d",
        "ca\structures\nav\nav_lighthouse2.p3d",
        "ca\structures\nav_boathouse\nav_boathouse.p3d",
        "ca\structures\nav_boathouse\nav_boathouse_pier.p3d",
        "ca\structures\nav_boathouse\nav_boathouse_pierr.p3d",
        "ca\structures\nav_pier\nav_pier_c2.p3d",
        "ca\structures\nav_pier\nav_pier_c_big.p3d",
        "ca\structures\nav_pier\nav_pier_m.p3d",
        "ca\structures\nav_pier\nav_pier_m_end.p3d"
    ];

    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        "ca\buildings2\ind_cementworks\ind_expedice\ind_expedice_3.p3d",
        "ca\buildings2\ind_tank\ind_tankbig.p3d",
        "ca\structures\house\a_fuelstation\a_fuelstation_build.p3d",
        "ca\structures\house\a_fuelstation\a_fuelstation_feed.p3d",
        "ca\structures\house\a_fuelstation\a_fuelstation_shed.p3d",
        "ca\structures_e\ind\ind_oil_mine\ind_oil_pump_ep1.p3d",
        "ca\structures_e\ind\ind_oil_mine\ind_oil_tower_ep1.p3d"
    ];

    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
        "ca\buildings2\ind_cementworks\ind_pec\ind_pec_03.p3d",
        "ca\structures\ind_sawmill\ind_sawmill.p3d",
        "ca\structures\ind_sawmill\ind_sawmillpen.p3d",
        "ca\structures_e\ind\ind_coltan_mine\ind_coltan_conv2_ep1.p3d",
        "ca\structures_e\ind\ind_coltan_mine\ind_coltan_hopper_ep1.p3d",
        "ca\structures_e\ind\ind_coltan_mine\ind_coltan_main_ep1.p3d"
    ];

};
