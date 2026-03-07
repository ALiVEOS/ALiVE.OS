#include "\x\alive\addons\mil_C2ISTAR\script_component.hpp"
SCRIPT(taskGetCivilianCluster);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskGetCivilianCluster

Description:
Select a civilian settlement cluster for Hearts and Minds tasking.

Parameters:

Returns:
Array - [cluster, hostility, supportState, isOnCooldown]

Examples:
(begin example)
private _clusterData = [_position, "Short", "WEST", 25, 1000, "BLU_F", []] call ALIVE_fnc_taskGetCivilianCluster;
(end)

See Also:

Author:
OpenAI
---------------------------------------------------------------------------- */

params [
    ["_taskLocation", [], [[]]],
    ["_taskLocationType", "Short", [""]],
    ["_taskSide", ""],
    ["_minHostility", -100000, [0]],
    ["_maxHostility", 100000, [0]],
    ["_taskFaction", "", [""]],
    ["_tasksCurrent", [], [[]]],
    ["_allowCooldownFallback", false, [true]]
];

if (_taskLocation isEqualTo []) exitWith {[]};
if (isNil "ALIVE_clustersCivSettlement" || {isNil "ALIVE_clusterHandler"}) exitWith {[]};

private _sideText = switch (typeName _taskSide) do {
    case "SIDE": {
        private _sideNumber = [_taskSide] call ALIVE_fnc_sideObjectToNumber;
        [_sideNumber] call ALIVE_fnc_sideNumberToText;
    };
    case "STRING": {
        toUpper _taskSide
    };
    default {
        ""
    };
};

if !(_sideText in ["EAST", "WEST", "GUER"]) exitWith {[]};

private _eligibleClusters = [];
private _preferredClusters = [];
private _clusterIDs = ALIVE_clustersCivSettlement select 1;
private _heartsAndMindsTaskTypes = ["AidDelivery", "SupplyConvoy", "MeetLocalLeader", "VIPEscort", "SecureCommunityEvent", "RepairCriticalService"];

{
    private _cluster = [ALIVE_clusterHandler, "getCluster", _x] call ALIVE_fnc_clusterHandler;

    if !(isNil "_cluster") then {
        private _center = [_cluster, "center", []] call ALIVE_fnc_hashGet;

        if !(_center isEqualTo []) then {
            private _isDuplicate = false;

            if !(_tasksCurrent isEqualTo []) then {
                _isDuplicate = {
                    private _taskSource = [_x, 12, "", [""]] call BIS_fnc_param;
                    private _taskType = "";

                    if (!isNil "ALIVE_taskHandler") then {
                        private _parsedTaskSource = [ALIVE_taskHandler, "parseTaskSource", _taskSource] call ALiVE_fnc_taskHandler;
                        _taskType = _parsedTaskSource param [1, "", [""]];
                    };

                    (_x select 2) == _sideText &&
                    {(_x select 8) in ["Created", "Assigned"]} &&
                    {_taskType in _heartsAndMindsTaskTypes} &&
                    {(_x select 3) distance2D _center < 600}
                } count _tasksCurrent > 0;
            };

            if (!_isDuplicate) then {
                private _hostilityHash = [_cluster, "hostility", []] call ALIVE_fnc_hashGet;
                private _hostility = [_hostilityHash, _sideText, 0] call ALIVE_fnc_hashGet;
                private _supportState = [_cluster, _sideText] call ALIVE_fnc_taskGetCivilianSupportState;
                private _isOnCooldown = false;

                if !(_supportState isEqualTo []) then {
                    _isOnCooldown = [_supportState, "cooldownUntil", 0] call ALIVE_fnc_hashGet > serverTime;
                };

                private _entry = [_cluster, _hostility, _supportState, _isOnCooldown];

                _eligibleClusters pushBack _entry;

                if (_hostility >= _minHostility && {_hostility <= _maxHostility}) then {
                    _preferredClusters pushBack _entry;
                };
            };
        };
    };
} forEach _clusterIDs;

private _preferredClustersAvailable = _preferredClusters select {!(_x select 3)};
private _eligibleClustersAvailable = _eligibleClusters select {!(_x select 3)};
private _candidates = switch (true) do {
    case (count _preferredClustersAvailable > 0): {_preferredClustersAvailable};
    case (_allowCooldownFallback && {count _preferredClusters > 0}): {_preferredClusters};
    case (count _eligibleClustersAvailable > 0): {_eligibleClustersAvailable};
    case (_allowCooldownFallback): {_eligibleClusters};
    default {[]};
};
if (_candidates isEqualTo []) exitWith {[]};

private _sortedClusters = [_candidates, [_taskLocation], {
    _Input0 distance2D ([_x select 0, "center", []] call ALIVE_fnc_hashGet)
}, "ASCEND"] call ALIVE_fnc_SortBy;

private _minDistance = missionNamespace getVariable ["ALIVE_taskMinDistance", 0];
if (_taskLocationType in ["Short", "Medium", "Long"] && {_minDistance > 0}) then {
    private _filteredClusters = [];
    {
        private _center = [_x select 0, "center", []] call ALIVE_fnc_hashGet;
        if !(_center isEqualTo []) then {
            if (_taskLocation distance2D _center >= _minDistance) then {
                _filteredClusters pushBack _x;
            };
        };
    } forEach _sortedClusters;

    if (count _filteredClusters > 0) then {
        _sortedClusters = _filteredClusters;
    };
};

private _selectedIndex = 0;
private _maxIndex = (count _sortedClusters) - 1;

switch (_taskLocationType) do {
    case "Short": {
        _selectedIndex = 0;
    };
    case "Medium": {
        _selectedIndex = floor (_maxIndex / 2);
    };
    case "Long": {
        _selectedIndex = _maxIndex;
    };
    default {
        _selectedIndex = 0;
    };
};

_sortedClusters select _selectedIndex
