#include "\x\alive\addons\sys_profile\script_component.hpp"
SCRIPT(profileWaypointToWaypoint);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_profileWaypointToWaypoint

Description:
Takes a profile waypoint and creates a real waypoint

Parameters:
Hash - profile waypoint
Group - The group

Returns:
A waypoint

Examples:
(begin example)
_result = [_profileWaypoint, _group] call ALIVE_fnc_profileWaypointToWaypoint;
(end)

See Also:


Author:
ARJay
---------------------------------------------------------------------------- */

params ["_profileWaypoint","_group",["_setCurrent", false]];

if (isnil "_profileWaypoint" || {!(_profileWaypoint isequaltype [])}) exitwith {
    ["- ALiVE_fnc_ProfileWaypointToWaypoint retrieved wrong input: %1!",_this] call ALiVE_fnc_dump;
};

([_profileWaypoint,["position","radius","type","speed","completionRadius","timeout","formation","combatMode","behaviour","description","attachVehicle","statements","name"]] call ALiVE_fnc_hashGetMany) params [
    "_position",
    "_radius",
    "_type",
    "_speed",
    "_completionRadius",
    "_timeout",
    "_formation",
    "_combatMode",
    "_behaviour",
    "_description",
    "_attachVehicle",
    "_waypointStatements",
    "_waypointName"
];

// If the leader is in a land vehicle, snap waypoints to nearest road within 200m - do not do this if pathfinding enabled
private _assignedVehicle = assignedVehicle leader _group;
if (!isNull _assignedVehicle && {_assignedVehicle isKindOf "LandVehicle"}) then {
    if !([MOD(profileSystem),"pathfinding"] call ALiVE_fnc_hashGet) then {
        private _road = [_position, 200] call BIS_fnc_nearestRoad;
        if !(isNull _road) then {
            _position = (getPos _road) select [0, 2];
        };
    };
    _radius = 0;
};

_position set [2,0];

private _waypoint = _group addWaypoint [_position, _radius];
_waypoint setWaypointDescription _description;
_waypoint setWaypointType _type;
_waypoint setWaypointFormation _formation;
_waypoint setWaypointBehaviour _behaviour;
_waypoint setWaypointCombatMode _combatMode;
_waypoint setWaypointSpeed _speed;
_waypoint setWaypointName _waypointName;

if (_completionRadius >= 0) then {
    _waypoint setWaypointCompletionRadius _completionRadius;
};

if ((count _timeout) == 3) then {
    _waypoint setWaypointTimeout _timeout;
};

if !(_attachVehicle == "") then {
    _waypoint waypointAttachVehicle _attachVehicle;
};

if (_waypointStatements isEqualType []) then {
    _waypoint setWaypointStatements _waypointStatements;
};

if (_setCurrent) then {
    _group setCurrentWaypoint _waypoint;
};

//["p wp to wp"] call ALIVE_fnc_dump;
//_profileWaypoint call ALIVE_fnc_inspectHash;

_waypoint
