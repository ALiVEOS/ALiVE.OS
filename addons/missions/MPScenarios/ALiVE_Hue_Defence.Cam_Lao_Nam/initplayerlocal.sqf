/* 
* Filename:
* initPlayerLocal.sqf 
* 
* Arguments:
* [player:Object, didJIP:Boolean]
*
* Description:
* Executed locally when player joins mission (includes both mission start and JIP).
* 
* Created by [KH]Jman
* Creation date: 05/04/2021
* Email: jman@kellys-heroes.eu
* Web: http://www.kellys-heroes.eu
* 
* */
// ====================================================================================

_player = _this select 0;
_didJIP = _this select 1;

// init map markers 
if (isNil "PARAMS_Enablemapmarkers") then {PARAMS_Enablemapmarkers = 0;};
diag_log format["%2: initPlayerLocal.sqf -> PARAMS_Enablemapmarkers: %1", PARAMS_Enablemapmarkers, missionName];
if (PARAMS_Enablemapmarkers == 1) then {
	[] execVM "scripts\mapMarkers.sqf";
};


// init group markers (3D)
if (isNil "PARAMS_Enablegroupmarkers") then {PARAMS_Enablegroupmarkers = 0;};
diag_log format["%2: initPlayerLocal.sqf -> PARAMS_Enablegroupmarkers: %1", PARAMS_Enablegroupmarkers, missionName];
if (PARAMS_Enablegroupmarkers == 1) then {
		#include "scripts\groupMarkers.sqf";
};

