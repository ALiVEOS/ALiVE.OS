#include "\x\alive\addons\mil_c2istar\script_component.hpp"
SCRIPT(taskGetSideCluster);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskGetSideCluster

Description:
Get a enemy cluster for a task

Parameters:
checkMilCustom: bool. Check if custom military objectives allows player tasking.
    true: ignore custom military objectives that do not allow player tasking.
    false: assume all objectives allow player tasking.
excludedPositions: array of positions (optional). Clusters within 500 m of any of them are left out.

Returns:

Examples:
(begin example)
_position = [_position, "Medium", "EAST", "MIL"] call ALIVE_fnc_taskGetSideCluster;
(end)

See Also:

Author:
ARJay
Jman
---------------------------------------------------------------------------- */

private ["_sideClusters","_targetPosition","_debug","_result","_nextState","_sortedClusters"];

params [
    "_taskLocation",
    "_taskLocationType",
    "_side",
    ["_type", ""],
    ["_checkMilCustom", false],
    ["_excludedPositions", []],
    ["_knownTo", ""]
];

if(_type != "") then {
    _sideClusters = [ALIVE_battlefieldAnalysis,"getClustersOwnedBySideAndType",[[_side] call ALIVE_fnc_sideTextToObject, _type, _checkMilCustom]] call ALIVE_fnc_battlefieldAnalysis;
}else{
    _sideClusters = [ALIVE_battlefieldAnalysis,"getClustersOwnedBySide",[[_side] call ALIVE_fnc_sideTextToObject, _checkMilCustom]] call ALIVE_fnc_battlefieldAnalysis;
};

_targetPosition = [];

if(count _sideClusters > 0) then {

    private ["_countClusters","_targetCluster","_candidateClusters","_minDistance"];

    // there are enemy held clusters
    _sortedClusters = [_sideClusters,[],{_taskLocation distance ([_x, "position"] call ALIVE_fnc_hashGet)},"ASCEND"] call ALiVE_fnc_SortBy;
    _candidateClusters = +_sortedClusters;

    _minDistance = missionNamespace getVariable ["ALIVE_taskMinDistance", 0];
    if !(_taskLocationType in ["Short", "Medium", "Long"]) then {
        _minDistance = 0;
    };

    if (_minDistance > 0) then {
        private _filteredClusters = [];
        {
            private _clusterPos = [_x, "position", []] call ALIVE_fnc_hashGet;
            if !(_clusterPos isEqualTo []) then {
                if (_taskLocation distance2D _clusterPos >= _minDistance) then {
                    _filteredClusters pushBack _x;
                };
            };
        } forEach _sortedClusters;

        if (count _filteredClusters > 0) then {
            _candidateClusters = _filteredClusters;
        };
    };

    // Maximum Task Distance (TheLogatron on Discord, 23 Oct): only those within it of the player; none within
    // it (blacklisted spots aside), the whole list stays and the nearest beyond is used, as Minimum Task Distance falls back
    private _maxDistance = missionNamespace getVariable ["ALIVE_taskMaxDistance", 0];
    if (_taskLocationType in ["Short", "Medium", "Long"] && {_maxDistance > 0} && {count _candidateClusters > 0}) then {
        private _bl = missionNamespace getVariable ["ALIVE_taskBlacklistMarkers", []];
        private _within = _candidateClusters select { private _p = [_x, "position", []] call ALIVE_fnc_hashGet; _p isNotEqualTo [] && {(_taskLocation distance2D _p) <= _maxDistance} && {(_bl findIf { _p inArea _x }) < 0} };
        _candidateClusters = if (_within isEqualTo []) then {
            ["C2ISTAR - nothing within Maximum Task Distance %1 of %2, so the nearest beyond it is used", _maxDistance, mapGridPosition _taskLocation] call ALiVE_fnc_dump; _candidateClusters
        } else { _within };
    };

    // Clusters another task already holds are left out. A caller that passes no list sees
    // no change. If every cluster is held the result is empty, the same as a side holding
    // none, and the callers already fall back from there.
    if !(_excludedPositions isEqualTo []) then {
        _candidateClusters = _candidateClusters select {
            private _clusterPos = [_x, "position", []] call ALIVE_fnc_hashGet;
            _clusterPos isEqualTo [] || {(_excludedPositions findIf {_clusterPos distance2D _x < 500}) < 0}
        };
    };

    // Areas the mission keeps generated tasks out of (Task Blacklist on the C2ISTAR module, #729).
    private _taskBlacklist = missionNamespace getVariable ["ALIVE_taskBlacklistMarkers", []];
    if (_taskBlacklist isNotEqualTo []) then {
        _candidateClusters = _candidateClusters select {
            private _clusterPos = [_x, "position", []] call ALIVE_fnc_hashGet;
            _clusterPos isEqualTo [] || {(_taskBlacklist findIf {_clusterPos inArea _x}) < 0}
        };
    };

    // Tasks Only Against Known Enemy (C2ISTAR module): with _knownTo, the clusters that side knows of; none known, the
    // list stays and the task's own check turns it down (ALIVE_fnc_taskKnownEnemy)
    if (_knownTo != "" && {_taskLocationType != "Map"} && {_candidateClusters isNotEqualTo []}) then {
        private _mask = ["places", _knownTo, _candidateClusters apply { [_x, "position", []] call ALIVE_fnc_hashGet }] call ALIVE_fnc_taskKnownEnemy;
        private _knownClusters = [];
        { if (_mask select _forEachIndex) then { _knownClusters pushBack _x } } forEach _candidateClusters;
        if (_knownClusters isNotEqualTo []) then { _candidateClusters = _knownClusters };
    };

    _countClusters = count _candidateClusters;

    if (_countClusters > 0) then {
        if(_taskLocationType == "Map" || _taskLocationType == "Short") then {
            if(_countClusters > 1 && _taskLocationType == "Short") then {
                _targetCluster = _candidateClusters select 1;
            }else{
                _targetCluster = _candidateClusters select 0;
            };

        };

        if(_taskLocationType == "Medium") then {
            _targetCluster = _candidateClusters select (floor(_countClusters/2));
        };

        if(_taskLocationType == "Long") then {
            _targetCluster = _candidateClusters select (_countClusters-1);
        };

        _targetPosition = [_targetCluster, "position"] call ALIVE_fnc_hashGet;
    };

} else {
	// Empty result, not a 99999 sentinel. The sentinel propagated as a real
	// task position across most callers (fnc_taskCivAssault / taskMilAssault
	// / taskMilDefence / taskAssassination / taskCSAR / taskTransportInsertion
	// / taskRescue / taskDestroyBuilding) because they only checked
	// `count _targetPosition == 0` — the sentinel has count 3 so the fallback
	// path never engaged and the task marker landed at [99999,99999] off-map.
	// Only fnc_taskAidDelivery.sqf:108 had a defensive `>90000` patch for it.
	// Returning [] makes every caller's count==0 check route correctly into
	// its fallback chain (BIS_fnc_findSafePos / sectorCompositionPosition).
	// Symptom before fix: tasks like "Clear the town" appearing in the tasks
	// list but with no map marker because the marker was drawn at [99999,99999].
	_targetPosition = [];
};

_targetPosition
