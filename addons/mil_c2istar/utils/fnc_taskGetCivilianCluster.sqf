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
    ["_tasksCurrent", [], [[]]]
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

{
    private _cluster = [ALIVE_clusterHandler, "getCluster", _x] call ALIVE_fnc_clusterHandler;

    if !(isNil "_cluster") then {
        private _center = [_cluster, "center", []] call ALIVE_fnc_hashGet;

        if !(_center isEqualTo []) then {
            private _isDuplicate = false;

            if !(_taskFaction isEqualTo "" || {_tasksCurrent isEqualTo []}) then {
                _isDuplicate = {
                    (_x select 4) == _taskFaction &&
                    {(_x select 8) in ["Created", "Assigned"]} &&
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
    case (count _preferredClusters > 0): {_preferredClusters};
    case (count _eligibleClustersAvailable > 0): {_eligibleClustersAvailable};
    default {_eligibleClusters};
};
if (_candidates isEqualTo []) exitWith {[]};

private _sortedClusters = [_candidates, [_taskLocation], {
    _Input0 distance2D ([_x select 0, "center", []] call ALIVE_fnc_hashGet)
}, "ASCEND"] call ALIVE_fnc_SortBy;

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
