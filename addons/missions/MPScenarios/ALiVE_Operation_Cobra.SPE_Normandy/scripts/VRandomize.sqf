// Define "_this" variable
private _this = _this select 0;

// Vehicle initialization settings

[
    vehicle _this, 
    ["Camo1",0.5,"Camo2",0.5,"Camo3",0.5,"Camo4",0.5,"Camo5",0.5,"Camo6",0.5,"crew_camo_1_2AD",0.5,"crew_camo_1_3AD",0.5,"crew_camo_1",0.5,"crew_camo_1_4AD",0.5], 
    ["rhino_hide_source",0.4,"skirts_hide_source",0.5,"armour_hide_source",0.5,"logs_hide_source",0.5,"canopy_frame_hide_source",0.5,"canopy_hide_source",0.5,"winch_hide_source",0.5,"doorzad_hide",0.5,"tent_hide_source",0.5,
	"snorkel_hide_source",0.8,"gun_hide_cover_source",0.3,"Hide_Shields_Hull",0.5,"Hide_Shields_Turret",0.5,"hull_armour_hide_source",0.5,"turret_armour_hide_source",0.5]
] call BIS_fnc_initVehicle; 
[_this] call SPE_MissionUtilityFunctions_fnc_ReviveToksaInit;