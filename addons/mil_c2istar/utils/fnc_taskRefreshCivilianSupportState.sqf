#include "\x\alive\addons\mil_c2istar\script_component.hpp"
SCRIPT(taskRefreshCivilianSupportState);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskRefreshCivilianSupportState

Description:
Refresh derived Hearts and Minds support fields from the civic-state model.

Parameters:
Array - Cluster hash
String|Side - Task side
Array - Support state hash

Returns:
Array - Updated support state hash

Author:
Javen
Jman
---------------------------------------------------------------------------- */

params [
    ["_cluster", [], [[]]],
    ["_taskSide", ""],
    ["_supportState", [], [[]]]
];

if (_cluster isEqualTo [] || {_supportState isEqualTo []}) exitWith {[]};

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

private _support = ([_supportState, "support", 0] call ALIVE_fnc_hashGet) max 0 min 100;
private _trust = ([_supportState, "trust", _support] call ALIVE_fnc_hashGet) max 0 min 100;
private _security = ([_supportState, "security", _support] call ALIVE_fnc_hashGet) max 0 min 100;
private _services = ([_supportState, "services", _support] call ALIVE_fnc_hashGet) max 0 min 100;
private _failureStreak = [_supportState, "failureStreak", 0] call ALIVE_fnc_hashGet;
private _hostilityHash = [_cluster, "hostility", []] call ALIVE_fnc_hashGet;
private _hostility = [_hostilityHash, _sideText, 0] call ALIVE_fnc_hashGet;
private _civicStateEnabled = missionNamespace getVariable ["ALIVE_civicStateEnabled", false];
private _weakestAxis = "trust";
private _strongestAxis = "trust";
private _weakestValue = _trust;
private _strongestValue = _trust;
private _statusBand = "Hostile";
private _phase = "Stabilize";
private _insurgentPressure = ((_hostility max 0) min 100);

{
    _x params ["_axisName", "_axisValue"];

    if (_axisValue < _weakestValue) then {
        _weakestAxis = _axisName;
        _weakestValue = _axisValue;
    };

    if (_axisValue > _strongestValue) then {
        _strongestAxis = _axisName;
        _strongestValue = _axisValue;
    };
} forEach [
    ["trust", _trust],
    ["security", _security],
    ["services", _services]
];

if (_civicStateEnabled) then {
    private _hostilityScore = 100 - ((_hostility max 0) min 100);
    _support = round ((_trust + _security + _services + _hostilityScore) / 4);
    _insurgentPressure = round (
        (
            ((100 - _trust) * 0.25) +
            ((100 - _security) * 0.4) +
            ((100 - _services) * 0.15) +
            (((_hostility max 0) min 100) * 0.2) +
            ((_failureStreak min 4) * 4)
        ) min 100
    );

    if (_support < 25 || {_security < 20} || {_hostility > 65}) then {
        _statusBand = "Hostile";
        _phase = "Stabilize";
    } else {
        if (_support < 50 || {_security < 40} || {_hostility > 35}) then {
            _statusBand = "Fragile";
            _phase = "Engage";
        } else {
            if (_support < 75 || {_security < 60} || {_hostility > 10}) then {
                _statusBand = "Recovering";
                _phase = "Build";
            } else {
                _statusBand = "Stable";
                _phase = "Consolidate";
            };
        };
    };
} else {
    if (_hostility <= 0) then {
        _phase = "Consolidate";
        _statusBand = "Stable";
    } else {
        if (_hostility <= 25) then {
            _phase = "Build";
            _statusBand = "Recovering";
        } else {
            if (_hostility <= 65) then {
                _phase = "Engage";
                _statusBand = "Fragile";
            } else {
                _phase = "Stabilize";
                _statusBand = "Hostile";
            };
        };
    };
};

[_supportState, "trust", _trust] call ALIVE_fnc_hashSet;
[_supportState, "security", _security] call ALIVE_fnc_hashSet;
[_supportState, "services", _services] call ALIVE_fnc_hashSet;
[_supportState, "support", _support] call ALIVE_fnc_hashSet;
[_supportState, "phase", _phase] call ALIVE_fnc_hashSet;
[_supportState, "statusBand", _statusBand] call ALIVE_fnc_hashSet;
[_supportState, "weakestAxis", _weakestAxis] call ALIVE_fnc_hashSet;
[_supportState, "strongestAxis", _strongestAxis] call ALIVE_fnc_hashSet;
[_supportState, "insurgentPressure", _insurgentPressure] call ALIVE_fnc_hashSet;

_supportState
