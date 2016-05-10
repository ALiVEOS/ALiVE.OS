//#define DEBUG_MODE_FULL
#include <\x\alive\addons\civ_placement\script_component.hpp>
SCRIPT(auto_civClusterGeneration);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_auto_civClusterGeneration
Description:
Generates civilian clusters

Parameters:

Returns:

Examples:
(begin example)
[] call ALIVE_fnc_auto_civClusterGeneration;
(end)

See Also:

Author:
Wolffy
ARJay
Peer Reviewed:
nil
---------------------------------------------------------------------------- */

private ["_file","_obj_array","_types","_clusters","_clusters_tmp","_size"];

_file = format["@ALiVE\indexing\%1\x\alive\addons\main\static\%1_staticData.sqf", worldName];
call compile preprocessFileLineNumbers _file;

// Find HQ locations
// ------------------------------------------------------------------
private ["_clusters_hq","_clusters_copy_hq"];

"CO - Searching HQ locations" call ALiVE_fnc_logger;

_clusters_hq = [ALIVE_civilianHQBuildingTypes] call ALIVE_fnc_findTargets;
_clusters_hq = [_clusters_hq, "CIV", 50, "ColorBlack"] call ALIVE_fnc_setTargets;
_clusters_hq = [_clusters_hq] call ALIVE_fnc_consolidateClusters;

// Save the non consolidated clusters
_clusters_copy_hq = [_clusters_hq] call ALIVE_fnc_copyClusters;

_clusters = +_clusters_hq;



// Find civ power
// ------------------------------------------------------------------
private ["_clusters_power","_clusters_copy_power"];

"CO - Searching Power locations" call ALiVE_fnc_logger;

_clusters_power = [ALIVE_civilianPowerBuildingTypes] call ALIVE_fnc_findTargets;
_clusters_power = [_clusters_power, "CIV", 40, "ColorYellow"] call ALIVE_fnc_setTargets;

// Consolidate locations
_clusters_power = [_clusters_power] call ALIVE_fnc_consolidateClusters;

// Save the non consolidated clusters
_clusters_copy_power = [_clusters_power] call ALIVE_fnc_copyClusters;

_clusters = _clusters + _clusters_power;
//_clusters = [_clusters] call ALIVE_fnc_consolidateClusters;



// Find civ comms
// ------------------------------------------------------------------
private ["_clusters_comms","_clusters_copy_comms"];

"CO - Searching Comms locations" call ALiVE_fnc_logger;

_clusters_comms = [ALIVE_civilianCommsBuildingTypes] call ALIVE_fnc_findTargets;
_clusters_comms = [_clusters_comms, "CIV", 40, "ColorWhite"] call ALIVE_fnc_setTargets;

// Consolidate locations
_clusters_comms = [_clusters_comms] call ALIVE_fnc_consolidateClusters;

// Save the non consolidated clusters
_clusters_copy_comms = [_clusters_comms] call ALIVE_fnc_copyClusters;

_clusters = _clusters + _clusters_comms;
//_clusters = [_clusters] call ALIVE_fnc_consolidateClusters;



// Find civ marine
// ------------------------------------------------------------------
private ["_clusters_marine","_clusters_copy_marine"];

"CO - Searching Marine locations" call ALiVE_fnc_logger;

_clusters_marine = [ALIVE_civilianMarineBuildingTypes] call ALIVE_fnc_findTargets;
_clusters_marine = [_clusters_marine, "CIV", 30, "ColorBlue"] call ALIVE_fnc_setTargets;

// Consolidate locations
_clusters_marine = [_clusters_marine] call ALIVE_fnc_consolidateClusters;

// Save the non consolidated clusters
_clusters_copy_marine = [_clusters_marine] call ALIVE_fnc_copyClusters;

// Consolidate locations
_clusters = _clusters + _clusters_marine;
//_clusters = [_clusters] call ALIVE_fnc_consolidateClusters;



// Find civ rail
// ------------------------------------------------------------------
private ["_clusters_rail","_clusters_copy_rail"];

"CO - Searching Rail locations" call ALiVE_fnc_logger;

_clusters_rail = [ALIVE_civilianRailBuildingTypes] call ALIVE_fnc_findTargets;
_clusters_rail = [_clusters_rail, "CIV", 10, "ColorKhaki"] call ALIVE_fnc_setTargets;

// Consolidate locations
_clusters_rail = [_clusters_rail] call ALIVE_fnc_consolidateClusters;

// Save the non consolidated clusters
_clusters_copy_rail = [_clusters_rail] call ALIVE_fnc_copyClusters;

