#include "\x\alive\addons\mil_c2istar\script_component.hpp"
SCRIPT(taskMaybeTriggerRetaliation);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskMaybeTriggerRetaliation

Description:
Apply insurgent backlash against settlements that are trending toward stability.

Parameters:
Array - Position
Array - Cluster hash
String|Side - Task side
String - Task type
Number - Positive effect value

Returns:
Boolean

Author:
Javen
Jman
---------------------------------------------------------------------------- */

params [
    ["_position", [], [[]]],
    ["_cluster", [], [[]]],
    ["_taskSide", ""],
    ["_taskType", "", [""]],
    ["_effectValue", 0, [0]]
];

if (!(missionNamespace getVariable ["ALIVE_civicStateEnabled", false])) exitWith {false};
if (_position isEqualTo [] || {_cluster isEqualTo []} || {_effectValue <= 0}) exitWith {false};

private _supportState = [_cluster, _taskSide] call ALIVE_fnc_taskGetCivilianSupportState;
if (_supportState isEqualTo []) exitWith {false};

private _statusBand = [_supportState, "statusBand", "Hostile"] call ALIVE_fnc_hashGet;
if !(_statusBand in ["Recovering", "Stable"]) exitWith {false};

private _nearestObjective = [];
if !(isNil "ALiVE_fnc_INS_getNearestObjectiveByPosition") then {
    _nearestObjective = [_position, 2500, _taskSide, "asymmetric"] call ALiVE_fnc_INS_getNearestObjectiveByPosition;
};

private _retaliationChance = 0;
private _retaliationIntensity = 1;

if !(isNil "ALiVE_fnc_INS_getHostilitySetting") then {
    _retaliationChance = [_nearestObjective, "civicRetaliationChance", 0] call ALiVE_fnc_INS_getHostilitySetting;
    _retaliationIntensity = ([_nearestObjective, "civicRetaliationIntensity", 1] call ALiVE_fnc_INS_getHostilitySetting) max 0;
} else {
    _retaliationChance = missionNamespace getVariable ["ALIVE_civicRetaliationChance", 0];
    _retaliationIntensity = missionNamespace getVariable ["ALIVE_civicRetaliationIntensity", 1];
};

if (_retaliationChance <= 0 || {_retaliationIntensity <= 0}) exitWith {false};

private _lastRetaliationAt = [_supportState, "lastRetaliationAt", -1] call ALIVE_fnc_hashGet;
private _cooldownMultiplier = (missionNamespace getVariable ["ALIVE_civicCooldownMultiplier", 1]) max 0.25;
private _retaliationCooldown = round (1800 * _cooldownMultiplier);
if (_lastRetaliationAt >= 0 && {serverTime < (_lastRetaliationAt + _retaliationCooldown)}) exitWith {false};

private _successStreak = [_supportState, "successStreak", 0] call ALIVE_fnc_hashGet;
private _security = [_supportState, "security", 0] call ALIVE_fnc_hashGet;
private _effectiveChance = (_retaliationChance + (0.04 * (_successStreak min 3)) + (if (_statusBand == "Stable") then {0.08} else {0}) + (if (_security < 40) then {0.05} else {0})) min 0.85;
if (random 1 > _effectiveChance) exitWith {false};

private _retaliationType = switch (true) do {
    case (_taskType in ["AidDelivery", "RepairCriticalService", "MedicalOutreach"]): {"ServiceSabotage"};
    case (_taskType in ["MeetLocalLeader", "VIPEscort", "InformantExfiltration"]): {"InformantIntimidation"};
    case (_taskType in ["SecureCommunityEvent", "CheckpointPartnership", "MarketReopening"]): {"MarketDisruption"};
    default {"PropagandaBacklash"};
};

private _primaryDamage = (((ceil (_effectValue * 0.6 * _retaliationIntensity)) max 2) min 25);
private _secondaryDamage = (((ceil (_primaryDamage * 0.5)) max 1) min 15);

switch (_retaliationType) do {
    case "ServiceSabotage": {
        [_supportState, "services", (([_supportState, "services", 0] call ALIVE_fnc_hashGet) - _primaryDamage) max 0] call ALIVE_fnc_hashSet;
        [_supportState, "security", (([_supportState, "security", 0] call ALIVE_fnc_hashGet) - _secondaryDamage) max 0] call ALIVE_fnc_hashSet;
        [_supportState, "lastRetaliationAxis", "services"] call ALIVE_fnc_hashSet;
    };
    case "InformantIntimidation": {
        [_supportState, "trust", (([_supportState, "trust", 0] call ALIVE_fnc_hashGet) - _primaryDamage) max 0] call ALIVE_fnc_hashSet;
        [_supportState, "security", (([_supportState, "security", 0] call ALIVE_fnc_hashGet) - _secondaryDamage) max 0] call ALIVE_fnc_hashSet;
        [_supportState, "lastRetaliationAxis", "trust"] call ALIVE_fnc_hashSet;
    };
    case "MarketDisruption": {
        [_supportState, "security", (([_supportState, "security", 0] call ALIVE_fnc_hashGet) - _primaryDamage) max 0] call ALIVE_fnc_hashSet;
        [_supportState, "trust", (([_supportState, "trust", 0] call ALIVE_fnc_hashGet) - _secondaryDamage) max 0] call ALIVE_fnc_hashSet;
        [_supportState, "lastRetaliationAxis", "security"] call ALIVE_fnc_hashSet;
    };
    default {
        [_supportState, "trust", (([_supportState, "trust", 0] call ALIVE_fnc_hashGet) - _primaryDamage) max 0] call ALIVE_fnc_hashSet;
        [_supportState, "services", (([_supportState, "services", 0] call ALIVE_fnc_hashGet) - _secondaryDamage) max 0] call ALIVE_fnc_hashSet;
        [_supportState, "lastRetaliationAxis", "trust"] call ALIVE_fnc_hashSet;
    };
};

[_supportState, "lastRetaliationType", _retaliationType] call ALIVE_fnc_hashSet;
[_supportState, "lastRetaliationAt", serverTime] call ALIVE_fnc_hashSet;
[_supportState, "lastOutcome", _retaliationType] call ALIVE_fnc_hashSet;
[_supportState, "lastOutcomeAt", serverTime] call ALIVE_fnc_hashSet;
[_cluster, _taskSide, _supportState] call ALIVE_fnc_taskRefreshCivilianSupportState;

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

if (_sideText in ["EAST", "WEST", "GUER"]) then {
    private _hostilityShift = (((ceil (_primaryDamage / 2)) max 1) min 10);
    private _otherSides = ["EAST", "WEST", "GUER"] - [_sideText];
    [_position, [_sideText], _hostilityShift] call ALIVE_fnc_updateSectorHostility;
    [_position, _otherSides, _hostilityShift * -1] call ALIVE_fnc_updateSectorHostility;
};

private _nearestTown = [_position] call ALIVE_fnc_taskGetNearestLocationName;
if (_nearestTown == "") then {
    _nearestTown = "the settlement";
};

["COIN Update", format ["Insurgents launched %1 near %2. Local status is now %3.", _retaliationType, _nearestTown, [_supportState, "statusBand", "Fragile"] call ALIVE_fnc_hashGet]] remoteExec ["BIS_fnc_showSubtitle", 0];

true
