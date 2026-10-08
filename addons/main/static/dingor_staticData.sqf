// ALiVE 3 index v3.1, made 2026-10-08 by the ALiVE web indexer, building positions measured
private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: dingor (ALiVE 3 index v3.1, 2026-10-08)"] call ALiVE_fnc_dump;

ALiVE_indexVersion = ["3.1", "2026-10-08", "web", true];

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

 if (tolower(_worldName) == "dingor") then {
    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "ca\buildings2\a_crane_02\crane_rails.p3d",
        "ca\buildings2\a_crane_02\crane_rails_end.p3d",
        "ca\buildings2\ind_shed_02\ind_shed_02_end.p3d",
        "ca\buildings2\ind_shed_02\ind_shed_02_main.p3d",
        "ca\buildings2\misc_cargo\seacrate.p3d",
        "ca\buildings2\misc_waterstation\misc_waterstation.p3d",
        "ca\buildings\misc\plot_rust_vrat_o.p3d",
        "ca\buildings\misc\zed_civil.p3d",
        "ca\buildings\misc\zed_dira_civil.p3d",
        "ca\buildings\misc\zed_podplaz_civil.p3d",
        "ca\misc3\fort_bagfence_round.p3d",
        "ca\roads2\path_10 100.p3d",
        "ca\roads2\path_10 25.p3d",
        "ca\roads2\path_10 50.p3d",
        "ca\roads_pmc\bridge\bridge_asf_pmc.p3d",
        "ca\structures\misc\armory\pneu\pneu.p3d",
        "ca\structures\misc\armory\woodenramp\woodenramp.p3d",
        "ca\structures\wall\wall_woodvil_pole.p3d",
        "ca\structures_e\ind\ind_coltan_mine\ind_coltan_tunnel_ep1.p3d",
        "ca\structures_e\ind\ind_shed\ind_shed_02_ep1.p3d",
        "ca\structures_e\misc\misc_billboards\billboard_2_ep1.p3d",
        "ibr\lingor_bank\ibr_bank.p3d",
        "ibr\lingor_objects\alienegg.p3d",
        "ibr\lingor_objects\bilboard_creditz1.p3d",
        "ibr\lingor_objects\bilboard_creditz2.p3d",
        "ibr\lingor_objects\bilboard_icebdona.p3d",
        "ibr\lingor_objects\bilboard_jetski.p3d",
        "ibr\lingor_objects\bilboard_linkpark.p3d",
        "ibr\lingor_objects\bilboard_lovingit.p3d",
        "ibr\lingor_objects\bilboard_perfumes.p3d",
        "ibr\lingor_objects\bilboard_presidente.p3d",
        "ibr\lingor_objects\bilboard_rs2.p3d",
        "ibr\lingor_objects\bilboard_rs3.p3d",
        "ibr\lingor_objects\bilboard_rs4.p3d",
        "ibr\lingor_objects\bilboard_rs5.p3d",
        "ibr\lingor_objects\bilboard_venators.p3d",
        "ibr\lingor_objects\bilboard_welcling.p3d",
        "ibr\lingor_objects\conslab.p3d",
        "ibr\lingor_objects\ibr_mostd_bez_lamp.p3d",
        "ibr\lingor_objects\ibr_mostd_stred30.p3d",
        "ibr\lingor_objects\mbg_airportlogo.p3d",
        "ibr\lingor_objects\rampa.p3d",
        "ibr\lingor_objects\riddlerock1.p3d",
        "ibr\lingor_objects\riddlerock2.p3d",
        "ibr\lingor_objects\riddlerock3.p3d",
        "ibr\lingor_objects\riddlerock4.p3d",
        "ibr\lingor_objects\riddlerock5.p3d",
        "ibr\lingor_objects\riddlerock6.p3d",
        "ibr\lingor_objects\runway_end36.p3d",
        "ibr\lingor_objects\sil10100.p3d",
        "ibr\lingor_objects\sil1025.p3d",
        "ibr\lingor_objects\sil1050.p3d",
        "ibr\lingor_objects\sil1075.p3d",
        "ibr\lingor_objects\sil12.p3d",
        "ibr\lingor_objects\sil6.p3d",
        "ibr\lingor_objects\sil6konec.p3d",
        "ibr\lingor_objects\skala.p3d",
        "ibr\lingor_objects\skala1_1.p3d",
        "ibr\lingor_objects\skala3_1.p3d",
        "ibr\lingor_objects\skala3_2.p3d",
        "ibr\lingor_objects\skala3_3.p3d",
        "ibr\lingor_objects\skala3_4.p3d",
        "ibr\lingor_objects\skala3_5.p3d",
        "ibr\lingor_objects\skale.p3d",
        "ibr\lingor_roads\asfl_10100.p3d",
        "ibr\lingor_roads\asfl_1025.p3d",
        "ibr\lingor_roads\asfl_1050.p3d",
        "ibr\lingor_roads\asfl_1075.p3d",
        "ibr\lingor_roads\asfl_12.p3d",
        "ibr\lingor_roads\asfl_25.p3d",
        "ibr\lingor_roads\asfl_6.p3d",
        "ibr\lingor_roads\asfl_6konec.p3d",
        "ibr\lingor_roads\racetrack_10 25.p3d",
        "ibr\lingor_roads\racetrack_10 50.p3d",
        "ibr\lingor_roads\racetrack_12.p3d",
        "ibr\lingor_roads\racetrack_25.p3d",
        "ibr\lingor_roads\racetrack_6konec.p3d"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "ca\buildings\budova4_in.p3d",
        "ca\buildings\fuelstation_army.p3d",
        "ca\buildings\hangar_2.p3d",
        "ca\buildings\hlidac_budka.p3d",
        "ca\buildings\posed.p3d",
        "ca\misc3\fort_watchtower.p3d",
        "ca\misc3\fortified_nest_big.p3d",
        "ca\misc3\fortified_nest_small.p3d",
        "ca\misc3\tent_east.p3d",
        "ca\structures\mil\mil_barracks_i.p3d",
        "ca\structures\mil\mil_controltower.p3d",
        "mbg_buildings_2\m\buildings\mbg_police_station.p3d"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "ca\buildings\hangar_2.p3d",
        "ca\structures\mil\mil_controltower.p3d"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "ca\buildings\budova4_in.p3d",
        "ca\buildings\hangar_2.p3d",
        "ca\misc3\tent_east.p3d",
        "ca\structures\mil\mil_controltower.p3d"
    ];

    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        "ca\buildings\budova4_in.p3d",
        "ca\structures\mil\mil_controltower.p3d"
    ];

    ALIVE_militaryFieldworkBuildingTypes = ALIVE_militaryFieldworkBuildingTypes + [
        "ca\misc3\fortified_nest_big.p3d",
        "ca\misc3\fortified_nest_small.p3d"
    ];

    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
        "a3\structures_f\mil\tenthangar\tenthangar_v1_f.p3d",
        "ca\roads2\runway_main.p3d",
        "ca\roads2\runway_poj_t_2.p3d",
        "ibr\ibr_airports\ibr_terminal.p3d",
        "ibr\lingor_objects\runway_end18.p3d",
        "ibr\lingor_objects\runway_end27.p3d",
        "ibr\lingor_objects\runway_end9.p3d"
    ];

    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [
        "a3\structures_f\mil\tenthangar\tenthangar_v1_f.p3d",
        "ca\roads2\runway_main.p3d",
        "ca\roads2\runway_poj_t_2.p3d"
    ];

    ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
        "ibr\ibr_airports\ibr_terminal.p3d",
        "ibr\lingor_objects\runway_end18.p3d",
        "ibr\lingor_objects\runway_end27.p3d",
        "ibr\lingor_objects\runway_end9.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "ca\buildings2\a_generalstore_01\a_generalstore_01.p3d",
        "ca\buildings2\a_generalstore_01\a_generalstore_01a.p3d",
        "ca\buildings2\a_pub\a_pub_01.p3d",
        "ca\buildings2\barn_metal\barn_metal.p3d",
        "ca\buildings2\farm_cowshed\farm_cowshed_a.p3d",
        "ca\buildings2\farm_cowshed\farm_cowshed_b.p3d",
        "ca\buildings2\farm_cowshed\farm_cowshed_c.p3d",
        "ca\buildings2\houseblocks\houseblock_a\houseblock_a1_1.p3d",
        "ca\buildings2\houseruins\r_housev2_01a.p3d",
        "ca\buildings2\ind_cementworks\ind_vysypka\ind_vysypka.p3d",
        "ca\buildings2\ind_garage01\ind_garage01.p3d",
        "ca\buildings2\ind_shed_01\ind_shed_01_end.p3d",
        "ca\buildings2\ind_shed_01\ind_shed_01_main.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_01.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_02.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_03.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_04.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_l.p3d",
        "ca\buildings2\shed_small\shed_m01.p3d",
        "ca\buildings2\shed_small\shed_m03.p3d",
        "ca\buildings2\shed_small\shed_w01.p3d",
        "ca\buildings2\shed_small\shed_w01_ruins.p3d",
        "ca\buildings2\shed_small\shed_w02.p3d",
        "ca\buildings2\shed_small\shed_w03.p3d",
        "ca\buildings2\shed_wooden\shed_wooden.p3d",
        "ca\buildings\afbarabizna.p3d",
        "ca\buildings\bouda_plech.p3d",
        "ca\buildings\budova2.p3d",
        "ca\buildings\dum_istan3_hromada2.p3d",
        "ca\buildings\dum_mesto_in.p3d",
        "ca\buildings\dum_olez_istan1.p3d",
        "ca\buildings\dum_olez_istan2.p3d",
        "ca\buildings\garaz_mala.p3d",
        "ca\buildings\hut01.p3d",
        "ca\buildings\hut02.p3d",
        "ca\buildings\hut03.p3d",
        "ca\buildings\hut04.p3d",
        "ca\buildings\hut06.p3d",
        "ca\buildings\kostel_trosky.p3d",
        "ca\buildings\kulna.p3d",
        "ca\buildings\sara_domek_sedy.p3d",
        "ca\buildings\sara_domek_zluty.p3d",
        "ca\structures\house\a_hospital\a_hospital.p3d",
        "ca\structures\house\a_office01\a_office01.p3d",
        "ca\structures\house\a_office02\a_office02.p3d",
        "ca\structures\house\a_stationhouse\a_stationhouse.p3d",
        "ca\structures\house\church_02\church_02.p3d",
        "ca\structures\house\church_03\church_03.p3d",
        "ca\structures\house\church_05r\church_05r.p3d",
        "ca\structures\house\housebt\houseb_tenement.p3d",
        "ca\structures\house\housev2\housev2_01b.p3d",
        "ca\structures\house\housev2\housev2_02_interier.p3d",
        "ca\structures\house\housev2\housev2_03.p3d",
        "ca\structures\house\housev2\housev2_03b.p3d",
        "ca\structures\house\housev\housev_1i2.p3d",
        "ca\structures\house\housev\housev_2i.p3d",
        "ca\structures\house\housev\housev_2l.p3d",
        "ca\structures\house\housev\housev_2t1.p3d",
        "ca\structures\house\housev\housev_3i1.p3d",
        "ca\structures\house\housev\housev_3i2.p3d",
        "ca\structures\shed\shed_small\shed_w4.p3d",
        "ca\structures\shed_ind\shed_ind02.p3d",
        "ca\structures\shed_ind\shed_ind02_dam.p3d",
        "ca\structures_e\housea\a_office01\a_office01_ep1.p3d",
        "ca\structures_e\housea\a_stationhouse\a_stationhouse_ep1.p3d",
        "ca\structures_e\housea\a_villa\a_villa_ep1.p3d",
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
        "ca\structures_e\housek\house_k_1_ep1.p3d",
        "ca\structures_e\housek\house_k_3_ep1.p3d",
        "ca\structures_e\housek\house_k_5_ep1.p3d",
        "ca\structures_e\housek\house_k_6_ep1.p3d",
        "ca\structures_e\housek\house_k_7_ep1.p3d",
        "ca\structures_e\housek\house_k_8_ep1.p3d",
        "ca\structures_e\housel\house_l_1_ep1.p3d",
        "ca\structures_e\housel\house_l_3_ep1.p3d",
        "ca\structures_e\housel\house_l_4_ep1.p3d",
        "ca\structures_e\housel\house_l_6_ep1.p3d",
        "ca\structures_e\housel\house_l_7_ep1.p3d",
        "ca\structures_e\housel\house_l_8_ep1.p3d",
        "ca\structures_e\housel\house_l_9_ep1.p3d",
        "ca\structures_e\ind\ind_garage01\ind_garage01_ep1.p3d",
        "ca\structures_e\misc\misc_market\kiosk_ep1.p3d",
        "ca\structures_e\misc\misc_market\market_stalls_01_ep1.p3d",
        "ca\structures_e\misc\shed_m01_ep1.p3d",
        "ca\structures_e\misc\shed_w02_ep1.p3d",
        "ca\structures_e\misc\shed_w03_ep1.p3d",
        "ibr\ibr_airports\ibr_terminal.p3d",
        "ibr\lingor_fuel\ibr_fuelstation_build.p3d",
        "ibr\lingor_fuel\ibr_fuelstation_shed.p3d",
        "ibr\lingor_objects2\ibr_govhouse.p3d",
        "ibr\lingor_objects\house.p3d",
        "ibr\lingor_objects\mbg_stands.p3d",
        "mbg_buildings_2\m\buildings\mbg_radiotelescope.p3d",
        "mbg_buildings_2\m\flats\mbg_apartmentsone_g.p3d",
        "mbg_buildings_2\m\flats\mbg_apartmentsone_w.p3d",
        "mbg_buildings_2\m\flats\mbg_apartmentsone_y.p3d",
        "mbg_buildings_2\m\flats\mbg_apartmentstwo_b.p3d",
        "mbg_buildings_2\m\flats\mbg_apartmentstwo_g.p3d",
        "mbg_buildings_2\m\flats\mbg_apartmentstwo_p.p3d",
        "mbg_buildings_2\m\flats\mbg_flatone_r.p3d",
        "mbg_buildings_2\m\flats\mbg_flatone_w.p3d",
        "mbg_buildings_2\m\flats\mbg_flatone_y.p3d",
        "mbg_buildings_2\m\shanties\mbg_shanty_big.p3d"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "ca\buildings2\a_pub\a_pub_01.p3d",
        "ca\buildings\dum_mesto_in.p3d",
        "ca\structures\house\a_hospital\a_hospital.p3d",
        "ca\structures\house\a_office01\a_office01.p3d",
        "ca\structures\house\a_stationhouse\a_stationhouse.p3d",
        "ca\structures_e\housea\a_office01\a_office01_ep1.p3d",
        "ca\structures_e\housea\a_stationhouse\a_stationhouse_ep1.p3d",
        "ca\structures_e\housea\a_villa\a_villa_ep1.p3d",
        "ca\structures_e\housec\house_c_4_ep1.p3d",
        "ibr\lingor_objects2\ibr_govhouse.p3d"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "ca\buildings2\a_generalstore_01\a_generalstore_01.p3d",
        "ca\buildings2\a_generalstore_01\a_generalstore_01a.p3d",
        "ca\buildings2\a_pub\a_pub_01.p3d",
        "ca\buildings2\barn_metal\barn_metal.p3d",
        "ca\buildings2\farm_cowshed\farm_cowshed_a.p3d",
        "ca\buildings2\farm_cowshed\farm_cowshed_b.p3d",
        "ca\buildings2\farm_cowshed\farm_cowshed_c.p3d",
        "ca\buildings2\houseruins\r_housev2_01a.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_01.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_l.p3d",
        "ca\buildings\dum_istan3_hromada2.p3d",
        "ca\buildings\dum_mesto_in.p3d",
        "ca\buildings\dum_olez_istan1.p3d",
        "ca\buildings\hut01.p3d",
        "ca\buildings\hut02.p3d",
        "ca\buildings\hut04.p3d",
        "ca\buildings\sara_domek_sedy.p3d",
        "ca\buildings\sara_domek_zluty.p3d",
        "ca\structures\house\a_hospital\a_hospital.p3d",
        "ca\structures\house\a_office01\a_office01.p3d",
        "ca\structures\house\a_stationhouse\a_stationhouse.p3d",
        "ca\structures\house\church_03\church_03.p3d",
        "ca\structures\house\housebt\houseb_tenement.p3d",
        "ca\structures\house\housev2\housev2_02_interier.p3d",
        "ca\structures\house\housev\housev_2l.p3d",
        "ca\structures_e\housea\a_office01\a_office01_ep1.p3d",
        "ca\structures_e\housea\a_stationhouse\a_stationhouse_ep1.p3d",
        "ca\structures_e\housea\a_villa\a_villa_ep1.p3d",
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
        "ca\structures_e\housek\house_k_1_ep1.p3d",
        "ca\structures_e\housek\house_k_3_ep1.p3d",
        "ca\structures_e\housek\house_k_5_ep1.p3d",
        "ca\structures_e\housek\house_k_6_ep1.p3d",
        "ca\structures_e\housek\house_k_7_ep1.p3d",
        "ca\structures_e\housek\house_k_8_ep1.p3d",
        "ca\structures_e\housel\house_l_1_ep1.p3d",
        "ca\structures_e\housel\house_l_3_ep1.p3d",
        "ca\structures_e\housel\house_l_4_ep1.p3d",
        "ca\structures_e\housel\house_l_6_ep1.p3d",
        "ca\structures_e\housel\house_l_7_ep1.p3d",
        "ca\structures_e\housel\house_l_8_ep1.p3d",
        "ca\structures_e\housel\house_l_9_ep1.p3d",
        "ibr\ibr_airports\ibr_terminal.p3d",
        "ibr\lingor_objects2\ibr_govhouse.p3d",
        "ibr\lingor_objects\mbg_stands.p3d",
        "mbg_buildings_2\m\flats\mbg_apartmentsone_w.p3d"
    ];

    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
        "ca\buildings2\misc_powerstation\misc_powerstation.p3d",
        "ca\buildings\trafostanica_mala.p3d",
        "ca\buildings\trafostanica_velka.p3d",
        "ca\misc3\powergenerator\powergenerator.p3d"
    ];

    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
        "ca\buildings\telek1.p3d"
    ];

    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        "ca\buildings2\a_crane_02\a_crane_02a.p3d",
        "ca\buildings2\a_crane_02\a_crane_02b.p3d",
        "ca\buildings\majak2.p3d",
        "ca\structures\nav_boathouse\nav_boathouse.p3d",
        "ca\structures\nav_boathouse\nav_boathouse_pierl.p3d",
        "ca\structures\nav_boathouse\nav_boathouse_piert.p3d",
        "ca\structures\nav_pier\nav_pier_c.p3d",
        "ca\structures\nav_pier\nav_pier_c_90.p3d",
        "ca\structures\nav_pier\nav_pier_c_r.p3d",
        "ca\structures\nav_pier\nav_pier_c_t15.p3d",
        "ca\structures\nav_pier\nav_pier_f_17.p3d",
        "ca\structures\nav_pier\nav_pier_m_1.p3d",
        "ca\structures\nav_pier\nav_pier_m_end.p3d"
    ];

    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        "ca\buildings2\ind_tank\ind_tankbig.p3d",
        "ca\buildings\fuelstation.p3d",
        "ca\structures_e\ind\ind_oil_mine\ind_oil_pump_ep1.p3d",
        "ca\structures_e\ind\ind_oil_mine\ind_oil_tower_ep1.p3d",
        "ibr\lingor_fuel\ibr_fuelstation_build.p3d",
        "ibr\lingor_fuel\ibr_fuelstation_feed.p3d",
        "ibr\lingor_fuel\ibr_fuelstation_shed.p3d"
    ];

    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
        "ca\structures\ind_sawmill\ind_sawmill.p3d",
        "ca\structures\ind_sawmill\ind_sawmillpen.p3d"
    ];

};