// Consolidate locations
_clusters = _clusters + _clusters_rail;
//_clusters = [_clusters] call ALIVE_fnc_consolidateClusters;



// Find civ fuel
// ------------------------------------------------------------------
private ["_clusters_fuel","_clusters_copy_fuel"];

"CO - Searching Fuel locations" call ALiVE_fnc_logger;

_clusters_fuel = [ALIVE_civilianFuelBuildingTypes] call ALIVE_fnc_findTargets;
_clusters_fuel = [_clusters_fuel, "CIV", 30, "ColorOrange"] call ALIVE_fnc_setTargets;

// Consolidate locations
_clusters_fuel = [_clusters_fuel] call ALIVE_fnc_consolidateClusters;

// Save the non consolidated clusters
_clusters_copy_fuel = [_clusters_fuel] call ALIVE_fnc_copyClusters;

// Consolidate locations
_clusters = _clusters + _clusters_fuel;
//_clusters = [_clusters] call ALIVE_fnc_consolidateClusters;



// Find civ construction
// ------------------------------------------------------------------
private ["_clusters_construction","_clusters_copy_construction"];

"CO - Searching Construction locations" call ALiVE_fnc_logger;

_clusters_construction = [ALIVE_civilianConstructionBuildingTypes] call ALIVE_fnc_findTargets;
_clusters_construction = [_clusters_construction, "CIV", 10, "ColorPink"] call ALIVE_fnc_setTargets;

// Consolidate locations
_clusters_construction = [_clusters_construction] call ALIVE_fnc_consolidateClusters;

// Save the non consolidated clusters
_clusters_copy_construction = [_clusters_construction] call ALIVE_fnc_copyClusters;

// Consolidate locations
_clusters = _clusters + _clusters_construction;
//_clusters = [_clusters] call ALIVE_fnc_consolidateClusters;



// Find civ settlements
// ------------------------------------------------------------------
private ["_clusters_settlement","_clusters_copy_settlement"];

"CO - Searching Settlement locations" call ALiVE_fnc_logger;

_clusters_settlement = [ALIVE_civilianSettlementBuildingTypes] call ALIVE_fnc_findTargets;
_clusters_settlement = [_clusters_settlement, "CIV", 0, "ColorGreen"] call ALIVE_fnc_setTargets;

// Consolidate locations
_clusters_settlement = [_clusters_settlement] call ALIVE_fnc_consolidateClusters;

// Save the non consolidated clusters
_clusters_copy_settlement = [_clusters_settlement] call ALIVE_fnc_copyClusters;

// Consolidate locations
_clusters = _clusters + _clusters_settlement;



// Final Consolidation
// ------------------------------------------------------------------
"CO - Consolidating Clusters" call ALiVE_fnc_logger;
_clusters = [_clusters] call ALIVE_fnc_consolidateClusters;
"CO - Locations Completed" call ALiVE_fnc_logger;

{
	[_x, "debug", true] call ALIVE_fnc_cluster;
} forEach _clusters;



private ["_worldName","_objectivesName","_exportString","_result","_clusterCount","_pV"];

_worldName = toLower(worldName);
_clusterCount = 0;

"ALiVEClient" callExtension format["clusterData~%1|%2|#include <\x\alive\addons\civ_placement\script_component.hpp>",worldName, "civ"];

"ALiVEClient" callExtension format["clusterData~%1|%2|ALIVE_clusterBuild = [CLUSTERBUILD];",worldName, "civ"];

_pV = productVersion;
// "ALiVEClient" callExtension format['clusterData~%1|%2|** ALIVE_clusterBuild = ["%1", "%2", %3, %4, "%5"];',worldName, "civ", _pV select 0, _pV select 1, _pV select 2, _pV select 3, _pV select 4];

_objectivesName = "ALIVE_clustersCiv";
_result = [_clusters, _objectivesName, _clusterCount,"civ"] call ALIVE_fnc_auto_staticClusterOutput;
		diag_log _objectivesName;

if(count _clusters_copy_hq > 0) then {
	_objectivesName = "ALIVE_clustersCivHQ";
	_result = [_clusters_copy_hq, _objectivesName, _clusterCount,"civ"] call ALIVE_fnc_auto_staticClusterOutput;
			diag_log _objectivesName;

}else{
    _objectivesName = "ALIVE_clustersCivHQ";
	_result = [_clusters_copy_comms, _objectivesName, _clusterCount,"civ"] call ALIVE_fnc_auto_staticClusterOutput;
			diag_log _objectivesName;
};

