#include "\x\alive\addons\x_lib\script_component.hpp"

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_estimateMemoryUsage

Description:
	Estimates the uncompressed memory usage of some data value.
	
Parameters:
	0 - Data [any]

Returns:
	Memory usage in bytes [number]

Attributes:
	N/A

Examples:
	N/A

See Also:

Notes:
	1. Will freeze the game on large data values, so use with caution.

Author:
	Naught
---------------------------------------------------------------------------- */

count toArray(str(_this select 0))
