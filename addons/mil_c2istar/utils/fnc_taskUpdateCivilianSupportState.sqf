#include "\x\alive\addons\mil_C2ISTAR\script_component.hpp"
SCRIPT(taskUpdateCivilianSupportState);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskUpdateCivilianSupportState

Description:
Update persistent Hearts and Minds support state for a civilian cluster.

Parameters:

Returns:
Boolean

Examples:
(begin example)
[_cluster, "WEST", "AidDelivery", 8, 1800] call ALIVE_fnc_taskUpdateCivilianSupportState;
(end)

See Also:

Author:
OpenAI
---------------------------------------------------------------------------- */

params [
    ["_cluster", [], [[]]],
    ["_taskSide", ""],
    ["_taskType", "", [""]],
    ["_supportValue", 0, [0]],
    ["_cooldownDuration", 0, [0]]
];

if (_cluster isEqualTo []) exitWith {false};

private _supportState = [_cluster, _taskSide] call ALIVE_fnc_taskGetCivilianSupportState;
if (_supportState isEqualTo []) exitWith {false};

private _support = [_supportState, "support", 0] call ALIVE_fnc_hashGet;
_support = ((_support + _supportValue) max 0) min 100;

[_supportState, "support", _support] call ALIVE_fnc_hashSet;
[_supportState, "lastTaskType", _taskType] call ALIVE_fnc_hashSet;
[_supportState, "lastTaskAt", serverTime] call ALIVE_fnc_hashSet;
[_supportState, "cooldownUntil", serverTime + (_cooldownDuration max 0)] call ALIVE_fnc_hashSet;
[_supportState, "successStreak", ([_supportState, "successStreak", 0] call ALIVE_fnc_hashGet) + 1] call ALIVE_fnc_hashSet;
[_supportState, "failureStreak", 0] call ALIVE_fnc_hashSet;

true
