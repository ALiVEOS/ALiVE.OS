// ALiVE 3 index v3.1, made 2026-10-06 by the ALiVE web indexer, building positions measured
private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: ryderwood (ALiVE 3 index v3.1, 2026-10-06)"] call ALiVE_fnc_dump;

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

 if (tolower(_worldName) == "ryderwood") then {
    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "bthbc_map_data\data\objects\castle\bthbc_castle_bastion.p3d",
        "bthbc_map_data\data\objects\castle\bthbc_castle_bastion_ruins.p3d",
        "bthbc_map_data\data\objects\castle\bthbc_castle_donjon.p3d",
        "bthbc_map_data\data\objects\castle\bthbc_castle_donjon_ruins.p3d",
        "bthbc_map_data\data\objects\castle\bthbc_castle_gate.p3d",
        "bthbc_map_data\data\objects\castle\bthbc_castle_gate_ruins.p3d",
        "bthbc_map_data\data\objects\castle\bthbc_castle_stairs_a.p3d",
        "bthbc_map_data\data\objects\castle\bthbc_castle_wall1_20.p3d",
        "bthbc_map_data\data\objects\castle\bthbc_castle_wall1_20_ruins.p3d",
        "bthbc_map_data\data\objects\castle\bthbc_castle_wall1_20_turn.p3d",
        "bthbc_map_data\data\objects\castle\bthbc_castle_wall1_corner.p3d",
        "bthbc_map_data\data\objects\castle\bthbc_castle_wall1_end.p3d",
        "bthbc_map_data\data\objects\castle\bthbc_castle_wall1_end_2.p3d",
        "bthbc_map_data\data\objects\castle\bthbc_castle_walls_10.p3d",
        "bthbc_map_data\data\objects\castle\bthbc_castle_walls_5_d.p3d",
        "bthbc_map_data\data\objects\castle\bthbc_castle_walls_end.p3d"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "bthbc_map_data\data\objects\castle\bthbc_castle_bergfrit.p3d",
        "bthbc_map_data\data\objects\castle\bthbc_castle_bergfrit_ruins.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "bthbc_map_data\data\objects\buildings\cabinshack_1.p3d",
        "ca\structures\shed\shed_small\shed_w4.p3d"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "bthbc_map_data\data\objects\buildings\cabinshack_1.p3d"
    ];

    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        "a3\structures_f\dominants\lighthouse\lighthouse_f.p3d",
        "a3\structures_f\dominants\lighthouse\lighthouse_small_f.p3d",
        "ca\structures\nav_boathouse\nav_boathouse.p3d",
        "ca\structures\nav_boathouse\nav_boathouse_pier.p3d"
    ];

    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
        "ca\buildings\misc\leseni2x.p3d"
    ];

};
