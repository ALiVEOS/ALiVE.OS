/* 
* Filename:
* init.sqf
*
* Description:
* Executed when mission is started (before briefing screen)
* 
* Created by Jman
* Creation date: 05/04/2021
* 
* */
// ====================================================================================
// Includes
#include "macros.sqf"
// ====================================================================================
[] execNow "scripts\system.sqf";
// ====================================================================================	


//Grab multiplayer parameters and put them into readable variables
if (isMultiplayer) then {
	for [ {_i = 0}, {_i < count(paramsArray)}, {_i = _i + 1} ] do
	{
	        call compile format 
	        [
	                "PARAMS_%1 = %2",
	                (configName ((missionConfigFile >> "Params") select _i)),
	                (paramsArray select _i)
	        ];
	};
};

if (isNil "PARAMS_Enablemapmarkers") then {PARAMS_Enablemapmarkers = 1;};
if (isNil "PARAMS_Enablegroupmarkers") then {PARAMS_Enablegroupmarkers = 1;};

// ====================================================================================	
// Disable AI simuation in single player & editor preview
if (!isMultiplayer) then {
	skipTime 9;
	{if (_x != player) then {_x enableSimulation false}} forEach switchableUnits;
};
// ====================================================================================	

[vn_veh_steelking] call vn_ms_fnc_addRopeAttachEH;

// Set correct group Ids for radio comms
[] spawn {
    sleep 5;
    vn_grp_1marinexray_01 setGroupId ["1st Marine X-Ray"];
    vn_grp_steelking setGroupId ["Steel King 01"];
    (group vn_radio_xray) setGroupId ["XRAY"];
    (group vn_radio_xray_indig) setGroupId ["XRAY"];
    (group vn_radio_steelking) setGroupId ["STEELKING"];

};


