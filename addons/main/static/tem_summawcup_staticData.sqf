// ALiVE 3 index v3.1, made 2026-10-06 by the ALiVE web indexer, building positions measured
private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: tem_summawcup (ALiVE 3 index v3.1, 2026-10-06)"] call ALiVE_fnc_dump;

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

 if (tolower(_worldName) == "tem_summawcup") then {
    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "a3\structures_f\civ\accessories\timbers_f.p3d",
        "ca\buildings2\misc_waterstation\misc_waterstation.p3d",
        "ca\structures\proxy_ruins\walls\s2.p3d",
        "ca\structures\proxy_ruins\walls\s3.p3d",
        "ca\structures\proxy_ruins\walls\s4.p3d",
        "ca\structures\proxy_ruins\walls\s5.p3d",
        "ca\structures\proxy_ruins\walls\s6.p3d",
        "ca\structures\proxy_ruins\walls\s7.p3d",
        "ca\structures_pmc\buildings\ruins\farm_cowshed\ruin_cowshed_b_ruins_pmc.p3d"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "cup\terrains\cup_terrains_winter_objects\s_fortified_nest_big.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "ca\buildings2\a_generalstore_01\a_generalstore_01_ruins.p3d",
        "ca\buildings2\houseblocks\houseblock_a\houseblock_a1_ruins.p3d",
        "ca\buildings2\houseblocks\houseblock_a\houseblock_a3_ruins.p3d",
        "ca\buildings2\houseblocks\houseblock_b\houseblock_b4_ruins.p3d",
        "ca\buildings2\houseblocks\houseblock_b\houseblock_b5_ruins.p3d",
        "ca\buildings2\houseblocks\houseblock_c\houseblock_c1_ruins.p3d",
        "ca\buildings2\houseblocks\houseblock_c\houseblock_c4_ruins.p3d",
        "ca\buildings2\houseblocks\houseblock_d\houseblock_d2_ruins.p3d",
        "ca\buildings2\ind_garage01\ind_garage01_ruins.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_02_ruins.p3d",
        "ca\buildings2\shed_small\shed_m03.p3d",
        "ca\buildings2\shed_small\shed_w01.p3d",
        "ca\buildings2\shed_small\shed_w02.p3d",
        "ca\buildings\afdum_mesto2.p3d",
        "ca\buildings\afdum_mesto2l.p3d",
        "ca\buildings\bouda3.p3d",
        "ca\buildings\deutshe_mini.p3d",
        "ca\buildings\dulni_bs.p3d",
        "ca\buildings\dum_mesto_in.p3d",
        "ca\buildings\dum_rasovna.p3d",
        "ca\buildings\ruins\deutshe_ruins.p3d",
        "ca\buildings\ruins\hut_old02_ruins.p3d",
        "ca\buildings\ruins\sara_domek_zluty_bez_ruins.p3d",
        "ca\buildings\ruins\sara_stodola3_ruins.p3d",
        "ca\buildings\ruins\sara_zluty_statek_in_ruins.p3d",
        "ca\buildings\ruins\statek_kulna_ruins.p3d",
        "ca\buildings\ruins\zalchata_ruins.p3d",
        "ca\buildings\sara_stodola3.p3d",
        "ca\structures\barn_w\barn_w_01_dam.p3d",
        "ca\structures\barn_w\barn_w_02_ruins.p3d",
        "ca\structures\house\housev2\housev2_01b_ruins.p3d",
        "ca\structures\house\housev2\housev2_05_ruins.p3d",
        "ca\structures\house\housev\housev_1i4_ruins.p3d",
        "ca\structures\house\housev\housev_1l1_ruins.p3d",
        "ca\structures\house\housev\housev_3i1_ruins.p3d",
        "ca\structures\house\housev\housev_3i3_ruins.p3d",
        "ca\structures\shed\shed_small\shed_w4.p3d",
        "ca\structures\shed\shed_small\shed_w4_ruins.p3d",
        "ca\structures\shed_ind\shed_ind02.p3d",
        "ca\structures_e\misc\shed_m01_ep1.p3d"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "ca\buildings\dum_mesto_in.p3d"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "ca\buildings\deutshe_mini.p3d",
        "ca\buildings\dum_mesto_in.p3d",
        "ca\buildings\dum_rasovna.p3d"
    ];

    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        "ca\structures\nav_boathouse\nav_boathouse_piert.p3d"
    ];

};
