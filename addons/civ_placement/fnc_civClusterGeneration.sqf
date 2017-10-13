//#define DEBUG_MODE_FULL
#include <\x\alive\addons\civ_placement\script_component.hpp>
SCRIPT(civClusterGeneration);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_civClusterGeneration
Description:
Generates civilian clusters

Parameters:

Returns:

Examples:
(begin example)
[] call ALIVE_fnc_civClusterGeneration;
(end)

See Also:

Author:
Wolffy
ARJay
Peer Reviewed:
nil
---------------------------------------------------------------------------- */

call ALiVE_fnc_staticDataHandler;


// Find HQ locations
// ------------------------------------------------------------------

"CO - Searching HQ locations" call ALiVE_fnc_logger;

private _clusters_hq = [ALIVE_civilianHQBuildingTypes] call ALIVE_fnc_findTargets;
_clusters_hq = [_clusters_hq, "CIV", 50, "ColorBlack"] call ALIVE_fnc_setTargets;
_clusters_hq = [_clusters_hq] call ALIVE_fnc_consolidateClusters;

// Save the non consolidated clusters
private _clusters_copy_hq = [_clusters_hq] call ALIVE_fnc_copyClusters;

private _clusters = +_clusters_hq;



// Find civ power
// ------------------------------------------------------------------

"CO - Searching Power locations" call ALiVE_fnc_logger;

private _clusters_power = [ALIVE_civilianPowerBuildingTypes] call ALIVE_fnc_findTargets;
_clusters_power = [_clusters_power, "CIV", 40, "ColorYellow"] call ALIVE_fnc_setTargets;

// Consolidate locations
_clusters_power = [_clusters_power] call ALIVE_fnc_consolidateClusters;

// Save the non consolidated clusters
private _clusters_copy_power = [_clusters_power] call ALIVE_fnc_copyClusters;

_clusters append _clusters_power;
//_clusters = [_clusters] call ALIVE_fnc_consolidateClusters;



// Find civ comms
// ------------------------------------------------------------------

"CO - Searching Comms locations" call ALiVE_fnc_logger;

private _clusters_comms = [ALIVE_civilianCommsBuildingTypes] call ALIVE_fnc_findTargets;
_clusters_comms = [_clusters_comms, "CIV", 40, "ColorWhite"] call ALIVE_fnc_setTargets;

// Consolidate locations
_clusters_comms = [_clusters_comms] call ALIVE_fnc_consolidateClusters;

// Save the non consolidated clusters
private _clusters_copy_comms = [_clusters_comms] call ALIVE_fnc_copyClusters;

_clusters append _clusters_comms;
//_clusters = [_clusters] call ALIVE_fnc_consolidateClusters;



// Find civ marine
// ------------------------------------------------------------------

"CO - Searching Marine locations" call ALiVE_fnc_logger;

private _clusters_marine = [ALIVE_civilianMarineBuildingTypes] call ALIVE_fnc_findTargets;
_clusters_marine = [_clusters_marine, "CIV", 30, "ColorBlue"] call ALIVE_fnc_setTargets;

// Consolidate locations
_clusters_marine = [_clusters_marine] call ALIVE_fnc_consolidateClusters;

// Save the non consolidated clusters
private _clusters_copy_marine = [_clusters_marine] call ALIVE_fnc_copyClusters;

// Consolidate locations
_clusters append _clusters_marine;
//_clusters = [_clusters] call ALIVE_fnc_consolidateClusters;



// Find civ rail
// ------------------------------------------------------------------

"CO - Searching Rail locations" call ALiVE_fnc_logger;

private _clusters_rail = [ALIVE_civilianRailBuildingTypes] call ALIVE_fnc_findTargets;
_clusters_rail = [_clusters_rail, "CIV", 10, "ColorKhaki"] call ALIVE_fnc_setTargets;

// Consolidate locations
_clusters_rail = [_clusters_rail] call ALIVE_fnc_consolidateClusters;

// Save the non consolidated clusters
private _clusters_copy_rail = [_clusters_rail] call ALIVE_fnc_copyClusters;

