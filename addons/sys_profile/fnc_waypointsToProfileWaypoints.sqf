#include <\x\alive\addons\sys_profile\script_component.hpp>
SCRIPT(waypointsToProfileWaypoints);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_waypointsToProfileWaypoints

Description:
Takes real waypoints and creates profile waypoints

Parameters:
Array - The waypoints

Returns:

Examples:
(begin example)
_result = [_profile, _group] call ALIVE_fnc_waypointsToProfileWaypoints;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

params ["_profile","_group"];

if (isnil "_profile" || isnil "_group") exitwith {["ALiVE SYS PROFILE Warning: ALIVE_fnc_waypointsToProfileWaypoints has wrong inputs! - %1", _this] call ALiVE_fnc_Dump};

private _waypoints = waypoints _group;
if (count _waypoints == 0) exitwith {};

private _pathfindingEnabled = [MOD(profileSystem),"pathfinding"] call ALiVE_fnc_hashGet;

private _convertAndAddWaypoint = {
    params ["_profile","_waypoint"];

    private _profileWaypoint = [_waypoint] call ALIVE_fnc_waypointToProfileWaypoint;
    private _waypointPosition = [_profileWaypoint,"position"] call ALIVE_fnc_hashGet;
    private _waypointStatements = [_profileWaypoint,"statements"] call ALIVE_fnc_hashGet;

    if (_pathfindingEnabled) then {
        private _waypointName = [_profileWaypoint,"name"] call ALiVE_fnc_hashGet;
        private _waypointReady = _waypointName == "pathfound";

        if (!((_waypointPosition select [0,2]) isequalto [0,0]) && {(_waypointStatements select 1 != "_disableSimulation = true;")}) then {
            [_profile,"addPendingWaypoint", ["addWaypoint",_profileWaypoint,_waypointReady]] call ALIVE_fnc_profileEntity;
        };
    } else {
        if (!((_waypointPosition select [0,2]) isequalto [0,0]) && {(_waypointStatements select 1 != "_disableSimulation = true;")}) then {
            [_profile,"addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;
        };
    };

    /*
    ["STAMENTS :%1",_waypointStatements select 1] call ALIVE_fnc_dump;
    if(_waypointStatements select 1 == "_disableSimulation = true;") then {
        ["SIM DISABLED: TRUE"] call ALIVE_fnc_dump;
    }else{
        ["SIM DISABLED: FALSE"] call ALIVE_fnc_dump;
    };
    */
};

private _waypointCount = count _waypoints;

private _isCycling = _profile select 2 select 25;
if (_isCycling) then {
    // if the entity has a cycle waypoint need to get all completed waypoints and
    // stick them in the end of the waypoints array

    for "_i" from (currentWaypoint _group) to (_waypointCount - 1) do {
        private _waypoint = _waypoints select _i;
        [_profile,_waypoint] call _convertAndAddWaypoint;
    };

    for "_i" from 1 to (currentWaypoint _group)-1 do {
        private _waypoint = _waypoints select _i;
        [_profile,_waypoint] call _convertAndAddWaypoint;
    };

} else {

    // convert any non completed waypoints to profile waypoints
    if (currentWaypoint _group < count waypoints _group) then {
        for "_i" from (currentWaypoint _group) to (_waypointCount - 1) do {
            private _waypoint = _waypoints select _i;
            [_profile,_waypoint] call _convertAndAddWaypoint;
        };
    };
};