_clusterCount = _clusterCount + (count _clusters_copy_hq);

if(count _clusters_copy_power > 0) then {
	_objectivesName = "ALIVE_clustersCivPower";
	_result = [_clusters_copy_power, _objectivesName, _clusterCount,"civ"] call ALIVE_fnc_auto_staticClusterOutput;
	diag_log _objectivesName;

}else{
    _objectivesName = "ALIVE_clustersCivPower";
	_result = [_clusters_copy_comms, _objectivesName, _clusterCount,"civ"] call ALIVE_fnc_auto_staticClusterOutput;
	diag_log _objectivesName;
};

_clusterCount = _clusterCount + (count _clusters_copy_power);

if(count _clusters_copy_comms > 0) then {
	_objectivesName = "ALIVE_clustersCivComms";
	_result = [_clusters_copy_comms, _objectivesName, _clusterCount,"civ"] call ALIVE_fnc_auto_staticClusterOutput;
			diag_log _objectivesName;

}else{
    _objectivesName = "ALIVE_clustersCivComms";
	"ALiVEClient" callExtension format["clusterData~%1|%2|%3 = [] call ALIVE_fnc_hashCreate;",worldName,"civ",_objectivesName];
};

_clusterCount = _clusterCount + (count _clusters_copy_comms);

if(count _clusters_copy_marine > 0) then {
	_objectivesName = "ALIVE_clustersCivMarine";
	_result = [_clusters_copy_marine, _objectivesName, _clusterCount,"civ"] call ALIVE_fnc_auto_staticClusterOutput;
			diag_log _objectivesName;

}else{
    _objectivesName = "ALIVE_clustersCivMarine";
	"ALiVEClient" callExtension format["clusterData~%1|%2|%3 = [] call ALIVE_fnc_hashCreate;",worldName,"civ",_objectivesName];
};

_clusterCount = _clusterCount + (count _clusters_copy_marine);

if(count _clusters_copy_rail > 0) then {
	_objectivesName = "ALIVE_clustersCivRail";
	_result = [_clusters_copy_rail, _objectivesName, _clusterCount,"civ"] call ALIVE_fnc_auto_staticClusterOutput;
			diag_log _objectivesName;

}else{
    _objectivesName = "ALIVE_clustersCivRail";
	"ALiVEClient" callExtension format["clusterData~%1|%2|%3 = [] call ALIVE_fnc_hashCreate;",worldName,"civ",_objectivesName];
};

_clusterCount = _clusterCount + (count _clusters_copy_rail);

if(count _clusters_copy_fuel > 0) then {
	_objectivesName = "ALIVE_clustersCivFuel";
	_result = [_clusters_copy_fuel, _objectivesName, _clusterCount,"civ"] call ALIVE_fnc_auto_staticClusterOutput;
		diag_log _objectivesName;
}else{
    _objectivesName = "ALIVE_clustersCivFuel";
	"ALiVEClient" callExtension format["clusterData~%1|%2|%3 = [] call ALIVE_fnc_hashCreate;",worldName,"civ",_objectivesName];
};

_clusterCount = _clusterCount + (count _clusters_copy_fuel);

if(count _clusters_copy_construction > 0) then {
	_objectivesName = "ALIVE_clustersCivConstruction";
	_result = [_clusters_copy_construction, _objectivesName, _clusterCount,"civ"] call ALIVE_fnc_auto_staticClusterOutput;
		diag_log _objectivesName;
}else{
    _objectivesName = "ALIVE_clustersCivConstruction";
	"ALiVEClient" callExtension format["clusterData~%1|%2|%3 = [] call ALIVE_fnc_hashCreate;",worldName,"civ",_objectivesName];
};

_clusterCount = _clusterCount + (count _clusters_copy_construction);

if(count _clusters_copy_settlement > 0) then {
	_objectivesName = "ALIVE_clustersCivSettlement";
	_result = [_clusters_copy_settlement, _objectivesName, _clusterCount,"civ"] call ALIVE_fnc_auto_staticClusterOutput;
		diag_log _objectivesName;
}else{
    _objectivesName = "ALIVE_clustersCivSettlement";
	"ALiVEClient" callExtension format["clusterData~%1|%2|%3 = [] call ALIVE_fnc_hashCreate;",worldName,"civ",_objectivesName];
};

_clusterCount = _clusterCount + (count _clusters_copy_settlement);


["Civilian Objectives generation complete, results written to file"] call ALIVE_fnc_dump;
