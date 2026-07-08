#include "\x\alive\addons\mil_c2istar\script_component.hpp"
SCRIPT(taskUpdateCivilianSupportState);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskUpdateCivilianSupportState

Description:
Update persistent Hearts and Minds support state for a civilian cluster.

Parameters:
Array - Cluster hash
String|Side - Task side
String - Task type
Number - Support delta
Number - Cooldown duration (seconds)
String - Outcome

Returns:
Boolean

Author:
Javen
Jman
---------------------------------------------------------------------------- */

params [
    ["_cluster", [], [[]]],
    ["_taskSide", ""],
    ["_taskType", "", [""]],
    ["_supportValue", 0, [0]],
    ["_cooldownDuration", 0, [0]],
    ["_outcome", "", [""]]
];

if (_cluster isEqualTo []) exitWith {false};
if (_supportValue == 0) exitWith {false};

private _supportState = [_cluster, _taskSide] call ALIVE_fnc_taskGetCivilianSupportState;
if (_supportState isEqualTo []) exitWith {false};

private _previousTaskType = [_supportState, "lastTaskType", ""] call ALIVE_fnc_hashGet;
private _sameTaskType = _previousTaskType == _taskType;
private _support = [_supportState, "support", 0] call ALIVE_fnc_hashGet;
private _cooldownMultiplier = (missionNamespace getVariable ["ALIVE_civicCooldownMultiplier", 1]) max 0;
private _outcomeText = toLower _outcome;

_support = ((_support + _supportValue) max 0) min 100;
[_supportState, "support", _support] call ALIVE_fnc_hashSet;
[_supportState, "lastTaskType", _taskType] call ALIVE_fnc_hashSet;
[_supportState, "lastTaskFamily", _taskType] call ALIVE_fnc_hashSet;
[_supportState, "lastTaskAt", serverTime] call ALIVE_fnc_hashSet;
[_supportState, "cooldownUntil", serverTime + ((_cooldownDuration max 0) * _cooldownMultiplier)] call ALIVE_fnc_hashSet;

if (_outcomeText isEqualTo "") then {
    _outcomeText = if (_supportValue < 0) then {"failure"} else {"success"};
};

private _outcomeText = toLower _outcome;
if (_outcomeText isEqualTo "") then {
    _outcomeText = if (_supportValue < 0) then {"failure"} else {"success"};
};

private _successStreak = [_supportState, "successStreak", 0] call ALIVE_fnc_hashGet;
private _failureStreak = [_supportState, "failureStreak", 0] call ALIVE_fnc_hashGet;

switch (_outcomeText) do {
    case "failure": {
        [_supportState, "successStreak", 0] call ALIVE_fnc_hashSet;
        [_supportState, "failureStreak", if (_sameTaskType) then {_failureStreak + 1} else {1}] call ALIVE_fnc_hashSet;
    };
    default {
        [_supportState, "successStreak", if (_sameTaskType) then {_successStreak + 1} else {1}] call ALIVE_fnc_hashSet;
        [_supportState, "failureStreak", 0] call ALIVE_fnc_hashSet;
    };
};

[_supportState, "lastOutcome", _outcomeText] call ALIVE_fnc_hashSet;
[_supportState, "lastOutcomeAt", serverTime] call ALIVE_fnc_hashSet;

if (missionNamespace getVariable ["ALIVE_civicStateEnabled", false]) then {
    private _profile = [_taskType] call ALIVE_fnc_taskGetCivicTaskProfile;
    private _primaryAxis = [_profile, "primaryAxis", "trust"] call ALIVE_fnc_hashGet;
    private _secondaryAxis = [_profile, "secondaryAxis", "security"] call ALIVE_fnc_hashGet;
    private _primaryWeight = [_profile, "primaryWeight", 1] call ALIVE_fnc_hashGet;
    private _secondaryWeight = [_profile, "secondaryWeight", 0.35] call ALIVE_fnc_hashGet;
    private _baseDelta = (abs _supportValue) max 1;
    private _isFailure = _outcomeText == "failure";
    private _getAxisMultiplier = {
        params ["_axisName", "_axisFailure"];

        switch (_axisName) do {
            case "trust": {
                missionNamespace getVariable [if (_axisFailure) then {"ALIVE_civicTrustFailureMultiplier"} else {"ALIVE_civicTrustSuccessMultiplier"}, 1]
            };
            case "security": {
                missionNamespace getVariable [if (_axisFailure) then {"ALIVE_civicSecurityFailureMultiplier"} else {"ALIVE_civicSecuritySuccessMultiplier"}, 1]
            };
            case "services": {
                missionNamespace getVariable [if (_axisFailure) then {"ALIVE_civicServicesFailureMultiplier"} else {"ALIVE_civicServicesSuccessMultiplier"}, 1]
            };
            default {1};
        };
    };

    private _primaryDeltaRaw = _baseDelta * _primaryWeight * ([_primaryAxis, _isFailure] call _getAxisMultiplier);
    private _secondaryDeltaRaw = _baseDelta * _secondaryWeight * ([_secondaryAxis, _isFailure] call _getAxisMultiplier);
    private _primaryDelta = round _primaryDeltaRaw;
    private _secondaryDelta = round _secondaryDeltaRaw;
    if (_primaryDeltaRaw > 0 && {_primaryDelta <= 0}) then {_primaryDelta = 1};
    if (_secondaryDeltaRaw > 0 && {_secondaryDelta <= 0}) then {_secondaryDelta = 1};
    if (_isFailure) then {
        _primaryDelta = _primaryDelta * -1;
        _secondaryDelta = _secondaryDelta * -1;
    };

    [_supportState, _primaryAxis, ((([_supportState, _primaryAxis, 0] call ALIVE_fnc_hashGet) + _primaryDelta) max 0) min 100] call ALIVE_fnc_hashSet;
    [_supportState, _secondaryAxis, ((([_supportState, _secondaryAxis, 0] call ALIVE_fnc_hashGet) + _secondaryDelta) max 0) min 100] call ALIVE_fnc_hashSet;
};

[_cluster, _taskSide, _supportState] call ALIVE_fnc_taskRefreshCivilianSupportState;
true
