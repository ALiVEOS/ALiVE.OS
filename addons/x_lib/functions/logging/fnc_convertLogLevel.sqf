#include "\x\alive\addons\x_lib\script_component.hpp"

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_convertLogLevel

Description:
	Converts a log level string to a binary index
	and vis-versa.
	
Parameters:
	0 - Log level [string] || [number]

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
_index = _this select 0;

switch (typeName(_index)) do
{
	case "SCALAR": {LOG_LEVELS select _index};
	case "STRING": {LOG_LEVELS find _index};
};
