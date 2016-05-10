//#define DEBUG_MODE_FULL
#include <\x\alive\addons\mil_placement\script_component.hpp>
SCRIPT(auto_milClusterGeneration);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_auto_milClusterGeneration
Description:
Generates military clusters

Parameters:

Returns:

Examples:
(begin example)
[] call ALIVE_fnc_auto_milClusterGeneration;

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

"MO - Searching HQ locations" call ALiVE_fnc_logger;

_clusters_hq = [ALIVE_militaryHQBuildingTypes] call ALIVE_fnc_findTargets;
_clusters_hq = [_clusters_hq, "MIL", 50, "ColorRed"] call ALIVE_fnc_setTargets;
_clusters_hq = [_clusters_hq] call ALIVE_fnc_consolidateClusters;

// Save the non consolidated clusters
_clusters_copy_hq = [_clusters_hq] call ALIVE_fnc_copyClusters;

_clusters = +_clusters_hq;


// Find mil air locations
// ------------------------------------------------------------------
private ["_clusters_mil_air","_clusters_civ_air","_clusters_air","_clusters_copy_air"];

"MO - Searching airfield locations" call ALiVE_fnc_logger;

_clusters_mil_air = [ALIVE_militaryAirBuildingTypes] call ALIVE_fnc_findTargets;
_clusters_mil_air = [_clusters_mil_air, "MIL", 20, "ColorOrange"] call ALIVE_fnc_setTargets;

// Find civ air locations
_clusters_civ_air = [ALIVE_civilianAirBuildingTypes] call ALIVE_fnc_findTargets;
_clusters_civ_air = [_clusters_civ_air, "MIL", 10, "ColorOrange"] call ALIVE_fnc_setTargets;

// Consolidate locations
_clusters_air = _clusters_mil_air + _clusters_civ_air;
_clusters_air = [_clusters_air] call ALIVE_fnc_consolidateClusters;

// Save the non consolidated clusters
_clusters_copy_air = [_clusters_air] call ALIVE_fnc_copyClusters;

_clusters = _clusters + _clusters_air;
_clusters = [_clusters] call ALIVE_fnc_consolidateClusters;



// Find mil heli locations
// ------------------------------------------------------------------
private ["_clusters_mil_heli","_clusters_civ_heli","_clusters_heli","_clusters_copy_heli"];

"MO - Searching helipad locations" call ALiVE_fnc_logger;
_clusters_mil_heli = [ALIVE_militaryHeliBuildingTypes] call ALIVE_fnc_findTargets;
_clusters_mil_heli = [_clusters_mil_heli, "MIL", 20, "ColorYellow"] call ALIVE_fnc_setTargets;

// Find civ heli locations
_clusters_civ_heli = [ALIVE_civilianHeliBuildingTypes] call ALIVE_fnc_findTargets;
_clusters_civ_heli = [_clusters_civ_heli, "MIL", 10, "ColorYellow"] call ALIVE_fnc_setTargets;

// Consolidate locations
_clusters_heli = _clusters_mil_heli + _clusters_civ_heli;
_clusters_heli = [_clusters_heli] call ALIVE_fnc_consolidateClusters;

// Save the non consolidated clusters
_clusters_copy_heli = [_clusters_heli] call ALIVE_fnc_copyClusters;

_clusters = _clusters + _clusters_heli;
_clusters = [_clusters] call ALIVE_fnc_consolidateClusters;



// Find general military locations
// ------------------------------------------------------------------
private ["_clusters_mil"];

"MO - Searching military locations" call ALiVE_fnc_logger;

// Military targets
_clusters_mil = [ALIVE_militaryBuildingTypes] call ALIVE_fnc_findTargets;
_clusters_mil = [_clusters_mil, "MIL", 0, "ColorGreen"] call ALIVE_fnc_setTargets;

// Consolidate locations
_clusters = _clusters + _clusters_mil;
_clusters = [_clusters] call ALIVE_fnc_consolidateClusters;



// Final Consolidation
// ------------------------------------------------------------------
"MO - Consolidating Clusters" call ALiVE_fnc_logger;
_clusters = [_clusters] call ALIVE_fnc_consolidateClusters;
"MO - Locations Completed" call ALiVE_fnc_logger;

{
	[_x, "debug", true] call ALIVE_fnc_cluster;
} forEach _clusters;



private ["_worldName","_objectivesName","_exportString","_result","_clusterCount","_pV"];

_worldName = toLower(worldName);

_clusterCount = 0;

"ALiVEClient" callExtension format["clusterData~%1|%2|#include <\x\alive\addons\civ_placement\script_component.hpp>",worldName, "mil"];

"ALiVEClient" callExtension format["clusterData~%1|%2|ALIVE_clusterBuild = [CLUSTERBUILD];",worldName, "mil"];

_pV = productVersion;
// "ALiVEClient" callExtension format['clusterData~%1|%2|** ALIVE_clusterBuild = ["%1", "%2", %3, %4, "%5"];',worldName, "mil", _pV select 0, _pV select 1, _pV select 2, _pV select 3, _pV select 4];

_objectivesName = "ALIVE_clustersMil";
_result = [_clusters, _objectivesName, _clusterCount,"mil"] call ALIVE_fnc_auto_staticClusterOutput;

_clusterCount = _clusterCount + count _clusters;


if(count _clusters_copy_hq > 0) then {
	_objectivesName = "ALIVE_clustersMilHQ";
	_result = [_clusters_copy_hq, _objectivesName, _clusterCount,"mil"] call ALIVE_fnc_auto_staticClusterOutput;
	diag_log _objectivesName;
}else{
    _objectivesName = "ALIVE_clustersMilHQ";
    "ALiVEClient" callExtension format["clusterData~%1|%2|%3 = [] call ALIVE_fnc_hashCreate;",worldName,"mil",_objectivesName];
};

_clusterCount = _clusterCount + count _clusters_copy_hq;

if(count _clusters_copy_air > 0) then {
	_objectivesName = "ALIVE_clustersMilAir";
	_result = [_clusters_copy_air, _objectivesName, _clusterCount,"mil"] call ALIVE_fnc_auto_staticClusterOutput;
		diag_log _objectivesName;
}else{
    _objectivesName = "ALIVE_clustersMilAir";
    "ALiVEClient" callExtension format["clusterData~%1|%2|%3 = [] call ALIVE_fnc_hashCreate;",worldName,"mil",_objectivesName];
};

_clusterCount = _clusterCount + count _clusters_copy_air;

if(count _clusters_copy_heli > 0) then {
	_objectivesName = "ALIVE_clustersMilHeli";
	_result = [_clusters_copy_heli, _objectivesName, _clusterCount,"mil"] call ALIVE_fnc_auto_staticClusterOutput;
		diag_log _objectivesName;
}else{
    _objectivesName = "ALIVE_clustersMilHeli";
    "ALiVEClient" callExtension format["clusterData~%1|%2|%3 = [] call ALIVE_fnc_hashCreate;",worldName,"mil",_objectivesName];
};

_clusterCount = _clusterCount + count _clusters_copy_heli;

["Military Objectives generation complete, results written to file"] call ALIVE_fnc_dump;
