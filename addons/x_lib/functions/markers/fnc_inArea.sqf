#include <\x\alive\addons\mil_cqb\script_component.hpp>
SCRIPT(inArea);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_inArea

Description:
	Checks to see if an object, position-array or location is within a marker- or triggerarea.
	From A3 1.58 the legacy functionality has been replaced with engineside inArea command.

Parameters:
	0 - Unit/Vehicle [object] or position [array] or location [location]
	1 - Marker [string] or trigger [object]

Returns:
	Object in area [bool]

Attributes:
	N/A

Examples:
	[player,_marker] call ALiVE_fnc_inArea

See Also:

Author:
	Olsen, Highhead
---------------------------------------------------------------------------- */

private["_object", "_objectPosition", "_marker"];

_object = _this select 0;
_marker = _this select 1;

switch (typeName _object) do {
	case "ARRAY" : {_objectPosition = _object};
	case "LOCATION" : {_objectPosition = getpos _object};
	default {_objectPosition = getpos _object};
};

_objectPosition inArea _marker;