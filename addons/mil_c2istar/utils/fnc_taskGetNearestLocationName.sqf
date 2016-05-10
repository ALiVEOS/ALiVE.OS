#include <\x\alive\addons\mil_C2ISTAR\script_component.hpp>
SCRIPT(taskGetNearestLocationName);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskGetNearestLocationName

Description:
Get the nearest location name for a task description

Parameters:

Returns:

Examples:
(begin example)
(end)

See Also:

Author:
Highhead
---------------------------------------------------------------------------- */

private ["_taskLocation","_distance","_nearLocations","_nearestLocation"];

_taskLocation = _this select 0;
_distance = if(count _this > 1) then {_this select 1} else {1000};

if(isnil "_taskLocation" || {count _taskLocation == 0}) exitWith {""};

_nearLocations = nearestLocations [_taskLocation, ["NameVillage","NameCity","NameCityCapital","NameLocal"], _distance];

while {count _nearLocations < 1} do {
    _distance = _distance + 500;
    _nearLocations = nearestLocations [_taskLocation, ["NameVillage","NameCity","NameCityCapital","NameLocal"], _distance];
};

_nearestLocation = _nearLocations select 0;
_nearestLocation = text _nearestLocation;

_nearestLocation