#include "\x\alive\addons\mil_c2istar\script_component.hpp"
SCRIPT(taskGetCivicDebugDescription);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskGetCivicDebugDescription

Description:
Build a civic-state debug summary for Hearts and Minds task descriptions.

Parameters:
String - Cluster ID
String|Side - Task side
Array - Task position

Returns:
String

Author:
Javen
Jman
---------------------------------------------------------------------------- */

params [
    ["_clusterID", "", [""]],
    ["_taskSide", ""],
    ["_taskPosition", [], [[]]]
];

if !(missionNamespace getVariable ["ALIVE_civicDebugIntel", false]) exitWith {""};
if (isNil "ALIVE_clusterHandler" || {isNil "ALIVE_clustersCivSettlement"}) exitWith {""};

private _cluster = [];

if !(_clusterID isEqualTo "") then {
    _cluster = [ALIVE_clusterHandler, "getCluster", _clusterID] call ALIVE_fnc_clusterHandler;
    if (isNil "_cluster") then {
        _cluster = [];
    };
};

if (_cluster isEqualTo [] && {!(_taskPosition isEqualTo [])}) then {
    private _closestDistance = 1500;

    {
        private _candidateCluster = [ALIVE_clusterHandler, "getCluster", _x] call ALIVE_fnc_clusterHandler;
        if !(isNil "_candidateCluster") then {
            private _center = [_candidateCluster, "center", []] call ALIVE_fnc_hashGet;
            if !(_center isEqualTo []) then {
                private _distance = _taskPosition distance2D _center;
                if (_distance < _closestDistance) then {
                    _closestDistance = _distance;
                    _cluster = _candidateCluster;
                };
            };
        };
    } forEach (ALIVE_clustersCivSettlement select 1);
};

if (_cluster isEqualTo []) exitWith {""};

private _supportState = [_cluster, _taskSide] call ALIVE_fnc_taskGetCivilianSupportState;
if (_supportState isEqualTo []) exitWith {""};

private _statusBand = [_supportState, "statusBand", "Hostile"] call ALIVE_fnc_hashGet;
private _trust = [_supportState, "trust", 0] call ALIVE_fnc_hashGet;
private _security = [_supportState, "security", 0] call ALIVE_fnc_hashGet;
private _services = [_supportState, "services", 0] call ALIVE_fnc_hashGet;
private _insurgentPressure = [_supportState, "insurgentPressure", 0] call ALIVE_fnc_hashGet;
private _recentOutcome = [_supportState, "lastOutcome", "none"] call ALIVE_fnc_hashGet;
private _weakestAxis = [_supportState, "weakestAxis", "trust"] call ALIVE_fnc_hashGet;

format [
    "COIN: %1 | Trust %2 | Security %3 | Services %4 | Pressure %5 | Weakest %6 | Recent %7",
    _statusBand,
    _trust,
    _security,
    _services,
    _insurgentPressure,
    _weakestAxis,
    _recentOutcome
]
