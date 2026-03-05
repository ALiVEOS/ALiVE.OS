#include "\x\alive\addons\mil_C2ISTAR\script_component.hpp"
SCRIPT(taskGetSideCluster);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskGetSideCluster

Description:
Get a enemy cluster for a task

Parameters:
checkMilCustom: bool. Check if custom military objectives allows player tasking.
    true: ignore custom military objectives that do not allow player tasking.
    false: assume all objectives allow player tasking.

Returns:

Examples:
(begin example)
_position = [_position, "Medium", "EAST", "MIL"] call ALIVE_fnc_taskGetSideCluster;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_sideClusters","_targetPosition","_debug","_result","_nextState","_sortedClusters"];

params [
    "_taskLocation",
    "_taskLocationType",
    "_side",
    ["_type", ""],
    ["_checkMilCustom", false]
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
	_targetPosition = [99999,99999,99999];
};

_targetPosition
