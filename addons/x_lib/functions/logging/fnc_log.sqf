#include "\x\alive\addons\x_lib\script_component.hpp"

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_log

Description:
	Logs a value to the diagnostics logs.
	
Parameters:
	0 - Log level [string]
	1 - Component [string]
	2 - Message [string]
	3 - Message parameters [array] (optional)
	4 - File path [string] (optional)
	5 - Line number [number] (optional)

Returns:
	Nothing

Attributes:
	N/A

Examples:
	N/A

See Also:

Author:
	Naught
---------------------------------------------------------------------------- */

if ([ALiVE_log_level,([toLower(_this select 0)] call ALiVE_fnc_convertLogLevel)] call ALiVE_fnc_selBinStr) then
{
	private ["_output"];
	_output = format[
		"%1: %2 [ T: %3 | TT: %4 | F: '%5:%6' | M: '%7' | W: '%8' ] %9",
		(_this select 0),
		(_this select 1),
		time,
		diag_tickTime,
		([_this, 4, ["STRING"], "File Not Found"] call ALiVE_fnc_param),
		str([_this, 5, ["SCALAR"], 0] call ALiVE_fnc_param),
		missionName,
		worldName,
		format([_this select 2] + ([_this, 3, ["ARRAY"], []] call ALiVE_fnc_param))
	];
	
	diag_log text _output;
	
	if (ALiVE_logToDiary) then
	{
		if (isNil "ALiVE_diaryLogQueue") then {ALiVE_diaryLogQueue = []};
		[ALiVE_diaryLogQueue, _output] call ALiVE_fnc_push;
	};
};
