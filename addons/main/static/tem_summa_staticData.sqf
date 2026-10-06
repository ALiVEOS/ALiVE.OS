// ALiVE 3 index v3.1, made 2026-10-06 by the ALiVE web indexer, building positions measured
private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: tem_summa (ALiVE 3 index v3.1, 2026-10-06)"] call ALiVE_fnc_dump;

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

 if (tolower(_worldName) == "tem_summa") then {
    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "a3\structures_f\civ\accessories\timbers_f.p3d",
        "a3\structures_f_exp\civilian\accessories\clothesline_01_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_06_f.p3d",
        "a3\structures_f_exp\military\pillboxes\pillboxwall_01_6m_f.p3d",
        "a3\structures_f_exp\military\pillboxes\pillboxwall_01_6m_round_f.p3d",
        "a3\structures_f_exp\naval\piers\pierwooden_03_f.p3d",
        "ca\buildings2\misc_waterstation\misc_waterstation.p3d"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "a3\structures_f\mil\bunker\bunker_f.p3d",
        "a3\structures_f_argo\military\bunkers\bunker_01_small_f.p3d",
        "a3\structures_f_argo\military\bunkers\bunker_01_tall_f.p3d",
        "a3\structures_f_exp\military\pillboxes\pillboxbunker_01_big_f.p3d",
        "a3\structures_f_exp\military\pillboxes\pillboxbunker_01_hex_f.p3d",
        "a3\structures_f_exp\military\pillboxes\pillboxbunker_01_rectangle_f.p3d",
        "ca\buildings\army_hut2.p3d",
        "ca\buildings\army_hut2_int.p3d",
        "ca\buildings\army_hut3_long.p3d",
        "ca\buildings\army_hut3_long_int.p3d",
        "ca\buildings\army_hut_storrage.p3d",
        "ca\buildings\garaz_bez_tanku.p3d",
        "ca\buildings\hlaska.p3d",
        "ca\structures_pmc\buildings\bunker\bunker_pmc.p3d"
    ];

    ALIVE_militaryFieldworkBuildingTypes = ALIVE_militaryFieldworkBuildingTypes + [
        "a3\structures_f_argo\military\bunkers\bunker_01_small_f.p3d",
        "a3\structures_f_argo\military\bunkers\bunker_01_tall_f.p3d",
        "a3\structures_f_exp\military\pillboxes\pillboxbunker_01_big_f.p3d",
        "a3\structures_f_exp\military\pillboxes\pillboxbunker_01_hex_f.p3d",
        "a3\structures_f_exp\military\pillboxes\pillboxbunker_01_rectangle_f.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "a3\structures_f\households\slum\slum_house03_f.p3d",
        "a3\structures_f_argo\industrial\agriculture\barn_01_brown_ruins_f.p3d",
        "a3\structures_f_exp\civilian\house_native_02\house_native_02_ruins_f.p3d",
        "a3\structures_f_exp\civilian\house_small_02\house_small_02_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_02_f.p3d",
        "ca\buildings2\a_generalstore_01\a_generalstore_01_ruins.p3d",
        "ca\buildings2\houseblocks\houseblock_b\houseblock_b2_ruins.p3d",
        "ca\buildings2\houseblocks\houseblock_b\houseblock_b5_ruins.p3d",
        "ca\buildings2\houseblocks\houseblock_c\houseblock_c1_ruins.p3d",
        "ca\buildings2\houseblocks\houseblock_c\houseblock_c3_ruins.p3d",
        "ca\buildings2\houseblocks\houseblock_c\houseblock_c5_ruins.p3d",
        "ca\buildings2\houseblocks\houseblock_d\houseblock_d2_ruins.p3d",
        "ca\buildings2\ind_garage01\ind_garage01.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_02.p3d",
        "ca\buildings2\shed_small\shed_m03.p3d",
        "ca\buildings2\shed_small\shed_w01.p3d",
        "ca\buildings2\shed_small\shed_w02.p3d",
        "ca\buildings\bouda1.p3d",
        "ca\buildings\bouda2_vnitrek.p3d",
        "ca\buildings\bouda3.p3d",
        "ca\buildings\budova3.p3d",
        "ca\buildings\deutshe_mini.p3d",
        "ca\buildings\dulni_bs.p3d",
        "ca\buildings\dum_mesto2.p3d",
        "ca\buildings\dum_mesto_in.p3d",
        "ca\buildings\dum_rasovna.p3d",
        "ca\buildings\dum_zboreny.p3d",
        "ca\buildings\dum_zboreny_total.p3d",
        "ca\buildings\hut_old02.p3d",
        "ca\buildings\kulna.p3d",
        "ca\buildings\ruins\deutshe_ruins.p3d",
        "ca\buildings\ruins\dum_zboreny_ruins.p3d",
        "ca\buildings\sara_domek_ruina.p3d",
        "ca\buildings\sara_domek_sedy.p3d",
        "ca\buildings\sara_domek_zluty.p3d",
        "ca\buildings\sara_stodola3.p3d",
        "ca\buildings\sara_zluty_statek_in.p3d",
        "ca\buildings\zalchata.p3d",
        "ca\structures\barn_w\barn_w_01_dam.p3d",
        "ca\structures\barn_w\barn_w_01_ruins.p3d",
        "ca\structures\barn_w\barn_w_02.p3d",
        "ca\structures\barn_w\barn_w_02_ruins.p3d",
        "ca\structures\house\a_office02\a_office02_ruins.p3d",
        "ca\structures\house\housev2\housev2_01b_ruins.p3d",
        "ca\structures\house\housev2\housev2_02_interier.p3d",
        "ca\structures\house\housev2\housev2_04_interier.p3d",
        "ca\structures\house\housev2\housev2_05.p3d",
        "ca\structures\house\housev\housev_1i1.p3d",
        "ca\structures\house\housev\housev_1i4.p3d",
        "ca\structures\house\housev\housev_1l1.p3d",
        "ca\structures\house\housev\housev_1t.p3d",
        "ca\structures\house\housev\housev_2i.p3d",
        "ca\structures\house\housev\housev_2t2.p3d",
        "ca\structures\house\housev\housev_3i1.p3d",
        "ca\structures\house\housev\housev_3i2.p3d",
        "ca\structures\house\housev\housev_3i3.p3d",
        "ca\structures\house\housev\housev_3i4.p3d",
        "ca\structures\shed\shed_small\shed_w4.p3d",
        "ca\structures\shed_ind\shed_ind02.p3d",
        "ca\structures_e\misc\shed_m01_ep1.p3d"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "ca\buildings\dum_mesto_in.p3d"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "a3\structures_f\households\slum\slum_house03_f.p3d",
        "a3\structures_f_exp\civilian\house_small_02\house_small_02_f.p3d",
        "ca\buildings\bouda2_vnitrek.p3d",
        "ca\buildings\budova3.p3d",
        "ca\buildings\deutshe_mini.p3d",
        "ca\buildings\dum_mesto_in.p3d",
        "ca\buildings\dum_rasovna.p3d",
        "ca\buildings\sara_domek_sedy.p3d",
        "ca\buildings\sara_domek_zluty.p3d",
        "ca\buildings\sara_zluty_statek_in.p3d",
        "ca\structures\barn_w\barn_w_02.p3d",
        "ca\structures\house\housev2\housev2_02_interier.p3d",
        "ca\structures\house\housev2\housev2_04_interier.p3d",
        "ca\structures\house\housev\housev_1i4.p3d",
        "ca\structures\house\housev\housev_2t2.p3d"
    ];

    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        "a3\structures_f_exp\naval\piers\pierwooden_02_16m_f.p3d",
        "ca\structures\nav_boathouse\nav_boathouse_pierl.p3d",
        "ca\structures\nav_boathouse\nav_boathouse_piert.p3d"
    ];

};
