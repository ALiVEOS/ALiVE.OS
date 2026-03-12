#include "\x\alive\addons\mil_cqb\script_component.hpp"
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

private ["_object", "_objectPosition", "_marker"];

_object = _this select 0;
_marker = _this select 1;
_objectPosition = [];

switch (typeName _object) do {
    case "ARRAY": {
        _objectPosition = +_object;
    };
    case "LOCATION": {
        _objectPosition = getPos _object;
    };
    case "OBJECT": {
        if !(isNull _object) then {
            _objectPosition = getPos _object;
        };
    };
};

if !(_objectPosition isEqualType [] && {count _objectPosition >= 2}) exitWith {false};

if (count _objectPosition == 2) then {
    _objectPosition pushBack 0;
};

if (_marker isEqualType "") exitWith {
    if !(_marker call ALIVE_fnc_markerExists) exitWith {false};
    _objectPosition inArea _marker;
};

if (_marker isEqualType objNull) exitWith {
    if (isNull _marker) exitWith {false};
    _objectPosition inArea _marker;
};

false;
