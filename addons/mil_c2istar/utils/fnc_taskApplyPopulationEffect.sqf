#include "\x\alive\addons\mil_C2ISTAR\script_component.hpp"
SCRIPT(taskApplyPopulationEffect);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskApplyPopulationEffect

Description:
Apply a local civilian hostility shift in favor of the tasking side.

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

if (_position isEqualTo [] || {_value <= 0}) exitWith {false};

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

[_position, [_sideText], _value * -1] call ALIVE_fnc_updateSectorHostility;
[_position, _otherSides, _value] call ALIVE_fnc_updateSectorHostility;

if !(_supportData isEqualTo []) then {
    _supportData params [
        ["_clusterID", "", [""]],
        ["_taskType", "", [""]],
        ["_cooldownDuration", 0, [0]]
    ];

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

    if !(isNil "_cluster") then {
        [_cluster, _sideText, _taskType, _value, _cooldownDuration] call ALIVE_fnc_taskUpdateCivilianSupportState;
    };
};

true
