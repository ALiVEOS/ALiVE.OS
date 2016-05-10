// ALiVE_fnc_autoUpdateStaticData
private ["_categories","_choice","_enabled","_ctrl","_arr"];
// diag_log (_this);
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

	"ALIVE_civilianPopulationBuildingTypes",
	"ALIVE_civilianHQBuildingTypes",
	"ALIVE_civilianSettlementBuildingTypes",

	"ALIVE_civilianPowerBuildingTypes",
	"ALIVE_civilianCommsBuildingTypes",
	"ALIVE_civilianMarineBuildingTypes",
	"ALIVE_civilianRailBuildingTypes",
	"ALIVE_civilianFuelBuildingTypes",
	"ALIVE_civilianConstructionBuildingTypes"
];

if (_enabled == 1) then {
	call compile format["%1 pushback ALiVE_wrp_model",(_categories select _choice)];
} else {
	call compile format["%1 = %1 - [ALiVE_wrp_model]",(_categories select _choice)];
};

// systemchat format["%1 = %2",(_categories select _choice), call compile(_categories select _choice)];