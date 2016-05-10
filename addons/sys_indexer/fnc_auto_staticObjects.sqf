private ["_categories","_result","_custom"];

_custom = _this select 0;

_categories = [

	["ALIVE_Indexing_Blacklist","Blacklist","Any objects that should not be included in analysis"],

	["ALIVE_militaryBuildingTypes","Military Buildings","All military buildings here"],
	["ALIVE_militaryParkingBuildingTypes","Military - Parking","Buildings that ambient vehicles will be placed around"],
	["ALIVE_militarySupplyBuildingTypes","Military - Supply","Buildings that ambient supply boxes will be placed around"],
	["ALIVE_militaryHQBuildingTypes","Military - HQ","Buildings that can be selected as HQ locations"],
	["ALIVE_airBuildingTypes","Generic - Air","All building where fixed wing aircraft can be spawned"],
	["ALIVE_militaryAirBuildingTypes","Military - Air","Buildings that ambient fixed wing aircraft spawn in"],
	["ALIVE_civilianAirBuildingTypes","Civilian - Air","Buildings that ambient fixed wing aircraft spawn in"],

	["ALIVE_heliBuildingTypes","Generic - Air","All building where rotary wing aircraft can be spawned"],
	["ALIVE_militaryHeliBuildingTypes","Military - Heli","Buildings that ambient helicopters spawn in"],
	["ALIVE_civilianHeliBuildingTypes","Civilian - Heli","Buildings that ambient helicopters spawn in"],

	["ALIVE_civilianPopulationBuildingTypes","Civilian - Population","Buildings that ambient civs can spawn in and ambient vehicles can spawn around"],
	["ALIVE_civilianHQBuildingTypes","Civilian - HQ","Buildings that can be selected as HQ locations for insurgency/occupation"],
	["ALIVE_civilianSettlementBuildingTypes","Civilian - Settlement","All buildings used to create a civilian cluster (this should include all buildings listed in Civilian - Population)"],

	["ALIVE_civilianPowerBuildingTypes","Civilian - Power",""],
	["ALIVE_civilianCommsBuildingTypes","Civilian - Comms",""],
	["ALIVE_civilianMarineBuildingTypes","Civilian - Marine",""],
	["ALIVE_civilianRailBuildingTypes","Civilian - Rail",""],
	["ALIVE_civilianFuelBuildingTypes","Civilian - Fuel",""],
	["ALIVE_civilianConstructionBuildingTypes","Civilian - Construction",""]
];

