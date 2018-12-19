#include <\x\alive\addons\sys_profile\script_component.hpp>
SCRIPT(createProfileWaypoint);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_createProfileWaypoint

Description:
Creates a waypoint hash for storage in agent profiles

Parameters:
Array - position array
Scalar - the waypoint creation random placement radius
String - type of waypoint
String - speed of waypoint movement
Scalar - completion radius of waypoint
Array - timeout array of scalars [min, mid, max]
String - formation type
String - combat mode
String - behaviour type
String - description
Vehicle - vehicle object

Returns:
A hash of waypoint settings for storage in a profile

Examples:
(begin example)
// simple move waypoint
_result = [getPos player, 100] call ALIVE_fnc_createProfileWaypoint;

// search and destroy waypoint
_result = [getPos player, 100, "SAD"] call ALIVE_fnc_createProfileWaypoint;

// transport unload waypoint with complex parameters
_result = [getPos player, 100, "TR UNLOAD", "FULL", 100] call ALIVE_fnc_createProfileWaypoint;
(end)

See Also:


Author:
ARJay
---------------------------------------------------------------------------- */

params [
    "_position",
    ["_radius", 0],
    ["_type", "MOVE"],
    ["_speed", "UNCHANGED"],
    ["_completionRadius", -1],
    ["_timeout", []],
    ["_formation", "NO CHANGE"],
    ["_combatMode", "NO CHANGE"],
    ["_behaviour", "UNCHANGED"],
    ["_description", ""],
    ["_attachVehicle", ""],
    ["_statements", ""],
    ["_name", ""]
];

private _waypoint = [
    [
        ["position", _position],
        ["radius", _radius],
        ["type", _type],
        ["speed", _speed],
        ["completionRadius", _completionRadius],
        ["timeout", _timeout],
        ["formation", _formation],
        ["combatMode", _combatMode],
        ["behaviour", _behaviour],
        ["description", _description],
        ["attachVehicle", _attachVehicle],
        ["statements", _statements],
        ["name", _name]
    ]
] call ALIVE_fnc_hashCreate;

_waypoint