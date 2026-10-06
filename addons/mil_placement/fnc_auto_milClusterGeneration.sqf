//#define DEBUG_MODE_FULL
#include "\x\alive\addons\mil_placement\script_component.hpp"
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
Jman
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

"ALiVEClient" callExtension format["clusterData~%1|%2|#include ""\x\alive\addons\civ_placement\script_component.hpp""",worldName, "mil"];

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

// Fieldwork groups
// ------------------------------------------------------------------
// Every model ticked as a fieldwork (trench, bunker, sandbag position) within 50 m of another is linked
// into one group, the same single-link grouping as the web indexer, and a group of three or more becomes
// a fieldwork objective. Military Placement only uses them when its Fieldworks setting asks for them.
// The list is written even when empty, so Military Placement can tell "no groups" from an older index.
"MO - Searching fieldwork groups" call ALiVE_fnc_logger;

private _fwLink = 50;
private _fwFewest = 3;

private _fwModels = createHashMap;
{
    _fwModels set [toLower _x, true];
} forEach (missionNamespace getVariable ["ALIVE_militaryFieldworkBuildingTypes", []]);

// [id, x, y] for every placed fieldwork, from the object list the indexer read in
private _fwPoints = [];
if (count _fwModels > 0) then {
    {
        _x params ["_fwModel", "_fwInstances"];
        if ((toLower _fwModel) in _fwModels) then {
            {
                private _fwId = _x select 0;
                if (_fwId isEqualType 0) then {_fwId = _fwId toFixed 0};
                _fwPoints pushBack [_fwId, (_x select 1) select 0, (_x select 1) select 1];
            } forEach _fwInstances;
        };
    } forEach (missionNamespace getVariable ["wrp_objects", []]);
};

// Union-find over a grid of _fwLink-metre cells: only the 3x3 cells around a point can hold a link
private _fwParent = [];
for "_i" from 0 to (count _fwPoints - 1) do {_fwParent pushBack _i};

private _fwRoot = {
    private _node = _this;
    while {(_fwParent select _node) != _node} do {
        _fwParent set [_node, _fwParent select (_fwParent select _node)];
        _node = _fwParent select _node;
    };
    _node
};

private _fwGrid = createHashMap;
{
    private _cell = [floor ((_x select 1) / _fwLink), floor ((_x select 2) / _fwLink)];
    if !(_cell in _fwGrid) then {_fwGrid set [_cell, []]};
    (_fwGrid get _cell) pushBack _forEachIndex;
} forEach _fwPoints;

{
    private _cell = _x;
    private _members = _y;
    for "_dx" from -1 to 1 do {
        for "_dy" from -1 to 1 do {
            private _others = _fwGrid getOrDefault [[(_cell select 0) + _dx, (_cell select 1) + _dy], []];
            {
                private _j = _x;
                {
                    private _i = _x;
                    if (_i < _j) then {
                        private _p = _fwPoints select _i;
                        private _q = _fwPoints select _j;
                        if (([_p select 1, _p select 2] distance2D [_q select 1, _q select 2]) <= _fwLink) then {
                            _fwParent set [_i call _fwRoot, _j call _fwRoot];
                        };
                    };
                } forEach _members;
            } forEach _others;
        };
    };
} forEach _fwGrid;

private _fwByRoot = createHashMap;
{
    private _r = _forEachIndex call _fwRoot;
    if !(_r in _fwByRoot) then {_fwByRoot set [_r, []]};
    (_fwByRoot get _r) pushBack _x;
} forEach _fwPoints;

// Groups of three or more, largest first
private _fwGroups = (values _fwByRoot) select {count _x >= _fwFewest};
private _fwOrder = [];
{
    _fwOrder pushBack [-(count _x), _forEachIndex];
} forEach _fwGroups;
_fwOrder sort true;
_fwGroups = _fwOrder apply {_fwGroups select (_x select 1)};

[">>>>>>>>>>>>>>>>>> Fieldworks: %1 models, %2 points, %3 groups of %4 or more", count _fwModels, count _fwPoints, count _fwGroups, _fwFewest] call ALiVE_fnc_dump;

"ALiVEClient" callExtension format["clusterData~%1|%2|// fieldworks: used only when Military Placement's Fieldworks setting asks for them",worldName,"mil"];
"ALiVEClient" callExtension format["clusterData~%1|%2|ALIVE_clustersMilFieldwork = [] call ALIVE_fnc_hashCreate;",worldName,"mil"];

{
    private _group = _x;
    private _cx = 0;
    private _cy = 0;
    {
        _cx = _cx + (_x select 1);
        _cy = _cy + (_x select 2);
    } forEach _group;
    _cx = _cx / (count _group);
    _cy = _cy / (count _group);

    private _far = 0;
    {
        _far = _far max ([_cx, _cy] distance2D [_x select 1, _x select 2]);
    } forEach _group;
    private _fwSize = (((ceil (_far / 10)) * 10 + 20) max 50) min 500;

    "ALiVEClient" callExtension format['clusterData~%1|%2|_cluster = [nil, "create"] call ALIVE_fnc_cluster;',worldName,"mil"];
    "ALiVEClient" callExtension format['clusterData~%1|%2|_nodes = [];',worldName,"mil"];
    {
        "ALiVEClient" callExtension format['clusterData~%1|%2|_nodes set [count _nodes, ["%3",[%4,%5,0]]];',worldName,"mil",_x select 0,(_x select 1) toFixed 2,(_x select 2) toFixed 2];
    } forEach _group;
    "ALiVEClient" callExtension format['clusterData~%1|%2|[_cluster,"nodes",_nodes] call ALIVE_fnc_hashSet;',worldName,"mil"];
    "ALiVEClient" callExtension format['clusterData~%1|%2|[_cluster, "state", _cluster] call ALIVE_fnc_cluster;',worldName,"mil"];
    "ALiVEClient" callExtension format['clusterData~%1|%2|[_cluster,"clusterID","c_%3"] call ALIVE_fnc_hashSet;',worldName,"mil",_clusterCount];
    "ALiVEClient" callExtension format['clusterData~%1|%2|[_cluster,"center",[%3,%4]] call ALIVE_fnc_hashSet;',worldName,"mil",_cx toFixed 2,_cy toFixed 2];
    "ALiVEClient" callExtension format['clusterData~%1|%2|[_cluster,"size",%3] call ALIVE_fnc_hashSet;',worldName,"mil",_fwSize];
    "ALiVEClient" callExtension format['clusterData~%1|%2|[_cluster,"type","MIL"] call ALIVE_fnc_hashSet;',worldName,"mil"];
    "ALiVEClient" callExtension format['clusterData~%1|%2|[_cluster,"priority",5] call ALIVE_fnc_hashSet;',worldName,"mil"];
    "ALiVEClient" callExtension format['clusterData~%1|%2|[_cluster,"debugColor","ColorBrown"] call ALIVE_fnc_hashSet;',worldName,"mil"];
    "ALiVEClient" callExtension format['clusterData~%1|%2|[ALIVE_clustersMilFieldwork,"c_%3",_cluster] call ALIVE_fnc_hashSet;',worldName,"mil",_clusterCount];

    _clusterCount = _clusterCount + 1;
} forEach _fwGroups;

["Military Objectives generation complete, results written to file"] call ALIVE_fnc_dump;
