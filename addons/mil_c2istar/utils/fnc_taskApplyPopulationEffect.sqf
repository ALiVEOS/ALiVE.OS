#include "\x\alive\addons\mil_C2ISTAR\script_component.hpp"
SCRIPT(taskApplyPopulationEffect);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskApplyPopulationEffect

Description:
Apply a local civilian hostility shift in favor of or against the tasking side.

Parameters:

Returns:

Examples:
(begin example)
[_position, "WEST", 10] call ALIVE_fnc_taskApplyPopulationEffect;
(end)

See Also:

Author:
OpenAI
---------------------------------------------------------------------------- */

params [
    ["_position", [], [[]]],
    ["_taskSide", ""],
    ["_value", 0, [0]],
    ["_supportData", [], [[]]]
];

if (_position isEqualTo [] || {_value == 0}) exitWith {false};

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

if !(_sideText in ["EAST", "WEST", "GUER"]) exitWith {false};

private _otherSides = ["EAST", "WEST", "GUER"] - [_sideText];
private _clusterID = "";
private _taskType = "";
private _cooldownDuration = 0;
private _outcome = "success";

if !(_supportData isEqualTo []) then {
    _supportData params [
        ["_clusterID", "", [""]],
        ["_taskType", "", [""]],
        ["_cooldownDuration", 0, [0]],
        ["_outcome", "success", [""]]
    ];
};

private _cluster = nil;

if (!isNil "ALIVE_clusterHandler" && {!(_clusterID isEqualTo "")}) then {
    _cluster = [ALIVE_clusterHandler, "getCluster", _clusterID] call ALIVE_fnc_clusterHandler;
};

if (
    isNil "_cluster" &&
    {!isNil "ALIVE_clustersCivSettlement"} &&
    {!isNil "ALIVE_clusterHandler"}
) then {
    private _closestDistance = 1000000;

    {
        private _candidateCluster = [ALIVE_clusterHandler, "getCluster", _x] call ALIVE_fnc_clusterHandler;

        if !(isNil "_candidateCluster") then {
            private _center = [_candidateCluster, "center", []] call ALIVE_fnc_hashGet;

            if !(_center isEqualTo []) then {
                private _distance = _position distance2D _center;

                if (_distance < _closestDistance) then {
                    _closestDistance = _distance;
                    _cluster = _candidateCluster;
                };
            };
        };
    } forEach (ALIVE_clustersCivSettlement select 1);

    if (_closestDistance > 1000) then {
        _cluster = nil;
    };
};

private _supportState = [];
if !(isNil "_cluster") then {
    _supportState = [_cluster, _sideText] call ALIVE_fnc_taskGetCivilianSupportState;
};

private _baseValue = (abs _value) max 1;
private _effectValue = _baseValue;
private _outcomeText = toLower _outcome;

if (_outcomeText == "failure") then {
    private _multiplier = 0.75;

    if !(_supportState isEqualTo []) then {
        private _failureStreak = [_supportState, "failureStreak", 0] call ALIVE_fnc_hashGet;
        private _lastTaskType = [_supportState, "lastTaskType", ""] call ALIVE_fnc_hashGet;

        _multiplier = 0.75 + (0.15 * (_failureStreak min 4));

        if (_lastTaskType == _taskType && {!(_taskType isEqualTo "")}) then {
            _multiplier = _multiplier + 0.1;
        };
    };

    _effectValue = ceil (_baseValue * _multiplier);
} else {
    if !(_supportState isEqualTo []) then {
        private _lastTaskType = [_supportState, "lastTaskType", ""] call ALIVE_fnc_hashGet;

        if (_lastTaskType == _taskType && {!(_taskType isEqualTo "")}) then {
            private _successStreak = [_supportState, "successStreak", 0] call ALIVE_fnc_hashGet;
            private _multiplier = (1 - (0.15 * (_successStreak min 4))) max 0.4;

            _effectValue = round (_baseValue * _multiplier);
        };
    };
};

_effectValue = _effectValue max 1;

if (_outcomeText == "failure") then {
    [_position, [_sideText], _effectValue] call ALIVE_fnc_updateSectorHostility;
    [_position, _otherSides, _effectValue * -1] call ALIVE_fnc_updateSectorHostility;
} else {
    [_position, [_sideText], _effectValue * -1] call ALIVE_fnc_updateSectorHostility;
    [_position, _otherSides, _effectValue] call ALIVE_fnc_updateSectorHostility;
};

if !(isNil "_cluster") then {
    private _supportDelta = if (_outcomeText == "failure") then {_effectValue * -1} else {_effectValue};
    [_cluster, _sideText, _taskType, _supportDelta, _cooldownDuration, _outcomeText] call ALIVE_fnc_taskUpdateCivilianSupportState;
};

true
