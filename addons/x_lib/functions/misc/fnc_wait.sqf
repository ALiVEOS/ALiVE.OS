#include "\x\alive\addons\x_lib\script_component.hpp"

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_wait

Description:
    Advanced version of sleep

Parameters:
    0 - Wait condition [code:string]
    1 - Max wait duration in seconds [number] (optional)
    2 - Trace component [string] (optional)
    3 - Condition parameters [any] (optional)

Returns:
    Value [bool]

Attributes:
    N/A

Examples:
    N/A

See Also:

Author:
    Naught, dixon13
---------------------------------------------------------------------------- */

private ["_startTime", "_endTime", "_val"];

params ["_condCode", ["_maxDuration", -1, [0]], ["_traceComp", "component", ["_params", [], [[]]]]];

_condCode = if (typeName(_condCode) == "CODE") then {_condCode} else {compile(_condCode)};

_startTime = diag_tickTime;
_endTime = _startTime + _maxDuration;

LOG_FORMAT("Info", "Wait", "Waiting for %1.", [_traceComp]);

waitUntil
{
    _val = _params call _condCode;
    _val || {(_maxDuration > 0) && {diag_tickTime > _endTime}};
};

["Info", "Wait", "Done waiting for %1. Benchmark: %2 sec. Value: %3.", [
    _traceComp,
    (diag_tickTime - _startTime),
    _val
], __FILE__, __LINE__] call ALiVE_fnc_log;

_val
