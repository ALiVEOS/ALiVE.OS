#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(taskPatrol);

/* ----------------------------------------------------------------------------
Function: CBA_fnc_taskPatrol

Description:
    A function for a group to randomly patrol a parsed radius and location.

    ALiVE extends this function so the final CYCLE waypoint uses the same exact
    placement method as the patrol waypoints. This avoids the heavy engine placement
    search caused by applying the full patrol radius to the final waypoinh.

Parameters:
    - Group (Group or Object)

Optional:
    - Position (XYZ, Object, Location or Group)
    - Radius (Scalar)
    - Waypoint Count (Scalar)
    - Waypoint Type (String)
    - Behaviour (String)
    - Combat Mode (String)
    - Speed Mode (String)
    - Formation (String)
    - Code To Execute at Each Waypoint (String)
    - TimeOut at each Waypoint (Array [Min, Med, Max])

Example:
    (begin example)
    [this, getMarkerPos "objective1", 50] call CBA_fnc_taskPatrol
    [this, this, 300, 7, "MOVE", "AWARE", "YELLOW", "FULL", "STAG COLUMN", "this call CBA_fnc_searchNearby", [3, 6, 9]] call CBA_fnc_taskPatrol;
    (end)

Returns:
    Nil

Author:
    Rommel

---------------------------------------------------------------------------- */

params [
    ["_group", grpNull, [grpNull, objNull]],
    ["_position", [], [[], objNull, grpNull, locationNull], [2, 3]],
    ["_radius", 100, [0]],
    ["_count", 3, [0]]
];

_group = _group call CBA_fnc_getGroup;
if !(local _group) exitWith {}; // Don't create waypoints on each machine

_position = [_position, _group] select (_position isEqualTo []);
_position = _position call CBA_fnc_getPos;

// Clear existing waypoints first
[_group] call CBA_fnc_clearWaypoints;
{
    _x enableAI "PATH";
} forEach units _group;

// Can pass parameters straight through to addWaypoint
private _args = +_this;
_args set [2,-1];
if (count _args > 3) then {
    _args deleteAt 3;
};

// Using angles create better patrol patterns
// Also fixes weird editor bug where all WP are on same position
private _step = 360 / _count;
private _offset = random _step;
private _firstWaypointPosition = _position;
for "_i" from 1 to _count do {
    // Gaussian distribution avoids all waypoints ending up in the center
    private _rad = _radius * random [0.1, 0.75, 1];

    // Alternate sides of circle & modulate offset
    private _theta = (_i % 2) * 180 + sin (deg (_step * _i)) * _offset + _step * _i;

    private _waypointPosition = _position getPos [_rad, _theta];
    if (_i isEqualTo 1) then {
        _firstWaypointPosition = _waypointPosition;
    };
    _args set [1, _waypointPosition];
    _args call CBA_fnc_addWaypoint;
};

// Close the patrol loop at the first generated patrol position
_args set [1, _firstWaypointPosition];
_args set [2, -1];
_args set [3, "CYCLE"];
_args call CBA_fnc_addWaypoint;