// Consolidate locations
_clusters append _clusters_rail;
//_clusters = [_clusters] call ALIVE_fnc_consolidateClusters;



// Find civ fuel
// ------------------------------------------------------------------

"CO - Searching Fuel locations" call ALiVE_fnc_logger;

private _clusters_fuel = [ALIVE_civilianFuelBuildingTypes] call ALIVE_fnc_findTargets;
_clusters_fuel = [_clusters_fuel, "CIV", 30, "ColorOrange"] call ALIVE_fnc_setTargets;

// Consolidate locations
_clusters_fuel = [_clusters_fuel] call ALIVE_fnc_consolidateClusters;

// Save the non consolidated clusters
private _clusters_copy_fuel = [_clusters_fuel] call ALIVE_fnc_copyClusters;

// Consolidate locations
_clusters append _clusters_fuel;
//_clusters = [_clusters] call ALIVE_fnc_consolidateClusters;



// Find civ construction
// ------------------------------------------------------------------

"CO - Searching Construction locations" call ALiVE_fnc_logger;

private _clusters_construction = [ALIVE_civilianConstructionBuildingTypes] call ALIVE_fnc_findTargets;
_clusters_construction = [_clusters_construction, "CIV", 10, "ColorPink"] call ALIVE_fnc_setTargets;

// Consolidate locations
_clusters_construction = [_clusters_construction] call ALIVE_fnc_consolidateClusters;

// Save the non consolidated clusters
private _clusters_copy_construction = [_clusters_construction] call ALIVE_fnc_copyClusters;

// Consolidate locations
_clusters append _clusters_construction;
//_clusters = [_clusters] call ALIVE_fnc_consolidateClusters;



// Find civ settlements
// ------------------------------------------------------------------

"CO - Searching Settlement locations" call ALiVE_fnc_logger;

private _clusters_settlement = [ALIVE_civilianSettlementBuildingTypes] call ALIVE_fnc_findTargets;
_clusters_settlement = [_clusters_settlement, "CIV", 0, "ColorGreen"] call ALIVE_fnc_setTargets;

// Consolidate locations
_clusters_settlement = [_clusters_settlement] call ALIVE_fnc_consolidateClusters;

// Save the non consolidated clusters
private _clusters_copy_settlement = [_clusters_settlement] call ALIVE_fnc_copyClusters;

// Consolidate locations
_clusters append _clusters_settlement;



// Final Consolidation
// ------------------------------------------------------------------
"CO - Consolidating Clusters" call ALiVE_fnc_logger;
_clusters = [_clusters] call ALIVE_fnc_consolidateClusters;
"CO - Locations Completed" call ALiVE_fnc_logger;

{
    [_x, "debug", true] call ALIVE_fnc_cluster;
} forEach _clusters;



private _worldName = toLower(worldName);
private _exportString = '';
private _clusterCount = 0;


private _pV = productVersion;
_exportString = _exportString + format['ALIVE_clusterBuild = ["%1", "%2", %3, %4, "%5"];',_pV select 0, _pV select 1, _pV select 2, _pV select 3, _pV select 4];

private _objectivesName = 'ALIVE_clustersCiv';
private _result = [_clusters, _objectivesName] call ALIVE_fnc_staticClusterOutput;

_exportString = _exportString + _result;



if(count _clusters_copy_hq > 0) then {
    _objectivesName = 'ALIVE_clustersCivHQ';
    _result = [_clusters_copy_hq, _objectivesName, _clusterCount] call ALIVE_fnc_staticClusterOutput;
    _exportString = _exportString + _result;
}else{
    _objectivesName = 'ALIVE_clustersCivHQ';
    _result = format['%1 = [] call ALIVE_fnc_hashCreate;',_objectivesName];
    _exportString = _exportString + _result;
};

_clusterCount = _clusterCount + (count _clusters_copy_hq);

