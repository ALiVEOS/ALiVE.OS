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
[] call compile preprocessFileLineNumbers "scripts\system.sqf";
// ====================================================================================	
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
[vn_veh_steelking] call vn_ms_fnc_addRopeAttachEH;


