#include "\x\alive\addons\x_lib\script_component.hpp"

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_setLogLevel

Description:
	Toggles a log level on the local machine.
	
Parameters:
	0 - Log level [string]
	1 - Logging Toggle [bool]

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

private ["_index"];
_index = [toLower(_this select 0)] call ALiVE_fnc_convertLogLevel;

if (_index >= 0) then
{
	private ["_logLevel"];
	_logLevel = toArray(ALiVE_log_level);
	
	// Note: 48 = Digit Zero; 49 = Digit One;
	while {(count _logLevel) < _index} do
	{
		_logLevel pushback 48;
	};
	
	_logLevel set [_index, (if (_this select 1) then {49} else {48})];
	
	ALiVE_log_level = toString(_logLevel);
};