if(count _clusters_copy_power > 0) then {
    _objectivesName = 'ALIVE_clustersCivPower';
    _result = [_clusters_copy_power, _objectivesName, _clusterCount] call ALIVE_fnc_staticClusterOutput;
    _exportString = _exportString + _result;
}else{
    _objectivesName = 'ALIVE_clustersCivPower';
    _result = format['%1 = [] call ALIVE_fnc_hashCreate;',_objectivesName];
    _exportString = _exportString + _result;
};

_clusterCount = _clusterCount + (count _clusters_copy_power);

if(count _clusters_copy_comms > 0) then {
    _objectivesName = 'ALIVE_clustersCivComms';
    _result = [_clusters_copy_comms, _objectivesName, _clusterCount] call ALIVE_fnc_staticClusterOutput;
    _exportString = _exportString + _result;
}else{
    _objectivesName = 'ALIVE_clustersCivComms';
    _result = format['%1 = [] call ALIVE_fnc_hashCreate;',_objectivesName];
    _exportString = _exportString + _result;
};

_clusterCount = _clusterCount + (count _clusters_copy_comms);

if(count _clusters_copy_marine > 0) then {
    _objectivesName = 'ALIVE_clustersCivMarine';
    _result = [_clusters_copy_marine, _objectivesName, _clusterCount] call ALIVE_fnc_staticClusterOutput;
    _exportString = _exportString + _result;
}else{
    _objectivesName = 'ALIVE_clustersCivMarine';
    _result = format['%1 = [] call ALIVE_fnc_hashCreate;',_objectivesName];
    _exportString = _exportString + _result;
};

_clusterCount = _clusterCount + (count _clusters_copy_marine);

if(count _clusters_copy_rail > 0) then {
    _objectivesName = 'ALIVE_clustersCivRail';
    _result = [_clusters_copy_rail, _objectivesName, _clusterCount] call ALIVE_fnc_staticClusterOutput;
    _exportString = _exportString + _result;
}else{
    _objectivesName = 'ALIVE_clustersCivRail';
    _result = format['%1 = [] call ALIVE_fnc_hashCreate;',_objectivesName];
    _exportString = _exportString + _result;
};

_clusterCount = _clusterCount + (count _clusters_copy_rail);

if(count _clusters_copy_fuel > 0) then {
    _objectivesName = 'ALIVE_clustersCivFuel';
    _result = [_clusters_copy_fuel, _objectivesName, _clusterCount] call ALIVE_fnc_staticClusterOutput;
    _exportString = _exportString + _result;
}else{
    _objectivesName = 'ALIVE_clustersCivFuel';
    _result = format['%1 = [] call ALIVE_fnc_hashCreate;',_objectivesName];
    _exportString = _exportString + _result;
};

_clusterCount = _clusterCount + (count _clusters_copy_fuel);

if(count _clusters_copy_construction > 0) then {
    _objectivesName = 'ALIVE_clustersCivConstruction';
    _result = [_clusters_copy_construction, _objectivesName, _clusterCount] call ALIVE_fnc_staticClusterOutput;
    _exportString = _exportString + _result;
}else{
    _objectivesName = 'ALIVE_clustersCivConstruction';
    _result = format['%1 = [] call ALIVE_fnc_hashCreate;',_objectivesName];
    _exportString = _exportString + _result;
};

_clusterCount = _clusterCount + (count _clusters_copy_construction);

if(count _clusters_copy_settlement > 0) then {
    _objectivesName = 'ALIVE_clustersCivSettlement';
    _result = [_clusters_copy_settlement, _objectivesName, _clusterCount] call ALIVE_fnc_staticClusterOutput;
    _exportString = _exportString + _result;
}else{
    _objectivesName = 'ALIVE_clustersCivSettlement';
    _result = format['%1 = [] call ALIVE_fnc_hashCreate;',_objectivesName];
    _exportString = _exportString + _result;
};

_clusterCount = _clusterCount + (count _clusters_copy_settlement);


copyToClipboard _exportString;
["Civilian Objectives generation complete, results have been copied to the clipboard"] call ALIVE_fnc_dump;
["Should be pasted in file: civ_placement\clusters\clusters.%1_civ.sqf", _worldName] call ALIVE_fnc_dump;
