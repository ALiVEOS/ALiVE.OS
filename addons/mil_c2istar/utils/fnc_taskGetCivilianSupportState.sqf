#include "\x\alive\addons\mil_C2ISTAR\script_component.hpp"
SCRIPT(taskGetCivilianSupportState);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskGetCivilianSupportState

Description:
Get or create persistent Hearts and Minds support state for a civilian cluster.

Parameters:

Returns:
Array - Support state hash

Examples:
(begin example)
private _state = [_cluster, "WEST"] call ALIVE_fnc_taskGetCivilianSupportState;
(end)

See Also:

Author:
OpenAI
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
    [_newSupportState, "phase", "Stabilize"] call ALIVE_fnc_hashSet;
    [_newSupportState, "lastTaskType", ""] call ALIVE_fnc_hashSet;
    [_newSupportState, "lastTaskAt", -1] call ALIVE_fnc_hashSet;
    [_newSupportState, "cooldownUntil", 0] call ALIVE_fnc_hashSet;
    [_newSupportState, "successStreak", 0] call ALIVE_fnc_hashSet;
    [_newSupportState, "failureStreak", 0] call ALIVE_fnc_hashSet;
    [_heartsAndMinds, _sideText, _newSupportState] call ALIVE_fnc_hashSet;
    _newSupportState
};

private _hostilityHash = [_cluster, "hostility", []] call ALIVE_fnc_hashGet;
private _hostility = [_hostilityHash, _sideText, 0] call ALIVE_fnc_hashGet;
private _phase = "Stabilize";

if (_hostility <= 0) then {
    _phase = "Consolidate";
} else {
    if (_hostility <= 25) then {
        _phase = "Build";
    } else {
        if (_hostility <= 65) then {
            _phase = "Engage";
        };
    };
};

[_supportState, "phase", _phase] call ALIVE_fnc_hashSet;

_supportState