// Init arrays
if (_custom) then {
	[">>>>>>>>>>>>>>>>>> Starting static data creation"] call ALiVE_fnc_dump;
	{
		call compile format["%1 = []", _x select 0];
	} foreach _categories;

	{
		private ["_model","_samples","_idc"];
		_model = _x select 0;
		_samples = _x select 1;
		ALiVE_wrp_model = _model;
		ALIVE_map_index_choice = 99;
		_i = 0;
		createDialog "alive_indexing_list";

		while {ALIVE_map_index_choice == 99} do
		{
			private ["_o","_id","_pos","_obj","_cam","_size"];
			_o = _samples select _i;
			_id = _o select 0;
			_pos = _o select 1;
			_obj = _pos nearestObject _id;

            if (!isNil "_obj") then {
    			_cam = [_obj, false, "HIGH"] call ALiVE_fnc_addCamera;
    			[_cam, true] call ALIVE_fnc_startCinematic;
    			cutText [format["Progress:%3/%4 - Object: %1, Model: %2", typeof _obj, str(_model), _foreachIndex + 1, count wrp_objects],"PLAIN DOWN"];

    			_size = sizeOf (typeof _obj);
    			if (isnil "_size" || _size == 0) then {_size = 8};

    			// diag_log str(_size);

    			[_cam,_obj,2,false, -2 * _size, _size * 0.5] call ALIVE_fnc_chaseShot;

    			sleep 1;
    			camDestroy _cam;
            } else {
                [">>>>>>>>>>>>>>>>>>>>>>>>>>>> Warning: could not find object for %1 at %2", _model, _pos] call ALiVE_fnc_dump;
            };
			_i = _i + 1;
			if (_i == count _samples) then {_i = 0;};
		};

		// Once choice made, record choice in array
		// call compile format['%1 pushBack "%2"', ((_categories select ALIVE_map_index_choice) select 0), _model];
		// Reset Checkboxes
		closeDialog 0;

	} foreach wrp_objects;
} else {
	[">>>>>>>>>>>>>>>>>> Using default static data set"] call ALiVE_fnc_dump;

	ALIVE_Indexing_Blacklist = [];

	ALIVE_heliBuildingTypes = [
		"helipads"
	];

 	ALIVE_airBuildingTypes = [
    	"hangar"
    ];

    ALIVE_militaryParkingBuildingTypes = [
    	"bunker",
    	"cargo_house_v",
    	"cargo_patrol_",
    	"research"
    ];

    ALIVE_militarySupplyBuildingTypes = [
    	"barrack",
    	"cargo_hq_",
    	"miloffices",
    	"cargo_house_v",
    	"cargo_patrol_",
    	"research"
    ];

    ALIVE_militaryHQBuildingTypes = [
    	"barrack",
    	"cargo_hq_",
    	"miloffices",
    	"cargo_tower"
    ];

    ALIVE_militaryAirBuildingTypes = [
    	"tenthangar"
    ];

    ALIVE_civilianAirBuildingTypes = [
    	"hangar",
    	"runway_beton",
    	"runway_main",
    	"runway_secondary"
    ];

    ALIVE_militaryHeliBuildingTypes = [
    	"helipads"
    ];

    ALIVE_civilianHeliBuildingTypes = [
    	"helipads"
    ];

    ALIVE_militaryBuildingTypes = [
    	"airport_tower",
    	"radar",
    	"bunker",
    	"cargo_house_v",
    	"cargo_patrol_",
    	"research",
    	"mil_wall",
    	"fortification",
    	"razorwire",
    	"dome"
    ];

    ALIVE_civilianPopulationBuildingTypes = [
        "house_",
        "shop_",
        "garage_",
        "stone_"
    ];

    ALIVE_civilianHQBuildingTypes = [
    	"offices"
    ];

    ALIVE_civilianPowerBuildingTypes = [
    	"dp_main",
    	"spp_t"
    ];

    ALIVE_civilianCommsBuildingTypes = [
    	"communication_f",
    	"ttowerbig_"
    ];

    ALIVE_civilianMarineBuildingTypes = [
    	"crane",
    	"lighthouse",
    	"nav_pier",
    	"pier_"
    ];

    ALIVE_civilianRailBuildingTypes = [

    ];

    ALIVE_civilianFuelBuildingTypes = [
    	"fuelstation",
    	"dp_bigtank"
    ];

    ALIVE_civilianConstructionBuildingTypes = [
    	"wip",
    	"bridge_highway"
    ];

    ALIVE_civilianSettlementBuildingTypes = [
        "church",
    	"hospital",
    	"amphitheater",
    	"chapel_v",
    	"households"
    ];

	ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
        "hangar"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "bunker"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "barrack",
        "mil_house",
        "mil_controltower"
    ];

    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        "barrack",
        "mil_house",
        "mil_controltower"
    ];

    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [

    ];

    ALIVE_civilianAirBuildingTypes = ALIVE_civilianAirBuildingTypes + [
        "ss_hangar",
        "hangar_2",
        "hangar",
        "runway_beton",
        "runway_end",
        "runway_main",
        "runway_secondary"
    ];

    ALIVE_militaryHeliBuildingTypes = ALIVE_militaryHeliBuildingTypes + [
    ];

    ALIVE_civilianHeliBuildingTypes = ALIVE_civilianHeliBuildingTypes + [
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "deerstand",
        "vez"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "a_office01",
        "a_office02",
        "a_municipaloffice"
    ];

    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
        "pec_",
        "powerstation",
        "trafostanica"
    ];

    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
        "illuminanttower",
        "vysilac_fm",
        "telek",
        "tvtower"
    ];

    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        "crane",
        "lighthouse",
        "nav_pier",
        "pier_",
        "pier"
    ];

    ALIVE_civilianRailBuildingTypes = ALIVE_civilianRailBuildingTypes + [
        "rail_house",
        "rail_station",
        "rail_platform",
        "rails_bridge",
        "stationhouse"
    ];

    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        "fuelstation",
        "expedice",
        "indpipe",
        "komin",
        "ind_stack_big",
        "ind_tankbig",
        "fuel_tank_big"
    ];

    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
        "ind_mlyn_01",
        "ind_pec_01",
        "wip",
        "sawmillpen",
        "workshop"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "hospital",
        "houseblock",
        "generalstore",
        "house"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianSettlementBuildingTypes;
};


// Dump arrays to extension that can write the staticData file
[">>>>>>>>>>>>>>>>>> Writing static data to file..."] call ALiVE_fnc_dump;

// Set the mapbounds
_mapBounds = [ALIVE_mapBounds, worldname, 0] call ALIVE_fnc_hashGet;
if (_mapBounds != 0) then {
    _result = "ALiVEClient" callExtension format['staticData~%1|[ALIVE_mapBounds, worldName, %2] call ALIVE_fnc_hashSet;',worldName,_mapBounds];
};

{
	private ["_array","_arrayActual","_result"];
	_array = _x select 0;
	_arrayActual = call compile _array;
	diag_log format['staticData~%1|%2 = %2 + %3;',worldName,_array, _arrayActual];
	_result = "ALiVEClient" callExtension format['staticData~%1|%2 = %2 + %3;',worldName,_array, _arrayActual];
	//diag_log str(_result);
} foreach _categories;

_result = "ALiVEClient" callExtension format['staticData~%1|};',worldName];
// diag_log str(_result);
[">>>>>>>>>>>>>>>>>> Completed static data..."] call ALiVE_fnc_dump;
true