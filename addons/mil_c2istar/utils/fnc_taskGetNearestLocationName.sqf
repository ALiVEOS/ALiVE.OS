#include "\x\alive\addons\mil_c2istar\script_component.hpp"
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
Jman
---------------------------------------------------------------------------- */

private ["_taskLocation","_distance","_nearLocations","_nearestLocation"];

_taskLocation = _this select 0;
_distance = if(count _this > 1) then {_this select 1} else {1000};

if(isnil "_taskLocation" || {count _taskLocation == 0}) exitWith {""};

_nearLocations = nearestLocations [_taskLocation, ["NameVillage","NameCity","NameCityCapital","NameLocal"], _distance];

// Bounded expansion. Without an upper bound, callers passing an
// off-map position get a location name from far away that bears
// no real relation to the position -- Rujasu's 2026-05-19 report
// (Chernarus VIPEscort destination at [-2620.79, 3456.32], name
// returned "Pavlovo" from ~14 km away). 5 km cap: if no named
// location within that radius, the position isn't near a real
// settlement and "" is honest. Callers (e.g.
// fnc_taskVIPEscort:258) already handle "" by substituting "the
// destination settlement".
private _maxDistance = 5000;
while {count _nearLocations < 1 && {_distance < _maxDistance}} do {
    _distance = _distance + 500;
    _nearLocations = nearestLocations [_taskLocation, ["NameVillage","NameCity","NameCityCapital","NameLocal"], _distance];
};

if (count _nearLocations < 1) exitWith {""};

_nearestLocation = _nearLocations select 0;
_nearestLocation = text _nearestLocation;

_nearestLocation