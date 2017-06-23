#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(getNearestObjectInArray);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_getNearestObjectInArray

Description:
Returns the nearest object to the given object from a list of objects

Parameters:
Object - The object for comparison
Array - A list of objects to compare
Number - Maximum distance allowed (optional)

Returns:
Object - Nearest object

Examples:
(begin example)
_nearest = [_point, _obj, _array] call ALIVE_fnc_getNearestObjectInArray;
(end)

See Also:
- <ALIVE_fnc_getObjectsByType>
- <ALIVE_fnc_chooseInitialCenters>

Author:
Wolffy.au
---------------------------------------------------------------------------- */

private ["_minDistance","_maxDistance","_minObject","_distance","_err"];

params ["_point", "_cluster", ["_maxDistance", 999999]];

_err = "point provided not valid";
ASSERT_DEFINED("_point",_err);
ASSERT_TRUE(typeName _point == "OBJECT", _err);
_err = "array of objects provided not valid";
ASSERT_DEFINED("_cluster",_err);
ASSERT_TRUE(typeName _cluster == "ARRAY", _err);

_minDistance = 999999;
_minObject = nil;
{
    _distance = _point distance _x;
    if (_point != _x && {_distance < _minDistance} && {_distance < _maxDistance}) then {
        _minDistance = _distance;
        _minObject = _x;
    };
} forEach _cluster;

if(isNil "_minObject") then {_minObject = _point;};
_minObject
