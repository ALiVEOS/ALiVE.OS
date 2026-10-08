// ALiVE 3 index v3.1, made 2026-10-08 by the ALiVE web indexer, building positions measured
private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: seangola (ALiVE 3 index v3.1, 2026-10-08)"] call ALiVE_fnc_dump;

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

ALiVE_mapCompositionType = "Woodland";

 if (tolower(_worldName) == "seangola") then {
    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "a3\structures_f\walls\mil_wallbig_gate_f.p3d",
        "a3\structures_f_heli\furniture\rattantable_01_f.p3d",
        "a3\structures_f_heli\items\airport\portablehelipadlight_01_f.p3d",
        "ca\buildings\misc\zed_civil.p3d",
        "ca\buildings\podesta_10.p3d"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "ca\buildings\army_hut2.p3d",
        "ca\buildings\army_hut2_int.p3d",
        "ca\buildings\army_hut3_long_int.p3d",
        "ca\buildings\army_hut_int.p3d",
        "ca\buildings\army_hut_storrage.p3d",
        "ca\buildings\garaz_bez_tanku.p3d",
        "ca\buildings\hangar_2.p3d",
        "ca\buildings\hlidac_budka.p3d",
        "ca\buildings\posed.p3d",
        "ca\misc3\wf\wf_field_hospital_east.p3d",
        "ca\structures\mil\mil_barracks.p3d",
        "ca\structures\mil\mil_barracks_i.p3d",
        "ca\structures\mil\mil_controltower.p3d",
        "ca\structures\mil\mil_guardhouse.p3d",
        "ca\structures\mil\mil_house.p3d",
        "ca\structures_e\mil\mil_repair_center_ep1.p3d"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "ca\buildings\hangar_2.p3d",
        "ca\structures\mil\mil_controltower.p3d",
        "ca\structures\mil\mil_house.p3d"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "ca\buildings\hangar_2.p3d",
        "ca\structures\mil\mil_controltower.p3d",
        "ca\structures\mil\mil_house.p3d"
    ];

    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        "ca\structures\mil\mil_controltower.p3d",
        "ca\structures\mil\mil_house.p3d"
    ];

    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
        "ca\buildings\hangar_2.p3d",
        "ca\roads2\runway_poj_t_2.p3d",
        "ca\roads\runway_end27.p3d",
        "ca\roads\runway_end9.p3d",
        "ca\roads\runway_main.p3d"
    ];

    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [
        "ca\buildings\hangar_2.p3d",
        "ca\roads2\runway_poj_t_2.p3d",
        "ca\roads\runway_end27.p3d",
        "ca\roads\runway_end9.p3d",
        "ca\roads\runway_main.p3d"
    ];

    ALiVE_HeliBuildingTypes = ALiVE_HeliBuildingTypes + [
        "a3\structures_f\mil\helipads\helipadcircle_f.p3d"
    ];

    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
        "a3\structures_f\mil\helipads\helipadcircle_f.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "a3\structures_f\households\slum\slum_house01_f.p3d",
        "a3\structures_f\households\slum\slum_house02_f.p3d",
        "a3\structures_f\households\slum\slum_house03_f.p3d",
        "a3\structures_f\ind\shed\i_shed_ind_f.p3d",
        "ca\buildings2\ind_cementworks\ind_pec\ind_pec_03a.p3d",
        "ca\buildings2\ind_garage01\ind_garage01.p3d",
        "ca\buildings2\ind_workshop01\ind_workshop01_04.p3d",
        "ca\buildings2\shed_wooden\shed_wooden.p3d",
        "ca\buildings\watertower1.p3d",
        "ca\structures_e\ind\ind_garage01\ind_garage01_ep1.p3d",
        "ibr\seangola_obj\hut_2\afhut.p3d"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "a3\structures_f\households\slum\slum_house01_f.p3d",
        "a3\structures_f\households\slum\slum_house02_f.p3d",
        "a3\structures_f\households\slum\slum_house03_f.p3d",
        "ibr\seangola_obj\hut_2\afhut.p3d"
    ];

    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
        "ca\structures_e\ind\ind_powerstation\ind_powerstation_ep1.p3d"
    ];

    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
        "a3\structures_f\ind\transmitter_tower\communication_f.p3d"
    ];

    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        "ca\buildings\fuelstation.p3d"
    ];

};
