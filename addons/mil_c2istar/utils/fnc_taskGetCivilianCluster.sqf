#include "\x\alive\addons\mil_c2istar\script_component.hpp"
SCRIPT(taskGetCivilianCluster);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskGetCivilianCluster

Description:
Select a civilian settlement cluster for Hearts and Minds tasking.

Parameters:
Array - Task location
String - Task location type
String|Side - Task side
Number - Minimum hostility
Number - Maximum hostility
String - Task faction
Array - Current tasks
Bool - Allow cooldown fallback

Returns:
Array - [cluster, hostility, supportState, isOnCooldown]

Author:
Javen
Jman
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
private _heartsAndMindsTaskTypes = [
    "AidDelivery",
    "SupplyConvoy",
    "MeetLocalLeader",
    "VIPEscort",
    "SecureCommunityEvent",
    "RepairCriticalService",
    "MedicalOutreach",
    "CheckpointPartnership",
    "InformantExfiltration",
    "MarketReopening"
];

{
    private _cluster = [ALIVE_clusterHandler, "getCluster", _x] call ALIVE_fnc_clusterHandler;

    if !(isNil "_cluster") then {
        private _center = [_cluster, "center", []] call ALIVE_fnc_hashGet;

        if !(_center isEqualTo []) then {
            // Defensive off-map filter. Some civilian clusters in
            // ALIVE_clustersCivSettlement can carry a centroid
            // outside the [0, worldSize] envelope (Rujasu's
            // 2026-05-19 report on Chernarus -- centroid at
            // [-2620.79, 3456.32] picked as Long-distance
            // destination, marker landed in the ocean ~14 km
            // from the named town). Off-map distance always
            // sorts top of an ascending distance list, so the
            // bad cluster always wins selection for "Long" task
            // types without this filter. Root cause (how the
            // centroid got set wrong) is a separate trace into
            // the cluster handler / sys_analysis cluster-build
            // path.
            private _onMap = ((_center select 0) >= 0)
                          && {(_center select 0) <= worldSize}
                          && {(_center select 1) >= 0}
                          && {(_center select 1) <= worldSize};

            if (!_onMap) then {
                // DIAG-STRIP -- surface bad clusters so the
                // root-cause trace can locate which cluster
                // carries the corrupt centroid. Strip per
                // strategy_diag_strip_cleanup_pass.md once the
                // source is fixed.
                if (!isNil "ALiVE_mil_c2istar_debug" && {ALiVE_mil_c2istar_debug}) then {
                    [
                        "DIAG-STRIP taskGetCivilianCluster: skipping cluster '%1' with off-map center=%2 (worldSize=%3)",
                        _x, _center, worldSize
                    ] call ALiVE_fnc_dump;
                };
            };

            if (_onMap) then {

            private _isDuplicate = false;

            if !(_tasksCurrent isEqualTo []) then {
                _isDuplicate = {
                    private _taskSource = _x param [12, "", [""]];
                    private _taskType = "";

                    if (_taskSource != "") then {
                        if !(isNil "ALIVE_taskHandler") then {
                            private _parsedTaskSource = [ALIVE_taskHandler, "parseTaskSource", _taskSource] call ALiVE_fnc_taskHandler;
                            _taskType = _parsedTaskSource param [1, "", [""]];
                        } else {
                            private _taskSourceParts = [_taskSource, "-"] call CBA_fnc_split;
                            if (count _taskSourceParts >= 2) then {
                                _taskType = _taskSourceParts select ((count _taskSourceParts) - 2);
                            };
                        };
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

            };  // end if (_onMap) then
        };
    };
} forEach _clusterIDs;

// DIAG-STRIP: surface what made it past each filter so a future
// "No source civilian settlement found" path can be diagnosed.
// Strip per strategy_diag_strip_cleanup_pass.md once we have
// confidence the picker is healthy across cup_chernarus_a3 +
// other community Chernarus variants.
if (!isNil "ALiVE_mil_c2istar_debug" && {ALiVE_mil_c2istar_debug}) then {
    [
        "DIAG-STRIP taskGetCivilianCluster: clusterIDs=%1, eligible=%2, preferred=%3, sideText=%4, minHostility=%5, maxHostility=%6, locationType=%7",
        count _clusterIDs,
        count _eligibleClusters,
        count _preferredClusters,
        _sideText,
        _minHostility,
        _maxHostility,
        _taskLocationType
    ] call ALiVE_fnc_dump;
};

private _preferredClustersAvailable = _preferredClusters select {!(_x select 3)};
private _eligibleClustersAvailable = _eligibleClusters select {!(_x select 3)};
private _candidates = switch (true) do {
    case (count _preferredClustersAvailable > 0): {_preferredClustersAvailable};
    case (_allowCooldownFallback && {count _preferredClusters > 0}): {_preferredClusters};
    case (count _eligibleClustersAvailable > 0): {_eligibleClustersAvailable};
    case (_allowCooldownFallback): {_eligibleClusters};
    default {[]};
};
if (_candidates isEqualTo []) exitWith {
    if (!isNil "ALiVE_mil_c2istar_debug" && {ALiVE_mil_c2istar_debug}) then {
        ["DIAG-STRIP taskGetCivilianCluster: no candidates -- preferredAvailable=%1, eligibleAvailable=%2, allowCooldownFallback=%3",
            count _preferredClustersAvailable,
            count _eligibleClustersAvailable,
            _allowCooldownFallback] call ALiVE_fnc_dump;
    };
    []
};

private _civicStateEnabled = missionNamespace getVariable ["ALIVE_civicStateEnabled", false];
private _sortedClusters = if (_civicStateEnabled) then {
    [_candidates, [_taskLocation], {
        private _center = [_x select 0, "center", []] call ALIVE_fnc_hashGet;
        private _distance = _Input0 distance2D _center;
        private _supportState = _x select 2;
        private _pressureBias = 0;

        if !(_supportState isEqualTo []) then {
            _pressureBias = [_supportState, "insurgentPressure", 0] call ALIVE_fnc_hashGet;
        };

        _distance - (_pressureBias * 5)
    }, "ASCEND"] call ALIVE_fnc_SortBy
} else {
    [_candidates, [_taskLocation], {
        _Input0 distance2D ([_x select 0, "center", []] call ALIVE_fnc_hashGet)
    }, "ASCEND"] call ALIVE_fnc_SortBy
};

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
