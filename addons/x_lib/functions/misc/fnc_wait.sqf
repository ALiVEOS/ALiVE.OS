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
	Naught
---------------------------------------------------------------------------- */

private ["_condCode", "_maxDuration", "_traceComp", "_params", "_startTime", "_endTime", "_val"];
_condCode = if (typeName(_this select 0) == "CODE") then {_this select 0} else {compile(_this select 0)};
_maxDuration = [_this, 1, ["SCALAR"], -1] call ALiVE_fnc_param;
_traceComp = [_this, 2, ["STRING"], "component"] call ALiVE_fnc_param;
_params = [_this, 3, [], []] call ALiVE_fnc_param;
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
