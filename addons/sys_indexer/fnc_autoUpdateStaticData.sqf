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
    "ALIVE_militaryFieldworkBuildingTypes",

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

private _update = missionNamespace getVariable (_categories select _choice);

if (_enabled == 1) then {
    // A fieldwork is somewhere soldiers stand. An object with no building positions would be listed
    // and never used, so refuse the tick. Unticking fires this handler again with _enabled 0, which
    // removes a model that was never added: harmless.
    if ((_categories select _choice) == "ALIVE_militaryFieldworkBuildingTypes" && {isNil "ALiVE_wrp_object" || {isNull ALiVE_wrp_object} || {(ALiVE_wrp_object buildingPos 0) isEqualTo [0,0,0]}}) then {
        _ctrl ctrlSetChecked [_choice, false];
        hintSilent "Not a fieldwork: the object on screen has no building positions, so soldiers can't stand in it.";
    } else {
        _update pushback ALiVE_wrp_model; // Edits array in missionNamespace. No need to send back.
    };
} else {
    _update = _update - [ALiVE_wrp_model]; // Creates copy of the array. Needs sending back to missionNamespace
    missionNamespace setVariable [(_categories select _choice),_update];
};
