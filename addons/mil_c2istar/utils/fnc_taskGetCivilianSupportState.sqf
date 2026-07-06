#include "\x\alive\addons\mil_c2istar\script_component.hpp"
SCRIPT(taskGetCivilianSupportState);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskGetCivilianSupportState

Description:
Get or create persistent Hearts and Minds support state for a civilian cluster.

Parameters:
Array - Cluster hash
String|Side - Task side

Returns:
Array - Support state hash

Author:
Javen
Jman
---------------------------------------------------------------------------- */

params [
    ["_cluster", [], [[]]],
    ["_taskSide", ""]
];

if (_cluster isEqualTo []) exitWith {[]};

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

private _heartsAndMinds = if ("heartsAndMinds" in (_cluster select 1)) then {
    [_cluster, "heartsAndMinds"] call ALIVE_fnc_hashGet
} else {
    private _newHeartsAndMinds = [] call ALIVE_fnc_hashCreate;
    [_cluster, "heartsAndMinds", _newHeartsAndMinds] call ALIVE_fnc_hashSet;
    _newHeartsAndMinds
};

private _supportState = if (_sideText in (_heartsAndMinds select 1)) then {
    [_heartsAndMinds, _sideText] call ALIVE_fnc_hashGet
} else {
    private _newSupportState = [] call ALIVE_fnc_hashCreate;
    [_newSupportState, "support", 0] call ALIVE_fnc_hashSet;
    [_newSupportState, "trust", 0] call ALIVE_fnc_hashSet;
    [_newSupportState, "security", 0] call ALIVE_fnc_hashSet;
    [_newSupportState, "services", 0] call ALIVE_fnc_hashSet;
    [_newSupportState, "phase", "Stabilize"] call ALIVE_fnc_hashSet;
    [_newSupportState, "statusBand", "Hostile"] call ALIVE_fnc_hashSet;
    [_newSupportState, "weakestAxis", "trust"] call ALIVE_fnc_hashSet;
    [_newSupportState, "strongestAxis", "trust"] call ALIVE_fnc_hashSet;
    [_newSupportState, "insurgentPressure", 100] call ALIVE_fnc_hashSet;
    [_newSupportState, "lastTaskType", ""] call ALIVE_fnc_hashSet;
    [_newSupportState, "lastTaskFamily", ""] call ALIVE_fnc_hashSet;
    [_newSupportState, "lastTaskAt", -1] call ALIVE_fnc_hashSet;
    [_newSupportState, "cooldownUntil", 0] call ALIVE_fnc_hashSet;
    [_newSupportState, "successStreak", 0] call ALIVE_fnc_hashSet;
    [_newSupportState, "failureStreak", 0] call ALIVE_fnc_hashSet;
    [_newSupportState, "lastOutcome", ""] call ALIVE_fnc_hashSet;
    [_newSupportState, "lastOutcomeAt", -1] call ALIVE_fnc_hashSet;
    [_newSupportState, "lastRetaliationType", ""] call ALIVE_fnc_hashSet;
    [_newSupportState, "lastRetaliationAt", -1] call ALIVE_fnc_hashSet;
    [_newSupportState, "lastRetaliationAxis", ""] call ALIVE_fnc_hashSet;
    [_heartsAndMinds, _sideText, _newSupportState] call ALIVE_fnc_hashSet;
    _newSupportState
};

if !(_supportState isEqualTo []) then {
    private _support = [_supportState, "support", 0] call ALIVE_fnc_hashGet;

    {
        if !(_x in (_supportState select 1)) then {
            [_supportState, _x, _support] call ALIVE_fnc_hashSet;
        };
    } forEach ["trust", "security", "services"];

    if !("statusBand" in (_supportState select 1)) then {
        [_supportState, "statusBand", "Hostile"] call ALIVE_fnc_hashSet;
    };
    if !("weakestAxis" in (_supportState select 1)) then {
        [_supportState, "weakestAxis", "trust"] call ALIVE_fnc_hashSet;
    };
    if !("strongestAxis" in (_supportState select 1)) then {
        [_supportState, "strongestAxis", "trust"] call ALIVE_fnc_hashSet;
    };
    if !("insurgentPressure" in (_supportState select 1)) then {
        [_supportState, "insurgentPressure", 100] call ALIVE_fnc_hashSet;
    };
    if !("lastTaskFamily" in (_supportState select 1)) then {
        [_supportState, "lastTaskFamily", [_supportState, "lastTaskType", ""] call ALIVE_fnc_hashGet] call ALIVE_fnc_hashSet;
    };
    if !("lastOutcome" in (_supportState select 1)) then {
        [_supportState, "lastOutcome", ""] call ALIVE_fnc_hashSet;
    };
    if !("lastOutcomeAt" in (_supportState select 1)) then {
        [_supportState, "lastOutcomeAt", -1] call ALIVE_fnc_hashSet;
    };
    if !("lastRetaliationType" in (_supportState select 1)) then {
        [_supportState, "lastRetaliationType", ""] call ALIVE_fnc_hashSet;
    };
    if !("lastRetaliationAt" in (_supportState select 1)) then {
        [_supportState, "lastRetaliationAt", -1] call ALIVE_fnc_hashSet;
    };
    if !("lastRetaliationAxis" in (_supportState select 1)) then {
        [_supportState, "lastRetaliationAxis", ""] call ALIVE_fnc_hashSet;
    };

    [_cluster, _sideText, _supportState] call ALIVE_fnc_taskRefreshCivilianSupportState;
};

_supportState
