// ALiVE_fnc_autoUpdateStaticData
private ["_categories","_choice","_enabled","_ctrl","_arr"];

_ctrl = _this select 0;
_choice = _this select 1;
_enabled = _this select 2;

_categories = [

    "ALIVE_Indexing_Blacklist",
    "ALIVE_militaryBuildingTypes",
    "ALIVE_militaryParkingBuildingTypes",
    "ALIVE_militarySupplyBuildingTypes",
    "ALIVE_militaryHQBuildingTypes",

    "ALIVE_airBuildingTypes",
    "ALIVE_militaryAirBuildingTypes",
    "ALIVE_civilianAirBuildingTypes",

    "ALIVE_heliBuildingTypes",
    "ALIVE_militaryHeliBuildingTypes",
    "ALIVE_civilianHeliBuildingTypes",

    "ALIVE_civilianSettlementBuildingTypes",    
    "ALIVE_civilianHQBuildingTypes",
    "ALIVE_civilianPopulationBuildingTypes",

    "ALIVE_civilianPowerBuildingTypes",
    "ALIVE_civilianCommsBuildingTypes",
    "ALIVE_civilianMarineBuildingTypes",
    "ALIVE_civilianRailBuildingTypes",
    "ALIVE_civilianFuelBuildingTypes",
    "ALIVE_civilianConstructionBuildingTypes"
];

_update = missionNamespace getVariable (_categories select _choice);

if (_enabled == 1) then {
    _update pushback ALiVE_wrp_model; // Edits array in missionNamespace. No need to send back.
} else {
    _update = _update - [ALiVE_wrp_model]; // Creates copy of the array. Needs sending back to missionNameSpace
    missionNameSpace setVariable [(_categories select _choice),_update];
};
